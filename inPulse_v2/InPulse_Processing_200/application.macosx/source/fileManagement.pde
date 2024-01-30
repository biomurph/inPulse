


boolean logFileExists = false;
String logFilePath = "/Users/joelmurphy/Desktop";
String logFileName = "";
boolean stamp = true;
int thisHour;
int lastHour;


void logWriteSample(){
  String sample = livePlayers +","+ IBI[0] +","+ HRV[0] +","+ meanHRV[0] +","+ IBI[1]
                       +","+ HRV[1] +","+ meanHRV[1] +","+ SYNC +","+ targetSync;
  logWrite(sample);
}

void logWrite(String s){
  //println(s);
  thisHour = hour();
  if(thisHour != lastHour){
    lastHour = thisHour;
    //if(thisHour == 23){
    //  emailLogs();
    //}
    if(thisHour == 0){
      String today = year()+"_"+month()+"_"+day();
      logFileName = "inPulse_"+today+".csv";
    }
  }
  
  // println(sketchPath());
  try {
    logFilePath = "/Users/joelmurphy/Desktop/logs/" + logFileName;
    FileWriter output = new FileWriter(logFilePath, true);
    if(stamp){ output.write(timeStamp()+","); }
    output.write(s +"\n");
    output.flush();
    output.close();
  }

  catch(IOException e) {
    println("Event Log Write Failure");
    e.printStackTrace();
  }

  }

void initLogFile(){
  String today = year()+"_"+month()+"_"+day();
  logFileName = "inPulse_"+today+".csv";
  logWrite("Log Opened In Setup");
  stamp = false;
  logWrite("Time Stamp,Live Players,IBI[0],HRV[0],meanHRV[0],IBI[1],HRV[1],meanHRV[1],SYNC,targetSync");
  stamp = true;
}

String timeStamp(){
  String s = hour()+":"+minute()+":"+second();
  return s;
}
