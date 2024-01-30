

final int NO_PROGRESS = 0;
final int CLASP = 1;
final int BREATHE_IN = 2;
final int HOLD_IN  = 3;
final int BREATHE_OUT = 4;
final int HOLD_OUT = 5;
final int SPHERES = 6;
final int COLORS = 7;
final int END_SCORE = 8;
final int SCORE_BREATHS = 2;

int scoreState;
String scoreText1 = "";
String scoreText2 = "";
String scoreText3 = "";
float scoreTextY = 375;
float scoreTextLineSpace = 25;
float textFade;
float textFadeValue;
int scoreBreathCount = 0;


void printScore(){
  
  switch(scoreState){
    case CLASP:
      scoreText1 = "";
      scoreText2 = "GRIP THE SENSORS GENTLY";
      scoreText3 = "IN YOUR PALMS";
      break;
    case BREATHE_IN:
      if(textFade == 0){
        textFadeValue = 20;
        scoreText1 = "";
        scoreText2 = "BREATHE IN";
        scoreText3 = "";
      }
      break;
    case HOLD_IN:
      if(textFade == 0){
        textFadeValue = 20;
        scoreText1 = "";
        scoreText2 = "HOLD YOUR BREATH";
        scoreText3 = "";
      }
      break;
    case BREATHE_OUT:
      if(textFade == 0){
        textFadeValue = 20;
        scoreText1 = "";
        scoreText2 = "BREATHE OUT";
        scoreText3 = "";
      }
      break;
    case HOLD_OUT:
      if(textFade == 0){
        textFadeValue = 20;
        scoreText1 = "";
        scoreText2 = "HOLD YOUR BREATH";
        scoreText3 = "";
      }
      break;
    case SPHERES:
      if(textFade == 0){
        textFadeValue = 20;
        scoreText1 = "";
        scoreText2 = "THE SPHERES EXPAND";
        scoreText3 = "AS YOU BECOME CALMER";
      }
      break;
    case COLORS:
      if(textFade == 0){
        textFadeValue = 20;
        scoreText1 = "IF YOU ARE WITH SOMEONE ELSE";
        scoreText2 = "THE COLOR BECOMES VIOLET AS";
        scoreText3 = "YOUR HEART BEATS SYNC";
      }
      break;
    case END_SCORE:
      break;
    case NO_PROGRESS:
      scoreText1 = "";
      scoreText2 = "";
      scoreText3 = "";
      break;
    default:
      break;
  }
  if(scoreState > NO_PROGRESS){
    textFont(score,24);
    textAlign(CENTER);
    textFade += textFadeValue;
    textFade = constrain(textFade,0,255);
    fill(255,textFade);
    pushMatrix();
    translate(width/2, height/2); // Translate to the center
    rotate(radians(90));          // Rotate by radians(degree)
    text(scoreText1, 0, scoreTextY-scoreTextLineSpace); 
    text(scoreText2, 0, scoreTextY); 
    text(scoreText3, 0, scoreTextY+scoreTextLineSpace); 
    rotate(radians(180));
    text(scoreText1, 0, scoreTextY-scoreTextLineSpace); 
    text(scoreText2, 0, scoreTextY); 
    text(scoreText3, 0, scoreTextY+scoreTextLineSpace); 
    popMatrix();
    textFont(font);
    textAlign(LEFT);
  }
  
}
