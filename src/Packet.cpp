#include "Packet.h"

#define SET_BYTE_INTEGRAL(number, index, value) ((uint8_t*)&number)[index] = value;
#define GET_BYTE_INTEGRAL(number, index) ((uint8_t*)&number)[index];

bool verifyBytes(const uint8_t* const bytes, const size_t length)
{
    if (length < NSTREAMCOM_PROTOCOLSIZE)
        return false;

    if ( length - NSTREAMCOM_PROTOCOLSIZE != *(uint16_t*)(bytes + 4))
        return false;

    return true;
}

Packet::Packet()
    : id(0), messageSize(0), data(nullptr), dataLength(0), verified(false)
{
}

Packet::Packet(messageid_t id, uint16_t messageSize, const void* const data, const uint16_t length)
    : id(id), messageSize(messageSize), data(nullptr), dataLength(length), verified(true)
{
    this->data = new uint8_t[length];
    for (int i = 0; i < length; i++)
        this->data[i] = ((uint8_t*)(data))[i];
}

Packet::Packet(const uint8_t* const stream, uint32_t length)
    : id(0), messageSize(0), data(nullptr), dataLength(0), verified(false)
{
    verified = verifyBytes(stream, length);
    if (!verified)
        return;

    SET_BYTE_INTEGRAL(id, 0, stream[0]);
    SET_BYTE_INTEGRAL(id, 1, stream[1]);

    SET_BYTE_INTEGRAL(messageSize, 0, stream[2]);
    SET_BYTE_INTEGRAL(messageSize, 1, stream[3]);

    SET_BYTE_INTEGRAL(dataLength, 0, stream[4]);
    SET_BYTE_INTEGRAL(dataLength, 1, stream[5]);

    data = new uint8_t[dataLength];

    for (uint16_t iSource = NSTREAMCOM_PROTOCOLSIZE, iDestination = 0; iSource < length; iSource++, iDestination++)
        data[iDestination] = stream[iSource];
}

Packet::Packet(const Packet& other)
    : id(other.id), messageSize(other.messageSize), data(nullptr), dataLength(other.dataLength), verified(other.verified)
{
    data = new uint8_t[dataLength];
    for(uint16_t i = 0; i < dataLength; i++)
        data[i] = other.data[i];
}

void* Packet::getData() const
{
    return data;
}

messageid_t Packet::getID() const
{
    return id;
}

uint16_t Packet::getMessageSize() const
{
    return messageSize;
}

uint16_t Packet::getDataSize() const
{
    return dataLength;
}

bool Packet::isVerified() const
{
    return verified;
}

uint32_t Packet::getStreamBytes(uint8_t*& bytes) const
{
    bytes = new uint8_t[NSTREAMCOM_PROTOCOLSIZE + dataLength];
    *(uint16_t*)(bytes) = id;
    *(uint16_t*)(bytes + 2) = messageSize;
    *(uint16_t*)(bytes + 4) = dataLength;
    for (uint16_t iSource = 0, iDestination = NSTREAMCOM_PROTOCOLSIZE; iSource < dataLength; iSource++, iDestination++)
        bytes[iDestination] = data[iSource];
    return NSTREAMCOM_PROTOCOLSIZE + dataLength;
}

Packet& Packet::operator=(const Packet& other)
{
    id = other.id;
    messageSize = other.messageSize;
    dataLength = other.dataLength;
    verified = other.verified;
    if (data)
        delete[] data;
    data = new uint8_t[dataLength];
    for (uint16_t i = 0; i < dataLength; i++)
        data[i] = other.data[i];
    return *this;
}

bool Packet::operator==(const Packet& other) const
{
    return id == other.id && messageSize == other.messageSize && data == other.data && dataLength == other.dataLength;
}

Packet::~Packet()
{
    if (data)
        delete[] data;
    data = nullptr;
}