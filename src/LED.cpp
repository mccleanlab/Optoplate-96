#include "LED.h"

LED::LED(   const uint8_t * intensities_p, const uint8_t * periods_p, 
            const uint16_t * offset_p, const uint16_t * tInterpulse_p,
            const uint16_t * tPulse_p,
            const uint8_t phasesNumb_p) {
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
    caliNumb[0] = 255;
    caliNumb[1] = 255;
}

void
LED::setCalibrationValue(uint8_t caliLED1, uint8_t caliLED2) {
    caliNumb[0] = caliLED1;
    caliNumb[1] = caliLED2;
}

void 
LED::updateGetIntensity(uint8_t & intensity_p) {
    phaseTime++;
    switch (state)
    {
    case OFFSET:
        Serial.println("Offset");
        if(phaseTime >= pgm_read_word_near(&(offset[phase]))) {
            state = LED_HIGH;
            intensity_p = getIntensity(0);
            phaseTime = 0;
        } else {
            intensity_p = 0;
        }
        break;
    case LED_HIGH:
        Serial.println("Led High");
        if(phaseTime >= pgm_read_word_near(&(tPulse[phase]))) {
            state = LED_LOW;
            phaseTime = 0;
        } else {
            intensity_p = getIntensity(0);
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
                 intensity_p = 0;
             } else {
                 state = LED_HIGH;
                 intensity_p = getIntensity(0);
             }
        } else {
            intensity_p = 0;
        }
        break;
    case DONE:
        Serial.println("Led Done");
        intensity_p = 0;
        break;
    
    default:
        break;
    }
}


uint8_t 
LED::getIntensity(uint8_t indexLED) {
    return (uint8_t) ((pgm_read_byte_near(&(intensities[phase]))/256.0) * caliNumb[indexLED]);
}

