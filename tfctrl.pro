QT += quick widgets core charts qml

CONFIG += c++11

INCLUDEPATH += ../HIDAPI

win32:LIBS += -lhid -lsetupapi -L../build-HIDAPI-Desktop_Qt_5_13_2_MSVC2017_64bit-Debug/windows -lHIDAPI
linux:LIBS += -lhidapi-hidraw -L../HIDAPI/linux -lHIDAPI

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        back_end.cpp \
        hid_pnp.cpp \
        log_list_model.cpp \
        main.cpp \
        runtime_config_inc.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    back_end.h \
    hid_pnp.h \
    log_list_model.h \
    runtime_config_inc.h
