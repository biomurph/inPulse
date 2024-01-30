
String serialPort;
String[] serialPorts = new String[Serial.list().length];
boolean serialPortFound = false;
Radio[] button = new Radio[Serial.list().length*2];
int numPorts = 0;
boolean refreshPorts = false;



void serialEvent(Serial port){
  boolean logData = false;
try{
   String inData = port.readStringUntil('\n');
   inData = trim(inData);                 // cut off white space (carriage return)

 for(int i=0; i<numSensors;i++){
   if (inData.charAt(0) == 'a'+i){           // leading 'a' for sensor data
     inData = inData.substring(1);           // cut off the leading 'a'
     Sensor[i] = int(inData);                // convert the string to usable int
   }
   if (inData.charAt(0) == 'A'+i){           // leading 'A' for BPM data
     inData = inData.substring(1);           // cut off the leading 'A'
     BPM[i] = int(inData);                   // convert the string to usable int
     logData = true;
   }
   if (inData.charAt(0) == 'M'+i){             // leading 'M' means IBI data
       inData = inData.substring(1);           // cut off the leading 'M'
       IBI[i] = int(inData);                   // convert the string to usable int
       beat[i] = true;                         // set beat flag to advance heart rate graph
       HRV[i] = getHRV(i);
       meanHRV[i] = getMeanHRV(HRV[i]);    // do we need meanHRV?
       logData = true;
     }
   }
   
   if (inData.charAt(0) == 'X'){             // leading 'X' means SYNC data
     inData = inData.substring(1);           // cut off the leading 'T'
     SYNC = int(inData);                      // convert the string to usable int
     targetSync = getTargetSync(SYNC);
     logData = true;
   }
   
   if (inData.charAt(0) == '*'){             // leading '*' means Lead Off
     inData = inData.substring(1);           // 
     resetVariables(int(inData));            // 
     countPlayers(int(inData),0);
     println("* "+int(inData));
     logData = true;
   }
   
   if (inData.charAt(0) == '$'){             // leading '$' means Lead On
     inData = inData.substring(1);
     countPlayers(int(inData),1);
     println("$ "+int(inData));
     logData = true;
   }
   
   if(logData){
     logWriteSample();
   }

} catch(Exception e) {
  print("Serial Error: ");
  println(e.toString());
}

}


void serialConnect(){
  println(Serial.list());    // print a list of available serial ports to the console
  // serialPorts = Serial.list();

  try{
    // make sure Arduino is talking serial at 250000 baud
    port = new Serial(this, Serial.list()[Serial.list().length-2], 250000);
    delay(500);
    println(port.read());
    port.clear();            // flush buffer
    port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
    serialPortFound = true;
    println("Connected to "+Serial.list()[Serial.list().length-2]);
  }
  catch(Exception e){
    println("Couldn't open port " + Serial.list()[Serial.list().length-2]);
    if(exitSetup){
      fill(255);
      textFont(font,16);
      text("Couldn't open port " + Serial.list()[Serial.list().length-2],60,70);
      textFont(font);
    }
  }

}


void listAvailablePorts(){
  println(Serial.list());    // print a list of available serial ports to the console
  serialPorts = Serial.list();
  fill(255);
  textFont(font,16);
  // set a counter to list the ports backwards
  int yPos = 0;

  for(int i=numPorts-1; i>=0; i--){
    button[i] = new Radio(35, 95+(yPos*20),12,color(180),color(80),color(255),i,button);
    text(serialPorts[i],50, 100+(yPos*20));
    yPos++;
  }
  int p = numPorts;
   //inPulse.fill(255);
  button[p] = new Radio(35, 95+(yPos*20),12,color(180),color(80),color(255),p,button);
    text("Refresh Serial Ports List",50, 100+(yPos*20));

  textFont(font);
}

void autoScanPorts(){
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
