#include "LED.h"

// Outputs a value from 0 to 4095, indicating the LED intensity adjusted with calibration value
uint16_t getIntensity(uint8_t index, uint8_t indexLED);

uint8_t calibrationValues[NUMB_LED][2];

pulseState pulseStates[NUMB_LED]; // The current state of the LED
uint16_t pulseCounts[NUMB_LED]; // Number of pulses that have been looped through
uint16_t pulseTimeCounts[NUMB_LED]; // Time in seconds since start of high phase of pulse or low phase of pulse

subPulseState subpulseStates[NUMB_LED]; // Number of subpulses in pulse that have been looped through
uint16_t subpulseTimeCounts[NUMB_LED]; // Time in seconds since start of high phase of subpulse or low phase of subpulse

void LED_init()
{
    for (uint8_t i = 0; i < NUMB_LED; i++)
    {
        // Load calibration values from static memory
        calibrationValues[i][0] = EEPROM.read(i * 2);
        calibrationValues[i][1] = EEPROM.read(i * 2 + 1);

        // Initiate state machine
        pulseStates[i] = P_START;
        pulseCounts[i] = 0;
        pulseTimeCounts[i] = 0;

        subpulseStates[i] = SP_HIGH;
        subpulseTimeCounts[i] = 0;
    }
}

void LED_updateGetIntensity(uint8_t index, uint16_t *intensity1_p, uint16_t *intensity2_p)
{
    pulseTimeCounts[index]++;
    *intensity1_p = 0;
    *intensity2_p = 0;

    switch (pulseStates[index])
    {
    case P_START:
        if(pulseTimeCounts[index] >= pgm_read_byte_near(pusleStartTimes[index])) {
            pulseStates[index] = P_HIGH;
            pulseTimeCounts[index] = 0;

            subpulseStates[index] = SP_HIGH;
            subpulseTimeCounts[index] = 0;
            *intensity1_p = getIntensity(index, 1);
            *intensity2_p = getIntensity(index, 2);
        }
    break;

    case P_HIGH:
        if(pulseTimeCounts[index] >= pgm_read_byte_near(pulseHighTimes[index])) {
            pulseStates[index] = P_LOW;
            pulseTimeCounts[index] = 0;
        }
        else {
            subpulseTimeCounts[index]++;
            switch (subpulseStates[index])
            {
            case SP_HIGH:
                if(subpulseTimeCounts[index] >= pgm_read_byte_near(subpulseHighTimes[index])) {
                    subpulseStates[index] = SP_LOW;
                    subpulseTimeCounts[index] = 0;
                } else {
                    *intensity1_p = getIntensity(index, 1);
                    *intensity2_p = getIntensity(index, 2);
                } 
                break;
            case SP_LOW:
                if(subpulseTimeCounts[index] >= pgm_read_byte_near(subpulseLowTimes[index])) {
                    subpulseStates[index] = SP_HIGH;
                    subpulseTimeCounts[index] = 0;
                    *intensity1_p = getIntensity(index, 1);
                    *intensity2_p = getIntensity(index, 2);
                }
            break;
            }
        }
    break;

    case P_LOW:
    if(pulseTimeCounts[index] >= pgm_read_byte_near(pulseLowTimes[index])) {
        pulseCounts[index]++;
        pulseTimeCounts[index] = 0;
        if(pulseCounts[index]>= pgm_read_byte_near(pulseNumbs[index])) {
            pulseStates[index] = DONE;
        } else {
            pulseStates[index] = P_HIGH;
            subpulseStates[index] = SP_HIGH;
            subpulseTimeCounts[index] = 0;

            *intensity1_p = getIntensity(index, 1);
            *intensity2_p = getIntensity(index, 2);
        }
    }
    break;

    case DONE:
    break;
    }
}

uint16_t
getIntensity(uint8_t index, uint8_t indexLED)
{
    return (uint16_t)((pgm_read_byte_near(&(amplitudes[index])) / 16.0) * calibrationValues[index][indexLED]);
}