#ifndef STDTYPE_H
#define STDTYPE_H

// 8 bits
typedef signed char         int8_t;
typedef unsigned char       uint8_t;

// 16 bits
typedef signed short        int16_t;
typedef unsigned short      uint16_t;

// 32 bits
typedef signed int          int32_t;
typedef unsigned int        uint32_t;

// 64 bits
#ifdef __x86_64__
typedef signed long long    int64_t;
typedef unsigned long long  uint64_t;
#endif

#endif
