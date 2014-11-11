########################################
#
# Christopher Di Bella
#
# 2014, September 3
#
# This is the qmake file for COMP3601 team Orange
# Team Orange consists of 4 cool guys that I'll update later on :)
#
########################################

QT       += core gui opengl svg 

#greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

QMAKE_CXXFLAGS = -std=c++11 -Wall -Werror -Wextra -pedantic -pthread

TARGET       = clockwork-orange

SOURCES = \
    src/clockwork-orange.cpp \
    src/plot.cpp \
    src/qcustomplot.cpp \
    src/device.cpp \
    src/main_window.cpp \
    src/plot_window.cpp
    

HEADERS += inc/plot.hpp \
    inc/daci.h \
    inc/daio.h \
    inc/demc.h \
    inc/depp.h \
    inc/dgio.h \
    inc/djtg.h \
    inc/dmgr.h \
    inc/dmgt.h \
    inc/dpcdecl.h \
    inc/dpcdefs.h \
    inc/dpcutil.h \
    inc/dpio.h \
    inc/dspi.h \
    inc/dstm.h \
    inc/dtwi.h \
    inc/smart_thread.hpp \
    inc/qcustomplot.h \
    inc/main_window.hpp \
    inc/device.hpp \
    inc/value.hpp \
    inc/plot_window.hpp \
    inc/form_layout.hpp \
    inc/fmod/fmod.h

INCLUDEPATH += inc
LIBS += -L$$PWD/lib -ldpcutil -ldpcomm -ldmgr -ldmgr -ldjtg -ldepp -ldspi -ldstm -ldpio -ldabs -lfmod
