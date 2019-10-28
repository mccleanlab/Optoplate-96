#ifndef _TIMER_H
#define _TIMER_H

#include <Arduino.h>

class Timer{

public:
    Timer(void (*int_function)(), uint8_t hz);

private:
    void (*fcnPtr)();

};


#endif