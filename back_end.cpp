#include <cmath>
#include <QJsonObject>
#include "back_end.h"

// https://stackoverflow.com/a/41405501/1345237
//implements relative method - do not use for comparing with zero
template<typename TReal>
static bool isApproximatelyEqual(TReal a, TReal b, TReal tolerance = std::numeric_limits<TReal>::epsilon())
{
    TReal diff = std::fabs(a - b);
    if (diff <= tolerance)
        return true;

    if (diff < std::fmax(std::fabs(a), std::fabs(b)) * tolerance)
        return true;

    return false;
}

template<typename TFloat, typename TMulti = quint32>
static inline qreal toReal(TFloat a, TMulti multi = 10000)
{
    return static_cast<qreal>(static_cast<TMulti>(a * multi) / static_cast<qreal>(multi));
}


BackEndFanPV::BackEndFanPV(QObject *parent) :
    QObject(parent)
{
}

void BackEndFanPV::setRpm(const quint16 rpm)
{
    if (rpm == m_rpm)
        return;

    m_rpm = rpm;
    emit rpmChanged();
}
void BackEndFanPV::setPct(const quint8 pct)
{
    if (pct == m_pct)
        return;

    m_pct = pct;
    emit pctChanged();
}
void BackEndFanPV::setMode(const quint8 mode)
{
    if (mode == m_mode)
        return;
    else if (mode > 3)
        return;

    m_mode = mode;
    emit modeChanged();
}
void BackEndFanPV::setSource(const quint8 source)
{
    if (source == m_source) {
        return;
    }
    else if (source > 5) {
        return;
    }

    m_source = source;
    emit sourceChanged();
}

quint16 BackEndFanPV::rpm() const
{
    return m_rpm;
}
quint8 BackEndFanPV::pct() const
{
    return m_pct;
}
quint8 BackEndFanPV::mode() const
{
    return m_mode;
}
quint8 BackEndFanPV::source() const
{
    return m_source;
}


BackEndFan::BackEndFan(RuntimeConfig::FanConfig &fanConfig, QObject *parent) :
    QObject(parent), fanConfig(fanConfig), pctTbl()
{
    m_pv = new BackEndFanPV(this);
}

BackEndFan::~BackEndFan()
{
    if (m_pv != nullptr) {
        delete m_pv;
        m_pv = nullptr;
    }
}

quint8 BackEndFan::pinPWM()
{
    return fanConfig.pinPWM;
}
quint8 BackEndFan::pinRPM()
{
    return fanConfig.pinRPM;
}
quint8 BackEndFan::mode()
{
    return static_cast<quint8>(fanConfig.mode);
}
quint8 BackEndFan::source()
{
    return static_cast<quint8>(fanConfig.source);
}
qreal BackEndFan::ratio()
{
    return toReal(fanConfig.ratio);
}

QVariantList &BackEndFan::tbl()
{
    pctTbl.clear();
    const auto &pctTable = fanConfig.tbl.temp_pct_table;
    uint8_t i;
    for (i = 0; i < 10; i++) {
        pctTbl.append(QJsonObject{
                          {"temp", toReal(pctTable[i][0])},
                          {"pct", toReal(pctTable[i][1])}
                      });
    }
    return pctTbl;
}

BackEndFanPV* BackEndFan::pv() const
{
    return m_pv;
}

void BackEndFan::setPinPWM(const quint8 pinPWM)
{
    if (pinPWM == 0)
        setMode(static_cast<quint8>(CONTROL_MODE::MODE_OFF));  // set control mode OFF if pinPWM==0

    if (pinPWM == fanConfig.pinPWM)
        return;

    fanConfig.pinPWM = pinPWM;
    emit pinPWMChanged();
}
void BackEndFan::setPinRPM(const quint8 pinRPM)
{
    if (pinRPM == fanConfig.pinRPM)
        return;

    fanConfig.pinRPM = pinRPM;
    emit pinRPMChanged();
}
void BackEndFan::setMode(const quint8 mode)
{
    if (mode == static_cast<quint8>(fanConfig.mode))
        return;
    else if (mode > 3)
        return;

    fanConfig.mode = static_cast<CONTROL_MODE>(mode);
    emit modeChanged();
}
void BackEndFan::setSource(const quint8 source)
{
    if (source == static_cast<quint8>(fanConfig.source)) {
        return;
    }
    else if (source > 5) {
        return;
    }
    else if (fanConfig.mode == CONTROL_MODE::MODE_PID && source != 0 && source != 2 && source != 3 && source != 4) {
        emit sourceChanged();  // force Combo to display original source
        return;
    }

    fanConfig.source = static_cast<CONTROL_SOURCE>(source);
    emit sourceChanged();
}
void BackEndFan::setRatio(const qreal &ratio)
{
    if (isApproximatelyEqual(static_cast<float>(ratio), fanConfig.ratio))
        return;

    fanConfig.ratio = static_cast<float>(ratio);
    emit ratioChanged();
}

void BackEndFan::setTbl(const QVariantList &tbl)
{
    uint8_t i = 0;
    for (QVariantList::const_iterator j = tbl.begin(); j != tbl.end(); j++) {
        if (i > 9)
            break;
        fanConfig.tbl.temp_pct_table[i][0] = static_cast<float>(j->value<QJsonObject>().value("temp").toDouble());
        fanConfig.tbl.temp_pct_table[i][1] = static_cast<float>(j->value<QJsonObject>().value("pct").toDouble());
        i++;
    }
    uint8_t k;
    for (k = i; k < 10; k++) {
        fanConfig.tbl.temp_pct_table[k][0] = fanConfig.tbl.temp_pct_table[i - 1][0];
        fanConfig.tbl.temp_pct_table[k][1] = fanConfig.tbl.temp_pct_table[i - 1][1];
    }

    pctTbl = tbl;
    emit tblChanged();
}

void BackEndFan::setPv(const BackEndFanPV* pv)
{
    if (pv->pct() == m_pv->pct() && pv->rpm() == m_pv->rpm() && pv->mode() == m_pv->mode() && pv->source() == m_pv->source())
        return;

    m_pv->setPct(pv->pct());
    m_pv->setRpm(pv->rpm());
    m_pv->setMode(pv->mode());
    m_pv->setSource(pv->source());

    emit pvChanged();
}


BackEndSensor::BackEndSensor(RuntimeConfig::SensorConfig &sensorConfig, QObject *parent) :
    QObject(parent), sensorConfig(sensorConfig)
{
}

void BackEndSensor::checkUsage(const RuntimeConfig &cfg, const CONTROL_SOURCE src)
{
    setHasPid((cfg.fan1.source == src && cfg.fan1.mode == CONTROL_MODE::MODE_PID)
            || (cfg.fan2.source == src && cfg.fan2.mode == CONTROL_MODE::MODE_PID)
            || (cfg.fan3.source == src && cfg.fan3.mode == CONTROL_MODE::MODE_PID)
            || (cfg.fan4.source == src && cfg.fan4.mode == CONTROL_MODE::MODE_PID)
            || (cfg.fan5.source == src && cfg.fan5.mode == CONTROL_MODE::MODE_PID)
            || (cfg.fan6.source == src && cfg.fan6.mode == CONTROL_MODE::MODE_PID));
}

quint8 BackEndSensor::pin() const
{
    return sensorConfig.pin;
}
quint16 BackEndSensor::beta() const
{
    return sensorConfig.beta;
}
quint16 BackEndSensor::seriesR() const
{
    return sensorConfig.seriesR;
}
quint16 BackEndSensor::nominalR() const
{
    return sensorConfig.nominalR;
}
const qreal& BackEndSensor::pvSetpoint() const
{
    return m_setpoint;
}

const qreal& BackEndSensor::pvTemp() const
{
    return m_temp;
}
bool BackEndSensor::hasPid() const
{
    return m_hasPid;
}

void BackEndSensor::setPin(const quint8 pin)
{
    if (pin == sensorConfig.pin)
        return;

    sensorConfig.pin = pin;
    emit pinChanged();
}
void BackEndSensor::setBeta(const quint16 beta)
{
    if (beta == sensorConfig.beta)
        return;

    sensorConfig.beta = beta;
    emit betaChanged();
}
void BackEndSensor::setSeriesR(const quint16 seriesR)
{
    if (seriesR == sensorConfig.seriesR)
        return;

    sensorConfig.seriesR = seriesR;
    emit seriesRChanged();
}
void BackEndSensor::setNominalR(const quint16 nominalR)
{
    if (nominalR == sensorConfig.nominalR)
        return;

    sensorConfig.nominalR = nominalR;
    emit nominalRChanged();
}
void BackEndSensor::setPvTemp(const qreal &temp)
{
    if (isApproximatelyEqual(temp, m_temp))
        return;

    m_temp = temp;
    emit pvTempChanged();
}
void BackEndSensor::setPvSetpoint(const qreal &setpoint)
{
    setHasPid(setpoint > 0);
    if (isApproximatelyEqual(setpoint, m_setpoint))
        return;

    m_setpoint = setpoint;
    emit pvSetpointChanged();
}
void BackEndSensor::setHasPid(const bool hasPid)
{
    if (hasPid == m_hasPid)
        return;

    m_hasPid = hasPid;
    emit hasPidChanged();
}



BackEndPIDStep::BackEndPIDStep(RuntimeConfig::PIDConfig::PIDStep &step, QObject *parent) :
    QObject(parent), step(step)
{
}

quint8 BackEndPIDStep::pct() const
{
    return step.pct;
}

quint16 BackEndPIDStep::delay() const
{
    return step.delay;
}

qreal BackEndPIDStep::caseTempDelta() const
{
    return toReal(step.case_temp_delta);
}

void BackEndPIDStep::setPct(const quint8 pct)
{
    if (pct == step.pct)
        return;

    step.pct = pct;
    emit pctChanged();
}

void BackEndPIDStep::setDelay(const quint16 delay)
{
    if (delay == step.delay)
        return;

    step.delay = delay;
    emit delayChanged();
}

void BackEndPIDStep::setCaseTempDelta(const qreal &caseTempDelta)
{
    if (isApproximatelyEqual(static_cast<float>(caseTempDelta), step.case_temp_delta))
        return;

    step.case_temp_delta = static_cast<float>(caseTempDelta);
    emit caseTempDeltaChanged();
}



BackEndPID::BackEndPID(RuntimeConfig::PIDConfig &pid, QObject *parent) :
    QObject(parent), pid(pid)
{
    stepUpConfig = new BackEndPIDStep(pid.adaptive_sp_step_up, this);
    stepDownConfig = new BackEndPIDStep(pid.adaptive_sp_step_down, this);
}

BackEndPID::~BackEndPID()
{
    if (stepUpConfig != nullptr) {
        delete stepUpConfig;
        stepUpConfig = nullptr;
    }
    if (stepDownConfig != nullptr) {
        delete stepDownConfig;
        stepDownConfig = nullptr;
    }
}

quint8 BackEndPID::percentMin() const
{
    return pid.pwm_percent_min;
}

quint8 BackEndPID::percentMax1() const
{
    return pid.pwm_percent_max1;
}

quint8 BackEndPID::percentMax2() const
{
    return pid.pwm_percent_max2;
}

qreal BackEndPID::setpoint() const
{
    return toReal(pid.setpoint);
}

qreal BackEndPID::setpointMin() const
{
    return toReal(pid.setpoint_min);
}

qreal BackEndPID::setpointMax() const
{
    return toReal(pid.setpoint_max);
}

qreal BackEndPID::gainP() const
{
    return toReal(pid.gain_p);
}

qreal BackEndPID::gainI() const
{
    return toReal(pid.gain_i);
}

qreal BackEndPID::gainD() const
{
    return toReal(pid.gain_d);
}

bool BackEndPID::adaptiveSP() const
{
    return pid.adaptive_sp;
}

bool BackEndPID::adaptiveSPUseCaseTemp() const
{
    return pid.adaptive_sp_check_case_temp;
}

qreal BackEndPID::adaptiveSPStepSize() const
{
    return toReal(pid.adaptive_sp_step_size);
}

BackEndPIDStep* BackEndPID::adaptiveSPStepUp() const
{
    return stepUpConfig;
}

BackEndPIDStep* BackEndPID::adaptiveSPStepDown() const
{
    return stepDownConfig;
}

void BackEndPID::setPercentMin(const quint8 pct)
{
    if (pct == pid.pwm_percent_min)
        return;

    pid.pwm_percent_min = pct;
    emit percentMinChanged();
}

void BackEndPID::setPercentMax1(const quint8 pct)
{
    if (pct == pid.pwm_percent_max1)
        return;

    pid.pwm_percent_max1 = pct;
    emit percentMax1Changed();
}

void BackEndPID::setPercentMax2(const quint8 pct)
{
    if (!pid.adaptive_sp)
        setPercentMax1(pct);  // also set percentMax1 to this pct

    if (pct == pid.pwm_percent_max2)
        return;

    pid.pwm_percent_max2 = pct;
    emit percentMax2Changed();
}

void BackEndPID::setSetpoint(const qreal &setpoint)
{
    if (isApproximatelyEqual(static_cast<float>(setpoint), pid.setpoint))
        return;

    pid.setpoint = static_cast<float>(setpoint);
    emit setpointChanged();
}

void BackEndPID::setSetpointMin(const qreal &setpointMin)
{
    if (isApproximatelyEqual(static_cast<float>(setpointMin), pid.setpoint_min))
        return;

    pid.setpoint_min = static_cast<float>(setpointMin);
    emit setpointMinChanged();
}

void BackEndPID::setSetpointMax(const qreal &setpointMax)
{
    if (isApproximatelyEqual(static_cast<float>(setpointMax), pid.setpoint_max))
        return;

    pid.setpoint_max = static_cast<float>(setpointMax);
    emit setpointMaxChanged();
}

void BackEndPID::setGainP(const qreal &gain)
{
    if (isApproximatelyEqual(static_cast<float>(gain), static_cast<float>(pid.gain_p)))
        return;

    pid.gain_p = static_cast<uint8_t>(gain);
    emit gainPChanged();
}

void BackEndPID::setGainI(const qreal &gain)
{
    if (isApproximatelyEqual(static_cast<float>(gain), pid.gain_i))
        return;

    pid.gain_i = static_cast<float>(gain);
    emit gainIChanged();
}

void BackEndPID::setGainD(const qreal &gain)
{
    if (isApproximatelyEqual(static_cast<float>(gain), pid.gain_d))
        return;

    pid.gain_d = static_cast<float>(gain);
    emit gainDChanged();
}

void BackEndPID::setAdaptiveSP(const bool &adativeSP)
{
    if (adativeSP == pid.adaptive_sp)
        return;

    pid.adaptive_sp = adativeSP;
    emit adaptiveSPChanged();
}

void BackEndPID::setAdaptiveSPUseCaseTemp(const bool &adativeSPUseCaseTemp)
{
    if (adativeSPUseCaseTemp == pid.adaptive_sp_check_case_temp)
        return;

    pid.adaptive_sp_check_case_temp = adativeSPUseCaseTemp;
    emit adaptiveSPUseCaseTempChanged();
}

void BackEndPID::setAdaptiveSPStepSize(const qreal &stepSize)
{
    if (isApproximatelyEqual(static_cast<float>(stepSize), pid.adaptive_sp_step_size))
        return;

    pid.adaptive_sp_step_size = static_cast<float>(stepSize);
    emit adaptiveSPStepSizeChanged();
}

void BackEndPID::setAdaptiveSPStepUp(BackEndPIDStep *step)
{
    if (step == stepUpConfig)
        return;

    stepUpConfig = step;
    emit adaptiveSPStepUpChanged();
}

void BackEndPID::setAdaptiveSPStepDown(BackEndPIDStep *step)
{
    if (step == stepDownConfig)
        return;

    stepDownConfig = step;
    emit adaptiveSPStepDownChanged();
}




BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
    ctrl = new HID_PnP(this);

    pid1Config = new BackEndPID(m_config.tempSupply.pid, this);
    pid2Config = new BackEndPID(m_config.tempCase.pid, this);
    pid3Config = new BackEndPID(m_config.tempAux1.pid, this);
    pid4Config = new BackEndPID(m_config.tempAux2.pid, this);
    fan1Config = new BackEndFan(m_config.fan1, this);
    fan2Config = new BackEndFan(m_config.fan2, this);
    fan3Config = new BackEndFan(m_config.fan3, this);
    fan4Config = new BackEndFan(m_config.fan4, this);
    fan5Config = new BackEndFan(m_config.fan5, this);
    fan6Config = new BackEndFan(m_config.fan6, this);

    sensor1Config = new BackEndSensor(m_config.tempSupply, this);
    sensor2Config = new BackEndSensor(m_config.tempReturn, this);
    sensor3Config = new BackEndSensor(m_config.tempCase, this);
    sensor4Config = new BackEndSensor(m_config.tempAux1, this);
    sensor5Config = new BackEndSensor(m_config.tempAux2, this);

    connect(ctrl, SIGNAL(hid_connect_failure(bool)), this, SIGNAL(hidConnectFailure(bool)));

    connect(ctrl, SIGNAL(hid_comm_update(bool, UI_Data)), this, SLOT(update_gui(bool, UI_Data)));
    connect(ctrl, SIGNAL(log_append(bool, QString)), this, SLOT(update_log(bool, QString)));
    connect(ctrl, SIGNAL(hid_config_download(bool, RuntimeConfig)), this, SLOT(update_config(bool, RuntimeConfig)));

    connect(this, SIGNAL(saveConfig(RuntimeConfig)), ctrl, SLOT(saveConfig(RuntimeConfig)));

    // check fan/sensor usages
    checkUsages();
}

BackEnd::~BackEnd()
{
    if (ctrl != nullptr) {
        disconnect(ctrl, SIGNAL(hid_comm_update(bool, UI_Data)), this, SLOT(update_gui(bool, UI_Data)));
        disconnect(ctrl, SIGNAL(log_append(bool, QString)), this, SLOT(update_log(bool, QString)));
        disconnect(ctrl, SIGNAL(hid_config_download(bool, RuntimeConfig)), this, SLOT(update_config(bool, RuntimeConfig)));
        disconnect(this, SIGNAL(saveConfig(RuntimeConfig)), ctrl, SLOT(saveConfig(RuntimeConfig)));
        delete ctrl;
        ctrl = nullptr;
    }
    if (pid1Config != nullptr) {
        delete pid1Config;
        pid1Config = nullptr;
    }
    if (pid2Config != nullptr) {
        delete pid2Config;
        pid2Config = nullptr;
    }
    if (pid3Config != nullptr) {
        delete pid3Config;
        pid3Config = nullptr;
    }
    if (pid4Config != nullptr) {
        delete pid4Config;
        pid4Config = nullptr;
    }
    if (fan1Config != nullptr) {
        delete fan1Config;
        fan1Config = nullptr;
    }
    if (fan2Config != nullptr) {
        delete fan2Config;
        fan2Config = nullptr;
    }
    if (fan3Config != nullptr) {
        delete fan3Config;
        fan3Config = nullptr;
    }
    if (fan4Config != nullptr) {
        delete fan4Config;
        fan4Config = nullptr;
    }
    if (fan5Config != nullptr) {
        delete fan5Config;
        fan5Config = nullptr;
    }
    if (fan6Config != nullptr) {
        delete fan6Config;
        fan6Config = nullptr;
    }
    if (sensor1Config != nullptr) {
        delete sensor1Config;
        sensor1Config = nullptr;
    }
    if (sensor2Config != nullptr) {
        delete sensor2Config;
        sensor2Config = nullptr;
    }
    if (sensor3Config != nullptr) {
        delete sensor3Config;
        sensor3Config = nullptr;
    }
    if (sensor4Config != nullptr) {
        delete sensor4Config;
        sensor4Config = nullptr;
    }
    if (sensor5Config != nullptr) {
        delete sensor5Config;
        sensor5Config = nullptr;
    }
}

/*Q_INVOKABLE */bool BackEnd::save()
{
    saveConfig(m_config);
    return true;
}

void BackEnd::checkUsages()
{
    sensor1Config->checkUsage(m_config, CONTROL_SOURCE::SENSOR_WATER_SUPPLY_TEMP);
    sensor2Config->checkUsage(m_config, CONTROL_SOURCE::SENSOR_WATER_RETURN_TEMP);
    sensor3Config->checkUsage(m_config, CONTROL_SOURCE::SENSOR_CASE_TEMP);
    sensor4Config->checkUsage(m_config, CONTROL_SOURCE::SENSOR_AUX1_TEMP);
    sensor5Config->checkUsage(m_config, CONTROL_SOURCE::SENSOR_AUX2_TEMP);
}

void BackEnd::update_gui(bool isConnected, const UI_Data &ui_data)
{
    if (!isConnected)
        return;
    sensor1Config->setPvTemp(ui_data.supplyTemp);
    sensor1Config->setPvSetpoint(ui_data.setpointSupply);
    sensor2Config->setPvTemp(ui_data.returnTemp);
    sensor3Config->setPvTemp(ui_data.caseTemp);
    sensor4Config->setPvTemp(ui_data.aux1Temp);
    sensor4Config->setPvSetpoint(ui_data.setpointAux1);
    sensor5Config->setPvTemp(ui_data.aux2Temp);
    setDeltaT(static_cast<const qreal>(ui_data.deltaT));

    BackEndFan *fans[FAN_CNT] = {fan1Config, fan2Config, fan3Config, fan4Config, fan5Config, fan6Config};
    uint8_t i;
    for (i = 0; i < FAN_CNT; i++) {
        const UI_Data_Fan &src = ui_data.fans[i];
        BackEndFanPV &pv = *fans[i]->pv();
        pv.setRpm(src.rpm);
        pv.setPct(src.pct);
        pv.setMode(src.mode);
        pv.setSource(src.source);
    }
}

void BackEnd::update_log(bool isConnected, QString str)
{
    if (!isConnected)
        return;
    logBuffer += str;
    if (str.endsWith("\n")) {
        logAppend(logBuffer.left(logBuffer.length() - 1));
        logBuffer = "";
    }
}

void BackEnd::update_config(bool isConnected, const RuntimeConfig &config)
{
    if (!isConnected)
        return;

    m_config = config;

    emit fan1Changed();
    emit fan2Changed();
    emit fan3Changed();
    emit fan4Changed();
    emit fan5Changed();
    emit fan6Changed();

    checkUsages();
}

BackEndPID* BackEnd::pid1() const
{
    return pid1Config;
}
BackEndPID* BackEnd::pid2() const
{
    return pid2Config;
}
BackEndPID* BackEnd::pid3() const
{
    return pid3Config;
}
BackEndPID* BackEnd::pid4() const
{
    return pid4Config;
}

BackEndFan* BackEnd::fan1() const
{
    return fan1Config;
}
BackEndFan* BackEnd::fan2() const
{
    return fan2Config;
}
BackEndFan* BackEnd::fan3() const
{
    return fan3Config;
}
BackEndFan* BackEnd::fan4() const
{
    return fan4Config;
}
BackEndFan* BackEnd::fan5() const
{
    return fan5Config;
}
BackEndFan* BackEnd::fan6() const
{
    return fan6Config;
}

BackEndSensor* BackEnd::sensor1() const
{
    return sensor1Config;
}
BackEndSensor* BackEnd::sensor2() const
{
    return sensor2Config;
}
BackEndSensor* BackEnd::sensor3() const
{
    return sensor3Config;
}
BackEndSensor* BackEnd::sensor4() const
{
    return sensor4Config;
}
BackEndSensor* BackEnd::sensor5() const
{
    return sensor5Config;
}

qreal BackEnd::deltaT() const
{
    return m_deltaT;
}

void BackEnd::setPid1(BackEndPID *pid)
{
    if (pid == pid1Config)
        return;

    pid1Config = pid;
    emit pid1Changed();
}
void BackEnd::setPid2(BackEndPID *pid)
{
    if (pid == pid2Config)
        return;

    pid2Config = pid;
    emit pid2Changed();
}
void BackEnd::setPid3(BackEndPID *pid)
{
    if (pid == pid3Config)
        return;

    pid3Config = pid;
    emit pid3Changed();
}
void BackEnd::setPid4(BackEndPID *pid)
{
    if (pid == pid4Config)
        return;

    pid4Config = pid;
    emit pid4Changed();
}

void BackEnd::setFan1(BackEndFan *fan)
{
    if (fan == fan1Config)
        return;
    fan1Config = fan;
    emit fan1Changed();
}
void BackEnd::setFan2(BackEndFan *fan)
{
    if (fan == fan2Config)
        return;
    fan2Config = fan;
    emit fan2Changed();
}
void BackEnd::setFan3(BackEndFan *fan)
{
    if (fan == fan3Config)
        return;
    fan3Config = fan;
    emit fan3Changed();
}
void BackEnd::setFan4(BackEndFan *fan)
{
    if (fan == fan4Config)
        return;
    fan4Config = fan;
    emit fan4Changed();
}
void BackEnd::setFan5(BackEndFan *fan)
{
    if (fan == fan5Config)
        return;
    fan5Config = fan;
    emit fan5Changed();
}
void BackEnd::setFan6(BackEndFan *fan)
{
    if (fan == fan6Config)
        return;
    fan6Config = fan;
    emit fan6Changed();
}

void BackEnd::setSensor1(BackEndSensor *sensor)
{
    if (sensor == sensor1Config)
        return;
    sensor1Config = sensor;
    emit sensor1Changed();
}
void BackEnd::setSensor2(BackEndSensor *sensor)
{
    if (sensor == sensor2Config)
        return;
    sensor2Config = sensor;
    emit sensor2Changed();
}
void BackEnd::setSensor3(BackEndSensor *sensor)
{
    if (sensor == sensor3Config)
        return;
    sensor3Config = sensor;
    emit sensor3Changed();
}
void BackEnd::setSensor4(BackEndSensor *sensor)
{
    if (sensor == sensor4Config)
        return;
    sensor4Config = sensor;
    emit sensor4Changed();
}
void BackEnd::setSensor5(BackEndSensor *sensor)
{
    if (sensor == sensor5Config)
        return;
    sensor5Config = sensor;
    emit sensor5Changed();
}

void BackEnd::setDeltaT(const qreal &deltaT)
{
    if (isApproximatelyEqual(deltaT, m_deltaT))
        return;

    m_deltaT = deltaT;
    emit deltaTChanged();
}


