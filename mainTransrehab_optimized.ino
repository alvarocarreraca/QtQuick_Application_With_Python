/*
 * Main code of Myo-FES.
 * This code waits for connection from TransRehab, and executes all the actions required
 * 
 * Alvaro Carrera Cardeli - 14/06/2022
 */

#include <SoftwareSerial.h>
#include <ArduinoJson.h>
#include <movingAvg.h>

#define buffer_Size 40
#define buffer_Size_fes 25
#define buffer_Size_therapy 15

// ------------------------- CONSTANT VARIABLES: ---------------------------------------
// Pin IDs:
const int ENA_Buck = 5; // controls buck converter voltage output
const int ENA_Hbridge = 6; // controls the HBridge state (on or off)
const int in1_Hbridge = 8; // in of the IC
const int in2_Hbridge = 7;
const int pot = 1; // potentiometer port
const int in1_Buck = A4; // in of the IC
const int in2_Buck = A0;
const int EMG_PIN = A2;
const int FLEX_PIN = A3; // Pin connected to voltage diver output
const int LED_PIN = A5;
// Time constants:
unsigned long oneSecond = 62500; // one second is 62500

// ------------------------- EDITABLE VARIABLES: ---------------------------------------
// Therapy parameters:
int MAX_BUCK_V = 20; // maximum voltage that can be delivered from buck converter
int EMG_THRESHOLD = 512; // Set threshold value of the EMG to activate buck converter. Corresponds to the 60% of max volitional activity
//set the duration of on state for both positive and negaive wave (in ms)
int onState = 7; //Duration of positive wave. is 300 us with F_clock 62500;
int offState = 1200; //Duration of zero wave. Is 50Hz with F_clock 62500;

// ------------------------- OTHER VARIABLES: ------------------------------------------
int voltageBuck; // value from 0 to 255. This indicated the voltage at the output of the Buck  ---------------------------------------------------> CREATE IN THE FUNCTION
int potentiometerValue; //value read by the potentiometer  ---------------------------------------------------------------------------------------> CREATE IN THE FUNCTION
int voltageIndex; // used in the lookup function. This is the index of the voltageArray
int voltageIndex_BUCK;
int EMGValue; //value read by the analog input of the Arduin
//int test;

// ------------------------ LOOP CONTROL VARIABLES: -----------------------------------
bool isConnected;
String infoApp;
bool isRunningAction; // Boolean to identify that it is running an action
bool isEmgCalib; // Boolean to identify that it is running EMG Calibration
bool isAngleCalib; // Boolean to identify that it is running Angle Calibration
bool isFesCalib; // Boolean to identify that it is running FES Calibration
bool isRunTherapy; // Boolean to identify that it is running the Therapy
bool isInfoReady; // Boolean to identify that it received all the info from the communication channel
int baudRate = 19200;

SoftwareSerial BTSerial(3,4); //BTSerial(10,11); // TX, RX
movingAvg EMG_MovingAvg(5);

void setup() {
  //test = 0;
  Serial.begin(baudRate); // 9600
  Serial.println("Serial started");
  BTSerial.begin(baudRate); // 9600
  Serial.println("BT started");
  
  // ------------------------------- PINS SETTING: ---------------------------------
  // Set H-bridge pins to output
  pinMode(ENA_Hbridge , OUTPUT);
  pinMode(in1_Hbridge , OUTPUT);
  pinMode(in2_Hbridge , OUTPUT);
  // Set the H-Bridge to off
  digitalWrite(in1_Hbridge , LOW);
  digitalWrite(in2_Hbridge , LOW);
  //Set pins buck converter to in and out
  pinMode(ENA_Buck , OUTPUT);
  pinMode(in1_Buck , OUTPUT);
  pinMode(in2_Buck , OUTPUT);
  // Set the buck converter to off
  digitalWrite(in1_Buck , LOW);
  digitalWrite(in2_Buck , LOW);
  // Set flex and EMG pins:
  pinMode(FLEX_PIN, INPUT);
  pinMode(EMG_PIN, INPUT);

  // -------------------- CONTROL VARIABLES INITIALIZATION: ------------------------
  isConnected = false;
  infoApp = "";
  isRunningAction = false;
  isEmgCalib = false;
  isAngleCalib = false;
  isFesCalib = false;
  isRunTherapy = false;
  isInfoReady = false;
  EMG_MovingAvg.begin();
  // Set frequency of internal clock --> works for D5 and D6
  TCCR0B = TCCR0B & B11111000 | B00000001; // for PWM frequency of 62500.00 Hz
}

void loop() {
  while(!isConnected){
    checkForCommunication();
  }
  while (isConnected && !isRunningAction){
    checkForCommunication();
  }
  while (isConnected && isEmgCalib){
    EMGCalibration();
    checkForCommunication();
  }
  while (isConnected && isAngleCalib){
    angleCalibration();
    checkForCommunication();
  }
  while (isConnected && isFesCalib){
    FESCalibration();
    checkForCommunication();
  }
  while (isConnected && isRunTherapy){
    runTherapy();
    checkForCommunication();
  }
}

void checkForCommunication(){
  if (BTSerial.available() > 0){
    while(!isInfoReady){
      waitForCommunication();
    }
  }
  if (isInfoReady){
    updateActionsStatus();
  }
}

void waitForCommunication(){
  // The Json is not deserialized ultil all the stucture is received
  while(BTSerial.available() > 0 && !isInfoReady){
    char inChar = BTSerial.read();
    if (inChar != '}'){
      infoApp += inChar;
    } else if (inChar == '}'){
      infoApp += inChar;
      isInfoReady = true;
    }
  }
}

void updateActionsStatus(){
  prepareJSON();
  Serial.println(infoApp);
  isRunningAction = true;
  DynamicJsonDocument doc(512);
  deserializeJson(doc, infoApp);
  int actionID = doc["action"];
  int wantToConnect = doc["connect"];
  if (wantToConnect == 2){
    MAX_BUCK_V = doc["MAX_BUCK_V"];
    EMG_THRESHOLD = doc["EMG_THRESHOLD"];
    onState = doc["onState"];
    offState = doc["offState"];
  }
  Serial.println(actionID);
  switch (actionID){
    case 0:
      Serial.println("Connection");
      isRunningAction = false;
      if (wantToConnect == 0){
        isConnected = false;
      } else {
        isConnected = true;
      }
      break;
    case 1:
      Serial.println("EMG Calibration");
      digitalWrite(LED_PIN, HIGH);
      isEmgCalib = true;
      break;
    case 2:
      Serial.println("Angle Calibration");
      digitalWrite(LED_PIN, HIGH);
      isAngleCalib = true;
      break;
    case 3:
      Serial.println("FES Calibration");
      digitalWrite(LED_PIN, HIGH);
      isFesCalib = true;
      break;
    case 4:
      Serial.println("Run Therapy");
      digitalWrite(LED_PIN, HIGH);
      isRunTherapy = true;
      break;
    case 5:
      Serial.println("Stop");
      isEmgCalib = false;
      isAngleCalib = false;
      isFesCalib = false;
      isRunTherapy = false;
      isRunningAction = false;
      turnBuckOFF(); // turn buck converter off
      digitalWrite(LED_PIN, LOW);
      delay(oneSecond / 2);
      break;
    case 6:
      Serial.println("Set Simulation Parameters");
      break;
  }
  infoApp = "";
  isInfoReady = false;
}

void prepareJSON(){
  // remove extra charaters that are not part of the Json strucutre
  int idx = infoApp.indexOf("{");
  if (idx > 0){
    infoApp.remove(0, idx);
  }
}

void EMGCalibration(){
  DynamicJsonDocument doc(512);
  for (int ii = 0; ii < buffer_Size; ii++){
    EMGValue = analogRead(EMG_PIN);
    doc["emg"][ii] = EMG_MovingAvg.reading(EMGValue);
  }
  serializeJson(doc, BTSerial);
}

void angleCalibration(){
  DynamicJsonDocument doc(512);
  for (int ii = 0; ii < buffer_Size; ii++){
    doc["angle"][ii] = analogRead(FLEX_PIN);
  }
  serializeJson(doc, BTSerial);
}

void FESCalibration(){
  //if(Serial.available()){
  //  test = Serial.readString().toInt();
  //}
  DynamicJsonDocument doc(512);
  for (int ii = 0; ii < buffer_Size_fes; ii++){
    potentiometerValue = analogRead(pot); //read potentiometer value
    FES(potentiometerValue, 32, 0);
    doc["fes"][ii] = voltageIndex;
    doc["angle"][ii] = analogRead(FLEX_PIN);
  }
  serializeJson(doc, BTSerial);
}

void runTherapy(){
  DynamicJsonDocument doc(512);
  for (int ii = 0; ii < buffer_Size_therapy; ii++){
    EMGValue = analogRead(EMG_PIN); //read EMG value
    EMGValue = map (EMGValue , 0, 730, 0, 1023);
    EMGValue = EMG_MovingAvg.reading(EMGValue); // calculate the moving average  
    FES(EMGValue, MAX_BUCK_V, EMG_THRESHOLD);
    doc["fes"][ii] = voltageIndex;
    doc["emg"][ii] = EMGValue;
    doc["angle"][ii] = analogRead(FLEX_PIN);
  }
  serializeJson(doc, BTSerial);
  //voltageIndex_BUCK = MAP_EMG_TO_BUCK(EMG_THRESHOLD , MAX_BUCK_V , EMGValue); 
}

void FES(int value, int maxBuck, int threshold){
  voltageBuck = lookup (value, maxBuck, threshold); // see lookup function
  turnBuckON(voltageBuck); // turn on buck converter at voltageBuck voltage
  //produce biphasic wave
  positiveWave();
  negativeWave();
  zeroWave();
}

void positiveWave(){
  // creates the positive phase of the biphasic wave
  analogWrite(ENA_Hbridge, 255); // turn the H-bridge on
  digitalWrite(in1_Hbridge, HIGH);
  digitalWrite(in2_Hbridge, LOW);
  delay(onState);
}

void negativeWave(){
  // creates the negative phase of the biphasic wave
  analogWrite(ENA_Hbridge, 255); // turn the H-bridge on
  digitalWrite(in1_Hbridge, LOW);
  digitalWrite(in2_Hbridge, HIGH);
  delay(onState);
}

void zeroWave(){
  // turns of the Hbridge
  digitalWrite(in1_Hbridge, LOW);
  digitalWrite(in2_Hbridge, LOW);
  delay(offState);
}

void turnBuckON(int voltage){
  // write voltage and turn buck converter ON
  analogWrite(ENA_Buck , voltage);
  digitalWrite(in1_Buck , HIGH);
  digitalWrite(in2_Buck , LOW);
}

void turnBuckOFF(){
  // write voltage and turn buck converter ON
  analogWrite(ENA_Buck , 0);
  digitalWrite(in1_Buck , LOW);
  digitalWrite(in2_Buck , LOW);
}

int lookup(int potValue, int maxBuck , int minValue){
  // this function returns a quantized voltage value to be used as the input of the ENA_Buck pin
  // potValue is value read from potentiometer. From 0 to 1023
  int minPotValue = minValue; // min and max value read from potentiometer
  int maxPotValue = 1023;

  //VoltageIndex is declared outside the function to be used in Main
  voltageIndex = map (potValue , minPotValue , maxPotValue , 0, 33 ); // map values of potentiometer into indexes of the voltage array -> 33 == sizeof(voltageArray) / sizeof(int)
  if (voltageIndex < 0) //control
    voltageIndex = 0;

  if (voltageIndex > 32)
    voltageIndex = 32;

  int voltage = selectVoltageArray(voltageIndex); //voltageArray[ voltageIndex ];

  if (voltage > selectVoltageArray(maxBuck)){
    voltage = selectVoltageArray(maxBuck);
    voltageIndex = maxBuck;
  }
  //Serial.println(String(voltageIndex) + ", " + String(voltage));
  return voltage; //returns a value from 0 to 255 that corresponds to voltage of the buck converter output
}

int selectVoltageArray(int voltageIndex){
  //Serial.println("Test value: " + String(test));
  //return test;
  switch(voltageIndex){
    case 0: return 0; // 0 V
    case 1: return 1; // 1 V
    case 2: return 1; // 2 V
    case 3: return 1; // 3 V
    case 4: return 1; // 4 V
    case 5: return 2; // 5 V
    case 6: return 2; // 6 V
    case 7: return 3; // 7 V
    case 8: return 4; // 8 V
    case 9: return 4; // 9 V
    case 10: return 5; // 10 V
    case 11: return 6; // 11 V
    case 12: return 7; // 12 V
    case 13: return 8; // 13 V
    case 14: return 9; // 14 V
    case 15: return 10; // 15 V
    case 16: return 11; // 16 V
    case 17: return 13; // 17 V
    case 18: return 14; // 18 V
    case 19: return 16; // 19 V
    case 20: return 17; // 20 V
    case 21: return 21; // 21 V
    case 22: return 24; // 22 V
    case 23: return 28; // 23 V
    case 24: return 32; // 24 V
    case 25: return 38; // 25 V
    case 26: return 46; // 26 V
    case 27: return 58; // 27 V
    case 28: return 74; // 28 V
    case 29: return 104; // 29 V
    case 30: return 174; // 30 V
    case 31: return 255; // 31 V
    case 32: return 255; // 32 V
  }
}

int MAP_EMG_TO_BUCK(int EMG_THRESHOLD , int MAX_FES_VOLTAGE , int EMG_VALUE) {
  //receive values from emg and map them to FES voltage
  int FES_VOLTAGE = map (EMG_VALUE , EMG_THRESHOLD , 1023, 0 , MAX_FES_VOLTAGE);
  return FES_VOLTAGE;
}
