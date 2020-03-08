@ECHO OFF 
CALL scripts\env.bat

PATH=%PATH%;%QT_DIST_PATH%\%QT_BUILD%\bin

Echo Loading Visual Studio environment
CALL %VC_VARS_PATH%

ECHO Building Teensy Fan Controller

nmake clean
qmake -config release
nmake

ECHO Auild at .\release\
