#include "LED.h"

#if NUMB_WELL_LEDS <= 2
uint8_t calibrationValues[2][NUMB_WELLS];
#else
uint8_t calibrationValues[3][NUMB_WELLS];
#endif
pulseState pulseStates[NUMB_WELL_LEDS][NUMB_WELLS];   // The current state of the LED
uint16_t pulseCounts[NUMB_WELL_LEDS][NUMB_WELLS];     // Number of pulses that have been looped through
uint16_t pulseTimeCounts[NUMB_WELL_LEDS][NUMB_WELLS]; // Time in seconds since start of high phase of pulse or low phase of pulse

subPulseState subpulseStates[NUMB_WELL_LEDS][NUMB_WELLS]; // Number of subpulses in pulse that have been looped through
uint16_t subpulseTimeCounts[NUMB_WELL_LEDS][NUMB_WELLS];  // Time in seconds since start of high phase of subpulse or low phase of subpulse

void LED_init()
{

    for (uint8_t i = 0; i < NUMB_WELLS; i++)
    {
            // Load calibration values from static memory
            #if NUMB_WELL_LEDS < 3
            calibrationValues[0][i] = EEPROM.read(i * 2 );
            calibrationValues[1][i] = EEPROM.read(i * 2 + 1);
#else
            calibrationValues[0][i] = EEPROM.read(i * 3 );
            calibrationValues[1][i] = EEPROM.read(i * 3 + 1);
            calibrationValues[3][i] = EEPROM.read(i * 3 + 2);
#endif
        for (uint8_t led = 0; led < NUMB_WELL_LEDS; led++)
        {

            // Initiate state machine
            pulseStates[led][i] = P_START;
            pulseCounts[led][i] = 0;
            pulseTimeCounts[led][i] = 0;

            subpulseStates[led][i] = SP_HIGH;
            subpulseTimeCounts[led][i] = 0;
        }
    }
}

uint8_t LED_updateGetIntensity(uint8_t led, uint8_t well)
{
    bool ledHigh = false;
    pulseTimeCounts[led][well]++;

    switch (pulseStates[led][well])
    {
    case P_START:
        if (pulseTimeCounts[led][well] >= pgm_read_word_near(&pusleStartTimes[led][well]))
        {
            pulseStates[led][well] = P_HIGH;
            pulseTimeCounts[led][well] = 0;

            subpulseStates[led][well] = SP_HIGH;
            subpulseTimeCounts[led][well] = 0;

            ledHigh = true;
        }
        break;

    case P_HIGH:
        if (pulseTimeCounts[led][well] >= pgm_read_word_near(&pulseHighTimes[led][well]))
        {
            pulseStates[led][well] = P_LOW;
            pulseTimeCounts[led][well] = 0;
        }
        else
        {
            subpulseTimeCounts[led][well]++;
            switch (subpulseStates[led][well])
            {
            case SP_HIGH:
                if (subpulseTimeCounts[led][well] >= pgm_read_word_near(&subpulseHighTimes[led][well]))
                {
                    subpulseStates[led][well] = SP_LOW;
                    subpulseTimeCounts[led][well] = 0;
                }
                else
                {
                    ledHigh = true;
                }
                break;
            case SP_LOW:
                if (subpulseTimeCounts[led][well] >= pgm_read_word_near(&subpulseLowTimes[led][well]))
                {
                    subpulseStates[led][well] = SP_HIGH;
                    subpulseTimeCounts[led][well] = 0;

                    ledHigh = true;
                }
                break;
            }
        }
        break;

    case P_LOW:
        if (pulseTimeCounts[led][well] >= pgm_read_word_near(&pulseLowTimes[led][well]))
        {
            pulseCounts[led][well]++;
            pulseTimeCounts[led][well] = 0;
            if (pulseCounts[led][well] >= pgm_read_word_near(&pulseNumbs[led][well]))
            {
                pulseStates[led][well] = DONE;
            }
            else
            {
                pulseStates[led][well] = P_HIGH;
                subpulseStates[led][well] = SP_HIGH;
                subpulseTimeCounts[led][well] = 0;

                ledHigh = true;
            }
        }
        break;

    case DONE:
        break;
    }

    if (ledHigh)
    {
        return pgm_read_byte_near(&(amplitudes[led][well]));
    }
    else
    {
        return 0;
    }
}

uint16_t calibrateIntensity(uint8_t led, uint8_t well, uint8_t intensity)
{
    return ((uint16_t)(intensity)*calibrationValues[led][well]) / 16;
}