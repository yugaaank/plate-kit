# plate-kit, Qt port — plain Qt Quick app, no Quickshell.
#
# Build:   qmake6 && make
# Run:     ./plateapp   (from qt/ — see README "How loading works")
#
# LOADING REALITY (dev mode): the app QML and the PlateKit module are read from
# the sibling ./app and ./PlateKit directories next to the binary — hot-reload
# friendly, but the binary must stay beside those folders. Only the fonts go
# through compiled resources (qrc). For a self-contained shipping binary use
# CMake's qt_add_qml_module (see README).
TEMPLATE = app
TARGET = plateapp
CONFIG += c++17
QT += quick quickcontrols2

SOURCES += src/main.cpp
RESOURCES += app.qrc
