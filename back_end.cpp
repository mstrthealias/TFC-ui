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


BackEndFan::BackEndFan(RuntimeConfig::FanConfig &fanConfig, QObject *parent) :
    QObject(parent), fanConfig(fanConfig)
{
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
    return fanConfig.mode;
}
qreal BackEndFan::ratio()
{
    return toReal(fanConfig.ratio);
}

quint16 BackEndFan::rpm()
{
    return m_rpm;
}

void BackEndFan::setPinPWM(const quint8 &pinPWM)
{
    if (pinPWM == fanConfig.pinPWM)
        return;

    fanConfig.pinPWM = pinPWM;
    emit pinPWMChanged();
}
void BackEndFan::setPinRPM(const quint8 &pinRPM)
{
    if (pinRPM == fanConfig.pinRPM)
        return;

    fanConfig.pinRPM = pinRPM;
    emit pinRPMChanged();
}
void BackEndFan::setMode(const quint8 &mode)
{
    if (mode == fanConfig.mode)
        return;

    fanConfig.mode = mode == 0 ? MODE_PERCENT_TABLE
                                   : MODE_PID;
    emit modeChanged();
}
void BackEndFan::setRatio(const qreal &ratio)
{
    if (isApproximatelyEqual(static_cast<float>(ratio), fanConfig.ratio))
        return;

    fanConfig.ratio = static_cast<float>(ratio);
    emit ratioChanged();
}

void BackEndFan::setRpm(const quint16 rpm)
{
    if (rpm == m_rpm)
        return;

    m_rpm = rpm;
    emit rpmChanged();
}



BackEndSensor::BackEndSensor(RuntimeConfig::SensorConfig &sensorConfig, QObject *parent) :
    QObject(parent), sensorConfig(sensorConfig)
{
}

quint8 BackEndSensor::pin()
{
    return sensorConfig.pin;
}
quint16 BackEndSensor::beta()
{
    return sensorConfig.beta;
}
quint16 BackEndSensor::seriesR()
{
    return sensorConfig.seriesR;
}
quint16 BackEndSensor::nominalR()
{
    return sensorConfig.nominalR;
}

void BackEndSensor::setPin(const quint8 &pin)
{
    if (pin == sensorConfig.pin)
        return;

    sensorConfig.pin = pin;
    emit pinChanged();
}
void BackEndSensor::setBeta(const quint16 &beta)
{
    if (beta == sensorConfig.beta)
        return;

    sensorConfig.beta = beta;
    emit betaChanged();
}
void BackEndSensor::setSeriesR(const quint16 &seriesR)
{
    if (seriesR == sensorConfig.seriesR)
        return;

    sensorConfig.seriesR = seriesR;
    emit seriesRChanged();
}
void BackEndSensor::setNominalR(const quint16 &nominalR)
{
    if (nominalR == sensorConfig.nominalR)
        return;

    sensorConfig.nominalR = nominalR;
    emit nominalRChanged();
}




BackEndPIDStep::BackEndPIDStep(RuntimeConfig::PIDConfig::PIDStep &step, QObject *parent) :
    QObject(parent), step(step)
{
}

quint8 BackEndPIDStep::pct()
{
    return step.pct;
}

quint16 BackEndPIDStep::delay()
{
    return step.delay;
}

qreal BackEndPIDStep::caseTempDelta()
{
    return toReal(step.case_temp_delta);
}

void BackEndPIDStep::setPct(const quint8 &pct)
{
    if (pct == step.pct)
        return;

    step.pct = pct;
    emit pctChanged();
}

void BackEndPIDStep::setDelay(const quint16 &delay)
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



BackEndPID::BackEndPID(RuntimeConfig &config, QObject *parent) :
    QObject(parent), config(config)
{
    stepUpConfig = new BackEndPIDStep(config.pid.adaptive_sp_step_up, parent);
    stepDownConfig = new BackEndPIDStep(config.pid.adaptive_sp_step_down, parent);
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

quint8 BackEndPID::percentMin()
{
    return config.pwm_percent_min;
}

quint8 BackEndPID::percentMax1()
{
    return config.pwm_percent_max1;
}

quint8 BackEndPID::percentMax2()
{
    return config.pwm_percent_max2;
}

qreal BackEndPID::setpoint()
{
    return toReal(config.pid.setpoint);
}

qreal BackEndPID::setpointMin()
{
    return toReal(config.pid.setpoint_min);
}

qreal BackEndPID::setpointMax()
{
    return toReal(config.pid.setpoint_max);
}

qreal BackEndPID::gainP()
{
    return toReal(config.pid.gain_p);
}

qreal BackEndPID::gainI()
{
    return toReal(config.pid.gain_i);
}

qreal BackEndPID::gainD()
{
    return toReal(config.pid.gain_d);
}

bool BackEndPID::adaptiveSP()
{
    return config.pid.adaptive_sp;
}

bool BackEndPID::adaptiveSPUseCaseTemp()
{
    return config.pid.adaptive_sp_check_case_temp;
}

qreal BackEndPID::adaptiveSPStepSize()
{
    return toReal(config.pid.adaptive_sp_step_size);
}

BackEndPIDStep* BackEndPID::adaptiveSPStepUp()
{
    return stepUpConfig;
}

BackEndPIDStep* BackEndPID::adaptiveSPStepDown()
{
    return stepDownConfig;
}

void BackEndPID::setPercentMin(const quint8 pct)
{
    if (pct == config.pwm_percent_min)
        return;

    config.pwm_percent_min = pct;
    emit percentMinChanged();
}

void BackEndPID::setPercentMax1(const quint8 pct)
{
    if (pct == config.pwm_percent_max1)
        return;

    config.pwm_percent_max1 = pct;
    emit percentMax1Changed();
}

void BackEndPID::setPercentMax2(const quint8 pct)
{
    if (pct == config.pwm_percent_max2)
        return;

    config.pwm_percent_max2 = pct;
    emit percentMax2Changed();
}

void BackEndPID::setSetpoint(const qreal &setpoint)
{
    if (isApproximatelyEqual(static_cast<float>(setpoint), config.pid.setpoint))
        return;

    config.pid.setpoint = static_cast<float>(setpoint);
    emit setpointChanged();
}

void BackEndPID::setSetpointMin(const qreal &setpointMin)
{
    if (isApproximatelyEqual(static_cast<float>(setpointMin), config.pid.setpoint_min))
        return;

    config.pid.setpoint_min = static_cast<float>(setpointMin);
    emit setpointMinChanged();
}

void BackEndPID::setSetpointMax(const qreal &setpointMax)
{
    if (isApproximatelyEqual(static_cast<float>(setpointMax), config.pid.setpoint_max))
        return;

    config.pid.setpoint_max = static_cast<float>(setpointMax);
    emit setpointMaxChanged();
}

void BackEndPID::setGainP(const qreal &gain)
{
    if (isApproximatelyEqual(static_cast<float>(gain), static_cast<float>(config.pid.gain_p)))
        return;

    config.pid.gain_p = static_cast<uint8_t>(gain);
    emit gainPChanged();
}

void BackEndPID::setGainI(const qreal &gain)
{
    if (isApproximatelyEqual(static_cast<float>(gain), config.pid.gain_i))
        return;

    config.pid.gain_i = static_cast<float>(gain);
    emit gainIChanged();
}

void BackEndPID::setGainD(const qreal &gain)
{
    if (isApproximatelyEqual(static_cast<float>(gain), config.pid.gain_d))
        return;

    config.pid.gain_d = static_cast<float>(gain);
    emit gainDChanged();
}

void BackEndPID::setAdaptiveSP(const bool &adativeSP)
{
    if (adativeSP == config.pid.adaptive_sp)
        return;

    config.pid.adaptive_sp = adativeSP;
    emit adaptiveSPChanged();
}

void BackEndPID::setAdaptiveSPUseCaseTemp(const bool &adativeSPUseCaseTemp)
{
    if (adativeSPUseCaseTemp == config.pid.adaptive_sp_check_case_temp)
        return;

    config.pid.adaptive_sp_check_case_temp = adativeSPUseCaseTemp;
    emit adaptiveSPUseCaseTempChanged();
}

void BackEndPID::setAdaptiveSPStepSize(const qreal &stepSize)
{
    if (isApproximatelyEqual(static_cast<float>(stepSize), config.pid.adaptive_sp_step_size))
        return;

    config.pid.adaptive_sp_step_size = static_cast<float>(stepSize);
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
    ctrl = new HID_PnP(parent);

    pidConfig = new BackEndPID(m_config, parent);
    fan1Config = new BackEndFan(m_config.fan1, parent);
    fan2Config = new BackEndFan(m_config.fan2, parent);
    fan3Config = new BackEndFan(m_config.fan3, parent);
    fan4Config = new BackEndFan(m_config.fan4, parent);
    fan5Config = new BackEndFan(m_config.fan5, parent);
    fan6Config = new BackEndFan(m_config.fan6, parent);

    sensor1Config = new BackEndSensor(m_config.tempSupply, parent);
    sensor2Config = new BackEndSensor(m_config.tempReturn, parent);
    sensor3Config = new BackEndSensor(m_config.tempCase, parent);
    sensor4Config = new BackEndSensor(m_config.tempAux, parent);

    connect(ctrl, SIGNAL(hid_comm_update(bool, UI_Data)), this, SLOT(update_gui(bool, UI_Data)));
    connect(ctrl, SIGNAL(log_append(bool, QString)), this, SLOT(update_log(bool, QString)));
    connect(ctrl, SIGNAL(hid_config_download(bool, RuntimeConfig)), this, SLOT(update_config(bool, RuntimeConfig)));

    connect(this, SIGNAL(saveConfig(RuntimeConfig)), ctrl, SLOT(saveConfig(RuntimeConfig)));
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
    if (pidConfig != nullptr) {
        delete pidConfig;
        pidConfig = nullptr;
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
}

/*Q_INVOKABLE */bool BackEnd::save()
{
    saveConfig(m_config);
    return true;
}

void BackEnd::update_gui(bool isConnected, UI_Data ui_data)
{
    if (!isConnected)
        return;
    setSupplyTemp(static_cast<const qreal>(ui_data.supplyTemp));
    setReturnTemp(static_cast<const qreal>(ui_data.returnTemp));
    setCaseTemp(static_cast<const qreal>(ui_data.caseTemp));
    setAuxTemp(static_cast<const qreal>(ui_data.auxTemp));
    setDeltaT(static_cast<const qreal>(ui_data.deltaT));
    setSetpoint(static_cast<const qreal>(ui_data.setpoint));
    setFanPercentPID(static_cast<const qreal>(ui_data.fanPercentPID));
    setFanPercentTbl(static_cast<const qreal>(ui_data.fanPercentTbl));
    fan1Config->setRpm(ui_data.rpm1);
    fan2Config->setRpm(ui_data.rpm2);
    fan3Config->setRpm(ui_data.rpm3);
    fan4Config->setRpm(ui_data.rpm4);
    fan5Config->setRpm(ui_data.rpm5);
    fan6Config->setRpm(ui_data.rpm6);
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

void BackEnd::update_config(bool isConnected, RuntimeConfig config)
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
}

BackEndPID* BackEnd::pid()
{
    return pidConfig;
}

BackEndFan* BackEnd::fan1()
{
    return fan1Config;
}
BackEndFan* BackEnd::fan2()
{
    return fan2Config;
}
BackEndFan* BackEnd::fan3()
{
    return fan3Config;
}
BackEndFan* BackEnd::fan4()
{
    return fan4Config;
}
BackEndFan* BackEnd::fan5()
{
    return fan5Config;
}
BackEndFan* BackEnd::fan6()
{
    return fan6Config;
}

BackEndSensor* BackEnd::sensor1()
{
    return sensor1Config;
}
BackEndSensor* BackEnd::sensor2()
{
    return sensor2Config;
}
BackEndSensor* BackEnd::sensor3()
{
    return sensor3Config;
}
BackEndSensor* BackEnd::sensor4()
{
    return sensor4Config;
}

qreal BackEnd::setpoint()
{
    return m_setpoint;
}

qreal BackEnd::supplyTemp()
{
    return m_supplyTemp;
}

qreal BackEnd::returnTemp()
{
    return m_returnTemp;
}

qreal BackEnd::caseTemp()
{
    return m_caseTemp;
}

qreal BackEnd::auxTemp()
{
    return m_auxTemp;
}

qreal BackEnd::deltaT()
{
    return m_deltaT;
}

qreal BackEnd::fanPercentPID()
{
    return m_fanPercentPID;
}

qreal BackEnd::fanPercentTbl()
{
    return m_fanPercentTbl;
}

void BackEnd::setPid(BackEndPID *pid)
{
    if (pid == pidConfig)
        return;

    pidConfig = pid;
    emit pidChanged();
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

void BackEnd::setSetpoint(const qreal &setpoint)
{
    if (isApproximatelyEqual(setpoint, m_setpoint))
        return;

    m_setpoint = setpoint;
    emit setpointChanged();
}

void BackEnd::setSupplyTemp(const qreal &supplyTemp)
{
    if (isApproximatelyEqual(supplyTemp, m_supplyTemp))
        return;

    m_supplyTemp = supplyTemp;
    emit supplyTempChanged();
}

void BackEnd::setReturnTemp(const qreal &returnTemp)
{
    if (isApproximatelyEqual(returnTemp, m_returnTemp))
        return;

    m_returnTemp = returnTemp;
    emit returnTempChanged();
}

void BackEnd::setCaseTemp(const qreal &caseTemp)
{
    if (isApproximatelyEqual(caseTemp, m_caseTemp))
        return;

    m_caseTemp = caseTemp;
    emit caseTempChanged();
}

void BackEnd::setAuxTemp(const qreal &auxTemp)
{
    if (isApproximatelyEqual(auxTemp, m_auxTemp))
        return;

    m_auxTemp = auxTemp;
    emit auxTempChanged();
}

void BackEnd::setDeltaT(const qreal &deltaT)
{
    if (isApproximatelyEqual(deltaT, m_deltaT))
        return;

    m_deltaT = deltaT;
    emit deltaTChanged();
}

void BackEnd::setFanPercentPID(const qreal &fanPercent)
{
    if (isApproximatelyEqual(fanPercent, m_fanPercentPID))
        return;

    m_fanPercentPID = fanPercent;
    emit fanPercentPIDChanged();
}

void BackEnd::setFanPercentTbl(const qreal &fanPercent)
{
    if (isApproximatelyEqual(fanPercent, m_fanPercentTbl))
        return;

    m_fanPercentTbl = fanPercent;
    emit fanPercentTblChanged();
}

