/*
    Copyright 2021 Robin Zhang & Labs

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

 */

#include "dgs_dmx_interface.h"
#include "com_handler.h"

#include <QSerialPortInfo>

// FTDI USB
#define FTDI_VID 1027
#define FTDI_PID 24577

// digishow compatible widget USB
#define DGSW_VID 0xF000
#define DGSW_PID 0x1000

#define DMX_OUT_FREQ 30

DgsDmxInterface::DgsDmxInterface(QObject *parent) : DigishowInterface(parent)
{
    m_interfaceOptions["type"] = "dmx";
    m_com = nullptr;
    m_timer = nullptr;

    // clear dmx data buffer
    for (int n=0 ; n<512 ; n++) m_data[n]=0;
}

DgsDmxInterface::~DgsDmxInterface()
{
    closeInterface();
}

int DgsDmxInterface::openInterface()
{
    if (m_isInterfaceOpened) return ERR_DEVICE_BUSY;

    updateMetadata();

    // get com port configuration
    QString comPort = m_interfaceOptions.value("comPort").toString();
    if (comPort.isEmpty()) comPort = ComHandler::findPort(DGSW_VID, DGSW_PID); // use default port
    if (comPort.isEmpty()) comPort = ComHandler::findPort(FTDI_VID, FTDI_PID);
    if (comPort.isEmpty()) return ERR_INVALID_OPTION;

    // get number of total dmx channels
    int channels = 0;
    for (int n = 0 ; n<m_endpointInfoList.length() ; n++) {
        if (m_endpointInfoList[n].channel+1 > channels) channels = m_endpointInfoList[n].channel+1;
    }

    // create a com handler for the serial communication with the device
    bool done = false;
    m_com = new ComHandler();

    done = enttecDmxOpen(comPort, channels);

    // create a timer for sending dmx frames at a particular frequency
    int frequency = m_interfaceOptions.value("frequency").toInt();
    if (frequency == 0) frequency = DMX_OUT_FREQ;

    m_timer = new QTimer();
    connect(m_timer, SIGNAL(timeout()), this, SLOT(onTimerFired()));
    m_timer->setTimerType(Qt::PreciseTimer);
    m_timer->setSingleShot(false);
    m_timer->setInterval(1000 / frequency);
    m_timer->start();

    if (!done) {
        closeInterface();
        return ERR_DEVICE_NOT_READY;
    }

    m_isInterfaceOpened = true;
    return ERR_NONE;
}

int DgsDmxInterface::closeInterface()
{
    if (m_timer != nullptr) {
        m_timer->stop();
        delete m_timer;
        m_timer = nullptr;
    }

    if (m_com != nullptr) {
        m_com->close();
        delete m_com;
        m_com = nullptr;
    }

    m_isInterfaceOpened = false;
    return ERR_NONE;

}

int DgsDmxInterface::sendData(int endpointIndex, dgsSignalData data)
{
    int r = DigishowInterface::sendData(endpointIndex, data);
    if ( r != ERR_NONE) return r;

    if (data.signal != DATA_SIGNAL_ANALOG) return ERR_INVALID_DATA;

    int value = 255 * data.aValue / (data.aRange==0 ? 255 : data.aRange);
    if (value<0 || value>255) return ERR_INVALID_DATA;

    // update dmx data buffer
    int channel = m_endpointInfoList[endpointIndex].channel;
    m_data[channel] = static_cast<unsigned char>(value);

    // send dmx data frame
    //enttecDmxSendDmxFrame(m_data);

    return ERR_NONE;
}

void DgsDmxInterface::onTimerFired()
{
    // send dmx data frame
    enttecDmxSendDmxFrame(m_data);
}

bool DgsDmxInterface::enttecDmxOpen(const QString &port, int channels)
{
    // open serial port of the dmx adapter
    m_com->setAsyncReceiver(true);

    bool done = false;
    if (m_interfaceInfo.mode == INTERFACE_DMX_ENTTEC_PRO) {
        done = m_com->open(port.toLocal8Bit(), 115200, CH_SETTING_8N1);
    } else
    if (m_interfaceInfo.mode == INTERFACE_DMX_ENTTEC_OPEN) {
        done = m_com->open(port.toLocal8Bit(), 250000, CH_SETTING_8N2);
    }
    if (!done) return false;

    // clear dmx data buffer
    //for (int n=0 ; n<512 ; n++) m_data[n]=0;

    // set number of channels
    m_channels = (channels+7) / 8 * 8;
    if (m_channels<24) m_channels = 24; else if (m_channels>512) m_channels = 512;

    return true;
}

bool DgsDmxInterface::enttecDmxSendDmxFrame(unsigned char *data)
{
    if (m_channels < 24 || m_channels > 512) return false;

    // send frame
    bool done = true;
    if (!m_com->isBusySending()) {

        if (m_interfaceInfo.mode == INTERFACE_DMX_ENTTEC_PRO) {

            // send an enttec pro frame
            int length = m_channels;

            unsigned char head[] = {
                0x7e, // 0  leading character
                0x06, // 1  message type (6 = Output Only Send DMX Packet Request)
                0x00, // 2  data length LSB
                0x00, // 3  data length MSB
                0x00  // 4  start code (always zero)
            };
            head[2] = static_cast<unsigned char>((length+1) & 0xff);
            head[3] = static_cast<unsigned char>((length+1) >> 8);

            unsigned char tail[] = { 0xe7 };

            done &= m_com->sendBytes((const char*)head, sizeof(head), false);
            done &= m_com->sendBytes((const char*)data, length, false);
            done &= m_com->sendBytes((const char*)tail, sizeof(tail));

        } else if (m_interfaceInfo.mode == INTERFACE_DMX_ENTTEC_OPEN) {

            // send an open dmx frame

            // The start-of-packet procedure is a logic zero for more than 22 bit periods (>88usec),
            // followed by a logic 1 for more than 2 bit periods (>8usec).
            m_com->serialPort()->setBreakEnabled(false);
            QThread::usleep(88);
            m_com->serialPort()->setBreakEnabled(true);
            QThread::usleep(8);
            m_com->serialPort()->setBreakEnabled(false);

            m_com->serialPort()->setRequestToSend(true);
            unsigned char head[] = { 0x00 };
            done &= m_com->sendBytes((const char*)head, sizeof(head), false);
            done &= m_com->sendBytes((const char*)data, 512, true);
            m_com->serialPort()->setRequestToSend(false);

            m_com->serialPort()->setBreakEnabled(true);

        }

    }

    return done;
}

QVariantList DgsDmxInterface::listOnline()
{
    QVariantList list;
    QVariantMap info;

    foreach (const QSerialPortInfo &serialPortInfo, QSerialPortInfo::availablePorts()) {

#ifdef Q_OS_MAC
        if (serialPortInfo.portName().startsWith("cu.")) continue;
#endif

        info.clear();
        info["comPort"] = serialPortInfo.portName();

        if (serialPortInfo.hasVendorIdentifier() && serialPortInfo.hasProductIdentifier() && ((
            serialPortInfo.vendorIdentifier()==FTDI_VID && serialPortInfo.productIdentifier()==FTDI_PID ) || (
            serialPortInfo.vendorIdentifier()==DGSW_VID && serialPortInfo.productIdentifier()==DGSW_PID ))) {

            info["mode"] = "enttec";
        } else {
            info["mode"] = "general";
        }

        list.append(info);
    }

    return list;
}

