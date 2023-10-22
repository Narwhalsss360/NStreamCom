#ifndef Packet_h
#define Packet_h

#include "NStreamComCommon.h"

class Packet;

bool verifyBytes(const uint8_t* const bytes, const size_t length);

class Packet
{
public:
	Packet();

	Packet(messageid_t id, uint16_t messageSize, const void * const data, const uint16_t length);

	Packet(const uint8_t* const stream, const uint32_t length);

	Packet(const Packet& other);

	bool isVerified() const;

	void* getData() const;

	messageid_t getID() const;

	uint16_t getMessageSize() const;

	uint16_t getDataSize() const;

	uint32_t getStreamBytes(uint8_t*& bytes) const;

	Packet& operator=(const Packet& other);

	bool operator==(const Packet& other) const;

	~Packet();

private:
	messageid_t id;
	uint16_t messageSize;
	uint8_t* data;
	uint16_t dataLength;
	bool verified;
};

#endif // !Packet_h