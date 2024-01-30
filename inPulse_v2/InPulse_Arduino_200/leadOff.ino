



int readLeadOffPins(){

  for(int p=0; p<NUM_LEAD_OFF_PINS; p++){
    leadOffValue[p] = digitalRead(leadOffPin[p]);
    if(leadOffValue[p] != lastLeadOffValue[p]){
      
      lastLeadOffValue[p] = leadOffValue[p];
//      Serial.print(p); Serial.print("\t"); Serial.println(leadOffValue[p]);
      if((leadOffValue[0] == 0) && (leadOffValue[1] == 0)){
        liveOne[0] = true;
        Serial.print("$"); Serial.println(0);
      } else {
        liveOne[0] = false;
        Serial.print("*"); Serial.println(0);
        lastBeatSampleNumber[0] = 0;
        SYNC = 0;
      }
      if((leadOffValue[2] == 0) && (leadOffValue[3] == 0)){
        liveOne[1] = true;
        Serial.print("$"); Serial.println(1);
      } else {
        liveOne[1] = false;
        Serial.print("*"); Serial.println(1);
        lastBeatSampleNumber[1] = 0;
        SYNC = 0;
      }
      
    }
  }

}
