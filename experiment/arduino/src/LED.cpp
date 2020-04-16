#include "LED.h"

// Outputs a value from 0 to 4095, indicating the LED intensity adjusted with calibration value
uint16_t getIntensity(uint8_t index, uint8_t indexLED);

uint8_t calibrationValues[NUMB_LED][2];

pulseState pulseStates[NUMB_LED];
uint16_t pulseCounts[NUMB_LED];
uint16_t pulseTimeCounts[NUMB_LED];

subPulseState subPulseStates[NUMB_LED];
uint16_t subPulseTimeCounts[NUMB_LED];

void LEDinit()
{
    for (uint8_t i = 0; i < NUMB_LED; i++)
    {

        calibrationValues[i][0] = EEPROM.read(i * 2);
        calibrationValues[i][1] = EEPROM.read(i * 2 + 1);

        pulseStates[i] = P_START;
        pulseCounts[i] = 0;
        pulseTimeCounts[i] = 0;

        subPulseStates[i] = SP_HIGH;
        subPulseTimeCounts[i] = 0;
    }
}

void LEDupdateGetIntensity(uint8_t index, uint16_t *intensity1_p, uint16_t *intensity2_p)
{
    pulseTimeCounts[index]++;
    *intensity1_p = 0;
    *intensity2_p = 0;

    switch (pulseStates[index])
    {
    case P_START:
        if(pulseTimeCounts[index] >= pulseStartTimes[index]) {
            pulseStates[index] = P_HIGH;
            pulseTimeCounts[index] = 0;

            subPulseStates[index] = SP_HIGH;
            subPulseTimeCounts[index] = 0;
            *intensity1_p = getIntensity(index, 1);
            *intensity2_p = getIntensity(index, 2);
        }
    break;

    case P_HIGH:
        if(pulseTimeCounts[index] >= pulseHighTimes[index]) {
            pulseStates[index] = P_LOW;
            pulseTimeCounts[index] = 0;
        }
        else {
            subPulseTimeCounts[index]++;
            switch (subPulseStates[index])
            {
            case SP_HIGH:
                if(subPulseTimeCounts[index] >= subPulseHighTimes[index]) {
                    subPulseStates[index] = SP_LOW;
                    subPulseTimeCounts[index] = 0;
                } else {
                    *intensity1_p = getIntensity(index, 1);
                    *intensity2_p = getIntensity(index, 2);
                } 
                break;
            case SP_LOW:
                if(subPulseTimeCounts[index] >= subPulseLowTimes[index]) {
                    subPulseStates[index] = SP_HIGH;
                    subPulseTimeCounts[index] = 0;
                    *intensity1_p = getIntensity(index, 1);
                    *intensity2_p = getIntensity(index, 2);
                }
            break;
            }
        }
    break;

    case P_LOW:
    if(pulseTimeCounts[index] >= pulseLowTimes[index]) {
        pulseCounts[index]++;
        pulseTimeCounts[index] = 0;
        if(pulseCounts[index]>= pulseNumbers[index]) {
            pulseStates[index] = DONE;
        } else {
            pulseStates[index] = P_HIGH;
            subPulseStates[index] = SP_HIGH;
            subPulseTimeCounts[index] = 0;
            
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
    return (uint16_t)((pgm_read_byte_near(&(intensities[index])) / 16.0) * calibrationValues[index][indexLED]);
}