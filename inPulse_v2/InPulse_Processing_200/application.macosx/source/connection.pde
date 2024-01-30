
/*

     
*/


// CONNECTION STUFF
final int MIN_SYNC = 600;  // actual SYNC values
final int MAX_SYNC = 1;
final int MIN_HRV = 2;   // actual IBI values
final int MAX_HRV = 800; 
float maxHRVweight; // = 100;
float minHRVweight; // = 45;
int frameCounter = 1;
// low HRV color
final float syncLowHue = 407; //360+47;
final float syncLowSat = 94; 
final float syncLowBri = 81;
// high HRV color
final float syncHighHue = 214;
final float syncHighSat = 80;
final float syncHighBri = 73;
// drawn HRV color
float syncHue;
float syncSat;
float syncBri;
float[][] fadeDistance;
float maxDistance;
float targetHRVweight; // = minHRVweight;
float currentHRVweight; // = minHRVweight;
float HRVweight;
int[] runningSync = new int[5];  // average sync to avoid jittery
int[] runningHRV = new int[5];
int currentSync = MIN_SYNC;
int targetSync = MIN_SYNC;
int currentHRV = MIN_HRV;
int targetHRV = MIN_HRV;
boolean connecting = true;
int pointCount;
int syncGrowthFactor = 2;
int HRVgrowthFacor = 1;
float[] pointWeight;
int dotFadeCounter = 0;

int dotSpacer;

int hrvTotal;

int livePlayers;
int [] player = new int[2];

void drawConnection(){
  if(frameCounter == pointCount){
    frameCounter = 0;
    dots.shuffle();
    
  }
  
  // adjust for no players or one player
  if(livePlayers < 2){ targetSync = MIN_SYNC; }
    if(currentSync < targetSync){
      currentSync += syncGrowthFactor;
    } else if(currentSync > targetSync){
      currentSync -= syncGrowthFactor;
    }
  currentSync = constrain(currentSync, MAX_SYNC, MIN_SYNC);
  //println("curentSync "+currentSync);
  syncHue = map(currentSync,MIN_SYNC,MAX_SYNC,syncLowHue,syncHighHue);
  syncSat = map(currentSync,MIN_SYNC,MAX_SYNC,syncLowSat,syncHighSat);
  syncBri = map(currentSync,MIN_SYNC,MAX_SYNC,syncLowBri,syncHighBri);
  if(syncHue > 359){ syncHue -= 359; }
  
  if(livePlayers > 0){
    targetHRV = HRV[0] + HRV[1];
    if(livePlayers == 1){ targetHRV*= 2; }
  } else {
    targetHRV = MIN_HRV;
  }
  if(currentHRV < targetHRV){
    currentHRV += HRVgrowthFacor;
  } else if(currentHRV > targetHRV){
    currentHRV -= HRVgrowthFacor;
  }
  currentHRV = constrain(currentHRV,MIN_HRV, MAX_HRV);
  HRVweight = map(currentHRV,MIN_HRV,MAX_HRV,minHRVweight,maxHRVweight);
  
  //println("targetHRV: "+targetHRV+" hrv: "+currentHRV+" weight: "+HRVweight);
    // 24 dots by 16 dots
    // 1920 x 1080 = dotSpacer 
   int _x;
   int pointCounter = 0;
   int yCounter = 0;
   //println("pointCount "+pointCount);
   for (int y = 0; y < height-dotSpacer/2; y+=dotSpacer) { //-dotSpacer/2
     yCounter++;
      for (int x = 0; x < width-dotSpacer; x+=dotSpacer) {
        if(breathCounter < 0){
          float fadeOut = fadeDistance[x][y] - dotFadeCounter;
          fadeOut = constrain(fadeOut,0,fadeDistance[x][y]);
          stroke(syncHue, syncSat, syncBri, fadeOut);
        } else if(breathCounter == 0){
          float fadeIn = dotFadeCounter;
          fadeIn = constrain(fadeIn,0,fadeDistance[x][y]);
          stroke(syncHue, syncSat, syncBri, fadeIn);
        } else {
          stroke(syncHue, syncSat, syncBri, fadeDistance[x][y]);
        }
				if(yCounter % 2 == 0){
          _x = x + dotSpacer/2;  // this ofsets the rows
        } else {
          _x = x;
        }
        //println(pointCounter);
        //println(frameCounter);
        if(frameCounter == dots.get(pointCounter)){
            pointWeight[pointCounter] = HRVweight;
            //println("dot "+pointCounter);
        }
        strokeWeight(pointWeight[pointCounter]);
        point(_x + dotSpacer/2, y + dotSpacer/2);
        pointCounter++;
      }
    }
    frameCounter++;
    dotFadeCounter++;
}

void initConnection(){
  maxDistance = dist(width/2, height/2, width, height);
  fadeDistance = new float[width][height];
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      float distance = dist(width/2, height/2, x, y);
      fadeDistance[x][y] = distance/maxDistance * 255; // this sets an alpha fade?
    }
  }
  
  dotSpacer = height/16;
  minHRVweight = dotSpacer * 0.85;
  maxHRVweight = dotSpacer * 2.0;
  targetHRVweight = minHRVweight;
  currentHRVweight = minHRVweight;
  pointCount = int((width/dotSpacer)*(height/dotSpacer));
  println("pointCount " + pointCount);
  dots = new IntList();
  pointWeight = new float[pointCount];
  for(int i=0; i<pointCount; i++){
    pointWeight[i] = HRVweight;
    dots.append(i);  
  }
  for(int i=0; i<runningSync.length; i++){
    runningSync[i] = MIN_SYNC;
  }
  for(int i=0; i<runningHRV.length; i++){
    runningHRV[i] = MIN_HRV;
  }
  //lastSync = currentSync;
  dots.shuffle();
  //println("curentSync "+currentSync);
}

int getTargetSync(int s){
  int runningTotal = 0;
  for(int i=0; i<runningSync.length-1; i++){
    runningSync[i] = runningSync[i+1];
    runningTotal += runningSync[i];
  }
  runningSync[runningSync.length-1] = s;
  runningTotal += s;
  return runningTotal/runningSync.length;
}

int getMeanHRV(int h){
  int runningTotal = 0;
  for(int i=0; i<runningHRV.length-1; i++){
    runningHRV[i] = runningHRV[i+1];
    runningTotal += runningHRV[i];
  }
  runningHRV[runningHRV.length-1] = h;
  runningTotal += h;
  return runningTotal/runningHRV.length;
}

void countPlayers(int p, int g){
  player[p] = g;
  livePlayers = player[0] + player[1];
  println("livePlayers: "+livePlayers);
  switch(livePlayers){
    case 0:
      targetHRV = MIN_HRV;
      //add sync reset here too?
      //reset running averages
      break;
    default:
      break;
  }
}
