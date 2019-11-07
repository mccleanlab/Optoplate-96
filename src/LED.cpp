#include "LED.h"
LED::LED() {
    phase = 0;
    phaseTime = 0;
}


LED::LED(const uint8_t * intensities_p, const uint16_t * durations_p, const uint8_t phasesNumb_p, uint8_t caliNumb_p) {
    intensities = intensities_p;
    durations = durations_p;
    phase = 0;
    phaseTime = 0;
    phasesNumb = phasesNumb_p;
    caliNumb = caliNumb_p;
}

bool 
LED::updateGetIntensity(uint8_t & intensity_p) {
    phaseTime++;
    if(pgm_read_word_near(&durations[phase]) != 0 && phaseTime >= pgm_read_word_near(&durations[phase])) {
        phaseTime = 0;
        phase++;
        if(phase >= phasesNumb) {
            phase = 0;
        }
        intensity_p = (uint8_t) (pgm_read_byte_near(&intensities[phase])/256.0*caliNumb);
        return true;
    } else {
        intensity_p = 0;
        return false;
    }
}

uint8_t LED::getIntensity() {
    return (uint8_t) (pgm_read_byte_near(&intensities[phase])/256.0*caliNumb);
}

