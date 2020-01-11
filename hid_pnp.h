#ifndef HID_PNP_H
#define HID_PNP_H

#include <QObject>
#include <QTimer>
#include <stdlib.h>

#include "runtime_config_inc.h"
#include "../teensy_fan_controller/hid_shared.h"
#include "../HIDAPI/hidapi.h"


#define BUF_SIZE 65


class UI_Data
{
    public:
    bool isConnectedLog = false;
    bool isConnectedData = false;
    bool hasConfigDownloaded = false;
    bool pendingConfigUpdate = false;
    uint16_t rpm1 = 0;
    uint16_t rpm2 = 0;
    uint16_t rpm3 = 0;
    uint16_t rpm4 = 0;
    uint16_t rpm5 = 0;
    uint16_t rpm6 = 0;
    qreal setpoint = 0.0;
    qreal supplyTemp = 0.0;
    qreal returnTemp = 0.0;
    qreal caseTemp = 0.0;
    qreal auxTemp = 0.0;
    qreal deltaT = 0.0;
    qreal fanPercentPID = 0.0;
    qreal fanPercentTbl = 0.0;
};


class HID_PnP : public QObject
{
    Q_OBJECT
public:
    explicit HID_PnP(QObject *parent = nullptr);
    ~HID_PnP();

signals:
    void hid_config_download(bool isConnected, RuntimeConfig config);
    void hid_comm_update(bool isConnected, UI_Data ui_data);
    void log_append(bool isConnected, QString str);

public slots:
    void pollUSB();
    bool saveConfig(const RuntimeConfig &conf);
    bool writeConfigChunk(uint8_t chunk, bool isLast);

private:
    hid_device *deviceLog = nullptr;
    hid_device *deviceData = nullptr;
    QTimer *timer = nullptr;

    byte buf[BUF_SIZE];

    byte config_bytes[CONFIG_BYTES];

    UI_Data ui_data;
    RuntimeConfig config;

    void closeDevice();
};

#endif // HID_PNP_H
