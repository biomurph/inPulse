import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ImPulse_Processing_03 extends PApplet {

/*

      ImPulse 2021


*/


PFont font;

Serial port;

final int HOLD = 0;
final int IN = 1;
final int OUT = 2;
final int MIN_SYNC = 20;
final int WIDTH = 1200;
final int HEIGHT = 800;

int black = color(20,0,55);


public void setup(){
  
  frameRate(60);
  font = loadFont("Arial-BoldMT-24.vlw");
  textFont(font);
  textAlign(LEFT);
  rectMode(CENTER);
  ellipseMode(CENTER);

  // CONNECTION SETUP
  initConnection();
  // BREATH STUP
	initBreathPrompt();

  initSensors();

  serialConnect();

}



public void draw(){
  background(black);
  if(serialPortFound){

    drawConnection();
    drawBreathPrompt();
    drawIBIwaveform();
    printDataToScreen();

  } else { // SCAN TO FIND THE SERIAL PORT
      autoScanPorts();
      if(refreshPorts){
        refreshPorts = false;
        // drawDataWindows();
        listAvailablePorts();
      }

      for(int i=0; i<numPorts+1; i++){
        button[i].overRadio(mouseX,mouseY);
        button[i].displayRadio();
      }

    }
}


// BREATH PROMPT STUFF
float blue = 120.0f;
float red = 80.0f;
float green = 15;
float fadeValue = red;
int breathAlpha = 230;
int holdCount;
int holdDuration = 100;
float a = 0;
float inStep = 0.8f;
float outStep = 0.3f;
int breathing = OUT;
int breathCenterX;
int breathCenterY;
float lastBreathX;
float breathXmax = 900.0f;
float breathYmax = 600.0f;
float breathXmin = 100.0f;  // this works?
float breathYmin = 150.0f;  // this works?
float breathX = breathXmin;
float breathY = breathYmin;
float breathXstep = (breathXmax-breathXmin)/180.0f;
float breathYstep = (breathYmax-breathYmin)/180.0f;
float breathCycle; // = 60.0 / 6.0; // 10.0;
float breatheIn = 0.8f; // 60.0 / 10.0;
float breatheOut = 0.5f; //60.0 / 5.0;
float angle;
float angleStep;
int counter = 0;



public void drawBreathPrompt(){
	// float r = ((millis()/1000.0)/breathCycle)*360;
  angle = radians(a);
	float s = sin(angle);
	// lastBreathX = breathX;
  breathX = 100 + (sin(angle) * breathXmax/2) + breathXmax/2;
  breathY = 75 + (sin(angle) * breathYmax/2) + breathYmax/2;
  fadeValue = red + (sin(angle) * red/2) + red/2;
  noStroke();
  fill(fadeValue,green,blue,breathAlpha);
  ellipse(breathCenterX,breathCenterY,breathX,breathY);

  if(breathX < lastBreathX && breathing == IN ){
		breathing = OUT;
		// print(breathX);
		breathCycle = breatheOut;
		// println("  breathe out");
	}
	if(breathX > lastBreathX && breathing == OUT){
		breathing = HOLD;
		holdCount = 0;
		// print(breathX);
		// println("  breathe in");
		breathCycle = breatheIn;
	}
	lastBreathX = breathX;
	if(breathing == HOLD){
		holdCount++;
		if(holdCount > holdDuration){
			breathing = IN;
		}
		return;
	}
	a += breathCycle;
	// println(r);
}


public void initBreathPrompt(){
  breathCycle = breatheOut;
  breathCenterX = width/2;
  breathCenterY = height/2;
}

// CONNECTION STUFF
int frameCounter = 1;
int connectR = 140;
int connectG = 80;
int connectB = 0;
float[][] distances;
float maxDistance;
int spacer;
int sync = MIN_SYNC;
int lastSync;
boolean connecting = true;
int pointCount;
int[] pointWeight;


public void drawConnection(){
  if(frameCount % 180 == 0){
    catchUpPoints();
    lastSync = sync;
    frameCounter = 1;
    if(connecting){
      sync++;
      if(sync > spacer){ connecting = false; }
    } else {
      sync--;
      if(sync < MIN_SYNC){ connecting = true; }
    }
  }
   // strokeWeight(sync);
   int _x;
   int pointCounter = 0;
   if(frameCount % 3 == 0){ frameCounter++; } //  println(frameCounter); }
   for (int y = 0; y < height; y += spacer) {
      for (int x = 0; x < width; x += spacer) {
        stroke(connectR, connectG, connectB, distances[x][y]);
				if(y % 100 == 0){
          _x = x + spacer/2;
        } else {
          _x = x;
        }
        if(pointCounter % frameCounter == 0){
          if(pointWeight[pointCounter] == lastSync){
            pointWeight[pointCounter] = sync;
          }
        }
        strokeWeight(pointWeight[pointCounter]);
        point(_x + spacer/2, y + spacer/2);
        pointCounter++;
      }
    }


}

public void initConnection(){
  maxDistance = dist(width/2, height/2, width, height);
  distances = new float[width][height];
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      float distance = dist(width/2, height/2, x, y);
      distances[x][y] = distance/maxDistance * 255;
    }
  }
  spacer = 50;
  pointCount = (width/spacer)*(height/spacer);
  pointWeight = new int[pointCount];
  for(int i=0; i<pointCount; i++){
    pointWeight[i] = sync;
  }
}

public void catchUpPoints(){
  for(int i=0; i<pointCount; i++){
    if(pointWeight[i] == lastSync){ pointWeight[i] = sync; }
  }
}



int numSensors = 2;
int[] Sensor = new int[2];      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int[] IBI = new int[2];         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int[] BPM = new int[2];         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] HRV = new int[2];
int[][] RawPPG;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[][] ScaledPPG;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[][] ScaledIBI;      // USED TO POSITION BPM DATA WAVEFORM
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
int eggshell = color(255, 253, 248);
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
float[] runningTotal = {0.0f, 0.0f}; // 1.0;
int[] hrv = {0,0};
boolean[] beat = new boolean[2];    // set when a heart beat is detected, then cleared when the BPM graph is advanced

float[] sensorDataX = {30,WIDTH-100};
float sensorDataY = 30;

boolean showWave = false;


public int getHRV(int x){
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
      // hrv[x] = int(runningTotal[x]);
      freq[x] = (runningTotal[x]/1000) *2;   // scale milliseconds to seconds account for 1/2 wave data
      freq[x] = 1/freq[x];                   // convert time IBI trending up to Hz
      runningTotal[x] = 0;                // reset this for next time
      amp[x] = P[x]-T[x];                       // measure the size of the IBI 1/2 wave that just happend
      mean[x] = P[x]-amp[x]/2;                  // the average is useful for VLF derivation.......
      T[x] = lastIBI[x];                     // set the last IBI as the most recent trough cause we're going down
      // powerPointX[pointCount] = map(freq,0,1.2,75,windowWidth+75);  // plot the frequency
      // powerPointY[pointCount] = height-(35+amp);  // amp determines 'power' of signal
      // pointCount++;                    // build the powerPoint array
      // if(pointCount == 150){pointCount = 0;}      // overflow the powerPoint array
    }

    if (IBI[x] > lastIBI[x] && goingUp[x] == false){  // check for IBI wave trough
      goingUp[x] = true;                  // now changing direction from down to up
      direction[x] = "up";                // used in verbose feedback
      // hrv[x] = int(runningTotal[x]);
      freq[x] = (runningTotal[x]/1000) * 2;  // scale milliseconds to seconds, account for 1/2 wave data
      freq[x] = 1/freq[x];                   // convert time IBI trending up to Hz
      runningTotal[x] = 0;                // reset this for next time
      amp[x] = P[x]-T[x];                       // measure the size of the IBI 1/2 wave that just happend
      mean[x] = P[x]-amp[x]/2;                  // the average is useful for VLF derivation.......
      P[x] = lastIBI[x];                     // set the last IBI as the most recent peak cause we're going up
      // powerPointX[pointCount] = map(freq,0,1.2,75,windowWidth+75);  // plot the frequency
      // powerPointY[pointCount] = height-(35+amp); // amp determines 'power' of signal
      // pointCount++;                    // build the powerPoint array
      // if(pointCount == 150){pointCount = 0;}      // overflow the powerPoint array
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

public void drawPulseWaveform(){
  // DRAW THE PULSE WAVEFORM
  // prepare pulse data points
  for (int i=0; i<numSensors; i++) {
    RawPPG[i][PulseWindowWidth-1] = (1023 - Sensor[i]);   // place the new raw datapoint at the end of the array

    for (int j = 0; j < PulseWindowWidth-1; j++) {      // move the pulse waveform by
      RawPPG[i][j] = RawPPG[i][j+1];                         // shifting all raw datapoints one pixel left
      float dummy = RawPPG[i][j] * 0.625f/numSensors;       // adjust the raw data to the selected scale
      offset = PApplet.parseFloat(PulseWindowY[i]);                // calculate the offset needed at this window
      ScaledPPG[i][j] = PApplet.parseInt(dummy) + PApplet.parseInt(offset);   // transfer the raw data array to the scaled array
    }
    stroke(250, 0, 0);                               // red is a good color for the pulse waveform
    noFill();
    beginShape();                                  // using beginShape() renders fast
    for (int x = 1; x < PulseWindowWidth-1; x++) {
      vertex(x+10, ScaledPPG[i][x]);                    //draw a line connecting the data points
    }
    endShape();
  }

}

public void drawIBIwaveform(){
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
      ScaledIBI[i][BPMWindowWidth-1] = PApplet.parseInt(dummy);       // set the rightmost pixel to the new data point value
    }
  }
  if(!showWave){ return; }
  // GRAPH THE HEART RATE WAVEFORM
  stroke(250, 0, 0);                          // color of heart rate graph
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





public void resetDataTraces(){
  for (int i=0; i<numSensors; i++) {
    BPM[i] = 0;
    for(int j=0; j<BPMWindowWidth; j++){
      ScaledIBI[i][j] = BPMWindowY[i] + BPMWindowHeight;
    }
  }
  for (int i=0; i<numSensors; i++) {
    Sensor[i] = 512;
    for (int j=0; j<PulseWindowWidth; j++) {
      RawPPG[i][j] = 1024 - Sensor[i]; // initialize the pulse window data line to V/2
    }
  }
}

public void resetVariables(int s){

    IBI[s] = 0;
    for(int j=0; j<BPMWindowWidth; j++){
      ScaledIBI[s][j] = BPMWindowY[s] + BPMWindowHeight;
    }

    // Sensor[s] = 512;
    // for (int j=0; j<PulseWindowWidth; j++) {
    //   RawPPG[s][j] = 1024 - Sensor[s]; // initialize the pulse window data line to V/2
    // }

}

public void printDataToScreen(){ // PRINT THE DATA AND VARIABLE VALUES
    fill(eggshell);                                       // get ready to print text
    // text("ImPulse Visualizer", 245, 30);     // tell them what you are
    for (int i=0; i<numSensors; i++) {
      // text("freq " + nf(freq[i],0,2), 800, BPMWindowY[i] + 260);
      text("HRV " + HRV[i], sensorDataX[i], sensorDataY);
      // text(BPM[i] + " BPM", sensorDataX[i], BPMWindowY[i] +185);// 215          // print the Beats Per Minute
      text("IBI " + IBI[i] + "mS", sensorDataX[i], sensorDataY + 30);// 245   // print the time between heartbeats in mS
    }
    text("SYNC " + SYNC + "mS", width/2-40, sensorDataY);
}

public void initSensors(){
  PulseWindowWidth = 490;
  PulseWindowHeight = 640/numSensors;
  PulseWindowX = 10;
  PulseWindowY = new int [numSensors];
  for(int i=0; i<numSensors; i++){
    PulseWindowY[i] = 43 + (PulseWindowHeight * i);
    if(i > 0) PulseWindowY[i]+=spacer*i;
  }
  BPMWindowWidth = 180;
  BPMWindowHeight = PulseWindowHeight;
  BPMWindowX = PulseWindowX + PulseWindowWidth + 10;
  BPMWindowY = new int [numSensors];
  for(int i=0; i<numSensors; i++){
    BPMWindowY[i] = 43 + (BPMWindowHeight * i);
    if(i > 0) BPMWindowY[i]+=spacer*i;
  }
  beat = new boolean[numSensors];
  // Data Variables Setup
  Sensor = new int[numSensors];      // HOLDS PULSE SENSOR DATA FROM ARDUINO
  IBI = new int[numSensors];         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
  BPM = new int[numSensors];         // HOLDS HEART RATE VALUE FROM ARDUINO
  HRV = new int[numSensors];         // HOLDS THE LATEST IBI WAVE AMPLITUDE
  RawPPG = new int[numSensors][PulseWindowWidth];          // initialize raw pulse waveform array
  ScaledPPG = new int[numSensors][PulseWindowWidth];       // initialize scaled pulse waveform array
  ScaledIBI = new int [numSensors][BPMWindowWidth];           // initialize BPM waveform array

  // set the visualizer lines to 0
  resetDataTraces();
}

String serialPort;
String[] serialPorts = new String[Serial.list().length];
boolean serialPortFound = false;
Radio[] button = new Radio[Serial.list().length*2];
int numPorts = 0;
boolean refreshPorts = false;



public void serialEvent(Serial port){
try{
   String inData = port.readStringUntil('\n');
   inData = trim(inData);                 // cut off white space (carriage return)

 for(int i=0; i<numSensors;i++){
   if (inData.charAt(0) == 'a'+i){           // leading 'a' for sensor data
     inData = inData.substring(1);           // cut off the leading 'a'
     Sensor[i] = PApplet.parseInt(inData);                // convert the string to usable int
   }
   if (inData.charAt(0) == 'A'+i){           // leading 'A' for BPM data
     inData = inData.substring(1);           // cut off the leading 'A'
     BPM[i] = PApplet.parseInt(inData);                   // convert the string to usable int
     // beat[i] = true;                         // set beat flag to advance heart rate graph
     // heart[i] = 20;                          // begin heart image 'swell' timer
   }
   if (inData.charAt(0) == 'M'+i){             // leading 'M' means IBI data
       inData = inData.substring(1);           // cut off the leading 'M'
       IBI[i] = PApplet.parseInt(inData);                   // convert the string to usable int
       beat[i] = true;                         // set beat flag to advance heart rate graph
     }
   }
   if (inData.charAt(0) == 'X'){             // leading 'X' means SYNC data
     inData = inData.substring(1);           // cut off the leading 'T'
     SYNC = PApplet.parseInt(inData);                      // convert the string to usable int
   }
   if (inData.charAt(0) == '*'){             // leading '*' means Lead Off
     inData = inData.substring(1);           // cut off the leading 'T'
     resetVariables(PApplet.parseInt(inData));                      // convert the string to usable int
   }

} catch(Exception e) {
  print("Serial Error: ");
  println(e.toString());
}

}


public void serialConnect(){
  println(Serial.list());    // print a list of available serial ports to the console
  // serialPorts = Serial.list();

  try{
    port = new Serial(this, Serial.list()[Serial.list().length-1], 250000);  // make sure Arduino is talking serial at this baud rate
    delay(500);
    println(port.read());
    port.clear();            // flush buffer
    port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
    serialPortFound = true;
  }
  catch(Exception e){
    println("Couldn't open port " + Serial.list()[Serial.list().length-1]);
    fill(255,0,0);
    textFont(font,16);
    textAlign(LEFT);
    text("Couldn't open port " + Serial.list()[Serial.list().length-1],60,70);
    textFont(font);
    textAlign(CENTER);
  }

}


public void listAvailablePorts(){
  println(Serial.list());    // print a list of available serial ports to the console
  serialPorts = Serial.list();
  fill(0);
  textFont(font,16);
  textAlign(LEFT);
  // set a counter to list the ports backwards
  int yPos = 0;

  for(int i=numPorts-1; i>=0; i--){
    button[i] = new Radio(35, 95+(yPos*20),12,color(180),color(80),color(255),i,button);
    text(serialPorts[i],50, 100+(yPos*20));
    yPos++;
  }
  int p = numPorts;
   fill(233,0,0);
  button[p] = new Radio(35, 95+(yPos*20),12,color(180),color(80),color(255),p,button);
    text("Refresh Serial Ports List",50, 100+(yPos*20));

  textFont(font);
  textAlign(CENTER);
}

public void autoScanPorts(){
  if(Serial.list().length != numPorts){
    if(Serial.list().length > numPorts){
      println("New Ports Opened!");
      int diff = Serial.list().length - numPorts;	// was serialPorts.length
      serialPorts = expand(serialPorts,diff);
      numPorts = Serial.list().length;
    }else if(Serial.list().length < numPorts){
      println("Some Ports Closed!");
      numPorts = Serial.list().length;
    }
    refreshPorts = true;
    return;
}
}



class Radio {
  int _x,_y;
  int size, dotSize;
  int baseColor, overColor, pressedColor;
  boolean over, pressed;
  int me;
  Radio[] radios;

  Radio(int xp, int yp, int s, int b, int o, int p, int m, Radio[] r) {
    _x = xp;
    _y = yp;
    size = s;
    dotSize = size - size/3;
    baseColor = b;
    overColor = o;
    pressedColor = p;
    radios = r;
    me = m;
  }

  public boolean pressRadio(float mx, float my){
    if (dist(_x, _y, mx, my) < size/2){
      pressed = true;
      for(int i=0; i<numPorts+1; i++){
        if(i != me){ radios[i].pressed = false; }
      }
      return true;
    } else {
      return false;
    }
  }

  public boolean overRadio(float mx, float my){
    if (dist(_x, _y, mx, my) < size/2){
      over = true;
      for(int i=0; i<numPorts+1; i++){
        if(i != me){ radios[i].over = false; }
      }
      return true;
    } else {
      over = false;
      return false;
    }
  }

  public void displayRadio(){
    noStroke();
    fill(baseColor);
    ellipse(_x,_y,size,size);
    if(over){
      fill(overColor);
      ellipse(_x,_y,dotSize,dotSize);
    }
    if(pressed){
      fill(pressedColor);
      ellipse(_x,_y,dotSize,dotSize);
    }
  }
}
  public void settings() {  size(1200,800,P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ImPulse_Processing_03" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
