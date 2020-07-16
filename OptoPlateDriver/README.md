# OptoPlate UART Driver 
This folder contains a driver written for use with the software NIS-elements AR. A custom driver can with ease be written for other purposes. '

## OptoPlate with NIS-elements AR
The diver can be imported into NIS micro. 

1. To enable NIS to import the driver copy the folder Optoplate-96/OptoPlateDiver/OptoPlate to the NIS installation folder most likely located in C:/Program Files/NIS-Elements. When this is done you should have the following file strucure: C:/Program Files/NIS-Elements/OptoPlate/OptoPlateDriver.dll
NIS Micros can now send commands to the OptoPlate. 
The following example of a micro turns off all the LEDs in well 15 (B3). 
Remember to always call OptoPlateConnect() before sending anything and always call OptoPlateDisconnect before ending the program.
OptoPlateDiable(int) and OptoPlateEnable(int) takes an integer from 0 to 95 as input parameter. The index 15 correspond to the well B3 and index 16 to B4 and so on.  
```
import("OptoPlate\OptoPlateDriver.dll");
import int OptoPlateConnect();
import int OptoPlateDisconnect();
import int OptoPlateDisableLED(int LEDindex);
import int OptoPlateEnableLED(int LEDindex);

int main() {
   OptoPlateConnect();
   OptoPlateDisableLED(15);
   OptoPlateDisconnect();
   return 1;
}
```
To change the index to be enable/diable while running a JOB module insert a Expression block. By opening the box you will get a list of all the variables used by the JOB module. The desired variable can then be used as parameter in the functions OptoPlateDiable(int) and OptoPlateEnable(int). A simple example is provided in Optoplate-96/OptoPlateDriver/example    

## Help on implementation of custom driver
The OptoPlate accepts 1 byte messages over the Arduino Serial (UART) connection to the computer. The most significant bit is the enable/disable bit, the remaning 7 bits are the 0-indexed index of the well. For instance, by sending 0b0000 0010 over Serial, well A3 will turn off and 0b1000 1100 will enable enable well B1
