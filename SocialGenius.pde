
// http://www.faludi.com/socialgenius
// this program creates a board of picture and name tiles that can be matched together

import krister.Ess.*;  // import Ess library by Krister Olsson, http://www.tree-axis.com/Ess/

String version = "2.0.9";
int tilesX = 5;    // number of tiles across
int tilesY = 4;     // number of tiles down *** the product of these two must be even! ***
int bWidth = 800;  // width of window *** set this manually below too
int bHeight = 640; // height of window *** set this manually below too
int tFontSize = 20; // size of tile font
int bFontSize = 40; // size of board font
int numHighScores = 10;
int idleTime, timeOut, idleSince, maxIdle;
String[] data;
String[][] database;
String[] firstnames; 
String[] lastnames;
String[] bothnames;
String[] names;
String[] images;
String nameMode, message;
PImage[] tImage;
int dbSize;        // size of the database
Game theGame;
Board theBoard;
String[][] scoreArray;
Scores[] theScores;
PFont tFont, tFont20, tFontItal, mFont;
AudioChannel softclickSound;
AudioChannel glassSound;
AudioChannel applauseSound;
AudioChannel feile1Sound;
AudioChannel socialGeniusSound;
AudioChannel[] voiceSounds;
int myDebugCounter, voiceMode, heartbeatColor;
int heartbeatSign=1;
boolean playVoices, touchScreenMode, alreadyLoaded; 

/*static public void main(String args[]) {
 PApplet.main(new String[] { "--present", "--display=1", "--bgcolor=#555555", "SocialGenius" });
}*/

void setup() {
  size(800,660); // *** this has to be set manually so that export to the web works *** use bWidth and bHeight+20
  smooth();
  Ess.start(this);
  theGame = new Game();
  theBoard = new Board(tilesX,tilesY,bWidth,bHeight);
  tFont = loadFont("Futura-Medium-40.vlw");
  tFont20 = loadFont("Futura-Medium-20.vlw");
  tFontItal = loadFont("Futura-MediumItalic-40.vlw");
  mFont = loadFont("Menlo-Regular-48.vlw");
  data = loadStrings("matchdata.csv"); // load the main data file
  dbSize=data.length;                  // get the length of the file
  database = new String[dbSize][4];    // initialize strings for databases
  firstnames = new String[dbSize];
  lastnames = new String[dbSize];
  bothnames = new String[dbSize];
  images = new String[dbSize];
  for(int i=0; i<dbSize; i++) {
    database[i] = (split(data[i],',')); // split the data into a two-dimensional array database
  }
  for(int i=0; i<dbSize; i++) {
    firstnames[i] = database[i][3];    // load the data into individual variables
    lastnames[i] = database[i][2];
    bothnames[i] = database[i][3]+" "+database[i][2];
    images[i] = database[i][0];
  }
  tImage = new PImage[dbSize];
  softclickSound= new AudioChannel("softclick.wav"); 
  glassSound=new AudioChannel("glass.wav"); 
  feile1Sound=new AudioChannel("feile1.wav"); 
  socialGeniusSound = new AudioChannel("SocialGenius.wav");
  alreadyLoaded=true;
  openingScreen();
  idleTime = millis();
}



void draw() {
  if( (millis()-idleTime) / 1000 /60 > 1) { // if the program has been idle for more than 5 minutes
    openingScreen();
    //theBoard.newGame=true;
    newGame();
    println("reload");
    idleTime = millis();
  }
theGame.show();
}

void newGame() {
  theGame = new Game();
}

void openingScreen() {
  touchScreenMode=false;  // when set to true,  text and cursor are optimized for touch screen
  voiceMode = 1;        // sets the voices to original mode
  nameMode = "First";
  playVoices=true;
  names = firstnames;                  // start the game with first names
  if (touchScreenMode) {
    noCursor(); 
  }
  else {
    cursor(HAND); 
  }
}

void mousePressed() {
  theGame.mousePressed();
}

void keyPressed() {
  theGame.keyPressed();
}



public void stop() { 
  Ess.stop();
  super.stop(); 
} 
