#ifndef NStreamCom_h
#define NStreamCom_h

#include "declNStreamCom.h"

NStreamCom::NStreamCom(Stream* stream)
	: stream(stream)
{
}

NStreamCom::NStreamCom()
	: NStreamCom(&Serial)
{
}

NStreamData NStreamCom::parse()
{
	NSC_CLEAR_BUFFER();

	uint8_t inDataCount = 0;
	delayMicroseconds(NSC_DELAY);
	while (stream->available() && inDataCount < NSC_BUFFER_SIZE)
	{
		buffer[inDataCount] = stream->read();
		inDataCount++;
		delayMicroseconds(NSC_DELAY);
	}

	if ((inDataCount < NSC_PROTOCOL_OVERHEAD + 1) || (buffer[inDataCount - 2] != '\r' && buffer[inDataCount - 1] != '\n') || (inDataCount - buffer[1] != NSC_PROTOCOL_OVERHEAD) || buffer[0] != SOH) return {0, nullptr, 0};
	
	return { *(uint16_t*)&buffer[NSC_BUFFER_ID_IDX], &buffer[NSC_BUFFER_DATA_IDX], buffer[NSC_BUFFER_SIZE_IDX] };
}

void NStreamCom::send(uint16_t id, void* data, uint8_t size)
{
	NSC_CLEAR_BUFFER();

	buffer[NSC_BUFFER_SOH_IDX] = SOH;
	buffer[NSC_BUFFER_SIZE_IDX] = size;
	memmove(&buffer[NSC_BUFFER_ID_IDX], &id, 2);
	memmove(&buffer[NSC_BUFFER_DATA_IDX], data, size);
	buffer[size + NSC_BUFFER_DATA_IDX] = '\r';
	buffer[size + NSC_BUFFER_DATA_IDX + 1] = '\n';

	stream->write(buffer, size + NSC_BUFFER_DATA_IDX + 2);
}

void NStreamCom::send(NStreamData data)
{
	send(data.id, data.data, data.size);
}

template <typename T, size_t size>
void NStreamCom::send(uint16_t id, TypedByteArray<T, size> data)
{
	send(id, data.bytes, size);
}

#endif