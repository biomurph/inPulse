/*

      InPulse 2021
      Modified for the inPulse v2 hardware

      Integrated the changes in InPulse_Prompt_Only_04
      
      CHANGE THE SYNC AND THE HRV TO PERFORM THE OPPOSITE TASKS!
      
      ADD INSTRUCTION PROMPTS!
      
*/

import processing.serial.*;
import java.lang.*;
import java.util.*;
import java.io.*;
import java.util.Properties;
import java.util.Date;
import javax.activation.*;
//import javax.mail.*;
//import javax.mail.internet.*;
//import http.requests.*;
//import java.net.*;
import java.io.FileWriter;
//import java.io.BufferedWriter;

//FileWriter fw;
//BufferedWriter bw;

//PrintWriter writer;
//BufferedReader reader;

//PGraphics inPulse;
//SyphonServer server;


PFont font;
PFont score;

Serial port;

final int OUT_HOLD = 0;
final int IN_HOLD = 1;
final int IN = 2;
final int OUT = 3;

final int TOTAL_BREATHS = 25;
final int WIDTH = 1200;
final int HEIGHT = 800;

//color black = color(261,99,21);
IntList dots;

boolean exitSetup = false;

void setup(){
  fullScreen(P2D,1);   // production target
  //size(3900,2200,P2D); // super big
  //size(1200,800,P2D);    // working on smaller screen
  //inPulse = createGraphics(1200, 800, P2D);
  //server = new SyphonServer(this, "inPulse Syphon");
  colorMode(HSB,360,100,100);
  frameRate(60);
  font = loadFont("Arial-BoldMT-24.vlw");
  score = loadFont("Baskerville-48.vlw");
  textFont(font);
  textAlign(LEFT);
  rectMode(CENTER);
  ellipseMode(CENTER);
  
  serialConnect();
  
  // DATA LOGGING SETUP
  thisHour = lastHour = hour();
  initLogFile();
  // CONNECTION SETUP
  initConnection();
  // BREATH STUP
	initBreathPrompt();

  initSensors();
  
  thatTime = millis();
  exitSetup = true;
}



void draw(){
  //inPulse.beginDraw();
  //inPulse.colorMode(HSB,360,100,100);
  if(serialPortFound){
    background(261,99,21);
    drawConnection();
    drawBreathPrompt();
    //printScore();
    printDataToScreen();

  } else { // SCAN TO FIND THE SERIAL PORT
      autoScanPorts();
      if(refreshPorts){
        refreshPorts = false;
        background(261,99,21);
        listAvailablePorts();
      }

      for(int i=0; i<numPorts+1; i++){
        button[i].overRadio(mouseX,mouseY);
        button[i].displayRadio();
      }

    }
    //inPulse.endDraw();
    //image(inPulse,0,0);
    //server.sendImage(inPulse);
}
