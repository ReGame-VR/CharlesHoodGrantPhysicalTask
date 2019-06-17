
#if defined(__SAM3X8E__)
    #undef __FlashStringHelper::F(string_literal)
    #define F(string_literal) string_literal
#endif


////TEST STUFF ___________________
#include <SPI.h>
#include <Wire.h>

//TouchScreen ts = TouchScreen(XP, YP, XM, YM, 300);



void setup()
{
 //Use Serial for Xbee (due to shield) 
 //Use Serial1 (TX1 18, RX1 19) for MATLAB/computer
 
  Serial1.begin(9600);
  Serial.begin(9600);
  //Serial.println(F("START"));
  Serial.setTimeout(5);
  Serial1.setTimeout(5);  

}

void loop() //want to listen for data and color the screen accordingly
{
  
  //MATLAB SERIAL COMM
  //read from serial1, send to serial
  if (Serial1.available()>0)
  {

  char buffer[] = {' ',' ',' ',' ',' ',' ',' '}; // Receive up to 7 bytes

    Serial1.readBytesUntil('\n', buffer, 5); // 4 characters + newline
    
    char input[] = {' ',' ',' ',' ',' ',' ',' '};
    
    for (int x=0 ; x<=3; x++)
    {
     input[x]= buffer[x];
    }
    char slave = input[0];
    char _reset = input[1];
    char color = input[2]; //green=1, yellow=2, red=3
    char motor = input[3];
    
    Serial.print(slave);
    Serial.print(_reset);
    Serial.print(color);
    Serial.print(motor);
    Serial.print('\n');
  }

  //XBEE SERIAL COMM
  //Read serial, send to serial1
  if (Serial.available() > 0)
  {
    char slave_buffer[128] = {' '}; // Receive up to 129 bytes
    int bytes_read = Serial.readBytesUntil('\n', slave_buffer, 128);
    
    for (int x=0 ; x < bytes_read; x++)
    {
      Serial1.print(slave_buffer[x]);
    }
    Serial1.print('\n');
  }
}
  
