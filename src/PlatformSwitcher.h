#ifndef PlatformSwitcher_h
#define PlatformSwitcher_h

#if defined(ARDUINO) && ARDUINO >= 100
#include <Arduino.h>
using __platform_ostream__ = Stream;
#define __platform_ostream__write(stream, byte) stream.write(byte)
#else
#include <iostream>
using __platform_ostream__ = std::ostream;
#define __platform_ostream__write(stream, byte) (stream.out << byte)
#endif // DEBUG

#endif // !PlatformSwitcher_h