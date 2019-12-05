#include <Arduino.h>
#include "TLC5947_optoPlate.h"
//#include "experiment_config.h"
#include "LED.h"
#include <EEPROM.h>

#define NUM_LEDS 96

//define number of LED drivers and assign microcontroller
#define NUM_TLC5974 12 
#define DATA_PIN 4
#define CLK_PIN 5
#define LATCH_PIN 6
#define OUTPUT_EN 7  // set to -1 to not use the enable pin (its optional)

//DO NOT CHANGE
const int chanNum = 24*NUM_TLC5974; //number of channels

Adafruit_TLC5947 tlc = Adafruit_TLC5947(NUM_TLC5974, CLK_PIN, DATA_PIN, LATCH_PIN); //creates LED driver object

bool needLEDSetup = false;

void setLED(uint16_t well, uint16_t bright){
  tlc.setPWM((uint16_t)((int)(well/12) + 8*(well%12)), bright*16); //Set Blue
  tlc.setPWM((uint16_t)(well+192), bright*16);                     //Set Blue1
}


bool newSecond = false;

ISR(TIMER1_COMPA_vect){
  newSecond = true;
}

LED leds;


void setup() {
  for(uint8_t i = 0; i < NUM_LEDS; i++) {
//    leds[i].init(intensities[i], periods[i], offset[i], tInterpulse[i], tPulse[i],  PHASE_NUMB);
  }
  Serial.begin(9600);

  tlc.begin();
  delay(100);

  for(uint8_t i = 0; i < NUM_LEDS; i++) {
    setLED(i, 0);
  }
  if (OUTPUT_EN >= 0) {
    pinMode(OUTPUT_EN, OUTPUT);
    digitalWrite(OUTPUT_EN, HIGH);
  }        
  tlc.write();

  //Set up 1hz interrupt timer
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
    newSecond = false;

  } else if(needLEDSetup) {
    needLEDSetup = false;
    for(uint8_t i = 0; i < NUM_LEDS; i++) {
      uint8_t intensity = 10;
//      leds[i].updateGetIntensity(intensity); 
      setLED(i, (uint16_t) intensity);     
    }
    Serial.println("Done");
     Serial.print("The size of LED: ");
  Serial.println((uint8_t) sizeof(LED));
  }
}
