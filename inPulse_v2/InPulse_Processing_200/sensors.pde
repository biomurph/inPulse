


int numSensors = 2;
int[] Sensor = new int[2];      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int[] IBI = new int[2];         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int[] BPM = new int[2];         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] HRV = new int[2];
int[] meanHRV = new int[2];
int[][] RawPPG;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[][] ScaledPPG;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[][] ScaledIBI;      // USED TO POSITION BPM DATA WAVEFORM
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(42, 2, 99);
int SYNC;

int PulseWindowWidth; // = 490;
int PulseWindowHeight; // = 512;
int PulseWindowX;
int[] PulseWindowY;
int BPMWindowWidth; // = 180;
int BPMWindowHeight; // = 340;
int BPMWindowX;
int[] BPMWindowY;

// HRV TOOLS
int[] lastIBI = {0,0};
boolean[] goingUp = {false, false};
String[] direction = {"",""};
int[] P = new int[2];
int[] T= new int[2];
int[] amp = new int[2];
int[] mean = new int[2];
float[] freq= new float[2];
float[] runningTotal = {0.0, 0.0}; // 1.0;
int[] hrv = {0,0};
boolean[] beat = new boolean[2];    // set when a heart beat is detected, then cleared when the BPM graph is advanced

float[] sensorDataX = new float[2];
float sensorDataY = 30;

boolean showWave = false;

/*
    Recieves the sensor number [0,1]
    Returns the most recent amp for that sensor
*/
int getHRV(int x){
    if (IBI[x] < T[x]){                        // T is the trough
      T[x] = IBI[x];                         // keep track of lowest point in pulse wave
    }
    if (IBI[x] > P[x]){                        // P is the trough
      P[x] = IBI[x];                         // keep track of highest point in pulse wave
    }
    runningTotal[x] += IBI[x];               // how long since IBI wave changed direction?

    if (IBI[x] < lastIBI[x] && goingUp[x] == true){  // check for IBI wave peak
      goingUp[x] = false;                 // now changing direction from up to down
      direction[x] = "down";              // used in verbose feedback
      freq[x] = (runningTotal[x]/1000) *2;   // scale milliseconds to seconds account for 1/2 wave data
      freq[x] = 1/freq[x];                   // convert time IBI trending up to Hz
      runningTotal[x] = 0;                // reset this for next time
      amp[x] = P[x]-T[x];                       // measure the size of the IBI 1/2 wave that just happend
      mean[x] = P[x]-amp[x]/2;                  // the average is useful for VLF derivation.......
      T[x] = lastIBI[x];                     // set the last IBI as the most recent trough cause we're going down
      
    }

    if (IBI[x] > lastIBI[x] && goingUp[x] == false){  // check for IBI wave trough
      goingUp[x] = true;                  // now changing direction from down to up
      direction[x] = "up";                // used in verbose feedback
      freq[x] = (runningTotal[x]/1000) * 2;  // scale milliseconds to seconds, account for 1/2 wave data
      freq[x] = 1/freq[x];                   // convert time IBI trending up to Hz
      runningTotal[x] = 0;                // reset this for next time
      amp[x] = P[x]-T[x];                       // measure the size of the IBI 1/2 wave that just happend
      mean[x] = P[x]-amp[x]/2;                  // the average is useful for VLF derivation.......
      P[x] = lastIBI[x];                     // set the last IBI as the most recent peak cause we're going up
      
    }
    lastIBI[x] = IBI[x];                     // keep track to measure the trend

    return amp[x];
}


// void drawDataWindows(){
//   noStroke();
//   // DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES
//   fill(eggshell);  // color for the window background
//   for(int i=0; i<numSensors; i++){
//     rect(PulseWindowX, PulseWindowY[i], PulseWindowWidth, PulseWindowHeight);
//     rect(BPMWindowX, BPMWindowY[i], BPMWindowWidth, BPMWindowHeight);
//   }
// }

void drawPulseWaveform(){
  // DRAW THE PULSE WAVEFORM
  // prepare pulse data points
  for (int i=0; i<numSensors; i++) {
    RawPPG[i][PulseWindowWidth-1] = (1023 - Sensor[i]);   // place the new raw datapoint at the end of the array

    for (int j = 0; j < PulseWindowWidth-1; j++) {      // move the pulse waveform by
      RawPPG[i][j] = RawPPG[i][j+1];                         // shifting all raw datapoints one pixel left
      float dummy = RawPPG[i][j] * 0.625/numSensors;       // adjust the raw data to the selected scale
      offset = float(PulseWindowY[i]);                // calculate the offset needed at this window
      ScaledPPG[i][j] = int(dummy) + int(offset);   // transfer the raw data array to the scaled array
    }
    stroke(0, 99, 99);                               // red is a good color for the pulse waveform
    noFill();
    beginShape();                                  // using beginShape() renders fast
    for (int x = 1; x < PulseWindowWidth-1; x++) {
      vertex(x+10, ScaledPPG[i][x]);                    //draw a line connecting the data points
    }
    endShape();
  }

}

void drawIBIwaveform(){
// DRAW THE BPM WAVE FORM
// first, shift the BPM waveform over to fit then next data point only when a beat is found
  for(int i=0; i<numSensors; i++){  // ONLY ADVANCE THE BPM WAVEFORM WHEN THERE IS A BEAT
    if(beat[i] == true){   // move the heart rate line over one pixel every time the heart beats
      beat[i] = false;      // clear beat flag (beat flag waset in serialEvent tab)
      HRV[i] = getHRV(i);
      for(int j=0; j<BPMWindowWidth-1; j++){
        ScaledIBI[i][j] = ScaledIBI[i][j+1];                  // shift the bpm Y coordinates over one pixel to the left
      }
      // then limit and scale the BPM value
      IBI[i] = constrain(IBI[i], 500, 1300);                     // limit the IBI values
      float dummy = map(IBI[i], 500, 1300, BPMWindowY[i]+BPMWindowHeight, BPMWindowY[i]);   // map it to the heart rate window Y
      ScaledIBI[i][BPMWindowWidth-1] = int(dummy);       // set the rightmost pixel to the new data point value
    }
  }
  if(!showWave){ return; }
  // GRAPH THE HEART RATE WAVEFORM
  stroke(0, 100, 100);                          // color of heart rate graph
  strokeWeight(2);                          // thicker line is easier to read
  noFill();

  for(int i=0; i<numSensors; i++){
    beginShape();
    for (int j=0; j < BPMWindowWidth; j++) {    // variable 'j' will take the place of pixel x position
     vertex(j+BPMWindowX, ScaledIBI[i][j]);                 // display history of heart rate datapoints
    }
    endShape();
  }
}





//void resetDataTraces(){
//  for (int i=0; i<numSensors; i++) {
//    BPM[i] = 0;
//    for(int j=0; j<BPMWindowWidth; j++){
//      ScaledIBI[i][j] = BPMWindowY[i] + BPMWindowHeight;
//    }
//  }
//  for (int i=0; i<numSensors; i++) {
//    Sensor[i] = 512;
//    for (int j=0; j<PulseWindowWidth; j++) {
//      RawPPG[i][j] = 1024 - Sensor[i]; // initialize the pulse window data line to V/2
//    }
//  }
//}

void resetVariables(int s){

    IBI[s] = 0;
    HRV[s] = 0;
    //for(int j=0; j<BPMWindowWidth; j++){
    //  ScaledIBI[s][j] = BPMWindowY[s] + BPMWindowHeight;
    //}

    // Sensor[s] = 512;
    // for (int j=0; j<PulseWindowWidth; j++) {
    //   RawPPG[s][j] = 1024 - Sensor[s]; // initialize the pulse window data line to V/2
    // }

}

void printDataToScreen(){ // PRINT THE DATA AND VARIABLE VALUES
    fill(42,2,99);                                       // get ready to print text
    // text("ImPulse Visualizer", 245, 30);     // tell them what you are
    for (int i=0; i<numSensors; i++) {
      // text("freq " + nf(freq[i],0,2), 800, BPMWindowY[i] + 260);
      text("HRV " + HRV[i], sensorDataX[i], sensorDataY);
      // text(BPM[i] + " BPM", sensorDataX[i], BPMWindowY[i] +185);// 215          // print the Beats Per Minute
      text("IBI " + IBI[i] + "mS", sensorDataX[i], sensorDataY + 30);// 245   // print the time between heartbeats in mS
    }
    text("SYNC " + SYNC + "mS", sensorDataX[0], height-30);
}

void initSensors(){
  //PulseWindowWidth = 490;
  //PulseWindowHeight = 640/numSensors;
  //PulseWindowX = 10;
  //PulseWindowY = new int [numSensors];
  //for(int i=0; i<numSensors; i++){
  //  PulseWindowY[i] = 43 + (PulseWindowHeight * i);
  //  if(i > 0) PulseWindowY[i]+=spacer*i;
  //}
  //BPMWindowWidth = 180;
  //BPMWindowHeight = PulseWindowHeight;
  //BPMWindowX = PulseWindowX + PulseWindowWidth + 10;
  //BPMWindowY = new int [numSensors];
  //for(int i=0; i<numSensors; i++){
  //  BPMWindowY[i] = 43 + (BPMWindowHeight * i);
  //  if(i > 0) BPMWindowY[i]+=spacer*i;
  //}
  beat = new boolean[numSensors];
  // Data Variables Setup
  Sensor = new int[numSensors];      // HOLDS PULSE SENSOR DATA FROM ARDUINO
  IBI = new int[numSensors];         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
  BPM = new int[numSensors];         // HOLDS HEART RATE VALUE FROM ARDUINO
  HRV = new int[numSensors];         // HOLDS THE LATEST IBI WAVE AMPLITUDE
  //RawPPG = new int[numSensors][PulseWindowWidth];          // initialize raw pulse waveform array
  //ScaledPPG = new int[numSensors][PulseWindowWidth];       // initialize scaled pulse waveform array
  //ScaledIBI = new int [numSensors][BPMWindowWidth];           // initialize BPM waveform array
  sensorDataX[0] = 50;
  sensorDataX[1] = width - 150;
  // set the visualizer lines to 0
  //resetDataTraces();
}
