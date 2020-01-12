#ifndef BACK_END_H
#define BACK_END_H

#include <QTimer>
#include <QDebug>

#include "hid_pnp.h"


class BackEndFan : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint8 pinPWM READ pinPWM WRITE setPinPWM NOTIFY pinPWMChanged)
    Q_PROPERTY(quint8 pinRPM READ pinRPM WRITE setPinRPM NOTIFY pinRPMChanged)
    Q_PROPERTY(quint8 mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(quint8 source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(qreal ratio READ ratio WRITE setRatio NOTIFY ratioChanged)
    Q_PROPERTY(quint16 rpm READ rpm WRITE setRpm NOTIFY rpmChanged)

    Q_PROPERTY(QVariantList tbl READ tbl WRITE setTbl NOTIFY tblChanged)


signals:
    void pinPWMChanged();
    void pinRPMChanged();
    void modeChanged();
    void sourceChanged();
    void ratioChanged();
    void rpmChanged();
    void tblChanged();

public:
    explicit BackEndFan(RuntimeConfig::FanConfig &fanConfig, QObject *parent = nullptr);

    quint8 pinPWM();
    quint8 pinRPM();
    quint8 mode();
    quint8 source();
    qreal ratio();
    quint16 rpm();
    const QVariantList& tbl();

    void setPinPWM(const quint8 &pinPWM);
    void setPinRPM(const quint8 &pinRPM);
    void setMode(const quint8 &mode);
    void setSource(const quint8 &source);
    void setRatio(const qreal &ratio);
    void setRpm(const quint16 rpm);
    void setTbl(const QVariantList &tbl);

private:
    RuntimeConfig::FanConfig &fanConfig;
    quint16 m_rpm = 0;
    QVariantList pctTbl;
};


class BackEndSensor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint8 pin READ pin WRITE setPin NOTIFY pinChanged)
    Q_PROPERTY(quint16 beta READ beta WRITE setBeta NOTIFY betaChanged)
    Q_PROPERTY(quint16 seriesR READ seriesR WRITE setSeriesR NOTIFY seriesRChanged)
    Q_PROPERTY(quint16 nominalR READ nominalR WRITE setNominalR NOTIFY nominalRChanged)

signals:
    void pinChanged();
    void betaChanged();
    void seriesRChanged();
    void nominalRChanged();

public:
    explicit BackEndSensor(RuntimeConfig::SensorConfig &sensorConfig, QObject *parent = nullptr);

    quint8 pin();
    quint16 beta();
    quint16 seriesR();
    quint16 nominalR();

    void setPin(const quint8 &pin);
    void setBeta(const quint16 &beta);
    void setSeriesR(const quint16 &seriesR);
    void setNominalR(const quint16 &nominalR);

private:
    RuntimeConfig::SensorConfig &sensorConfig;
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

    quint8 pct();
    quint16 delay();
    qreal caseTempDelta();

    void setPct(const quint8 &pct);
    void setDelay(const quint16 &delay);
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

    quint8 percentMin();
    quint8 percentMax1();
    quint8 percentMax2();
    qreal setpoint();
    qreal setpointMin();
    qreal setpointMax();
    qreal gainP();
    qreal gainI();
    qreal gainD();
    bool adaptiveSP();
    bool adaptiveSPUseCaseTemp();
    qreal adaptiveSPStepSize();
    BackEndPIDStep* adaptiveSPStepUp();
    BackEndPIDStep* adaptiveSPStepDown();

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
    Q_OBJECT
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
    Q_PROPERTY(qreal setpoint READ setpoint WRITE setSetpoint NOTIFY setpointChanged)
    Q_PROPERTY(qreal supplyTemp READ supplyTemp WRITE setSupplyTemp NOTIFY supplyTempChanged)
    Q_PROPERTY(qreal returnTemp READ returnTemp WRITE setReturnTemp NOTIFY returnTempChanged)
    Q_PROPERTY(qreal caseTemp READ caseTemp WRITE setCaseTemp NOTIFY caseTempChanged)
    Q_PROPERTY(qreal auxTemp READ auxTemp WRITE setAuxTemp NOTIFY auxTempChanged)
    Q_PROPERTY(qreal deltaT READ deltaT WRITE setDeltaT NOTIFY deltaTChanged)
    Q_PROPERTY(qreal fanPercentPID READ fanPercentPID WRITE setFanPercentPID NOTIFY fanPercentPIDChanged)
    Q_PROPERTY(qreal fanPercentTbl READ fanPercentTbl WRITE setFanPercentTbl NOTIFY fanPercentTblChanged)


public slots:
    void update_gui(bool isConnected, UI_Data ui_data);
    void update_log(bool isConnected, QString str);
    void update_config(bool isConnected, RuntimeConfig config);

signals:
    void logAppend(QString log);
    void saveConfig(const RuntimeConfig &config);

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

    void setpointChanged();
    void supplyTempChanged();
    void returnTempChanged();
    void caseTempChanged();
    void auxTempChanged();
    void deltaTChanged();
    void fanPercentPIDChanged();
    void fanPercentTblChanged();

public:
    explicit BackEnd(QObject *parent = nullptr);

    ~BackEnd();

    Q_INVOKABLE bool save();

    BackEndPID* pid1();
    BackEndPID* pid2();
    BackEndPID* pid3();
    BackEndPID* pid4();
    BackEndFan* fan1();
    BackEndFan* fan2();
    BackEndFan* fan3();
    BackEndFan* fan4();
    BackEndFan* fan5();
    BackEndFan* fan6();
    BackEndSensor* sensor1();
    BackEndSensor* sensor2();
    BackEndSensor* sensor3();
    BackEndSensor* sensor4();
    BackEndSensor* sensor5();

    qreal setpoint();
    qreal supplyTemp();
    qreal returnTemp();
    qreal caseTemp();
    qreal auxTemp();
    qreal deltaT();
    qreal fanPercentPID();
    qreal fanPercentTbl();

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

    void setSetpoint(const qreal &setpoint);
    void setSupplyTemp(const qreal &supplyTemp);
    void setReturnTemp(const qreal &returnTemp);
    void setCaseTemp(const qreal &caseTemp);
    void setAuxTemp(const qreal &auxTemp);
    void setDeltaT(const qreal &deltaT);
    void setFanPercentPID(const qreal &fanPercent);
    void setFanPercentTbl(const qreal &fanPercent);

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

    qreal m_setpoint = 0.0;
    qreal m_supplyTemp = 0.0;
    qreal m_returnTemp = 0.0;
    qreal m_caseTemp = 0.0;
    qreal m_auxTemp = 0.0;
    qreal m_deltaT = 0.0;
    qreal m_fanPercentPID = 0.0;
    qreal m_fanPercentTbl = 0.0;

    QString logBuffer = "";

    RuntimeConfig m_config;

};

#endif // BACK_END_H
