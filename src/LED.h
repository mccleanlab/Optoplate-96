#ifndef _LED_H
#define _LED_H

#include <Arduino.h>
#include "experiment_config.h"

//Class for holding LED step parameters
class LED {
 public:
    LED(uint8_t * intensities_p, uint16_t * timeIntervals_p);

    //Increments local time and retuns true if new phase with new intensity
    bool updateGetIntensity(uint8_t & intensity_p); 
private:
    uint8_t * intensities;
    uint16_t * timeIntervals;

    uint8_t phase;
    uint16_t phaseTime;
};


#endif
