


void printRawSignal_Processing(){
  for(int i=0; i<2; i++){
    Serial.print(char('a'+i));
    if(liveOne[i]){ 
      Serial.println(rawSignal[i]);
    } else {
      Serial.println(512);
    }
  }
}

void printFilteredSignal_Processing(){
  for(int i=0; i<2; i++){
    Serial.print(char('a'+i));
    if(liveOne[i]){ 
      int mappedSignal = map(squaredAmp[i],0,5000,0,1000);
      Serial.println(mappedSignal);
    } else {
      Serial.println(0);
    }
  }
}

void printPulseData_Processing(){
  for(int i=0; i<2; i++){
    if(Pulse[i]){ // if we think we've found a beat
      Pulse[i] = false; // reset the flag
      Serial.print(char('M'+i)); Serial.println(IBI[i]); 
      Serial.print(char('A'+i)); Serial.println(BPM[i]); 
      Serial.print("X"); Serial.println(SYNC);
    }
  }
}

void printRawSignal_Plotter(){
  for(int i=0; i<2; i++){
    if(liveOne[i]){ 
//      Serial.print(rectifiedSignal[i]);
      Serial.print(firstDerivative[i]);
//      Serial.print(rawSignal[i]);
//      Serial.print(signalMean[i]);
    } else {
      Serial.print(0);
    }
    Serial.print(" ");
  }
}

void printFilteredSignal_Plotter(){
  for(int i=0; i<2; i++){
    if(liveOne[i]){ 
//      Serial.print(rmsSignal[i]);
      Serial.print(squaredAmp[i]);
//      Serial.print(amp[i]);
//      Serial.print(Signal[i]); 
//      Serial.print(" ");
    } else {
      Serial.print(0);
    }
    Serial.print(" ");
  }
}

void printAlgoData_Plotter(){
  for(int i=0; i<2; i++){
    if(liveOne[i]){
      Serial.print(threshold[i]); 
    } else {
      Serial.print(0);
    }
    Serial.print(" ");
  }
//  Serial.println();
}

void printPulseData_Terminal(){
  for(int i=0; i<2; i++){
    if(Pulse[i]){ // if we think we've found a beat
      Pulse[i] = false; // reset the flag
      Serial.print(i); Serial.print("  "); 
      Serial.print(IBI[i]); Serial.print("  "); 
      Serial.print(AMP[i]); Serial.print("  "); 
      Serial.println(BPM[i]);
    }
  }
}
