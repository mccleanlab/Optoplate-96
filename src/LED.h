#ifndef _LED_H
#define _LED_H

#include <Arduino.h>
#include "experiment_config.h"

//Class for holding LED step parameters
class LED {
 public:
    LED(uint8_t * intensities, uint16_t * time_intervals);

    //Increments local time and retuns true if new phase with new intensity
    bool update_get_intensity(uint8_t & intensity); 
private:
    uint8_t * _intensities;
    uint16_t * _time_intervals;

    uint8_t _phase;
    uint16_t _phase_time;
};


#endif
