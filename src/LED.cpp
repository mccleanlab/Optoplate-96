#include "LED.h"

LED::LED(uint8_t * intensities, uint16_t * time_intervals) {
    _intensities = intensities;
    _time_intervals = time_intervals;
    _phase = 0;
    _phase_time = 0;
}

bool 
LED::update_get_intensity(uint8_t & intensity) {
    if(++_phase_time >= _time_intervals[_phase]) {
        _phase_time = 0;
        _phase++;
        if(_phase > NUM_PHASES) {
            _phase = 0;
        }
        intensity = _intensities[_phase];
        return true;
    } else {
        return false;
    }
}