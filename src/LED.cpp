#include "LED.h"

LED::LED(const uint8_t * intensities_p, const uint16_t * durations_p, const uint8_t phasesNumb_p) {
    intensities = intensities_p;
    durations = durations_p;
    phase = 0;
    phaseTime = 0;
    phasesNumb = phasesNumb_p;
}

bool 
LED::updateGetIntensity(uint8_t & intensity_p) {
    if(durations[phase] != 0 && ++phaseTime >= durations[phase]) {
        phaseTime = 0;
        phase++;
        if(phase > phasesNumb) {
            phase = 0;
        }
        intensity_p = intensities[phase];
        return true;
    } else {
        return false;
    }
}

