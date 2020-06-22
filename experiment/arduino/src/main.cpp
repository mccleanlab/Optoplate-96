#include <Arduino.h>
#include "experiment_config.h"
#include "LED.h"
#include "TLC5947_optoPlate.h"

//define number of LED drivers and assign microcontroller

#define NUM_TLC5974 12
#define DATA_PIN 4
#define CLK_PIN 5
#define LATCH_PIN 6
#define OUTPUT_EN 7 // set to -1 to not use the enable pin (its optional)

Adafruit_TLC5947 tlc = Adafruit_TLC5947(NUM_TLC5974, CLK_PIN, DATA_PIN, LATCH_PIN); //creates LED driver object

bool needLedSetup = false;

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
#ifdef MICRO
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
#endif
#ifdef NUCLEO
  //RCC->APB2ENR |= RCC_APB2ENR_IOPAEN | RCC_APB2ENR_IOPCEN;
  RCC->APB1ENR |= RCC_APB1ENR_TIM7EN; //(uint32_t)1 << 4;   //clock enable

  TIM7->DIER |= TIM_DIER_UIE; //int. enable
  TIM7->PSC = 0xFFFF;         //prescaler for TIM7. -> clk = 1Mz/2^16 = 2^4 =16Hz
  TIM7->ARR = 1;              // int. flag every sec.
  TIM7->CR1 |= TIM_CR1_CEN;

  NVIC_EnableIRQ(TIM7_IRQn); // Enable interrupt from TIM3 (NVIC level)
#endif
}

// Timer interrupt functions
#ifdef MICRO
ISR(TIMER1_COMPA_vect)
{
  newSecond = true;
}
#endif
#ifdef NUCLEO
void TIM7_DAC_IRQHandler(void)
{
  newSecond = true;
  TIM7->SR &= ~TIM_SR_UIF; //UIF (Interrupt flag) disabled
}
#endif
void setup()
{
  LED_init();

  Serial.begin(9600);

  tlc.begin();

  delay(100);

  // Trun off all LEDs
  for (uint16_t i = 0; i < NUMB_WELLS; i++)
  {
#if NUMB_WELL_LEDS < 3
    setLED(0, i, 50);
    setLED(1, i, 50);
#endif
#if NUMB_WELL_LEDS == 3
    setLED(0, i, 0);
    setLED(1, i, 0);
    setLED(2, i, 0);
#endif
  }

  // Turn off all LEDs
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
    Serial.println("Hei!");
    // Set new values on LEDs
    tlc.write();
    needLedSetup = true;
    newSecond = false;
  }
  else if (needLedSetup)
  {
    // Prepare values for next second
    needLedSetup = false;

    for (uint8_t i = 0; i < NUMB_WELLS; i++)
    {

#if NUMB_WELL_LEDS == 1
      uint8_t intensity = LED_updateGetIntensity(0, i);
      setLED(0, i, calibrateIntensity(0, i, intensity));
      setLED(1, i, calibrateIntensity(1, i, intensity));

#endif
#if NUMB_WELL_LEDS == 2
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
