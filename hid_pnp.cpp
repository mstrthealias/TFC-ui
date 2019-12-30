#include "hid_pnp.h"
#include "runtime_config_inc.h"

#include <QDebug>


static hid_device *hid_open_usage(unsigned short vendor_id, unsigned short product_id, unsigned short usage_page, unsigned short usage)
{
    struct hid_device_info *devs, *cur_dev;
    const char *path_to_open = nullptr;
    hid_device *handle = nullptr;

    devs = hid_enumerate(vendor_id, product_id);
    cur_dev = devs;
    while (cur_dev) {
        if (cur_dev->vendor_id == vendor_id &&
            cur_dev->product_id == product_id) {
            if (usage_page && usage) {
                if (cur_dev->usage_page == usage_page && cur_dev->usage == usage) {
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

void HID_PnP::pollUSB()
{
//    qDebug() << "pollUSB()";
    memset(buf, 0x00, sizeof(buf));

    if (ui_data.isConnectedLog == false) {
        deviceLog = hid_open_usage(0x16C0, 0x0486, 0xFFC9, 0x0004);  // Serial log
//        deviceLog = hid_open_usage(0x16C0, 0x0486, 0x2f30, 0x3030);  // Serial log -- Linux HIDRAW??
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
        deviceData = hid_open_usage(0x16C0, 0x0486, 0xFFAB, 0x0200);  // USB RAW
//        deviceData = hid_open_usage(0x16C0, 0x0486, 0x67, 0x65);  // USB RAW -- Linux HIDRAW??
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

        if (buf[0] == HID_PAYLOAD_CONFIG1 && buf[1] == HID_PAYLOAD_CONFIG2) {
            memset(config_bytes, '\0', CONFIG_BYTES);
            memcpy(config_bytes, (buf + 2), CHUNK_SIZE);
            // TODO check next state ?
//            qDebug() << "Config chunk A downloaded";
        }
        else if (buf[0] == HID_PAYLOAD_CONFIG_B1 && buf[1] == HID_PAYLOAD_CONFIG_B2) {
            memcpy((config_bytes + CHUNK_SIZE), (buf + 2), CHUNK_SIZE);
            // TODO check next state ?
//            qDebug() << "Config chunk B downloaded";
        }
        else if (buf[0] == HID_PAYLOAD_CONFIG_C1 && buf[1] == HID_PAYLOAD_CONFIG_C2) {
            memcpy((config_bytes + 2*CHUNK_SIZE), (buf + 2), CONFIG_BYTES - 2*CHUNK_SIZE);

            ui_data.hasConfigDownloaded = true;

            config = RuntimeConfig::parse_bytes(config_bytes, CONFIG_BYTES);

            qDebug() << "Config version" << config.config_version << "downloaded";

            hid_config_download(ui_data.isConnectedData, config);
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
            ui_data.auxTemp = val/1000.0;

            memcpy(&val, (buf + 18), 4);
            ui_data.deltaT = val/1000.0;

            memcpy(&val, (buf + 22), 4);
            ui_data.fanPercentPID = val/1000.0;

            memcpy(&val, (buf + 26), 4);
            ui_data.fanPercentTbl = val/1000.0;

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

            // first 2 bytes are a signature
            buf[0] = 0x00;  // report #
            buf[1] = HID_PAYLOAD_CONFIG1;
            buf[2] = HID_PAYLOAD_CONFIG2;

            // place first chunk (48 bytes) in HID buffer
            memcpy((buf + 3), config_bytes, CHUNK_SIZE);

            FILL_ZEROS(buf, (CHUNK_SIZE + 3), BUF_SIZE);
            buf[64] = HID_DOWNLOAD;  // put next state at the end

            if (hid_write(deviceData, buf, sizeof(buf)) == -1) {
                closeDevice();
                ui_data.isConnectedData = false;
                return;
            }

            // first 2 bytes are a signature
            buf[0] = 0x00;  // report #
            buf[1] = HID_PAYLOAD_CONFIG_B1;
            buf[2] = HID_PAYLOAD_CONFIG_B2;

            // place 2nd chunk (48 bytes) in HID buffer
            memcpy((buf + 3), (config_bytes + CHUNK_SIZE), CHUNK_SIZE);

            FILL_ZEROS(buf, (CHUNK_SIZE + 3), BUF_SIZE);
            buf[64] = HID_DOWNLOAD;  // put next state at the end

            if (hid_write(deviceData, buf, sizeof(buf)) == -1) {
                closeDevice();
                ui_data.isConnectedData = false;
                return;
            }

            // first 2 bytes are a signature
            buf[0] = 0x00;  // report #
            buf[1] = HID_PAYLOAD_CONFIG_C1;
            buf[2] = HID_PAYLOAD_CONFIG_C2;

            // place remaining chunk (48 bytes) in HID buffer
            memcpy((buf + 3), (config_bytes + 2*CHUNK_SIZE), CONFIG_BYTES - 2*CHUNK_SIZE);

            FILL_ZEROS(buf, (CONFIG_BYTES - 2*CHUNK_SIZE + 3), BUF_SIZE);
            buf[64] = HID_DATA;  // put next state at the end

            // zero config_bytes
            memset(config_bytes, '\0', CONFIG_BYTES);

            if (hid_write(deviceData, buf, sizeof(buf)) == -1) {
                closeDevice();
                ui_data.isConnectedData = false;
                return;
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
