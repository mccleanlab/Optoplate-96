#include "LED.h"

LED::LED(uint8_t * intensities_p, uint16_t * time_intervals_p) {
    intensities = intensities_p;
    timeIntervals = time_intervals_p;
    phase = 0;
    phaseTime = 0;
}

bool 
LED::updateGetIntensity(uint8_t & intensity_p) {
    if(++phaseTime >= timeIntervals[phase]) {
        phaseTime = 0;
        phase++;
        if(phase > NUM_PHASES) {
            phase = 0;
        }
        intensity_p = intensities[phase];
        return true;
    } else {
        return false;
    }
}

