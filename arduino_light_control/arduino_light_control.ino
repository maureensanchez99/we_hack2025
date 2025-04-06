#include <SoftwareSerial.h>

/*GLOBALS*/

//Setup TX and RX pins for Bluetooth Module (HM-10; "HMSoft")
SoftwareSerial BTSerial(2, 3);

//manage state of 
unsigned long timerSet = 0;
unsigned long lightDuration = 60000;
bool status = false;

int redPin = 4;
int greenPin = 7;
int bluePin = 8;

/*SETUP*/

void setup() {

  //Open port for communication, bluetooth w/ baud rate
  BTSerial.begin(9600);

  //Configure IO pins for RGB LED
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);

  //Set color white, standby
  digitalWrite(redPin, HIGH);
  digitalWrite(greenPin, HIGH);
  digitalWrite(bluePin, HIGH);
}

/*FUNCTIONALITY*/

void loop() {

  //Check for active connection
  if (BTSerial.available()) {

    //Transmit message for LED set
    trigger(BTSerial.read());

    //Get current time to set reset timer
    timerSet = millis();
  }

  //Check that a timeout light color is active and if a minute has bassed
  if (status && millis() - timerSet >= lightDuration) {

    //Reset to Standby
    trigger('w');
  }
}

/*MESSAGE RESPONSE HANDLING*/

void trigger(char val) {

  //Trigger timer checker, cancel if interrupt called
  if (val == 'w') {
    status = false;
  } else {
    status = true;
  }

  /*
  HIGH -> On
  LOW -> Off

  White - All On
  Red - Red Only
  Green - Green Only 
  Blue - Blue Only
  Yellow - Red and Green
  Cyan - Green and Blue
  Magenta - Red and Blue
  */
  
  //Set color based on transmitted message
  switch (val) {

    //Reminder, failure or forgotten
    case 'r':
      digitalWrite(redPin, HIGH);
      digitalWrite(greenPin, LOW);
      digitalWrite(bluePin, LOW);
      break;

    //Reminder, success
    case 'g':
      digitalWrite(redPin, LOW);
      digitalWrite(greenPin, HIGH);
      digitalWrite(bluePin, LOW);
      break;

    //Water the flower
    case 'c':
      digitalWrite(redPin, LOW);
      digitalWrite(greenPin, HIGH);
      digitalWrite(bluePin, HIGH);
      break;

    //Give the flower some Sun
    case 'y':
      digitalWrite(redPin, HIGH);
      digitalWrite(greenPin, HIGH);
      digitalWrite(bluePin, LOW);
      break;

    //Message available
    case 'm':
      digitalWrite(redPin, HIGH);
      digitalWrite(greenPin, LOW);
      digitalWrite(bluePin, HIGH);
      break;

    //Standby, Inactive
    case 'w':
      digitalWrite(redPin, HIGH);
      digitalWrite(greenPin, HIGH);
      digitalWrite(bluePin, HIGH);
      break;
  }
}