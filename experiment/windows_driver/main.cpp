#include <Windows.h>
#include <stdio.h>
#include <string.h>
#include "TinyFrame.h"
#include "utilities/utils.h"


void initSerial(HANDLE & hComm, char * ComPortName);
void readSerial(HANDLE & hComm, char data[255], int & dLength);
void sendSerial(HANDLE  & hComm, char data[255], int dLength);
void closeSerial(HANDLE & hComm);


HANDLE hComm;                          // Handle to the Serial port
/*
	int main(void)
		{
			HANDLE hComm;                          // Handle to the Serial port
      char * portName = "COM5";
      initSerial(hComm, portName);

      char data[255];

      int dLength = 0;
      char text[] = "Hemmelig melding!";
      for(int i = 0; i < 10; i++) {
        sendSerial(hComm, text, sizeof(text));
        readSerial(hComm, data, dLength);
        for(int j = 0; j < dLength; j++) {
          printf("\n recived: %c ", data[j]);
        }
      }
     closeSerial(hComm);
      return 0;
		}//End of Main()
*/

TinyFrame *demo_tf;
bool stopReading;
bool do_corrupt = false;

/**
 * This function should be defined in the application code.
 * It implements the lowest layer - sending bytes to UART (or other)
 */
void TF_WriteImpl(TinyFrame *tf, const uint8_t *buff, uint32_t len)
{
  sendSerial(hComm, (char * ) buff, (int) len);
}

/** An example listener function */
TF_Result myListener(TinyFrame *tf, TF_Msg *msg)
{
    dumpFrameInfo(msg);
    return TF_STAY;
}

TF_Result testIdListener(TinyFrame *tf, TF_Msg *msg)
{
    printf("OK - ID Listener triggered for msg!\n");
    dumpFrameInfo(msg);
    stopReading = true;
    return TF_CLOSE;
}



int main(void)
{
    TF_Msg msg;
    char * portName = "COM5";
    stopReading = false;
    char data[255];
    int dLength = 0;
    initSerial(hComm, portName);
    const char *longstr = "Lorem ipsum dolor sit amet.";

    // Set up the TinyFrame library
    demo_tf  = TF_Init(TF_MASTER); // 1 = master, 0 = slave
    TF_AddGenericListener(demo_tf, myListener);

    TF_ClearMsg(&msg);
    msg.type = 0x22;
    msg.data = (pu8) "A";
    msg.len = 1;
    TF_Send(demo_tf, &msg);
    readSerial(hComm, data, dLength);
    TF_Accept(demo_tf, (uint8_t *)data, dLength);
    
/*
    msg.type = 0x33;
    msg.data = (pu8) longstr;
    msg.len = (TF_LEN) (strlen(longstr) + 1); // add the null byte
    TF_Send(demo_tf, &msg);

    readSerial(hComm, data, dLength);
    TF_Accept(demo_tf, (uint8_t *)data, dLength);


    msg.type = 0x44;
    msg.data = (pu8) "Hello2";
    msg.len = 7;
    TF_Send(demo_tf, &msg);

    readSerial(hComm, data, dLength);
    TF_Accept(demo_tf, (uint8_t *)data, dLength);

    msg.len = 0;
    msg.type = 0x77;
    TF_Query(demo_tf, &msg, testIdListener, 0);

    readSerial(hComm, data, dLength);
    TF_Accept(demo_tf, (uint8_t *)data, dLength);
    
    printf("This should fail:\n");
    
    // test checksums are tested
    do_corrupt = true;    
    msg.type = 0x44;
    msg.data = (pu8) "Hello2";
    msg.len = 7;
    TF_Send(demo_tf, &msg);

    readSerial(hComm, data, dLength);
    TF_Accept(demo_tf, (uint8_t *)data, dLength);
*/
    closeSerial(hComm);
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


void initSerial(HANDLE & hComm, char * ComPortName) {
			BOOL  Status;                          // Status of the various operations 
		
			hComm = CreateFile( ComPortName,                  // Name of the Port to be Opened
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