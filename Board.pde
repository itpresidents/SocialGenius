class Board {
  // define variables
  int tilesX, tilesY, clickX, clickY;
  int bWidth, bHeight,tHeight,tWidth;
  int gameStartTime, gameStopTime, gameErrors;
  Tile[][] theTiles;
  float _tID = -1;    // setting up tile ID number
  boolean tType = false;               // zero is an image tile and one is a text tile
  boolean initialPick = false;
  boolean responseReceived;
  int primaryTileID=0;   // this stores the information on clicked tiles
  int primaryTileX=0;
  int primaryTileY=0;
  int matchCount=0; 
  boolean newGame = true;
  String scoreText ="", gameOverText ="";


  Board(int _tilesX, int _tilesY, int _bWidth, int _bHeight) {
    tilesX = _tilesX;
    tilesY = _tilesY;
    bWidth = _bWidth;
    bHeight = _bHeight;
    tHeight = bHeight/tilesY;
    tWidth = bWidth/tilesX;
    theTiles = new Tile[tilesX][tilesY];

  }


  void render() {
    gameStartTime = millis();
    newGame = false;
    gameErrors = 0;
    scoreText ="";
    gameOverText ="";

    /*
    if(applauseSound != null) {
     applauseSound.destroy(); 
     }
     */

    glassSound = new AudioChannel("glass.wav"); 
    feile1Sound= new AudioChannel("feile1.wav"); 
    float[] dbNums = new float[dbSize];
    for(int i=0; i<dbSize; i++) {
      dbNums[i]=i;
    }
    RandArray dbSet = new RandArray(dbNums);
    float dbSubset[] = new float[tilesX*tilesY/2];
    for(int i=0; i<tilesX*tilesY/2; i++) {
      dbSubset[i]=dbSet.pick();
    }
    RandArray dbIDImage = new RandArray(dbSubset); // create a random bucket to pick Image numbers from
    RandArray dbIDText = new RandArray(dbSubset); // ...and the same for Text
    for(int j=0; j<tilesY; j++) {
      if (tilesX%2 == 0) { // if tilesX is even
        tType=!tType;      //  then start each row with the same type as the previous one ended
      }
      for(int i=0; i<tilesX; i++) {
        tType=!tType;
        if(tType == false) {
          _tID = dbIDImage.pick();
        }
        else {
          _tID = dbIDText.pick();
        }
        int tID = round(_tID);

        /////////// DESTROY AUDIO CHANNELS FOR EACH TILE ///////////
        if (theTiles[i][j] != null) {    // if this tile exists
          if(theTiles[i][j].fName != null) { // and if this tile has a first name
            theTiles[i][j].fName.destroy();  // destroy the channel for that name 
          }
          if(theTiles[i][j].lName != null) {
            theTiles[i][j].lName.destroy();
          }
          if(theTiles[i][j].pName != null) {
            theTiles[i][j].pName.destroy();
          }
        }

        ////////////////////////////////////////////////////////////

        //// CREATE THE TILES ////
        theTiles[i][j] = new Tile(tWidth/2+(i*tWidth), tHeight/2+(j*tHeight), tWidth, tHeight,tID,tType);
      }
    }

    for(int j=0; j<tilesY; j++) {
      for(int i=0; i<tilesX; i++) {
        theTiles[i][j].state=0;
      }
    }
    drawBoard();
  }

  void drawBoard() {
    //draws the board

      message = "SOCIAL GENIUS (v."+version+")" +"                                    ROUND: " + theGame.thisRound + " of " + theGame.maxRounds + "    SCORE: "+ theGame.score + "                                           Press Q to quit";

    for(int j=0; j<tilesY; j++) {
      for(int i=0; i<tilesX; i++) {
        theTiles[i][j].render();
      }
    }
    textSize(bFontSize);
    fill(20, 100, 255);
    textAlign(CENTER); // center the text on the xy coordinates
    text(scoreText,bWidth/2,bHeight/2-(bHeight/14)); // show the score text, if any
    text(gameOverText,bWidth/2,bHeight/2+(bHeight/14));  // show the game over text, if any
  }

  void clickedOn(int _clickX, int _clickY) {
    // what to do when the mouse is clicked
    clickX = _clickX;
    clickY = _clickY;
    if(newGame==true) {
      matchCount=0;      // resets the counter for a new game
      theGame.newBoard();
    }

    // sets the appropriate tile to its clicked upon state
    for(int j=0; j<tilesY; j++) {
      for(int i=0; i<tilesX; i++) {
        if (theTiles[i][j].isInside(clickX,clickY)) {
          theTiles[i][j].changeState();
          theTiles[i][j].playSound();
        }
      }
    }
    // this is the primary game logic
    int clickedCount=0;                         // initialize counter for clicked tiles
    for(int j=0; j<tilesY; j++) {
      for(int i=0; i<tilesX; i++) {
        if (theTiles[i][j].state==1) {          // if a tile has been clicked
          clickedCount=clickedCount+1;
          if(initialPick == false) {             // and it's the first clicked tile we've seen
            primaryTileID=theTiles[i][j].tID;  // remember its ID number
            primaryTileX = i;                 // and record the X & Y location
            primaryTileY = j;
            initialPick = true;            //   and record that we've seen a clicked tile
            theTiles[i][j].render();
          }
          else if (initialPick==true && ((primaryTileX != i) || (primaryTileY != j))) {   
            // if this is the second clicked tile (there's a first pick and the row or column of this this is different)
            if( (primaryTileID==theTiles[i][j].tID)
              || (theTiles[primaryTileX][primaryTileY].tTypeName.equals(theTiles[i][j].tTypeName) 
              && theTiles[primaryTileX][primaryTileY].tType != (theTiles[i][j].tType)) ) { //see if there's a match with the first
              matchCount=matchCount+1; // adding up the number of matches
              theTiles[i][j].state=2;
              theTiles[i][j].render();
              theTiles[primaryTileX][primaryTileY].state=2;
              theTiles[primaryTileX][primaryTileY].render();
              glassSound.stop();
              glassSound.play();
            }
            else if (theTiles[primaryTileX][primaryTileY].tType == (theTiles[i][j].tType)) { // if the same tile type was clicked
              theTiles[i][j].changeState();
              theTiles[i][j].render();
              theTiles[primaryTileX][primaryTileY].changeState();
              theTiles[primaryTileX][primaryTileY].render();
            }
            else {
              // if this tile is not a match
              theTiles[i][j].changeState();
              theTiles[i][j].render();
              theTiles[primaryTileX][primaryTileY].changeState();
              theTiles[primaryTileX][primaryTileY].render();
              gameErrors = gameErrors + 1;
              feile1Sound.stop();
              feile1Sound.play();
            }
            initialPick=false;
          }
        }
      }
    }
    if(clickedCount==0) {
      // if no tiles are clicked
      initialPick=false;
      theTiles[primaryTileX][primaryTileY].render();
    }

    if(matchCount>=tilesX*tilesY/2) {
      // if all of the tiles have been clicked
      gameStopTime = millis();                                     // record the time that game ended
      String gameTime;
      int gameLength = (gameStopTime-gameStartTime); // calculate length of game in milliseconds
      if (gameLength >= 20000) {
        gameTime = str(int(gameLength / 1000));    // round game length to no decimal places
      }
      else if (gameLength >= 10000) {
        gameTime = str(float(int(gameLength / 100))/10);    // round game length to 1 decimal place
      }
      else {
        gameTime = str(float(int(gameLength / 10))/100);    // round game length to 2 decimal places
      }
      theGame.score += constrain( 1000 - (gameLength/100) - (gameErrors * 30), 5, 1000);

      /////////HIGH SCORES DATA FILE MANAGEMENT\\\\\\\\\\
      String[] scoreData = loadStrings("scores.csv"); // load the scores file
      String[][] scoreArray;
      scoreArray = new String[scoreData.length+1][3];
      for(int i=0; i<scoreData.length; i++) {
        scoreArray[i] = (split(scoreData[i],',')); // split the data into a two-dimensional array database
      }
      scoreArray[scoreArray.length-1][0] = gameTime;
      scoreArray[scoreArray.length-1][1] = str(gameErrors);
      Calendar rightNow = Calendar.getInstance();
      scoreArray[scoreArray.length-1][2] = str(rightNow.getTimeInMillis());
      // Calendar backThen = Calendar.getInstance(); //USE THIS LATER TO RETREIVE A TIME FROM THE DATABASE
      // backThen.setTimeInMillis(rightNowInMillis); //USE THIS LATER TO RETREIVE A TIME FROM THE DATABASE
      String[] joinedScores;
      joinedScores = new String[scoreArray.length];
      for (int i=0; i<joinedScores.length; i++) {
        joinedScores[i] = join(scoreArray[i], ",");
      }
      if (online == false) {// don't save files in web applet mode
        saveStrings("data/scores.csv",joinedScores);
      }
      //////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\

      glassSound.destroy(); 
      feile1Sound.destroy(); 
      applauseSound = new AudioChannel("applause.wav"); 
      applauseSound.stop();
      applauseSound.play();
      newGame=true;
      if (gameErrors==1) {  // with one error don't pluralize the text
        scoreText = ("Round " + (theGame.thisRound) + " of " + theGame.maxRounds +",  Score: " + theGame.score);
      }
      else {  // with multiple or zero errors, pluralize the text
        scoreText = ("Round " + (theGame.thisRound) + " of " + theGame.maxRounds +",  Score: " + theGame.score);
      }
      if (touchScreenMode) {
        gameOverText =  ("Tap Screen to Continue");
      }
      else {
        gameOverText =  ("Click to Continue");
      }
    }
  }
}
