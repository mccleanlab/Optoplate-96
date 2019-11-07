#ifndef _LED_H
#define _LED_H

#include <Arduino.h>

//Class for holding LED phase parameters
class LED {
    public:
    LED();
    LED(const uint8_t * intensities_p, const uint16_t * durations_p, const uint8_t phasesNumb_p, uint8_t caliNumb_p);
    //Increments LED phase time and retuns true if new phase and and updates intensity
    bool updateGetIntensity(uint8_t & intensity_p); 
    
    
    uint8_t getIntensity();

    private:
    const uint8_t * intensities;
    const uint16_t * durations;

    uint8_t phase;
    uint16_t phaseTime;
    uint8_t phasesNumb;
    uint8_t caliNumb;
};
#endif
