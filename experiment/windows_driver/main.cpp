#include <Windows.h>
#include "OptoPlate.h"

int main() {
  const char * portName = "COM5";
  OptoPlateInit(portName);

  OptoPlateDisableLED(23);
  Sleep(1000);
  OptoPlateEnableLED(23);
  Sleep(1000);

  OptoPlateDisconnect();
  return 0;
}
