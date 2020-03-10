#ifndef _LED_H
#define _LED_H

#define NUMB_LED 96
#include "experiment_config.h"
#include <Arduino.h>
#include <EEPROM.h>

typedef enum LEDstate_e
{
    OFFSET,
    LED_HIGH,
    LED_LOW,
    DONE
} LEDstate;

// Initializes the LEDs, assumes EEPROM has been flashed with calibration values
void LEDinit();

// Increments the LED time and return the values from 0 to 4095 for the two LEDs in each well
void LEDupdateGetIntensity(uint8_t index, uint16_t *intensity1_p, uint16_t *intensity2_p);

// LED will be truned off
void LEDdisable(uint8_t index);

// LED will be truned on
void LEDenable(uint8_t index);

#endif