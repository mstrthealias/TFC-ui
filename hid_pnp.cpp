#include "hid_pnp.h"
#include "runtime_config_inc.h"

#include <QDebug>


//static hid_device *hid_open_usage(unsigned short vendor_id, unsigned short product_id, unsigned short usage_page, unsigned short usage)

static hid_device *hid_open_interface(unsigned short vendor_id, unsigned short product_id, int interface_number)
{
    struct hid_device_info *devs, *cur_dev;
    const char *path_to_open = nullptr;
    hid_device *handle = nullptr;

    devs = hid_enumerate(vendor_id, product_id);
    cur_dev = devs;
    while (cur_dev) {
        if (cur_dev->vendor_id == vendor_id &&
            cur_dev->product_id == product_id) {
            if (interface_number >= 0) {
                if (cur_dev->interface_number == interface_number) {
                    path_to_open = cur_dev->path;
                    break;
                }
            }
            else {
                path_to_open = cur_dev->path;
                break;
            }
        }
        cur_dev = cur_dev->next;
    }

    if (path_to_open) {
        /* Open the device */
        handle = hid_open_path(path_to_open);
    }

    hid_free_enumeration(devs);

    return handle;
}


HID_PnP::HID_PnP(QObject *parent) : QObject(parent)
{
    memset(buf, 0x00, sizeof(buf));

    timer = new QTimer();

    connect(timer, SIGNAL(timeout()), this, SLOT(pollUSB()));

    timer->start(250);

    hid_init();  // Initialize the hidapi library
}

HID_PnP::~HID_PnP()
{
    closeDevice();

    if (timer != nullptr) {
        timer->stop();
        disconnect(timer, SIGNAL(timeout()), this, SLOT(pollUSB()));
        delete timer;
        timer = nullptr;
    }
}

bool HID_PnP::saveConfig(const RuntimeConfig &conf)
{
    if (ui_data.pendingConfigUpdate) {
        return false;
    }
    config = conf;
    ui_data.pendingConfigUpdate = true;
    return true;
}

bool HID_PnP::writeConfigChunk(uint8_t chunk, bool isLast)
{
    // first 2 bytes are a signature
    buf[0] = 0x00;  // report #
    buf[1] = HID_PAYLOAD_CONFIG1;
    buf[2] = (HID_PAYLOAD_CONFIG2 + chunk);
    // place chunk in HID buffer
    if (!isLast) {
        memcpy((buf + 3), (config_bytes + (chunk * CHUNK_SIZE)), CHUNK_SIZE);
        FILL_ZEROS(buf, (CHUNK_SIZE + 3), BUF_SIZE);
        buf[64] = HID_DOWNLOAD;  // put next state at the end
    }
    else {
        // last chunk
        memcpy((buf + 3), (config_bytes + (chunk * CHUNK_SIZE)), CONFIG_BYTES - (chunk * CHUNK_SIZE));
        FILL_ZEROS(buf, (CONFIG_BYTES - (chunk * CHUNK_SIZE) + 3), BUF_SIZE);
        buf[64] = HID_DATA;  // put next state at the end
        memset(config_bytes, '\0', CONFIG_BYTES);  // zero config_bytes
    }
    if (hid_write(deviceData, buf, sizeof(buf)) == -1) {
        closeDevice();
        ui_data.isConnectedData = false;
        return false;
    }
    return true;
}

void HID_PnP::pollUSB()
{
//    qDebug() << "pollUSB()";
    memset(buf, 0x00, sizeof(buf));

    if (ui_data.isConnectedLog == false) {
        deviceLog = hid_open_interface(0x16C0, 0x0486, 1);
        //deviceLog = hid_open_usage(0x16C0, 0x0486, 0xFFC9, 0x0004);  // HIDAPI Linux does not support usage/usage_page
        if (deviceLog) {
            qDebug() << "HID Log connected";
            ui_data.isConnectedLog = true;
            hid_set_nonblocking(deviceLog, true);
            //timer->start(15);
            timer->start(50);
        }
        else {
            qDebug() << "HID connection failure";
        }
    }
    if (ui_data.isConnectedData == false) {
        deviceData = hid_open_interface(0x16C0, 0x0486, 0);
        //deviceData = hid_open_usage(0x16C0, 0x0486, 0xFFAB, 0x0200);  // HIDAPI Linux does not support usage/usage_page
        if (deviceData) {
            qDebug() << "HID Data connected";
            ui_data.isConnectedData = true;
            hid_set_nonblocking(deviceData, true);
            //timer->start(15);
            timer->start(50);
        }
        else {
            qDebug() << "HID connection failure";
        }
    }

    if (ui_data.isConnectedLog) {
        memset(buf, 0x00, sizeof(buf));
        int len = hid_read(deviceLog, buf, sizeof(buf) - 1);
        if (len == -1) {
            closeDevice();
            ui_data.isConnectedLog = false;
            return;
        }
        if (len && buf[0] != 0x0) {
            log_append(ui_data.isConnectedLog, QString(reinterpret_cast<char*>(buf)));
        }
    }

    if (ui_data.isConnectedData) {
        memset(buf, 0x00, sizeof(buf));
        int len = hid_read(deviceData, buf, sizeof(buf) - 1);
        if (len == -1) {
            closeDevice();
            ui_data.isConnectedData = false;
            return;
        }

        if (buf[0] == HID_PAYLOAD_CONFIG1 && buf[1] >= HID_PAYLOAD_CONFIG2 && buf[1] < HID_PAYLOAD_CONFIG2 + CHUNK_CNT) {
            // Remote is sending configuration payload chunk n
            // TODO state ?
            uint8_t chunk = buf[1] - HID_PAYLOAD_CONFIG2;

            qDebug() << "Config chunk" << chunk << "downloaded";

            if (chunk == 0)
                memset(config_bytes, '\0', CONFIG_BYTES);  // zero on first config packet

            if (chunk < CHUNK_CNT - 1) {
                // first or middle chunk
                memcpy((config_bytes + (chunk * CHUNK_SIZE)), (buf + 2), CHUNK_SIZE);
            }
            else {
                // last chunk
                memcpy((config_bytes + (chunk * CHUNK_SIZE)), (buf + 2), CONFIG_BYTES - (chunk * CHUNK_SIZE));

                ui_data.hasConfigDownloaded = true;
                config = RuntimeConfig::parse_bytes(config_bytes, CONFIG_BYTES);

                qDebug() << "Config version" << config.config_version << "downloaded";

                hid_config_download(ui_data.isConnectedData, config);
            }
        }
        else if (buf[0] == HID_OUT_PAYLOAD_DATA1 && buf[1] == HID_OUT_PAYLOAD_DATA2) {
            uint64_t val = 0;
            memcpy(&val, (buf + 2), 4);
            ui_data.supplyTemp = val/1000.0;

            memcpy(&val, (buf + 6), 4);
            ui_data.returnTemp = val/1000.0;

            memcpy(&val, (buf + 10), 4);
            ui_data.caseTemp = val/1000.0;

            memcpy(&val, (buf + 14), 4);
            ui_data.aux1Temp = val/1000.0;

            memcpy(&val, (buf + 18), 4);
            ui_data.aux2Temp = val/1000.0;

            memcpy(&val, (buf + 22), 4);
            ui_data.deltaT = val/1000.0;

//            memcpy(&val, (buf + 22), 4);
//            ui_data.fanPercentPID = val/1000.0;
            ui_data.fanPercentPID = 0;
//            memcpy(&val, (buf + 26), 4);
//            ui_data.fanPercentTbl = val/1000.0;
            ui_data.fanPercentTbl = 0;

            memcpy(&val, (buf + 30), 4);
            ui_data.setpoint = val/1000.0;

            memcpy(&ui_data.rpm1, (buf + 34), 2);
            memcpy(&ui_data.rpm2, (buf + 36), 2);
            memcpy(&ui_data.rpm3, (buf + 38), 2);
            memcpy(&ui_data.rpm4, (buf + 40), 2);
            memcpy(&ui_data.rpm5, (buf + 42), 2);
            memcpy(&ui_data.rpm6, (buf + 44), 2);

            hid_comm_update(ui_data.isConnectedData, ui_data);
        }

        // request config download
        if (!ui_data.hasConfigDownloaded) {
            ui_data.hasConfigDownloaded = true;
            buf[0] = 0x00;  // report #
            buf[1] = HID_IN_PAYLOAD_REQ_CONFIG1;
            buf[2] = HID_IN_PAYLOAD_REQ_CONFIG2;
            FILL_ZEROS(buf, 3, BUF_SIZE);
            buf[64] = HID_CONFIG;  // put next state at the end
            if (hid_write(deviceData, buf, sizeof(buf)) == -1) {
                closeDevice();
                ui_data.isConnectedData = false;
                return;
            }
            qDebug() << "Config requested";
        }
        else if (ui_data.pendingConfigUpdate) {
            ui_data.pendingConfigUpdate = false;

            // copy entire configuration into config_bytes
            if (config.to_bytes(config_bytes, CONFIG_BYTES) != 0) {
                qDebug() << "to_byes ERROR";
              return;  // -1;  // TODO errno
            }

            // write config chunks
            for (uint8_t chunk = 0; chunk < CHUNK_CNT; chunk++) {
                if (!writeConfigChunk(chunk, chunk == CHUNK_CNT - 1))
                    return;  // TODO handle failure
            }

            qDebug() << "Config saved";
        }
    }
}

void HID_PnP::closeDevice()
{
    if (deviceLog != nullptr) {
        hid_close(deviceLog);
        deviceLog = nullptr;
    }
    ui_data.isConnectedLog = false;

    if (deviceData != nullptr) {
        hid_close(deviceData);
        deviceData = nullptr;
    }
    ui_data.isConnectedData = false;

    hid_comm_update(ui_data.isConnectedData, ui_data);

    if (timer != nullptr) {
        timer->start(250);
    }
}
