


void keyPressed(){

 switch(key){
   case 's':    // pressing 's' or 'S' will take a jpg of the processing window
   case 'S':
     saveFrame("inPulse-####.jpg");      // take a shot of that!
     break;
   case 'm':
     //emailLogs();
     println("email logs not enabled");
     break;
   case 'l':
     println("Request to write sample to file");
     logWriteSample();
     break;
  // clear the screen when you press 'R' or 'r'
   //case 'r':
   //case 'R':
   //  resetVariables(0);
   //  resetVariables(1);
   //  break;
   //case 'W':
   //case 'w':
   //  //showWave = !showWave;
   //  break;
   //case '1':
   //  breatheIn += 0.1;
   //  breatheIn = constrain(breatheIn, 0.1, 1.0);
   //  println("breatheIn: " + nf(breatheIn,0,1));
   //  break;
   //case '2':
   //  breatheIn -= 0.1;
   //  breatheIn = constrain(breatheIn, 0.1, 1.0);
   //  println("breatheIn: " + nf(breatheIn,0,1));
   //  break;
   //case '3':
   //  //breathCycle = 60 / 5.0;
   //  break;
   //case '4':
   //  //breathCycle = 60 / 5.5;
   //  break;
   //case '5':
   //  holdDuration += 5;
   //  holdDuration = constrain(holdDuration, 5, 100);
   //  println("hold: " + holdDuration);
   //  break;
   //case '6':
   //  holdDuration -= 5;
   //  holdDuration = constrain(holdDuration, 5, 100);
   //  println("hold: " + holdDuration);
   //  break;
   //case '7':
   //  //breathCycle = 60 / 7.0;
   //  break;
   //case '8':
   //  //breathCycle = 60 / 7.5;
   //  break;
   //case '9':
   //  breatheOut += 0.1;
   //  breatheOut = constrain(breatheOut, 0.1, 1.0);
   //  println("breatheOut: " + nf(breatheOut,0,1));
   //  break;
   //case '0':
   //  breatheOut -= 0.1;
   //  breatheOut = constrain(breatheOut, 0.1, 1.0);
   //  println("breatheOut: " + nf(breatheOut,0,1));
   //  break;
   default:
     break;
 }
}
