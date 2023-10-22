#ifndef PacketCollector_h
#define PacketCollector_h

#include "NStreamComCommon.h"
#include "Packet.h"

using MessageReadyHandler = void (*)(const uint16_t id, void* data, uint16_t size);

class PacketCollector
{
public:
	PacketCollector();

	void messageReady(MessageReadyHandler handler);

	void discard();

	bool collect(const uint8_t* const bytes, size_t length);

	~PacketCollector();

private:

	bool recycle;
	uint8_t* receivedData;
	uint16_t bytesCollected;
	uint16_t id;
	uint16_t messageSize;
	MessageReadyHandler messageReadyHandler;
};

#endif // !PacketCollector_h