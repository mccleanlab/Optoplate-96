#include "LED.h"

LED::LED(   const uint8_t * intensities_p, const uint8_t * periods_p, 
            const uint16_t * offset_p, const uint16_t * tInterpulse_p,
            const uint16_t * tPulse_p,
            const uint8_t phasesNumb_p, 
            uint8_t caliNumb1_p, uint8_t caliNumb2_p) {
    intensities = intensities_p;
    periods = periods_p;
    offset = offset_p;
    tInterpulse = tInterpulse_p;
    tPulse = tPulse_p;

    phase = 0;
    phaseTime = 0;
    state = OFFSET;
    periodCount = 0;
    phasesNumb = phasesNumb_p;
    caliNumb1 = caliNumb1_p;
    caliNumb2 = caliNumb2_p;
}

void 
LED::updateGetIntensity(uint8_t & intensity1_p, uint8_t & intensity2_p) {
    phaseTime++;
    switch (state)
    {
    case OFFSET:
        Serial.println("Offset");
        if(phaseTime >= pgm_read_word_near(&(offset[phase]))) {
            state = LED_HIGH;
            intensity1_p = getIntensity(1);
            intensity2_p = getIntensity(2);
            phaseTime = 0;
        } else {
            intensity1_p = 0;
            intensity2_p = 0;
        }
        break;
    case LED_HIGH:
        Serial.println("Led High");
        if(phaseTime >= pgm_read_word_near(&(tPulse[phase]))) {
            state = LED_LOW;
            phaseTime = 0;
        } else {
            intensity1_p = getIntensity(1);
            intensity2_p = getIntensity(2);
        }
        break;
    case LED_LOW:
        Serial.println("Led low");
         if(phaseTime >= pgm_read_word_near(&(tInterpulse[phase]))) {
             periodCount++;
             phaseTime = 0;
             if(periodCount >= pgm_read_byte_near(&(periods[phase]))) {
                 phase++;
                 if(phase >= phasesNumb) {
                    state = DONE;
                 } else {
                    state = OFFSET;
                    periodCount = 0;
                 }
                 intensity1_p = 0;
                 intensity2_p = 0;
             } else {
                state = LED_HIGH;
                intensity1_p = getIntensity(1);
                intensity2_p = getIntensity(2);
             }
        } else {
            intensity1_p = 0;
            intensity2_p = 0;
        }
        break;
    case DONE:
        Serial.println("Led Done");
        intensity1_p = 0;
        intensity2_p = 0;
        break;
    
    default:
        break;
    }
}


uint8_t LED::getIntensity(uint8_t LEDindex) {
    if(LEDindex == 1) {
        return (uint8_t) (pgm_read_byte_near(&(intensities[phase]))/256.0*caliNumb1);
    } else {
        return (uint8_t) (pgm_read_byte_near(&(intensities[phase]))/256.0*caliNumb2);
    }
}

