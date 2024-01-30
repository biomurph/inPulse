/*
 *  Arduino firmware for the ImPulse Project
 *  Winter 2021
 *  
 *  Targeting ATmega32u4 on the SparkFun Pro Micro 3.3V-8MHz
 *    
 *    THIS CODE DESIGNED TO PRINT TO PROCESSING SKETCH AND SERIAL PLOTTER
 *    
 *    
 */


#define PULSE_1 0
#define PULSE_2 3
#define LEAD_OFF_01 14 
#define LEAD_OFF_02 15
#define LEAD_OFF_11 8
#define LEAD_OFF_12 9
#define NUM_LEAD_OFF_PINS 4
#define SERIAL_PLOT 0
#define PROCESSING 1
#define MEAN_SIZE 20
#define EMA_a 0.2

//#define EMA_a 0.8  //initialization of EMA alpha

int printDestination;

int pulsePin[] = {PULSE_1,PULSE_2};
int leadOffPin[] = {LEAD_OFF_01,LEAD_OFF_02,LEAD_OFF_11,LEAD_OFF_12};
int leadOffValue[4];
int lastLeadOffValue[4];

volatile unsigned int delta[2];
unsigned long lastBeatSampleNumber[2];
volatile unsigned int SYNC;

unsigned int startTime[2];
unsigned int stopTime[2];
unsigned int duration[2];


boolean liveOne[2];
boolean inBeat[] = {false,false};
//boolean[ outBeat[] = {true,true};
boolean newData = false;


volatile unsigned long sampleCounter = 0;
unsigned long lastBeatTime[] = {0,0};
volatile int rawSignal[] = {0,0};
volatile float EMA[] = {0.0,0.0};        //the EMA
volatile float EMA_EMA[] = {0.0,0.0};    //the EMA of the EMA
volatile float signalMean[] = {0.0,0.0};
volatile float signalMeanArray[MEAN_SIZE];
volatile float rectifiedSignal[2];
volatile float rmsSignal[2];
volatile long Signal[2];
volatile long lastSignal[2];
boolean rising[] = {false,false};
int trough[2];
int peak[2];
int amp[2];
int squaredAmp[2];
int AMP[2];
int IBI[] = {750,750};
int BPM[2];
volatile boolean Pulse[] = {false,false};
boolean firstBeat[] = {true,true};
int threshold[] = {1000,1000};

volatile float adjacentValue[2][3];
volatile int derivativeCounter[] = {0,0};
volatile float firstDerivative[2];

void setup() {
  for(int p=0; p<NUM_LEAD_OFF_PINS; p++){
    pinMode(leadOffPin[p],INPUT);
    leadOffValue[p] = lastLeadOffValue[p] = LOW; // assume it's disconnected
  }
  
  readLeadOffPins();
  
  Serial.begin(250000);
  while(!Serial) {}
  Serial.println("\nImPulse v01");

  setupInterrupt(); 
//  printDestination = SERIAL_PLOT;
  printDestination = PROCESSING;
}

void loop() {

//  readSerial();
  
  readLeadOffPins();

  if(printDestination == PROCESSING){
//    printRawSignal_Processing();
    printFilteredSignal_Processing();
    printPulseData_Processing();
    delay(10);
  }

  if(printDestination == SERIAL_PLOT){
//    printAlgoData_Plotter();
//    printRawSignal_Plotter();   
    printFilteredSignal_Plotter();
//    printPulseData_Terminal();
    Serial.println();

  delay(10);
  }
  

}
