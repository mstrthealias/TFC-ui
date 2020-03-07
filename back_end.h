#ifndef BACK_END_H
#define BACK_END_H

#include <QTimer>
#include <QDebug>

#include "hid_pnp.h"


class BackEndFanPV : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint16 rpm READ rpm WRITE setRpm NOTIFY rpmChanged)
    Q_PROPERTY(quint8 pct READ pct WRITE setPct NOTIFY pctChanged)
    Q_PROPERTY(quint8 mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(quint8 source READ source WRITE setSource NOTIFY sourceChanged)

signals:
    void rpmChanged();
    void pctChanged();
    void modeChanged();
    void sourceChanged();

public:
    explicit BackEndFanPV(QObject *parent = nullptr);

    quint16 rpm() const;
    quint8 pct() const;
    quint8 mode() const;
    quint8 source() const;

    void setRpm(const quint16 rpm);
    void setPct(const quint8 pct);
    void setMode(const quint8 mode);
    void setSource(const quint8 source);

private:
    quint16 m_rpm = 0;
    quint8 m_pct = 0;
    quint8 m_mode = 0;
    quint8 m_source = 0;
};


class BackEndFan : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint8 pinPWM READ pinPWM WRITE setPinPWM NOTIFY pinPWMChanged)
    Q_PROPERTY(quint8 pinRPM READ pinRPM WRITE setPinRPM NOTIFY pinRPMChanged)
    Q_PROPERTY(quint8 mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(quint8 source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(qreal ratio READ ratio WRITE setRatio NOTIFY ratioChanged)
    Q_PROPERTY(QVariantList tbl READ tbl WRITE setTbl NOTIFY tblChanged)

    Q_PROPERTY(BackEndFanPV* pv READ pv WRITE setPv NOTIFY pvChanged)

signals:
    void pinPWMChanged();
    void pinRPMChanged();
    void modeChanged();
    void sourceChanged();
    void ratioChanged();
    void tblChanged();
    void pvChanged();

public:
    explicit BackEndFan(RuntimeConfig::FanConfig &fanConfig, QObject *parent = nullptr);
    ~BackEndFan();

    quint8 pinPWM();
    quint8 pinRPM();
    quint8 mode();
    quint8 source();
    qreal ratio();
    QVariantList &tbl();
    BackEndFanPV* pv() const;

    void setPinPWM(const quint8 pinPWM);
    void setPinRPM(const quint8 pinRPM);
    void setMode(const quint8 mode);
    void setSource(const quint8 source);
    void setRatio(const qreal &ratio);
    void setTbl(const QVariantList &tbl);
    void setPv(const BackEndFanPV* pv);

private:
    RuntimeConfig::FanConfig &fanConfig;
    QVariantList pctTbl;
    BackEndFanPV* m_pv = nullptr;
};


class BackEndSensor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint8 pin READ pin WRITE setPin NOTIFY pinChanged)
    Q_PROPERTY(quint16 beta READ beta WRITE setBeta NOTIFY betaChanged)
    Q_PROPERTY(quint16 seriesR READ seriesR WRITE setSeriesR NOTIFY seriesRChanged)
    Q_PROPERTY(quint16 nominalR READ nominalR WRITE setNominalR NOTIFY nominalRChanged)
    Q_PROPERTY(qreal pvTemp READ pvTemp WRITE setPvTemp NOTIFY pvTempChanged)
    Q_PROPERTY(qreal pvSetpoint READ pvSetpoint WRITE setPvSetpoint NOTIFY pvSetpointChanged)
    Q_PROPERTY(bool hasPid READ hasPid WRITE setHasPid NOTIFY hasPidChanged)

signals:
    void pinChanged();
    void betaChanged();
    void seriesRChanged();
    void nominalRChanged();
    void pvTempChanged();
    void pvSetpointChanged();
    void hasPidChanged();

public:
    explicit BackEndSensor(RuntimeConfig::SensorConfig &sensorConfig, QObject *parent = nullptr);

    void checkUsage(const RuntimeConfig &cfg, const CONTROL_SOURCE src);

    quint8 pin() const;
    quint16 beta() const;
    quint16 seriesR() const;
    quint16 nominalR() const;
    const qreal &pvTemp() const;
    const qreal &pvSetpoint() const;
    bool hasPid() const;

    void setPin(const quint8 pin);
    void setBeta(const quint16 beta);
    void setSeriesR(const quint16 seriesR);
    void setNominalR(const quint16 nominalR);
    void setPvTemp(const qreal &temp);
    void setPvSetpoint(const qreal &setpoint);
    void setHasPid(const bool hasPid);

private:
    RuntimeConfig::SensorConfig &sensorConfig;
    bool m_hasPid = false;
    qreal m_temp = 0.0;
    qreal m_setpoint = 0.0;
};


class BackEndPIDStep : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint8 pct READ pct WRITE setPct NOTIFY pctChanged)
    Q_PROPERTY(quint16 delay READ delay WRITE setDelay NOTIFY delayChanged)
    Q_PROPERTY(qreal caseTempDelta READ caseTempDelta WRITE setCaseTempDelta NOTIFY caseTempDeltaChanged)

signals:
    void pctChanged();
    void delayChanged();
    void caseTempDeltaChanged();

public:
    explicit BackEndPIDStep(RuntimeConfig::PIDConfig::PIDStep &step, QObject *parent = nullptr);

    quint8 pct() const;
    quint16 delay() const;
    qreal caseTempDelta() const;

    void setPct(const quint8 pct);
    void setDelay(const quint16 delay);
    void setCaseTempDelta(const qreal &caseTempDelta);

private:
    RuntimeConfig::PIDConfig::PIDStep &step;
};


class BackEndPID : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal percentMin READ percentMin WRITE setPercentMin NOTIFY percentMinChanged)
    Q_PROPERTY(qreal percentMax1 READ percentMax1 WRITE setPercentMax1 NOTIFY percentMax1Changed)
    Q_PROPERTY(qreal percentMax2 READ percentMax2 WRITE setPercentMax2 NOTIFY percentMax2Changed)
    Q_PROPERTY(qreal setpoint READ setpoint WRITE setSetpoint NOTIFY setpointChanged)
    Q_PROPERTY(qreal setpointMin READ setpointMin WRITE setSetpointMin NOTIFY setpointMinChanged)
    Q_PROPERTY(qreal setpointMax READ setpointMax WRITE setSetpointMax NOTIFY setpointMaxChanged)
    Q_PROPERTY(qreal gainP READ gainP WRITE setGainP NOTIFY gainPChanged)
    Q_PROPERTY(qreal gainI READ gainI WRITE setGainI NOTIFY gainIChanged)
    Q_PROPERTY(qreal gainD READ gainD WRITE setGainD NOTIFY gainDChanged)
    Q_PROPERTY(bool adaptiveSP READ adaptiveSP WRITE setAdaptiveSP NOTIFY adaptiveSPChanged)
    Q_PROPERTY(bool adaptiveSPUseCaseTemp READ adaptiveSPUseCaseTemp WRITE setAdaptiveSPUseCaseTemp NOTIFY adaptiveSPUseCaseTempChanged)
    Q_PROPERTY(qreal adaptiveSPStepSize READ adaptiveSPStepSize WRITE setAdaptiveSPStepSize NOTIFY adaptiveSPStepSizeChanged)
    Q_PROPERTY(BackEndPIDStep* adaptiveSPStepUp READ adaptiveSPStepUp WRITE setAdaptiveSPStepUp NOTIFY adaptiveSPStepUpChanged)
    Q_PROPERTY(BackEndPIDStep* adaptiveSPStepDown READ adaptiveSPStepDown WRITE setAdaptiveSPStepDown NOTIFY adaptiveSPStepDownChanged)

signals:
    void percentMinChanged();
    void percentMax1Changed();
    void percentMax2Changed();
    void setpointChanged();
    void setpointMinChanged();
    void setpointMaxChanged();
    void gainPChanged();
    void gainIChanged();
    void gainDChanged();
    void adaptiveSPChanged();
    void adaptiveSPUseCaseTempChanged();
    void adaptiveSPStepSizeChanged();
    void adaptiveSPStepUpChanged();
    void adaptiveSPStepDownChanged();

public:
    explicit BackEndPID(RuntimeConfig::PIDConfig &pid, QObject *parent = nullptr);
    ~BackEndPID();

    quint8 percentMin() const;
    quint8 percentMax1() const;
    quint8 percentMax2() const;
    qreal setpoint() const;
    qreal setpointMin() const;
    qreal setpointMax() const;
    qreal gainP() const;
    qreal gainI() const;
    qreal gainD() const;
    bool adaptiveSP() const;
    bool adaptiveSPUseCaseTemp() const;
    qreal adaptiveSPStepSize() const;
    BackEndPIDStep* adaptiveSPStepUp() const;
    BackEndPIDStep* adaptiveSPStepDown() const;

    void setPercentMin(const quint8 pct);
    void setPercentMax1(const quint8 pct);
    void setPercentMax2(const quint8 pct);
    void setSetpoint(const qreal &setpoint);
    void setSetpointMin(const qreal &setpointMin);
    void setSetpointMax(const qreal &setpointMax);
    void setGainP(const qreal &gain);
    void setGainI(const qreal &gain);
    void setGainD(const qreal &gain);
    void setAdaptiveSP(const bool &adativeSP);
    void setAdaptiveSPUseCaseTemp(const bool &adativeSPUseCaseTemp);
    void setAdaptiveSPStepSize(const qreal &stepSize);
    void setAdaptiveSPStepUp(BackEndPIDStep *step);
    void setAdaptiveSPStepDown(BackEndPIDStep *step);

private:
    RuntimeConfig::PIDConfig &pid;

    BackEndPIDStep *stepUpConfig = nullptr;
    BackEndPIDStep *stepDownConfig = nullptr;
};


class BackEnd : public QObject
{
public:
    // QML enum for connection state
    enum class UiState : uint8_t {
        Offline,
        Online,
        Connecting,
        NoLog,   // DATA is connected
        NoData,  // LOG is connected
    };
    // QML enum for HID state
    enum class HidState : uint8_t {
        HidData,
        HidConfig,
        HidDownload,
    };
    // QML enum representing CONTROL_MODE enum
    enum class ControlMode : uint8_t {
        Tbl,
        PID,
        Fixed,
        Off
    };
    // QML enum representing CONTROL_SOURCE enum
    enum class ControlSource : uint8_t {
        WaterSupplyTemp,
        WaterReturnTemp,
        CaseTemp,
        Aux1Temp,
        Aux2Temp,
        VirtualDeltaT
    };

private:
    Q_OBJECT
    Q_ENUM(UiState)
    Q_ENUM(HidState)
    Q_ENUM(ControlMode)
    Q_ENUM(ControlSource)
    // configuration
    Q_PROPERTY(BackEndPID* pid1 READ pid1 WRITE setPid1 NOTIFY pid1Changed)
    Q_PROPERTY(BackEndPID* pid2 READ pid2 WRITE setPid2 NOTIFY pid2Changed)
    Q_PROPERTY(BackEndPID* pid3 READ pid3 WRITE setPid3 NOTIFY pid3Changed)
    Q_PROPERTY(BackEndPID* pid4 READ pid4 WRITE setPid4 NOTIFY pid4Changed)
    Q_PROPERTY(BackEndFan* fan1 READ fan1 WRITE setFan1 NOTIFY fan1Changed)
    Q_PROPERTY(BackEndFan* fan2 READ fan2 WRITE setFan2 NOTIFY fan2Changed)
    Q_PROPERTY(BackEndFan* fan3 READ fan3 WRITE setFan3 NOTIFY fan3Changed)
    Q_PROPERTY(BackEndFan* fan4 READ fan4 WRITE setFan4 NOTIFY fan4Changed)
    Q_PROPERTY(BackEndFan* fan5 READ fan5 WRITE setFan5 NOTIFY fan5Changed)
    Q_PROPERTY(BackEndFan* fan6 READ fan6 WRITE setFan6 NOTIFY fan6Changed)
    Q_PROPERTY(BackEndSensor* sensor1 READ sensor1 WRITE setSensor1 NOTIFY sensor1Changed)
    Q_PROPERTY(BackEndSensor* sensor2 READ sensor2 WRITE setSensor2 NOTIFY sensor2Changed)
    Q_PROPERTY(BackEndSensor* sensor3 READ sensor3 WRITE setSensor3 NOTIFY sensor3Changed)
    Q_PROPERTY(BackEndSensor* sensor4 READ sensor4 WRITE setSensor4 NOTIFY sensor4Changed)
    Q_PROPERTY(BackEndSensor* sensor5 READ sensor5 WRITE setSensor5 NOTIFY sensor5Changed)

    // present values
    Q_PROPERTY(qreal deltaT READ deltaT WRITE setDeltaT NOTIFY deltaTChanged)

public slots:
    void update_gui(bool isConnected, const UI_Data &ui_data);
    void update_log(bool isConnected, QString str);
    void update_config(bool isConnected, const RuntimeConfig &config);

signals:
    void hidState(const quint8 state);
    void hidConnectStatus(const bool connecting, const bool dataOnline, const bool logOnline);
    void logAppend(QString log);
    void saveConfig(const RuntimeConfig &config);
    void configDownloaded();

    void pid1Changed();
    void pid2Changed();
    void pid3Changed();
    void pid4Changed();
    void fan1Changed();
    void fan2Changed();
    void fan3Changed();
    void fan4Changed();
    void fan5Changed();
    void fan6Changed();
    void sensor1Changed();
    void sensor2Changed();
    void sensor3Changed();
    void sensor4Changed();
    void sensor5Changed();

    void deltaTChanged();

public:
    explicit BackEnd(QObject *parent = nullptr);
    ~BackEnd();

    Q_INVOKABLE void reconnect();
    Q_INVOKABLE bool save();

    void checkUsages();

    BackEndPID* pid1() const;
    BackEndPID* pid2() const;
    BackEndPID* pid3() const;
    BackEndPID* pid4() const;
    BackEndFan* fan1() const;
    BackEndFan* fan2() const;
    BackEndFan* fan3() const;
    BackEndFan* fan4() const;
    BackEndFan* fan5() const;
    BackEndFan* fan6() const;
    BackEndSensor* sensor1() const;
    BackEndSensor* sensor2() const;
    BackEndSensor* sensor3() const;
    BackEndSensor* sensor4() const;
    BackEndSensor* sensor5() const;

    qreal deltaT() const;

    void setPid1(BackEndPID *pid);
    void setPid2(BackEndPID *pid);
    void setPid3(BackEndPID *pid);
    void setPid4(BackEndPID *pid);
    void setFan1(BackEndFan *fan);
    void setFan2(BackEndFan *fan);
    void setFan3(BackEndFan *fan);
    void setFan4(BackEndFan *fan);
    void setFan5(BackEndFan *fan);
    void setFan6(BackEndFan *fan);
    void setSensor1(BackEndSensor *sensor);
    void setSensor2(BackEndSensor *sensor);
    void setSensor3(BackEndSensor *sensor);
    void setSensor4(BackEndSensor *sensor);
    void setSensor5(BackEndSensor *sensor);

    void setDeltaT(const qreal &deltaT);

private:
    HID_PnP *ctrl = nullptr;

    BackEndPID *pid1Config = nullptr;
    BackEndPID *pid2Config = nullptr;
    BackEndPID *pid3Config = nullptr;
    BackEndPID *pid4Config = nullptr;
    BackEndFan *fan1Config = nullptr;
    BackEndFan *fan2Config = nullptr;
    BackEndFan *fan3Config = nullptr;
    BackEndFan *fan4Config = nullptr;
    BackEndFan *fan5Config = nullptr;
    BackEndFan *fan6Config = nullptr;
    BackEndSensor *sensor1Config = nullptr;
    BackEndSensor *sensor2Config = nullptr;
    BackEndSensor *sensor3Config = nullptr;
    BackEndSensor *sensor4Config = nullptr;
    BackEndSensor *sensor5Config = nullptr;

    qreal m_deltaT = 0.0;

    QString logBuffer = "";

    RuntimeConfig m_config;

};

#endif // BACK_END_H
