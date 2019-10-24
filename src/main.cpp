#include <Arduino.h>
#include "TLC5947_optoPlate.h"
#include "LED.h"

#define NUM_LEDS 96


//DO NOT CHANGE 
//define number of LED drivers and assign microcontroller
const uint8_t NUM_TLC5974 = 12; 
const uint8_t data  = 4;
const uint8_t clock = 5;
const uint8_t latch = 6;
const uint8_t oe  = 7;  // set to -1 to not use the enable pin (its optional)

//DO NOT CHANGE
const int chanNum = 24*NUM_TLC5974; //number of channels
Adafruit_TLC5947 tlc = Adafruit_TLC5947(NUM_TLC5974, clock, data, latch); //creates LED driver object

bool needLEDSetup = false;

uint8_t l1[] = {1, 2, 3, 4, 5};
uint16_t l2[] = {1, 2, 3, 4, 5};

LED leds[] = {LED(l1, l2)}; 



void setBlue1(uint16_t well, uint16_t bright){
  uint16_t blue1Position = (uint16_t)((int)(well/12) + 8*(well%12));
  tlc.setPWM(blue1Position, (uint16_t)((bright)*float(3300.0000/4095.0000)));   //Set Blue
  Serial.println((uint16_t)((bright)*float(3300.0000/4095.0000)));
}

void setBlue2(uint16_t well, uint16_t *bright){
  uint16_t blue2Position = (uint16_t)(well+192);
  tlc.setPWM(blue2Position, *(bright));   //Set Far-red
}

void setBlue3_oldRed(uint16_t well, uint16_t *bright){
  uint16_t blue3Position = (uint16_t)((int)(well/12) + 8*(well%12)+96);
  tlc.setPWM(blue3Position, (uint16_t)((*bright)*float(3300.0000/4095.0000)));   //Set Red
}

bool newSecond = false;

ISR(TIMER1_COMPA_vect){
  newSecond = true;
}


void setup() {
  Serial.begin(9600);
  tlc.begin();


//Set up 1s interrupt timer
  cli();//stop interrupts

  //set timer1 interrupt at 1Hz
  TCCR1A = 0;// set entire TCCR1A register to 0
  TCCR1B = 0;// same for TCCR1B
  TCNT1  = 0;//initialize counter value to 0
  // set compare match register for 1hz increments
  OCR1A = 15624;// = (16*10^6) / (1*1024) - 1 (must be <65536)
  // turn on CTC mode
  TCCR1B |= (1 << WGM12);
  // Set CS10 and CS12 bits for 1024 prescaler
  TCCR1B |= (1 << CS12) | (1 << CS10);  
  // enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);

  sei();

}

void loop() {
  if(newSecond) {
    tlc.write();
    needLEDSetup = true;
  } else if(needLEDSetup) {
    needLEDSetup = false;
    for(uint8_t i = 0; i < NUM_LEDS; i++) {
      uint8_t intensity = 0;
      if(leds[i].updateGetIntensity(intensity)) {
        setBlue1(i, (uint16_t)intensity);
      }
      
    }
  }
}