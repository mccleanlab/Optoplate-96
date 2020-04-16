#ifndef OPTOPLATE_H
#define OPTOPLATE_H

#include "TinyFrame.h"
#include <Windows.h>
#include <stdio.h>
#include <string.h>
#include "utilities/utils.h"

void TF_WriteImpl(TinyFrame *tf, const uint8_t *buff, uint32_t len);

void OptoPlateInit(const char * portName);
void OptoPlateDisconnect();

void OptoPlateDisableLED(uint8_t LEDindex);
void OptoPlateEnableLED(uint8_t LEDindex);


#endif //OPTOPLATE_H