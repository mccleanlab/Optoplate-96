#include "LED.h"

// Outputs a value from 0 to 4095, indicating the LED intensity adjusted with calibration value
uint16_t getIntensity(uint8_t index, uint8_t indexLED);

uint8_t phase[NUMB_LED];
uint16_t phaseTime[NUMB_LED];
uint8_t caliNumb[NUMB_LED][2];
uint8_t periodCount[NUMB_LED];
LEDstate state[NUMB_LED];

void LEDinit()
{
    for (uint8_t i = 0; i < NUMB_LED; i++)
    {
        phase[i] = 0;
        phaseTime[i] = 0;
        caliNumb[i][0] = EEPROM.read(i * 2);
        caliNumb[i][1] = EEPROM.read(i * 2 + 1);
        periodCount[i] = 0;

        state[i] = OFFSET;
    }
}

void LEDupdateGetIntensity(uint8_t index, uint16_t *intensity1_p, uint16_t *intensity2_p)
{
    phaseTime[index]++;
    switch (state[index])
    {
    case OFFSET:

        Serial.println("Offset");
        if (phaseTime[index] >= pgm_read_word_near(&(offset[index][phase[index]])))
        {
            state[index] = LED_HIGH;
            *intensity1_p = getIntensity(index, 0);
            *intensity2_p = getIntensity(index, 1);
            phaseTime[index] = 0;
        }
        else
        {
            *intensity1_p = 0;
            *intensity2_p = 0;
        }
        break;
    case LED_HIGH:
        Serial.println("Led High");
        if (phaseTime[index] >= pgm_read_word_near(&(tPulse[index][phase[index]])))
        {
            state[index] = LED_LOW;
            phaseTime[index] = 0;
        }
        else
        {
            *intensity1_p = getIntensity(index, 0);
            *intensity2_p = getIntensity(index, 1);
        }
        break;
    case LED_LOW:
        Serial.println("Led low");
        if (phaseTime[index] >= pgm_read_word_near(&(tInterpulse[index][phase[index]])))
        {
            periodCount[index]++;
            phaseTime[index] = 0;
            if (periodCount[index] >= pgm_read_byte_near(&(periods[index][phase[index]])))
            {
                phase[index]++;
                if (phase[index] >= PHASE_NUMB)
                {
                    state[index] = DONE;
                }
                else
                {
                    state[index] = OFFSET;
                    periodCount[index] = 0;
                }
                *intensity1_p = 0;
                *intensity2_p = 0;
            }
            else
            {
                state[index] = LED_HIGH;
                *intensity1_p = getIntensity(index, 0);
                *intensity2_p = getIntensity(index, 1);
            }
        }
        else
        {
            *intensity1_p = 0;
            *intensity2_p = 0;
        }
        break;
    case DONE:
        Serial.println("Led Done");
        *intensity1_p = 0;
        *intensity2_p = 0;
        break;

    default:
        break;
    }
}

uint16_t
getIntensity(uint8_t index, uint8_t indexLED)
{
    return (uint16_t)((pgm_read_byte_near(&(intensities[index][phase[index]])) / 16.0) * caliNumb[index][indexLED]);
}