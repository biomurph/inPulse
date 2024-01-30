

// BREATH PROMPT STUFF
// color of biggest ellipse
final float breathInHue = 207.0;
final float breathInSat = 99.0;
final float breathInBri = 99.0;
// color of smallest ellipse
final float breathOutHue = 240.0;
final float breathOutSat = 40.0; 
final float breathOutBri = 93.0; 
// color of fading ellipse
float thisBreathHue;
float thisBreathSat;
float thisBreathBri;
final int IN_HOLD_DURATION = 100;
final int OUT_HOLD_DURATION = 50;
final float maxBreathAlpha = 230;
float breathAlpha = maxBreathAlpha;
int holdCount;
int holdDuration;
float a = 0;
int breathing = OUT;
int breathCenterX;
int breathCenterY;
float lastBreathX;
float breathXmax = 3400.0;
float breathYmax = 1800.0;
float breathXmin = 400.0;  // 200?
float breathYmin = 200.0;  // 150?
float breathX = breathXmin;
float breathY = breathYmin;
float breathXstep = (breathXmax-breathXmin)/180.0;
float breathYstep = (breathYmax-breathYmin)/180.0;
float breathCycle; // = 60.0 / 6.0; // 10.0;
float breatheIn = 0.9; // 60.0 / 10.0;
float breatheOut = 0.5; //60.0 / 5.0;
float angle;

long thatTime;
int thisTime;


int breathCounter = 0;


void drawBreathPrompt() {
  // float r = ((millis()/1000.0)/breathCycle)*360;
  angle = radians(a);
  float s = sin(angle);
  // lastBreathX = breathX;
  breathX = 200 + (sin(angle) * breathXmax/2) + breathXmax/2;
  breathY = 150 + (sin(angle) * breathYmax/2) + breathYmax/2;

  thisBreathHue = map(breathX, breathXmin, breathXmax, breathOutHue, breathInHue);
  thisBreathSat = map(breathX, breathXmin, breathXmax, breathOutSat, breathInSat);
  thisBreathBri = map(breathX, breathXmin, breathXmax, breathOutBri, breathInBri);
  noStroke();
  fill(thisBreathHue, thisBreathSat, thisBreathBri, breathAlpha);
  //println("red "+thisBreathRed+" green "+thisBreathGreen+" blue "+thisBreathBlue);
  ellipse(breathCenterX, breathCenterY, breathX, breathY);

  if (breathX < lastBreathX && breathing == IN ) {
    breathing = IN_HOLD;
    holdCount = 0;
    holdDuration = IN_HOLD_DURATION;
    breathCycle = breatheOut;
    if (scoreState == BREATHE_IN) { 
      scoreState = HOLD_IN; 
      textFadeValue = -10;
    }
  }
  if (breathX > lastBreathX && breathing == OUT) {
    breathing = OUT_HOLD;
    holdCount = 0;
    holdDuration = OUT_HOLD_DURATION;
    breathCycle = breatheIn;
    if (scoreState == BREATHE_OUT) { 
      scoreState = HOLD_OUT; 
      textFadeValue = -25;
    }
  }
  lastBreathX = breathX;
  if (breathing == IN_HOLD || breathing == OUT_HOLD) {
    holdCount++;
    if (holdCount > holdDuration) {
      if (breathing == OUT_HOLD) {
        breathing = IN;
        thisTime = int(millis() - thatTime);
        thatTime = millis();
        //println(thisTime + "mS   " + nf(60000.0/float(thisTime),0,1) + " breaths/min   "
        //        +nf(breatheIn,0,1) +" in   " + holdDuration + " hold   " + nf(breatheOut,0,1) + " out");
        breathCounter++;
        //countBreaths();
        println("breathCounter "+breathCounter);
      }
      if (breathing == IN_HOLD) {
        breathing = OUT;
        if (scoreState == HOLD_IN) { 
          scoreState = BREATHE_OUT; 
          textFadeValue = -20;
        }
      }
    }
    return;
  }
  a += breathCycle;
  // println(r);
}


void initBreathPrompt() {
  breathCycle = breatheOut;
  breathCenterX = width/2;
  breathCenterY = height/2;
  // size the breath prompt to the screen
  breathXmax = width * 0.80;
  breathYmax = height * 0.75;
}


void countBreaths() {
  switch(breathCounter) {
  case TOTAL_BREATHS:
    breathCounter = -5;
    scoreState = CLASP;
    textFadeValue = 1;
    dotFadeCounter = 1;
    break;
  case -4:
    scoreState = BREATHE_IN;
    textFadeValue = -20;
    break;
  case -3:
    scoreState = BREATHE_IN;
    textFadeValue = -5;
    break;
  case -2:
    scoreState = SPHERES;
    textFadeValue = -5;
    break;
  case -1:
    scoreState = COLORS;
    textFadeValue = -20;
    break;
  case 0:
    scoreState = END_SCORE;
    textFadeValue = -2;
    dotFadeCounter = 1;
    break;
  case 1:
    scoreState = NO_PROGRESS;
    break;
  default:
    break;
  }
}
