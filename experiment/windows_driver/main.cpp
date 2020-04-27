#include <Windows.h>
#include "OptoPlate.h"
#include <stdio.h>

int main() {
  int i  = 1;
  i = iterate(i);
  printf("Iteration: %i\n", i);
  const char * portName = "COM3";
  OptoPlateInit(portName);

  OptoPlateDisableLED(23);
  Sleep(1000);
  OptoPlateEnableLED(23);
  Sleep(1000);

  OptoPlateDisconnect();
  return 0;
}
