/*
LED.h
Finite state machine for the LEDs. Also handels the calibration values of the LEDs
*/
#ifndef _LED_H
#define _LED_H

#include "experiment_config.h"
#include <Arduino.h>
#include <EEPROM.h>

typedef enum pulseState_e
{
    P_START,
    P_HIGH_SP_HIGH,
    P_HIGH_SP_LOW,
    P_LOW,
    DONE
} pulseState;

// Initializes the LEDs, assumes EEPROM has been flashed with calibration values
void LED_init();

// Increments the LED time and return the values from 0 to 255 for the one LED
uint8_t LED_updateGetIntensity(const uint8_t led, const uint8_t well);

// Takes in a intensity value and ajustes it with a calibration value
// well - a number from 0 to 95 representing the well,
// led - the index of the LED in the well
// intensity_p -  light intenisty of the LED, from 0 to 255
uint16_t calibrateIntensity(const uint8_t led, const uint8_t well, const uint8_t intensity);

#endif