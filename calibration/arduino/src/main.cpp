#include <Arduino.h>
#include <EEPROM.h>
#include "calibration_config.h"

#define NUM_LEDS 96

void setup() {
  Serial.begin(9600);
  for(uint8_t i = 0; i < NUM_LEDS; i++) {
    EEPROM.write(i*2, calibration_data[i][0]);
    EEPROM.write(i*2+1, calibration_data[i][1]);
  }

delay(5000);
for(uint8_t i = 0; i < NUM_LEDS*2; i++) {
    Serial.println(EEPROM.read(i));
  }
}

void loop() {
  // put your main code here, to run repeatedly:
}