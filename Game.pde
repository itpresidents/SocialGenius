class Game {
  int creationTime, score, thisRound, maxRounds, scroller, scrollDelay, initialScrollDelay, followingScrollDelay, splashGray, splashGrayDirection, splashTime, now;
  boolean showSplash, showSummary, showHighScore;
  Scores theScores[];
  String keyboardInput, initials;


  Game() {
    maxRounds = 3;
    thisRound = 0;
    creationTime=millis();
    keyboardInput="";
    initials="";
    showSplash = true;
    splashTime = millis();
    initialScrollDelay = 4*30; // time in seconds times frame rate to delay before showing high scores
    followingScrollDelay = 60*30; // time in seconds times frame rate to delay before showing high score
    scrollDelay = initialScrollDelay;
    splashGrayDirection = -1;
  }

  void show() {
    // displays the appropriate game elements
    smooth();
    textFont(tFont,bFontSize);
    background(0);
    if (showSplash == true) {
      if (millis()-splashTime < 5*60*1000) {
        renderSplash();
        scrollDelay = initialScrollDelay; // and reset the summary screen
      }
      else if (millis()-splashTime < 2*5*60*1000 ) {
        renderSummary();
      }
      else {
        splashTime = millis();
      }
    }
    else if (showHighScore == true && online == false) {
      renderHighScore();
    }
    else if (showSummary == true) {
      renderSummary();
    } 
    else {
      theBoard.drawBoard();
      scrollDelay = initialScrollDelay;  // and reset the summary screen
    } 

    fill(255);
    rectMode(CORNERS);
    rect(0,bHeight,width,height);
    fill(0);
    textFont(mFont,9);
    textAlign(LEFT);
    text(message,10,bHeight+13);
    heartbeat();

  }


  void heartbeat() {
    if (heartbeatColor == 126 || heartbeatColor == 0) {
      heartbeatSign = heartbeatSign * -1; 
    }
    heartbeatColor =  (heartbeatColor + heartbeatSign ) % 127;
    noStroke();
    fill(heartbeatColor*2);
    rect(width-2,height-2,width,height);
  }

  void mousePressed() {
    softclickSound.stop();
    softclickSound.play();
    initials = keyboardInput;  // get initials if user clicks on score rather than hitting enter

    if (showHighScore == true) {
      if (online == true) { // if we're online we're skipping the high score stuff so we create a new game right away
        newGame();
      }
      ; // ignore clicks on high score screen
    }
    else if (showSummary == true) {
      captureScore();
      newGame();
    }
    else if (showSplash == true) {
      socialGeniusSound.play();
      showSplash = false;
      newBoard();
    }
    else {
      theBoard.clickedOn(mouseX,mouseY);
    }

    idleTime = millis();

  }


  void keyPressed() {
    if(showHighScore == true) {     // if we are currently accepting keyboard input
      if (key == ENTER && keyboardInput.length() >= 2) {
        initials = keyboardInput;
        keyboardInput = "";
        setHighScore();
        showHighScore = false;
      }
      if (key != CODED && key != ENTER) {      // (the docs say that the enter key is coded, but it's not)
        if (key == BACKSPACE && keyboardInput.length() > 0) {       // handle deleting text
          keyboardInput = keyboardInput.substring(0,keyboardInput.length()-1); // only delete text if it exists
        }
        else if (keyboardInput.length() <= 2) {                     // add each keypress to the previous ones
          keyboardInput = keyboardInput+key;
          initials = "";  // clear the previous entry
        }
      }
    }

    else if (key=='f' || key=='F') {
      tFontSize = 20; // size of tile font
      names = firstnames;
      nameMode="First";
    }
    else if (key=='l' || key=='L') {
      tFontSize = 20; // size of tile font
      names = lastnames;
      nameMode="Last";
    }
    else if (key=='+') {
      playVoices=true;
    }  
    else if (key=='-') {
      playVoices=false;
    }
    else if (key=='b' || key=='B' || key=='m' || key=='M' ) {
      tFontSize = 14; // size of tile font
      names = bothnames;
      nameMode="Both";
    } 

    else if (key=='t' || key=='T') {
      touchScreenMode = !touchScreenMode;
      if (touchScreenMode) {
        noCursor(); 
      }
      else {
        cursor(HAND); 
      }
    }
    else if (theBoard != null && (key == 'Q' || key == 'q')) { // deals with quitting the game, outside of the high score screen
      newGame();
    }



    else if (key=='1') { //ORIGINAL MODE
      voiceMode=1;
    }
    else if (key=='2') { // EASY MODE
      voiceMode=2;
    }
    else if (key=='3') { //NAME ONLY
      voiceMode=3;
    }

    else if (theBoard.newGame == false) {
      theBoard.drawBoard();
    }
    idleTime = millis();
  }


  void newBoard() {
    if (thisRound >= maxRounds) {  // if this is the last round
      if (checkHighScore() == true) {
        showHighScore = true;
      }
      showSummary = true;
    }
    else {
      thisRound = thisRound +1;
      theBoard = new Board(tilesX, tilesY, bWidth, bHeight);
      theBoard.render();
    }
  }



  void renderSplash () {
    if (splashGray > 254 || splashGray < 1) {
      splashGrayDirection = splashGrayDirection * -1;
    }
    if (millis() - now >= 1000*15 && creationTime > 1000*60*10) {
      splashGray = constrain((splashGray + splashGrayDirection), 0 , 255);
      now = millis();
    }
    background(0); //background(splashGray);
    fill(255); //fill(255-((round(float(splashGray)/255.0)*255)));
    textSize(40);
    textAlign(CENTER); // center the text on the xy coordinates
    text("Social Genius",bWidth/2,bHeight/2-50);
    if (touchScreenMode) {
      text("Tap Screen to Begin",bWidth/2,bHeight/2+50); 
    }
    else {
      text("Click to Begin",bWidth/2,bHeight/2+50); 
    }
    textSize(9); 
    textAlign(RIGHT);
    text("v "+version+" by Rob Faludi", bWidth-3, bHeight-6);
    message = "SOCIAL GENIUS (v."+version+")  keys: \"F\" = first names \"L\" = last names \"B\" = both names  Sound:\"1\" = name/place \"2\" = easy \"3\" = name only ";
  }

  void renderHighScore () {
    String dashes = "";
    for (int i=0; i<(3-keyboardInput.length()); i++) {
      dashes = dashes + "_";
    }
    background(0);
    fill(255);
    textSize(40);
    textAlign(CENTER); // center the text on the xy coordinates
    text(theGame.score + " is a High Score! (Top "+numHighScores+")",width/2,height/2-150);
    text("Type Your Initials: " + keyboardInput + dashes,width/2,height/2);
    text("Press Enter to Continue",width/2,height/2+150);
  }


  void renderSummary () {
    background(0);
    fill(255);
    textSize(40);
    textAlign(CENTER); // center the text on the xy coordinates
    text("Game Over",width/2,height/2-150+scroller);
    if (theGame.score > 0 ) {
      text("Your Score: " + theGame.score,width/2,height/2+scroller);
    }
    text("Click to Continue",width/2,height/2+150+scroller);
    if (online == false ) {
      text("High Scores",width/2,height+150+scroller);
      getHighScores();
      for (int i=0; i<scoreArray.length; i++) {
        if(scoreArray[i][0] != null) {
          text((i+1) + ".   " + scoreArray[i][1] + "   " + scoreArray[i][0] + " points",width/2,height+300+scroller+(i*(150)));
        }
      }
      if (scrollDelay > 0) {
        scrollDelay--;
      }
      else if (scroller > (((150 * numHighScores)+height+300)*-1) ) {
        scroller--;
      }
      else {
        scroller = 0;
        scrollDelay = followingScrollDelay;
      }
    }
  }


  void captureScore() {

    ///////// SCORES DATA FILE MANAGEMENT\\\\\\\\\\
    String[] allscoreData = loadStrings("scores.csv"); // load the scores file
    String[][] allscoreArray;
    allscoreArray = new String[allscoreData.length+1][5];
    for(int i=0; i<allscoreData.length; i++) {
      allscoreArray[i] = (split(allscoreData[i],',')); // split the data into a two-dimensional array database
    }
    allscoreArray[allscoreArray.length-1][0] = str(theGame.score);
    allscoreArray[allscoreArray.length-1][1] = initials;
    allscoreArray[allscoreArray.length-1][2] = str(theGame.maxRounds);
    allscoreArray[allscoreArray.length-1][3] = str(timeOut);
    Calendar rightNow = Calendar.getInstance();
    allscoreArray[allscoreArray.length-1][4] = str(rightNow.getTimeInMillis());
    // Calendar backThen = Calendar.getInstance(); //USE THIS LATER TO RETREIVE A TIME FROM THE DATABASE
    // backThen.setTimeInMillis(rightNowInMillis); //USE THIS LATER TO RETREIVE A TIME FROM THE DATABASE
    String[] joinedScores;
    joinedScores = new String[allscoreArray.length];
    for (int i=0; i<joinedScores.length; i++) {
      joinedScores[i] = join(allscoreArray[i], ",");
    }
    if (online == false) { // don't save files in web applet mode
      saveStrings("data/scores.csv",joinedScores);
    }
    //////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
  }

  void getHighScores() {
    String[] scoreData = loadStrings("highscores.csv"); // load the scores file
    scoreArray = new String[scoreData.length+1][5];
    for(int i=0; i<scoreData.length; i++) {
      scoreArray[i] = (split(scoreData[i],',')); // split the data into a two-dimensional array database
    }
  }

  boolean checkHighScore() {
    getHighScores();
    boolean highScore = false;
    if (scoreArray.length < numHighScores) {  // if we haven't maxed out on high scores then this is one too
      highScore = true;
    }
    else if (int(scoreArray[scoreArray.length-2][0]) < theGame.score) { // otherwise, check the last (lowest) score to see if we beat it
      highScore = true;
    }
    return highScore;
  }


  void setHighScore() {
    getHighScores();
    // add the new high score to the Array
    scoreArray[scoreArray.length-1][0] = str(theGame.score);
    scoreArray[scoreArray.length-1][1] = initials;
    scoreArray[scoreArray.length-1][2] = str(theGame.maxRounds);
    scoreArray[scoreArray.length-1][3] = str(timeOut);
    Calendar rightNow = Calendar.getInstance();
    scoreArray[scoreArray.length-1][4] = str(rightNow.getTimeInMillis());
    // Calendar backThen = Calendar.getInstance(); //USE THIS LATER TO RETREIVE A TIME FROM THE DATABASE
    // backThen.setTimeInMillis(rightNowInMillis); //USE THIS LATER TO RETREIVE A TIME FROM THE DATABASE

    theScores = new Scores[scoreArray.length];
    for (int i=0; i<theScores.length; i++) {
      theScores[i] = new Scores(int(scoreArray[i][0]), scoreArray[i][1], scoreArray[i][2], scoreArray[i][3], scoreArray[i][4]);
    }
    sortScores();

    int numToSave = numHighScores;
    if (theScores.length < numHighScores) {
      numToSave = theScores.length;
    }

    String[][] scoreSave;
    scoreSave = new String[numToSave][5];
    for (int i=0; i<numToSave; i++) { // get the scores back, dropping the last one if it's over the max
      scoreSave[i][0] = str(theScores[i].score);
      scoreSave[i][1] = theScores[i].initials;
      scoreSave[i][2] = theScores[i].maxRounds;
      scoreSave[i][3] = theScores[i].timeOut;
      scoreSave[i][4] = theScores[i].datetime;
    }
    String[] joinedScores;
    joinedScores = new String[scoreSave.length];
    for (int i=0; i<joinedScores.length; i++) {
      joinedScores[i] = join(scoreSave[i], ",");
    }
    if (online == false) {
      saveStrings("data/highscores.csv",joinedScores);
    }
  }


  void sortScores() { 
    for (int i = 0; i < theScores.length; i++) {
      int biggest = theScores[i].score;
      int biggestIndex = i;
      for (int j = i; j < theScores.length; j++) {
        if (theScores[j].score > biggest)  {
          biggest = theScores[j].score;
          biggestIndex = j; 
        }
      }
      // SWAP TWO ELEMENTS
      Scores temp = theScores[i];
      theScores[i] = theScores[biggestIndex];
      theScores[biggestIndex] = temp;
    }

  }
}


class Scores {
  int score, dateTimeInMillis;
  String initials, maxRounds, timeOut, datetime, scoreText;

  Scores(int score_, String initials_, String maxRounds_, String timeOut_, String datetime_) {
    score = score_;
    initials = initials_;
    maxRounds = maxRounds_;
    timeOut = timeOut_;
    datetime = datetime_;
  }
}



