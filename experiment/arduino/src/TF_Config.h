//
// Created by MightyPork on 2017/10/15.
//

#ifndef TF_CONFIG_H
#define TF_CONFIG_H

#include <stdint.h>
#include <stdio.h>


#define TF_ID_BYTES     1
#define TF_LEN_BYTES    1
#define TF_TYPE_BYTES   1
#define TF_CKSUM_TYPE TF_CKSUM_XOR
#define TF_USE_SOF_BYTE 1
#define TF_SOF_BYTE     0x01
typedef uint16_t TF_TICKS;
typedef uint8_t TF_COUNT;
#define TF_MAX_PAYLOAD_RX 256
#define TF_SENDBUF_LEN 256
#define TF_MAX_ID_LST   5
#define TF_MAX_TYPE_LST 5
#define TF_MAX_GEN_LST  5
#define TF_PARSER_TIMEOUT_TICKS 10

#define TF_Error(format, ...) printf("[TF] " format "\n", ##__VA_ARGS__)

#endif //TF_CONFIG_H
