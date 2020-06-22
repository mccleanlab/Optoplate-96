#include "LED.h"
#if NUMB_WELL_LEDS < 3
uint8_t calibrationValues[2][NUMB_WELLS];
#else
uint8_t calibrationValues[3][NUMB_WELLS];
#endif

pulseState pulseStates[NUMB_WELL_LEDS][NUMB_WELLS];   // The current state of the LED
uint16_t pulseCounts[NUMB_WELL_LEDS][NUMB_WELLS];     // Number of pulses that have been looped through
uint16_t pulseTimeCounts[NUMB_WELL_LEDS][NUMB_WELLS]; // Time in seconds since start of high phase of pulse or low phase of pulse

subPulseState subpulseStates[NUMB_WELL_LEDS][NUMB_WELLS]; // Number of subpulses in pulse that have been looped through
void LED_init()
{
    for (uint8_t well = 0; well < NUMB_WELLS; well++)
    {

#if NUMB_WELL_LEDS < 3
        calibrationValues[0][well] = EEPROM.read(well * 2);
        calibrationValues[1][well] = EEPROM.read(well * 2 + 1);
#else
        calibrationValues[0][well] = EEPROM.read(well * 3);
        calibrationValues[1][well] = EEPROM.read(well * 3 + 1);
        calibrationValues[2][well] = EEPROM.read(well * 3 + 2);
#endif
        for (uint8_t led = 0; led < NUMB_WELL_LEDS; led++)
        {

            // Initiate state machine
            pulseStates[led][well] = P_START;
            pulseCounts[led][well] = 0;
            pulseTimeCounts[led][well] = 0;

            subpulseStates[led][well] = SP_HIGH;
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
            pulseStates[led][well] = P_HIGH;
            pulseTimeCounts[led][well] = 0;

            subpulseStates[led][well] = SP_HIGH;

            ledHigh = true;
        }
        break;

    case P_HIGH:
        if (pulseTimeCounts[led][well] >= pgm_read_word_near(&(pulseHighTimes[led][well])))
        {
            pulseStates[led][well] = P_LOW;
            pulseTimeCounts[led][well] = 0;
        }
        else
        {
            uint16_t spHighTime = pgm_read_word_near(&(subpulseHighTimes[led][well]));
            uint16_t spLowTime = pgm_read_word_near(&(subpulseLowTimes[led][well]));
            switch (subpulseStates[led][well])
            {
            case SP_HIGH:
                if (pulseTimeCounts[led][well] % (spHighTime + spLowTime) == spHighTime)
                {
                    subpulseStates[led][well] = SP_LOW;
                }
                else
                {
                    ledHigh = true;
                }
                break;
            case SP_LOW:
                if (pulseTimeCounts[led][well] % (spHighTime + spLowTime) == 0)
                {
                    subpulseStates[led][well] = SP_HIGH;
                    ledHigh = true;
                }
                break;
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
                pulseStates[led][well] = P_HIGH;
                subpulseStates[led][well] = SP_HIGH;
                ledHigh = true;
            }
        }
        break;

    case DONE:
        break;
    }

    if (ledHigh)
    {
        return (uint8_t)pgm_read_byte_near(&amplitudes[led][well]);
    }
    else
    {
        return 0;
    }
}

uint16_t calibrateIntensity(uint8_t led, uint8_t well, uint8_t intensity)
{
    return ((uint16_t)intensity * (uint16_t)calibrationValues[led][well]) / 16;
}