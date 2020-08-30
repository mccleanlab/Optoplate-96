
#include "OptoPlate.h"


HANDLE hComm; 

void sendSerial(HANDLE  & hComm, char data[255], int dLength);
void readSerial(HANDLE  & hComm, char data[255], int & dLength);
void closeSerial(HANDLE & hComm);
void initSerial(HANDLE & hComm, const char * ComPortName);

int OptoPlateConnect(int portNumber) {
	std::string portName = std::string("COM") + std::to_string(portNumber);
	initSerial(hComm, portName.c_str());
	return 1;
}

int OptoPlateConnectAuto() {

	std::string portName;

	TCHAR lpTargetPath[5000]; // buffer to store the path of the COMPORTS
	DWORD test;
	bool gotPort = 0; // in case the port is not found

	for (int i = 0; i < 50; i++) // checking ports from COM0 to COM255
	{
		std::string str = std::to_string(i);
		std::string ComName = std::string("COM") + str; // converting to COM0, COM1, COM2

		test = QueryDosDevice(ComName.c_str(), (LPSTR)lpTargetPath, 5000);

		// Test the return value and error if any
		if (test != 0) //QueryDosDevice returns zero if it didn't find an object
		{
			portName = ComName;
			gotPort = 1; // found port
		}
	}
	if (gotPort) {
		initSerial(hComm, portName.c_str());
	}
	else {
		printf("Error: unable to find COMport.");
	}
	return 1;
}


int OptoPlateDisconnect() {
    closeSerial(hComm);
	return 1;
}

int OptoPlateDisableLED(int LEDindex) {
	char buff = (char)LEDindex;
	sendSerial(hComm, &buff, 1);
	return 1;
}

int OptoPlateEnableLED(int LEDindex) {
	char buff = 1<<7 | (char)LEDindex;
	sendSerial(hComm, &buff, 1);
	return 1;
}

int getNISindex(int LEDindex) {
	int col = (LEDindex - 1) / 12;
	int row = (LEDindex -1 ) % 12;
	int NISLEDindex = 0;
	if (col % 2 == 0) {
		NISLEDindex = (col + 1) * 12 - row - 1;
	}
	else
	{
		NISLEDindex = LEDindex - 1;
	}
	return NISLEDindex;
}

int OptoPlateDisableLEDNIS(int LEDindex) {
	OptoPlateDisableLED(getNISindex(LEDindex));
	return 1;
}
int OptoPlateEnableLEDNIS(int LEDindex) {
	OptoPlateEnableLED(getNISindex(LEDindex));
	return 1;
}


void sendSerial(HANDLE  & hComm, char data[255], int dLength) {
    BOOL  Status;                          // Status of the various operations 
    DWORD dNoOFBytestoWrite = dLength;     // No of bytes to write into the port
    DWORD dNoOfBytesWritten = 0;     // No of bytes written to the port

    Status = WriteFile(hComm,        // Handle to the Serial port
                      data,     // Data to be written to the port
                      dNoOFBytestoWrite,  //No of bytes to write
                      &dNoOfBytesWritten, //Bytes written
                      NULL);

}

void readSerial(HANDLE  & hComm, char data[255], int & dLength) {
  
  DWORD dwEventMask;                     // Event mask to trigger
  BOOL  Status;                          // Status of the various operations 
  char  TempChar;                        // Temperory Character
  DWORD NoBytesRead;                     // Bytes read by ReadFile()
  int i = 0;
	
  Status = WaitCommEvent(hComm, &dwEventMask, NULL); //Wait for the character to be received
  if (Status == FALSE)
    {
      printf("\n    Error! in Setting WaitCommEvent()");
      dLength = 0;
    }
  else //If  WaitCommEvent()==True Read the RXed data using ReadFile();
    {
      do
        {
          Status = ReadFile(hComm, &TempChar, sizeof(TempChar), &NoBytesRead, NULL);
          data[i] = TempChar;
          i++;
        } 
      while (NoBytesRead > 0);  
      dLength = i;
    }	
}

void closeSerial(HANDLE & hComm) {
  CloseHandle(hComm);//Closing the Serial Port
}


void initSerial(HANDLE & hComm, const char * ComPortName) {
			BOOL  Status;                          // Status of the various operations 
		
			std::string ComPortNameModified = "\\\\.\\" + std::string(ComPortName);
			hComm = CreateFile(ComPortNameModified.c_str(),                  // Name of the Port to be Opened
		                        GENERIC_READ | GENERIC_WRITE, // Read/Write Access
								0,                            // No Sharing, ports cant be shared
								NULL,                         // No Security
							    OPEN_EXISTING,                // Open existing port only
		                        0,                            // Non Overlapped I/O
		                        NULL);                        // Null for Comm Devices

			if (hComm == INVALID_HANDLE_VALUE)
				printf("\n    Error! - Port %s can't be opened\n", ComPortName);
			else
				printf("\n    Port %s Opened\n ", ComPortName);
			
			DCB dcbSerialParams = { 0 };                         // Initializing DCB structure
			dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

			Status = GetCommState(hComm, &dcbSerialParams);      //retreives  the current settings

			if (Status == FALSE)
				printf("\n    Error! in GetCommState()");

			dcbSerialParams.BaudRate = CBR_115200;      // Setting BaudRate = 115200
			dcbSerialParams.ByteSize = 8;             // Setting ByteSize = 8
			dcbSerialParams.StopBits = ONESTOPBIT;    // Setting StopBits = 1
			dcbSerialParams.Parity = NOPARITY;        // Setting Parity = None 

			Status = SetCommState(hComm, &dcbSerialParams);  //Configuring the port according to settings in DCB 

			if (Status == FALSE)
				{
					printf("\n    Error! in Setting DCB Structure");
				}
			else //If Successfull display the contents of the DCB Structure
				{
					printf("\n\n    Setting DCB Structure Successfull\n");
					printf("\n       Baudrate = %d", dcbSerialParams.BaudRate);
					printf("\n       ByteSize = %d", dcbSerialParams.ByteSize);
					printf("\n       StopBits = %d", dcbSerialParams.StopBits);
					printf("\n       Parity   = %d", dcbSerialParams.Parity);
				}

			COMMTIMEOUTS timeouts = { 0 };
			timeouts.ReadIntervalTimeout         = 500;
			timeouts.ReadTotalTimeoutConstant    = 50;
			timeouts.ReadTotalTimeoutMultiplier  = 10;
			timeouts.WriteTotalTimeoutConstant   = 50;
			timeouts.WriteTotalTimeoutMultiplier = 10;
			
			if (SetCommTimeouts(hComm, &timeouts) == FALSE)
				printf("\n\n    Error! in Setting Time Outs");
			else
				printf("\n\n    Setting Serial Port Timeouts Successfull");

			
			Status = SetCommMask(hComm, EV_RXCHAR); //Configure Windows to Monitor the serial device for Character Reception
	
			if (Status == FALSE)
				printf("\n\n    Error! in Setting CommMask");
			else
				printf("\n\n    Setting CommMask successfull");

}