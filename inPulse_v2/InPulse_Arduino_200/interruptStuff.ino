



void setupInterrupt(){

  // Initializes Timer1 to throw an interrupt every 2mS.
  // Interferes with PWM on pins 9 and 10
  TCCR1A = 0x00;            // Disable PWM and go into CTC mode
  TCCR1C = 0x00;            // don't force compare
  #if F_CPU == 16000000L    // if using 16MHz crystal
    TCCR1B = 0x0C;          // prescaler 256
    OCR1A = 0x007C;         // count to 124 for 2mS interrupt
  #elif F_CPU == 8000000L   // if using 8MHz crystal
    TCCR1B = 0x0B;          // prescaler = 64
    OCR1A = 0x00F9;         // count to 249 for 2mS interrupt
  #endif
  TIMSK1 = 0x02;            // Enable OCR1A match interrupt  DISABLE BY SETTING TO 0x00
        
}


ISR(TIMER1_COMPA_vect)
{
  sampleCounter += 2;
  for(int i=0; i<2; i++){
    rawSignal[i] = analogRead(pulsePin[i]);
    EMA[i] = (EMA_a*float(rawSignal[i])) + ((1.0-EMA_a)*EMA[i]);  //run the EMA
    EMA_EMA[i] = (EMA_a*float(EMA[i])) + ((1.0-EMA_a)*EMA_EMA[i]); //run the double
    rectifiedSignal[i] = 512.0 - EMA_EMA[i];
    rmsSignal[i] = sqrt(sq(rectifiedSignal[i]));

    adjacentValue[i][0] = adjacentValue[i][1];
    adjacentValue[i][1] = adjacentValue[i][2];
    adjacentValue[i][2] = rmsSignal[i];
    if(derivativeCounter[i] > 2){
      firstDerivative[i] = (adjacentValue[i][2] - adjacentValue[i][0]);
    } else {
      derivativeCounter[i]++;
    }
    
    signalMean[i] = firstDerivative[i];  // EMA_EMA[i]; 
    for(int m=0; m<MEAN_SIZE-1; m++){
      signalMeanArray[m] = signalMeanArray[m+1];  // shift
      signalMean[i] += signalMeanArray[m];        // add
    }
    signalMean[i] /= MEAN_SIZE;                   // divide
    signalMeanArray[MEAN_SIZE-1] = firstDerivative[i];  // EMA_EMA[i]; // add to the FIFO
    
    Signal[i] = firstDerivative[i];  // sq(EMA_EMA[i] - emaMean[i]);
//    Signal[i] = constrain(Signal[i],0,3000);

    int n = sampleCounter - lastBeatTime[i];

    if(liveOne[i]){ 
        
        if(Signal[i] < lastSignal[i]){
          if(rising[i]){
            rising[i] = false;
            peak[i] = Signal[i];
            amp[i] = 0;
          }
        }else if(Signal[i] > lastSignal[i]){
          if(!rising[i]){
            rising[i] = true;
            trough[i] = Signal[i];
            amp[i] = peak[i] - trough[i]; // get the amplitude at the trough
            squaredAmp[i] = sq(amp[i]);
          }
        }
        lastSignal[i] = Signal[i];
        
      if(n > 300){// put in a time constraint here too?
        if(n > ((IBI[i] / 5) * 3)){ // adjust this as needed?
          if(squaredAmp[i] > threshold[i]){   // figure this is the pulse?
            threshold[i] = squaredAmp[i]/2;   // monitor the threshold value?
//            threshold[i] = constrain(threshold[i],800, 2000);
            IBI[i] = sampleCounter - lastBeatTime[i];
            BPM[i] = 60000/IBI[i];
            AMP[i] = squaredAmp[i];
            lastBeatTime[i] = sampleCounter;

            if(firstBeat[i]){
              firstBeat[i] = false; // throw away the first beat
              return; 
            }
            lastBeatSampleNumber[i] = sampleCounter;
            if(i == 0){ delta[0] = sampleCounter - lastBeatSampleNumber[1]; }
            if(i == 1){ delta[1] = sampleCounter - lastBeatSampleNumber[0]; }
            SYNC = min(delta[0],delta[1]);
            Pulse[i] = true;
            
          }
        }
      }

      } // if(liveOne)

        if(n > 1500){
          IBI[i] = 0; // 600;
          BPM[i] = 0;
          threshold[i] = 1000;
          Pulse[i] = false;
          firstBeat[i] = true;
          lastBeatTime[i] = sampleCounter;
        }



//    } // if(liveOne)
    
  }

}
