#ifndef declNStreamCom_h
#define declNStreamCom_h

#include <Stream.h>
#include <stdint.h>
#include <TypedByteArray.h> //<- remove

#define NSC_PROTOCOL_OVERHEAD 6
#define NSC_BUFFER_SOH_IDX 0
#define NSC_BUFFER_SIZE_IDX 1
#define NSC_BUFFER_ID_IDX 2
#define NSC_BUFFER_DATA_IDX 4

#define INVALID_DATA(d) ((d.size == 0) ? 1 : 0)

#ifndef NSC_BUFFER_SIZE
#define NSC_BUFFER_SIZE 36
#else
	#if NSC_BUFFER_SIZE < 10
	#define NSC_BUFFER_SIZE 36
	#endif
#endif

#ifndef NSC_DELAY
#define NSC_DELAY 9
#endif

#define NSC_CLEAR_BUFFER() for (uint8_t i = 0; i < NSC_BUFFER_SIZE; i++) buffer[i] = 0
#define SOH 1

enum NStreamComErrors
{
	SUCCESS,
	INBUFFER_LENGTH_MISMATCH,
	INBUFFER_BAD_TAIL,
	INBUFFER_SIZE_MISMATCH,
	INBUFFER_BAD_HEAD
};

struct NStreamData
{
	uint16_t id;
	uint8_t* data;
	uint8_t size;
};

class NStreamCom
{
	Stream* stream;
	uint8_t buffer[NSC_BUFFER_SIZE];
	int lastError;
public:
	NStreamCom();
	NStreamCom(Stream*);
	NStreamData parse();
	void send(uint16_t, void*, uint8_t);
	void send(NStreamData);
	int getLastError();
#ifdef TypedByteArray_h
	template <typename T, size_t size>
	void send(uint16_t, TypedByteArray<T, size>);
#endif
};

#endif