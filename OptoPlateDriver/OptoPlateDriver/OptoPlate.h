#if !defined(OPTOPLATE_H)
#define OPTOPLATE_H

#include <Windows.h>
#include <stdio.h>
#include <string>


#ifdef LUCIA_CALLBACK_EXPORTS
    #define LUCIA_CALLBACK_API __declspec(dllexport)
#else
    #define LUCIA_CALLBACK_API __declspec(dllimport)
#endif

extern "C" LUCIA_CALLBACK_API int OptoPlateConnect(int portNumber);
extern "C" LUCIA_CALLBACK_API int OptoPlateConnectAuto();
extern "C" LUCIA_CALLBACK_API int OptoPlateDisconnect();
extern "C" LUCIA_CALLBACK_API int OptoPlateDisableLED(int LEDindex);
extern "C" LUCIA_CALLBACK_API int OptoPlateEnableLED(int LEDindex);

extern "C" LUCIA_CALLBACK_API int OptoPlateDisableLEDNIS(int LEDindex);
extern "C" LUCIA_CALLBACK_API int OptoPlateEnableLEDNIS(int LEDindex);

#endif //OPTOPLATE_H