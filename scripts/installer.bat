@ECHO OFF 
CALL scripts\env.bat

PATH=%PATH%;%QT_DIST_PATH%\%QT_BUILD%\bin;%QT_PATH%\tools\QtInstallerFramework\3.2\bin

cd installer

ECHO Building installer
binarycreator --offline-only -c config/config.xml -p packages TFCtrlInstaller

cd ..


ECHO Installer available at .\installer\TFCtrlInstaller.exe
