#include <Arduino.h>

#include "TLC5947_optoPlate.h"
#include "experiment_config.h"
#include "LedStateMachine.h"
#include "TinyFrame.h"
#include "TF_messages.h"

#define NUM_LEDS 96

// ------------------------------------------------------------------------
// Setting up LED driver

//define number of LED drivers and assign microcontroller
#define NUM_TLC5974 12
#define DATA_PIN 4
#define CLK_PIN 5
#define LATCH_PIN 6
#define OUTPUT_EN 7 // set to -1 to not use the enable pin (its optional)

//DO NOT CHANGE
const int chanNum = 24 * NUM_TLC5974; //number of channels

Adafruit_TLC5947 tlc = Adafruit_TLC5947(NUM_TLC5974, CLK_PIN, DATA_PIN, LATCH_PIN); //creates LED driver object

bool needLedSetup = false;

void setLED(uint16_t well, uint16_t intensity1, uint16_t intensity2)
{
  tlc.setPWM((uint16_t)((int)(well / 12) + 8 * (well % 12)), intensity1); //Set Blue
  tlc.setPWM((uint16_t)(well + 192), intensity2);                         //Set Blue1
}

// ------------------------------------------------------------------------
// Setting up robust serial communication using TinyFrame
TinyFrame tf_s;
#define tf  &tf_s


/** An example listener function */
TF_Result myListener(TinyFrame *tf_p, TF_Msg *msgIn)
{
    uint8_t data = msgIn->data[0] + 2;
    TF_Msg msg;
    TF_ClearMsg(&msg);
    msg.type = 0x22;
    msg.data = &data;
    msg.len = 1;
    TF_Send(tf, &msg);
    return TF_STAY;
}

TF_Result enableCmdHandler(TinyFrame *tf_p, TF_Msg *msgIn)
{
  uint8_t LEDindex = msgIn->data[0];
  LEDenable(LEDindex);
  tlc.write();
  return TF_STAY;
}

TF_Result disableCmdHandler(TinyFrame *tf_p, TF_Msg *msgIn)
{
  uint8_t LEDindex = msgIn->data[0];
  LEDdisable(LEDindex);
  tlc.write();
  return TF_STAY;
}

/**
 * This function should be defined in the application code.
 * It implements the lowest layer - sending bytes to UART (or other)
 */
void TF_WriteImpl(TinyFrame *tf_p, const uint8_t *buff, uint32_t len)
{
  Serial.write(buff, len);
}



// ------------------------------------------------------------------------

// True every second so that the LEDs will be flashed
bool newSecond = false;

// Interupt function that is called every second
ISR(TIMER1_COMPA_vect)
{
  newSecond = true;
}


void setup()
{

  LED_init();

  Serial.begin(115200);

  // Init the LED driver
  tlc.begin();
  delay(100);

  // Init TinyFrame
  TF_InitStatic(tf, TF_SLAVE);

  // Listen for incoming messages
  TF_AddTypeListener(tf, TF_ENABLE_CMD, enableCmdHandler);
  TF_AddTypeListener(tf, TF_DISABLE_CMD, disableCmdHandler);

  // Set all the LED intensity to zero
  for (uint8_t i = 0; i < NUM_LEDS; i++)
  {
    setLED(i, 0, 0);
  }
  if (OUTPUT_EN >= 0)
  {
    pinMode(OUTPUT_EN, OUTPUT);
    digitalWrite(OUTPUT_EN, HIGH);
  }
  tlc.write();

  //Set up 1hz interrupt timer
  cli(); // disable interrupts
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
  sei(); // enable interrupts
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
    // Prepare values for next second
    needLedSetup = false;
    for (uint8_t i = 0; i < NUM_LEDS; i++)
    {
      uint16_t intensity1 = 0;
      uint16_t intensity2 = 0;
      LED_updateGetIntensity(i, &intensity1, &intensity2);
      setLED(i, intensity1, intensity2);
    }
    tlc.write();
    newSecond = false;
  }
  // Read Serial and update the TinyFrame listener
  if(Serial.available() > 0) {
    uint8_t buff[32];
    uint8_t c  = 0;
    while(Serial.available() > 0) {
      buff[c] = Serial.read();
      c++;
      if(c > 32) break;
    }
    TF_Accept(tf, buff, c);
  }
}
