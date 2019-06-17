
#define STEP_PIN 3
#define DIR_PIN 4
 
bool dirHigh;
//delay for setting speed of spin
int d_time = 1;

void full_spin()
{
   if(dirHigh)
  {
    delay(500);
    dirHigh = false;
    digitalWrite(DIR_PIN, LOW);
  }
  else
  {
    delay(500);
    dirHigh = true;
    digitalWrite(DIR_PIN, HIGH);
  }
 
  // Step the motor 50 times before changing direction again.
  for(int i = 0; i < 1200; i++)
  {
    // Trigger the motor to take one step.
    digitalWrite(STEP_PIN, HIGH);
    delay(d_time);
    digitalWrite(STEP_PIN, LOW);
    delay(d_time);
  }
}

void half_spin()
{
   if(dirHigh)
  {
    delay(500);
    dirHigh = false;
    digitalWrite(DIR_PIN, LOW);
  }
  else
  {
    delay(500);
    dirHigh = true;
    digitalWrite(DIR_PIN, HIGH);
  }
 
  // Step the motor 50 times before changing direction again.
  for(int i = 0; i < 100; i++)
  {
    // Trigger the motor to take one step.
    digitalWrite(STEP_PIN, HIGH);
    delay(d_time);
    digitalWrite(STEP_PIN, LOW);
    delay(d_time);
  }
}

void quarter_spin()
{
   if(dirHigh)
  {
    delay(500);
    dirHigh = false;
    digitalWrite(DIR_PIN, LOW);
  }
  else
  {
    delay(500);
    dirHigh = true;
    digitalWrite(DIR_PIN, HIGH);
  }
 
  // Step the motor 50 times before changing direction again.
  for(int i = 0; i < 50; i++)
  {
    // Trigger the motor to take one step.
    digitalWrite(STEP_PIN, HIGH);
    delay(d_time);
    digitalWrite(STEP_PIN, LOW);
    delay(d_time);
  }
}
void setup()
{
  dirHigh = true;
  digitalWrite(DIR_PIN, HIGH);
  digitalWrite(STEP_PIN, LOW);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(STEP_PIN, OUTPUT);
}
 
void loop()
{
  full_spin();
  //half_spin();
  //quarter_spin();
//    digitalWrite(STEP_PIN, HIGH);
//    delay(d_time);
//    digitalWrite(STEP_PIN, LOW);
//    delay(d_time);
}
