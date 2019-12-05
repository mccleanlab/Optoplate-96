#ifndef _LED_H
#define _LED_H
#define NUMB_LED 96
#include "experiment_config.h"
#include <Arduino.h>
#include <EEPROM.h>

typedef enum LEDstate_e{
    OFFSET,
    LED_HIGH,
    LED_LOW,
    DONE
} LEDstate;

void LEDinit();
void LEDupdateGetIntensity(uint8_t index, uint8_t * intensity1_p,  uint8_t * intensity2_p);


#endif