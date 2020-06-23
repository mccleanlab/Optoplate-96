#include <Arduino.h>
#include "experiment_config.h"
#include "LED.h"
#include "TLC5947_optoPlate.h"

//define number of LED drivers and assign microcontroller

#define NUM_TLC5947 12
#define DATA_PIN 4
#define CLK_PIN 5
#define LATCH_PIN 6
#define OUTPUT_EN 7

Adafruit_TLC5947 tlc = Adafruit_TLC5947(NUM_TLC5947, CLK_PIN, DATA_PIN, LATCH_PIN); //creates LED driver object

bool needLedSetup = false;

// Wrights the intensities to a buffer in tlc, to flash the values to the LEDs tlc.wright must be called 
void setLED(uint8_t led, uint16_t well, uint16_t intensity)
{
  if (led == 0)
  {
    tlc.setPWM((uint16_t)((int)(well / 12) + 8 * (well % 12)), intensity);
  }
  else if (led == 1)
  {
    tlc.setPWM((uint16_t)(well + 192), intensity);
  }
  else if (led == 2)
  {
    tlc.setPWM((uint16_t)((int)(well / 12) + 8 * (well % 12) + 96), intensity);
  }
}

// True every second
bool newSecond = false;

void init1HzTimer()
{
  //Set up 1hz interrupt timer
  cli(); //stop interrupts
  //set timer1 interrupt at 1Hz
  TCCR1A = 0; // set entire TCCR1A register to 0
  TCCR1B = 0; // same for TCCR1B
  TCNT1 = 0;  //initialize counter value to 0
  // set compare match register for 1hz increments
  OCR1A = 15624; // = (16*10^6) / (1*1024) - 1 (must be <65536)
  // turn on CTC mode
  TCCR1B |= (1 << WGM12);
  // Set CS10 and CS12 bits for 1024 prescaler
  TCCR1B |= (1 << CS12) | (1 << CS10);
  // enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);
  sei();
}

ISR(TIMER1_COMPA_vect)
{
  newSecond = true;
}

void setup()
{
  // Set up LED state machine
  LED_init();
  
  Serial.begin(9600);

  tlc.begin();

  delay(100);

  // Turn off all LEDs
  for (uint16_t i = 0; i < NUMB_WELLS; i++)
  {
#if NUMB_WELL_LEDS < 3
    setLED(0, i, 0);
    setLED(1, i, 0);
#endif
#if NUMB_WELL_LEDS == 3
    setLED(0, i, 0);
    setLED(1, i, 0);
    setLED(2, i, 0);
#endif
  }

  if (OUTPUT_EN >= 0)
  {
    pinMode(OUTPUT_EN, OUTPUT);
    digitalWrite(OUTPUT_EN, HIGH);
  }
  tlc.write();
  init1HzTimer();
}

void loop()
{

  if (newSecond)
  {
    // Set new values on LEDs
    tlc.write();
    needLedSetup = true;
    newSecond = false;
  }
  else if (needLedSetup)
  {
    // Run the state machine for all the LED and prepare the new intensities to be flashed in the new second
    needLedSetup = false;

    for (uint8_t i = 0; i < NUMB_WELLS; i++)
    {

#if NUMB_WELL_LEDS == 1
      // When only 1 color of LED is used the two LED in a well share the same LED state machine
      uint8_t intensity = LED_updateGetIntensity(0, i);
      setLED(0, i, calibrateIntensity(0, i, intensity));
      setLED(1, i, calibrateIntensity(1, i, intensity));

#endif
#if NUMB_WELL_LEDS == 2
      // When multiple colors of LED are used they get their own state machine
      uint8_t intensity = LED_updateGetIntensity(0, i);
      setLED(0, i, calibrateIntensity(0, i, intensity));
      intensity = LED_updateGetIntensity(1, i);
      setLED(1, i, calibrateIntensity(1, i, intensity));
#endif
#if NUMB_WELL_LEDS == 3
      uint8_t intensity = LED_updateGetIntensity(0, i);
      setLED(0, i, calibrateIntensity(0, i, intensity));
      intensity = LED_updateGetIntensity(1, i);
      setLED(1, i, calibrateIntensity(1, i, intensity));
      intensity = LED_updateGetIntensity(2, i);
      setLED(2, i, calibrateIntensity(2, i, intensity));
#endif
    }
  }
}
