#include "LED.h"

pulseState pulseStates[NUMB_WELL_LEDS][NUMB_WELLS];   // The current state of the LED
uint16_t pulseCounts[NUMB_WELL_LEDS][NUMB_WELLS];     // Number of pulses that have been looped through
uint16_t pulseTimeCounts[NUMB_WELL_LEDS][NUMB_WELLS]; // Time in seconds since start of high phase of pulse or low phase of pulse
bool enabled[NUMB_WELL_LEDS][NUMB_WELLS]; //  Enable/disable LED 


// Reads the EEPROM and returns the calibration value
uint8_t getCalibrationValue(uint8_t led, uint8_t well)
{
#if NUMB_WELL_LEDS < 3
    return EEPROM.read(well * 2 + led);
#else
    return EEPROM.read(well * 3 + led);
#endif
}

void LED_init()
{
    for (uint8_t well = 0; well < NUMB_WELLS; well++)
    {
        for (uint8_t led = 0; led < NUMB_WELL_LEDS; led++)
        {
            // Initiate state machine
            pulseStates[led][well] = P_START;
            pulseCounts[led][well] = 0;
            pulseTimeCounts[led][well] = 0;
            enabled[led][well] = true;
        }
    }
}

uint8_t LED_updateGetIntensity(const uint8_t led, const uint8_t well)
{

    bool ledHigh = false;
    pulseTimeCounts[led][well]++;
    switch (pulseStates[led][well])
    {
    case P_START:
        if (pulseTimeCounts[led][well] >= pgm_read_word_near(&(pusleStartTimes[led][well])))
        {   
            pulseStates[led][well] = P_HIGH_SP_HIGH;
            pulseTimeCounts[led][well] = 0;

            ledHigh = true;
        }
        break;

    case P_HIGH_SP_HIGH:
        if (pulseTimeCounts[led][well] >= pgm_read_word_near(&(pulseHighTimes[led][well])))
        {
            pulseStates[led][well] = P_LOW;
            pulseTimeCounts[led][well] = 0;
        }
        else
        {
            uint16_t spHighTime = pgm_read_word_near(&(subpulseHighTimes[led][well]));
            uint16_t spLowTime = pgm_read_word_near(&(subpulseLowTimes[led][well]));
            if (pulseTimeCounts[led][well] % (spHighTime + spLowTime) == spHighTime)
            {
                pulseStates[led][well] = P_HIGH_SP_LOW;
            }
            else
            {
                ledHigh = true;
            }
        }
        break;
    case P_HIGH_SP_LOW:
        if (pulseTimeCounts[led][well] >= pgm_read_word_near(&(pulseHighTimes[led][well])))
        {
            pulseStates[led][well] = P_LOW;
            pulseTimeCounts[led][well] = 0;
        }
        else
        {
            uint16_t spHighTime = pgm_read_word_near(&(subpulseHighTimes[led][well]));
            uint16_t spLowTime = pgm_read_word_near(&(subpulseLowTimes[led][well]));
            if (pulseTimeCounts[led][well] % (spHighTime + spLowTime) == 0)
            {
                pulseStates[led][well] = P_HIGH_SP_HIGH;
                ledHigh = true;
            }
        }
        break;

    case P_LOW:
        if (pulseTimeCounts[led][well] >= pgm_read_word_near(&(pulseLowTimes[led][well])))
        {
            pulseCounts[led][well]++;
            pulseTimeCounts[led][well] = 0;
            if (pulseCounts[led][well] >= pgm_read_word_near(&(pulseNumbs[led][well])))
            {
                pulseStates[led][well] = DONE;
            }
            else
            {
                pulseStates[led][well] = P_HIGH_SP_HIGH;
                ledHigh = true;
            }
        }
        break;

    case DONE:
        break;
    }

    if (ledHigh && enabled[led][well])
    {
        return (uint8_t)pgm_read_byte_near(&amplitudes[led][well]);
    }
    else
    {
        return 0;
    }
}

void LED_disable(const uint8_t led, const uint8_t well) {
    enabled[led][well] = false;
}

void LED_enable(const uint8_t led, const uint8_t well) {
    enabled[led][well] = true;
}

void LED_wellDisable(const uint8_t well) {
    for(int i = 0; i < NUMB_WELL_LEDS; i++) {
        LED_disable(i, well);
    }
}

void LED_wellEnable(const uint8_t well) {
    for(int i = 0; i < NUMB_WELL_LEDS; i++) {
        LED_enable(i, well);
    }
}

uint16_t calibrateIntensity(const uint8_t led, const uint8_t well, const uint8_t intensity)
{
    return ((uint16_t)intensity * getCalibrationValue(led, well)) / 16;
}