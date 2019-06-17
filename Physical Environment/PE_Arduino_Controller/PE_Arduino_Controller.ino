#include <Adafruit_GFX.h>    // Core graphics library
#include <Adafruit_TFTLCD.h> // Hardware-specific library
#include <TouchScreen.h> // library for touchscreen
//#include "pitches.h"

#if defined(__SAM3X8E__)
    #undef __FlashStringHelper::F(string_literal)
    #define F(string_literal) string_literal
#endif

#define LCDWidth 160  //define screen width,height
#define LCDHeight 128
#define _Digole_Serial_UART_  //To tell compiler compile the special communication only, 
//#define TOUCH_SCEEN   //if the module equipt with touch screen, use this, otherwise use // to disable it
//#define FLASH_CHIP    //if the module equipt with 2MB or 4MB flash chip, use it, otherwise  use // to disable it
#define Ver 34           //if the version of firmware on display is V3.3 and newer, use this
//all available are:_Digole_Serial_UART_, _Digole_Serial_I2C_ and _Digole_Serial_SPI_
//#define MONO  //if the screen panel is monochrome

//define draw window
#define DW_X 5
#define DW_Y 8
#define DW_W (LCDWidth - 10)
#define DW_H (LCDHeight - 15)
#ifdef MONO
#define COLORRG 2
#define BGCOLOR 1
#else
#define BGCOLOR 256
#define COLORRG 256
#endif

#define basex 25
#define basey 25
#define R 20

#include <DigoleSerial.h>
//--------UART setup
#if defined(_Digole_Serial_UART_)
DigoleSerialDisp mydisp(&Serial1, 9600); //UART:Arduino UNO: Pin 1(TX)on arduino to RX on module
#endif

#include <stdint.h>

//// Assign human-readable names to some common 16-bit color values:
#define BLACK   0x00  //0x0000
#define BLUE    0x00  //0x001F  
#define RED     0xC8  //0xF800
#define GREEN   0x08  //0x07E0  
#define CYAN    0x07  //0x07FF
#define MAGENTA 0xF8  //0xF81F
#define YELLOW  0xFD  //FFE0
#define WHITE   0xFF  //0xFFFF


#include <SPI.h>
#include <Wire.h>

//*****
//CHANGE THIS CHAR FOR EACH ARDUINO
char target_num = '6';

//display functions

void grid_green()
{
  mydisp.setColor(GREEN);
int y=1;
for (int x =1; x<=240; x=x+10)
{
  mydisp.drawVLine(x,1,320);
  mydisp.drawHLine(1,y,240);
  y = y + 15;
}
  mydisp.setColor(WHITE);
  mydisp.drawCircle(120,160,15,1);
}

void grid_yellow()
{
  mydisp.setColor(YELLOW);
int y=1;
for (int x =1; x<=240; x=x+10)
{
  mydisp.drawVLine(x,1,320);
  mydisp.drawHLine(1,y,240);
  y = y + 15;
}
  mydisp.setColor(WHITE);
  mydisp.drawCircle(120,160,15,1);
}

void grid_red()
{
  mydisp.setColor(RED);
int y=1;
for (int x =1; x<=240; x=x+10)
{
  mydisp.drawVLine(x,1,320);
  mydisp.drawHLine(1,y,240);
  y = y + 15;
}
  mydisp.setColor(WHITE);
  mydisp.drawCircle(120,160,15,1);
}

//touch setup
int PENIRQ = 2;
int touch_state;

void setup()
{
 //serial setup
  Serial.begin(9600);
 // Serial.setTimeout(5); 

  //PIN SETUP
  pinMode(PENIRQ, INPUT);

  //display setup
  mydisp.begin(); //initiate serial port
  mydisp.setRotation(0);
  mydisp.setPrintPos(0,0,0);
  mydisp.clearScreen();  
  mydisp.setLinePattern(255); //set the line patter, 255 is regular line
  mydisp.setBgColor(0); //set another back ground color

}


//setup variables for trial timing
double start_time = 0;
double target_time = 10000;
double end_time = 0;
double touch_time = 0;
double time_remaining = 0;
double check_time = 0;
char current_color = '0';
bool test_complete = false;

void loop() //want to listen for data and color the screen accordingly
{
  bool timeout_reset = false;
  char current_color;
  //SERIAL IS FOR COMM THROUGH XBEE
  //MATLAB SHOULD BE SENDING STRINGS CONTINUOSLY AS IT READS THE COP
  while (Serial.available()>0 && timeout_reset == false){ //wait for serial input
    //Declarations  didn't use all of these, some were from testing 
    bool activate=true;
    bool point=true;
    bool touched=false;
    bool restart = false;
    bool quit = false;
    bool acknowledged = false;
   
    char out_data[]={' ',' ',' '};
    byte byte_count;
    int x_point;
    int y_point;

    //reading in serial data
    char buffer[] = {' ',' ',' ',' ',' ',' ',' '}; // Receive up to 7 bytes
    byte_count = Serial.readBytesUntil('\n', buffer, 5); //7
    char a[] = {' ',' ',' ',' ',' ',' ',' '};



    
    for (int x=0 ; x < 5; x++)
    {
     a[x]= buffer[x];
    }
    
    //processing serial data
    char slave = a[0];
    char timing = a[1]; //1 = start timing //0 = continue //2 == reset // 3 = matlab ack
    char color = a[2]; //green=1, yellow=2, red=3
    char motor = a[3];
  
    //CHANGE SLAVE NUM FOR EACH ARDUINO
    if (slave == target_num){ //make sure data was sent to this arduino
  
     if (timing == '1'){ 
      start_time = millis();
      start_time = start_time/1000;
      test_complete = false;
      acknowledged = false; 
     }
     
     else if (test_complete) {
      break;
     }
     
     else if (timing == '0'){
      check_time = millis();
      check_time = check_time/1000;
      double diff = check_time - start_time;
      if (diff >= 10){ // if the target has been active for 10 sec time is up
        //TEST
        //Serial.println("TIMEOUT...");
  
        //SENDING timeout signal
        Serial.print('t'); //target
        Serial.print(target_num);
        Serial.print(',');
        Serial.print('f'); //failed to touch
        Serial.println('1');

        mydisp.clearScreen();
        mydisp.setColor(RED);
        mydisp.drawBox(0,0,240,320);
        mydisp.clearScreen();
      
        timeout_reset = true;
        test_complete = true;
        break;
      }
     }
     

    if (color == '1'){ //want to set display to show green target and listen for touch event
      if (current_color != color)
      {
        current_color = color;
        grid_green();
      }
  
      //want to listen for a touch only while the newest serial data is indicating green
     //want to go back to start of loop when new data is received or a touch is read
      while (quit == false && !Serial.available()){
       int x_pos = 0;
       int y_pos = 0;     
       touch_state = digitalRead(PENIRQ);
       if (touch_state == LOW) { 
     
        mydisp.readTouchScreen(&x_pos,&y_pos);
        
        //timing for score   
        end_time = millis();
        end_time = end_time/1000;
        touch_time = end_time - start_time;
        time_remaining = 10 - touch_time;
        //ADD SCORE CALCULATION HERE !!!!
       // long target_score = calculate_score(p.x,p.y,time_remaining);
       
         double x_center = 120; //240 across
         double y_center = 160; //320 across
         double x_distance = abs(x_pos - x_center);
         double y_distance = abs(y_pos - y_center);
         double distance = sqrt(x_distance*x_distance + y_distance*y_distance);
         double hypotenuse = 200;
         double acc_score = abs((distance/hypotenuse)*10-10);
         double target_score = time_remaining + acc_score;   
         
     
  //TESTING: PRINTING VARIABLES TO CHECK CALCULATION
  //      Serial.println("----------------------");
  //      Serial.print("x position: ");
  //      Serial.println(x_pos);
  //      Serial.print("y position: ");
  //      Serial.println(y_pos);
  //      Serial.print("x distance: ");
  //      Serial.println(x_distance);
  //      Serial.print("y distance: ");
  //      Serial.println(y_distance);      
  //      Serial.print("distance: ");
  //      Serial.println(distance);
  //      Serial.print("accuracy score: ");
  //      Serial.println(acc_score);
  //      Serial.print("target score: ");
  //      Serial.println(target_score);
  //      Serial.print("touch time: ");
  //      Serial.println(touch_time);      
  //      Serial.print("time remaining: ");
  //      Serial.println(time_remaining);
  
       while (!acknowledged) {      
         //SENDING THE SCORE
          Serial.print('t'); //target
          Serial.print(target_num);
          Serial.print(',');
          Serial.print('f'); //failed to touch
          Serial.print('0');
          Serial.print(',');
          Serial.print('s'); //score
          Serial.print(target_score);
          Serial.print(',');
          //SENDING EXTRA DATA FOR ANALYSIS
          Serial.print('r'); //remaining time
          Serial.print(time_remaining);
          Serial.print(',');
          Serial.print('x'); //x distance  
          Serial.print(x_distance);
          Serial.print(',');
          Serial.print('y'); //y distance
          Serial.print(y_distance);
          Serial.print(',');
          Serial.print('a'); //accuracy score
          Serial.println(acc_score);
          delay(500);
          // Wait for matlab ACK
          if (Serial.available() > 0) {
            Serial.readBytesUntil('\n', buffer, 5);
            if ((buffer[0] == target_num) && (buffer[1] == 3)){
              acknowledged = true;
            }
          } else {
            delay(500);
          }
       }
       acknowledged = false;

  
  //TESTING: SENDING THE TOUCH COORDINATES
  //      Serial.print('t');
  //      Serial.print(target_num);
  //      Serial.print('x');
  //      Serial.print(p.x);
  //      Serial.print('y');
  //      Serial.println(p.y);
        
    mydisp.clearScreen();
    mydisp.setColor(GREEN);
    mydisp.drawBox(0,0,240,3200);
    mydisp.clearScreen();
        
        quit = true;
       }
     }
     
  
     }
       
     //just display yellow target when yellow received; no touch data
     else if (color == '2'){
       if (current_color != color)
      {
        current_color = color;
        grid_yellow();
      }
     }
     
     //just display red target when red received; no touch data
     else if (color == '3'){
       if (current_color != color)
       {
        current_color = color;
        grid_red();
       }
     }
    }
  }
}


