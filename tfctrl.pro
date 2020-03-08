# Application icon, version, description, etc.:
RC_ICONS = tfctrl.ico

win32:VERSION = 0.1.0.0
else:VERSION = 0.1.0

QMAKE_TARGET_COMPANY = mstrthealias
QMAKE_TARGET_DESCRIPTION = Teensy Fan Controller configuration UI (tfctrl)
QMAKE_TARGET_COPYRIGHT = "\\251 2020 Jack Davis"
QMAKE_TARGET_PRODUCT = Teensy Fan Controller

# Build config
CONFIG += release windeployqt x11 windows
QT += widgets core qml quick quickcontrols2 quicktemplates2


# Include headers for libraries (that this project builds directly):
INCLUDEPATH += ../HIDAPI ../nanopb


## HIDAPI dep: include HIDAPI source in build, to simplify building dependent HIDAPI project
#macx:  SOURCES += ../HIDAPI/mac/hid.c
#unix: !macx:  SOURCES += ../HIDAPI/linux/hid.c
#win32: SOURCES += ../HIDAPI/windows/hid.c
## HIDAPI requires linking against libhidapi or OS HID
#win32:LIBS += -lhid -lsetupapi
#linux:LIBS += -lhidapi-hidraw
## Note: dependent project builds require top level qmake project (TEMPLATE=subdir):
##SUBDIRS += ../HIDAPI
##tfctrl.subdir = ../HIDAPI
##tfctrl.depends = ../HIDAPI
win32:LIBS += -lhid -lsetupapi -L../HIDAPI/windows -lHIDAPI
linux:LIBS += -lhidapi-hidraw -L../HIDAPI/linux -lHIDAPI


RESOURCES += qml.qrc

HEADERS += \
    back_end.h \
    hid_pnp.h \
    log_list_model.h \
    runtime_config_inc.h

SOURCES += \
        ../nanopb/pb_common.c \
        ../nanopb/pb_decode.c \
        ../nanopb/pb_encode.c \
        ../teensy_fan_controller/src/runtime_config_v1.pb.c \
        back_end.cpp \
        hid_pnp.cpp \
        log_list_model.cpp \
        main.cpp \
        runtime_config_inc.cpp

# `make install` path:
qnx: target.path = /tmp/$${TARGET}/bin
else: win32: target.path = installer/packages/com.github.mstrthealias/data
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target



# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

