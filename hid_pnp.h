#ifndef HID_PNP_H
#define HID_PNP_H

#include <QObject>
#include <QTimer>
#include <stdlib.h>
#include <array>

#include "runtime_config_inc.h"
#include "../teensy_fan_controller/src/hid_shared.h"
#include "../HIDAPI/hidapi.h"


#define BUF_SIZE 65
#define HID_CONNECT_FAIL_MAX 3


struct UI_Data_Fan
{
    uint16_t rpm = 0;
    uint8_t pct = 0;
    uint8_t mode = 0;
    uint8_t source = 0;
};

struct UI_Data
{
    bool isConnectedLog = false;
    bool isConnectedData = false;
    bool hasConfigDownloaded = false;
    bool pendingConfigUpdate = false;

    qreal supplyTemp = 0.0;
    qreal returnTemp = 0.0;
    qreal caseTemp = 0.0;
    qreal aux1Temp = 0.0;
    qreal aux2Temp = 0.0;
    qreal deltaT = 0.0;
    qreal setpointSupply = 0.0;
    qreal setpointAux1 = 0.0;

    std::array<UI_Data_Fan, FAN_CNT> fans;
};


class HID_PnP : public QObject
{
    Q_OBJECT
public:
    explicit HID_PnP(QObject *parent = nullptr);
    ~HID_PnP();

    void reconnect();

signals:
    void hid_config_download(bool isConnected, const RuntimeConfig &config);
    void hid_comm_update(bool isConnected, const UI_Data &ui_data);
    void hid_connect_status(const bool connecting, const bool dataOnline, const bool logOnline);
    void hid_state(const quint8 state);
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

    uint8_t connectLogErrCnt = 0;
    uint8_t connectDataErrCnt = 0;

    void closeDevice();
};

#endif // HID_PNP_H
