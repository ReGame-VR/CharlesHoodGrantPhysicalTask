//Written by Nicholas Sullo 1/29/2016 for use in the Regame VR lab for the physical environment task. Rewrite 2
// Some parts of code taken from: NeoPixel Ring simple sketch (c) 2013 Shae Erisson
// released under the GPLv3 license to match the rest of the AdaFruit NeoPixel library
// Everything is operational with this code, not optimized though.
// This code has the transfer task switching functionality

//#include <Wire.h> //Only needed for debugging with i2c

#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
  #include <avr/power.h>
#endif

// Which pin on the Arduino is connected to the NeoPixels?
// On a Trinket or Gemma we suggest changing this to 1
#define PIN            11

// How many NeoPixels are attached to the Arduino? There are 7 neopixels per jewel, for a total of 42 neopixels used in the physical environment
#define NUMPIXELS      42

// When we setup the NeoPixel library, we tell it how many pixels, and which pin to use to send signals.
// Note that for older NeoPixel strips you might need to change the third parameter--see the strandtest
// example for more information on possible values.
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

int endVal = 0;
int button = 0;
int timeBetween = 1500;
int switchPin = 10;

int i = 0; //Making a general variable for the for loops in the functions below
int lightNum = 0;
int greenFlag = 0;
int redFlag = 0;
int yellowFlag = 0;
int lightNum_tmp;
int lightNum_tmp1=0;
int lightNum_tmp2=0;
int greenFlag_tmp;
int redFlag_tmp;
int yellowFlag_tmp;
int weightShift = 0;
int numperpixel = 7;
int lightmax = 150;

//For testing purposes
int delayTime = 0;

void setup() {
  
  //  Wire.begin(); // join i2c bus for debugging

  Serial.begin(9600); // Open the serial port at 9600 baud

  pixels.begin(); // This initializes the NeoPixel library.

  pinMode(12, OUTPUT);
  pinMode(switchPin, INPUT);

  char check = 'b';
  
  Serial.println('a'); // Send an 'a' to MATLAB
  
  while (check != 'g'){ // Sit tight until the MATLAB sends us a 'g'
    check = Serial.read();
  }
// Once we get a 'g' we end setup knowing we have a connection

}

void loop() {

if (Serial.available()){
  lightNum_tmp =  Serial.parseInt();
  Serial.flush();
}

 if (lightNum_tmp!=lightNum_tmp1 & lightNum_tmp>999 & lightNum_tmp<6101){
  lightNum_tmp1 = lightNum_tmp;
  lightNum = lightNum_tmp/1000;
  lightNum_tmp=lightNum_tmp%1000;

  greenFlag = lightNum_tmp/100;
  lightNum_tmp = lightNum_tmp%100;

  redFlag = lightNum_tmp/10;
  yellowFlag = lightNum_tmp%10;

  if (digitalRead(switchPin) == LOW){
    if(lightNum_tmp2!=lightNum){
      lightNum_tmp2 = lightNum;
      pixelHandler(lightNum_tmp2, lightmax, 0, 0); // Light the LED RED
    }
    
  } else {
  
    if (greenFlag < 2 & greenFlag >=0 & redFlag < 2 & redFlag >=0 & yellowFlag < 2 & yellowFlag>=0){
      if (greenFlag){ 
          pixelHandler(lightNum, 0, lightmax, 0); // Light the LED GREEN
      } else if (redFlag){
          pixelHandler(lightNum, lightmax, 0, 0); // Light the LED RED
      } else{
          pixelHandler(lightNum, lightmax, lightmax/2, 0); // Light the LED YELLOW
      }
    } 
  }
 } else if (lightNum_tmp == 333){
    endSequence();
 }

  
} // End of loop


//Functions used in program above are defined below:

/**
 * Set one neopixel jewel to a specific color
 * Takes in a value x for the number of the jewel, 1-6
 * Takes in an integer value for the red, green, and blue to light the LED
 */
void pixelHandler (int x, int R, int G, int B){
  pixelsOff();
  for (i = (x*numperpixel)-numperpixel; i < (x*numperpixel); i++){
  //  for (i = 0; i<60; i++){
      
    //if (i>=((12*x)-12) & i <=((12*x)-1)){
      pixels.setPixelColor(i, pixels.Color(R,G,B));
   // } else {
    //  pixels.setPixelColor(i, pixels.Color(0,0,0));
    //}
    

    pixels.show();
      
  } // End of for loop
} // End of pixelHandler

void endSequence(){
  pixelsOff();
  for (i = 0; i<NUMPIXELS; i++){
    pixels.setPixelColor(i,pixels.Color(0,0,lightmax));
  }
  pixels.show();
  delay(500);
  pixelsOff();
  delay(500);
  for (i = 0; i<NUMPIXELS; i++){
    pixels.setPixelColor(i,pixels.Color(0,0,lightmax));
  }
  pixels.show();
  delay(500);
  pixelsOff();
  delay(500);
  for (i = 0; i<NUMPIXELS; i++){
    pixels.setPixelColor(i,pixels.Color(0,0,lightmax));
  }
  pixels.show();
  delay(500);
  pixelsOff();
}

/**
 * Creates a gradient effect with the neopixels
 */
void gradHandler (int x, int R, int G, int B){
  pixelsOff();

  x = ((x * numperpixel)-numperpixel);
  for (i = x; i < x + weightShift + 1; i++){
    pixels.setPixelColor(i, pixels.Color(R, G, B));
    pixels.show();
  } // End of for
} // End of gradHandler

/**
 * Turns all of the neopixels off by setting the color of each pixel to 0, 0, 0
 * Takes no inputs and returns nothing
 */
void pixelsOff (){
  for (i = 0; i < NUMPIXELS; i++){

    pixels.setPixelColor(i, pixels.Color(0,0,0));

    pixels.show(); // This sends the updated pixel color to the hardware.

  } // End of for loop
} // End of pixelsoff

/**
 * Turn all of the neopixels on a certain color, this was used for debugging earlier
 * Takes the integer red, green, and blue values to turn all the pixels to
 * Returns nothing
 */
void pixelsOn (int R, int G, int B){
  for (i = 0; i < NUMPIXELS; i++){
    
    pixels.setPixelColor(i, pixels.Color(R,G,B));

    pixels.show();
    
  } // End of for loop
} // End of pixelsOn


