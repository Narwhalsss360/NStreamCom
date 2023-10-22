#include "PacketCollector.h"

PacketCollector::PacketCollector()
	: recycle(false), receivedData(nullptr), bytesCollected(0), id(0), messageSize(0), messageReadyHandler(nullptr)
{
}

void PacketCollector::messageReady(MessageReadyHandler handler)
{
	messageReadyHandler = handler;
}

void PacketCollector::discard()
{
	recycle = false;
	if (receivedData)
		delete[] receivedData;
	receivedData = nullptr;
	bytesCollected = 0;
	messageSize = 0;
}

bool PacketCollector::collect(const uint8_t* const bytes, size_t length)
{
	recycle = false;
	if (!verifyBytes(bytes, length))
	{
		discard();
		return false;
	}

	if (receivedData)
	{
		if (*(uint16_t*)bytes == id)
		{
			for (int iSource = NSTREAMCOM_PROTOCOLSIZE, iDestination = bytesCollected; iSource < length && iDestination < messageSize; iSource++, iDestination++)
				receivedData[iDestination] = bytes[iSource];
			bytesCollected += *(uint16_t*)(bytes + 4);
			if (bytesCollected != messageSize)
				return true;
		}
		else
		{
			if (bytesCollected != messageSize)
			{
				discard();
				return false;
			}
			recycle = true;
		}
	}
	else
	{
		id = *(uint16_t*)bytes;
		messageSize = *(uint16_t*)(bytes + 2);
		receivedData = new uint8_t[messageSize];
		bytesCollected += *(uint16_t*)(bytes + 4);

		for (int iSource = NSTREAMCOM_PROTOCOLSIZE, iDestination = 0; iSource < length && iDestination < messageSize; iSource++, iDestination++)
			receivedData[iDestination] = bytes[iSource];

		if (bytesCollected != messageSize)
			return true;
	}

	if (messageReadyHandler)
		messageReadyHandler(id, receivedData, messageSize);
	discard();
	if (recycle)
		collect(bytes, length);
	return true;
}

PacketCollector::~PacketCollector()
{
}