@ECHO OFF 
CALL scripts\env.bat

PATH=%PATH%;%QT_DIST_PATH%\%QT_BUILD%\bin

del /F /S /Q %INSTALL_DEST%\*
del /F /S /Q %INSTALL_DEST%\*.*

mkdir %INSTALL_DEST%
copy release\tfctrl.exe %INSTALL_DEST%\
copy release\tfctrl_resource.rc %INSTALL_DEST%\

ECHO Creating application deployment
windeployqt --compiler-runtime --qmldir . --release .\%INSTALL_DEST%\


ECHO Application deployed to %INSTALL_DEST%