#include <Arduino.h>
#include "TinyFrame.h"

TinyFrame demo_tf_s;

#define demo_tf  &demo_tf_s

/**
 * This function should be defined in the application code.
 * It implements the lowest layer - sending bytes to UART (or other)
 */
void TF_WriteImpl(TinyFrame *tf, const uint8_t *buff, uint32_t len)
{
  Serial.write(buff, len);
}

/** An example listener function */
TF_Result myListener(TinyFrame *tf, TF_Msg *msgIn)
{   

    uint8_t data = msgIn->data[0] + 2;
    TF_Msg msg;
    TF_ClearMsg(&msg);
    msg.type = 0x22;
    msg.data = &data;
    msg.len = 1;
    TF_Send(demo_tf, &msg);
    return TF_STAY;
}


void setup() {
  TF_InitStatic(demo_tf, TF_SLAVE); // 1 = master, 0 = slave
  Serial.begin(115200);
  // Set up the TinyFrame library
  TF_AddGenericListener(demo_tf, myListener);
}

void loop() {
  
  while(Serial.available() > 0) {
    uint8_t rx_data = Serial.read();
    TF_AcceptChar(demo_tf, rx_data);
  }
  
}

