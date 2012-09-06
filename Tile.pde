class Tile {
  // define variables
  int x, y, tHeight, tWidth, tID;
  int state;
  color tColor;
  boolean tType;
  String tTypeName;
  AudioChannel fName, lName, pName;


  Tile(int _x, int _y, int _tHeight, int _tWidth, int _tID, boolean _tType) {
    x = _x;
    y = _y;
    tHeight =  _tHeight;
    tWidth = _tWidth;
    tID = _tID;
    tType = _tType;                                     // false = photo tile, true = text tile
    tColor = color(204, 153, 0);
    state = 0;                                          // 0 = not clicked, 1 = clicked, 2 = matched correctly
    // File f = new File(dataPath("images/"+images[tID]+".jpg"));   // check if the file exists
    // if (f.exists() && tImage[tID] == null)   {      //if this image exists and isn't already loaded 
    if (tImage[tID] == null)   {      //if this image exists and isn't already loaded 
        tImage[tID] = loadImage("images/"+images[tID]+".jpg");   // load the image now
      
    }
  }


  void render() {
    // draws the tiles on the screen
    //code for rendering including tile postiion, image, border
    strokeWeight(2);
    stroke(0);
    if(state==0) {  // tile is not clicked
      tColor = color(255, 255, 255);
      tint(255, 255, 255);
    }
    else if(state==1) {  // tile is clicked
      tColor = color(50, 210, 255);
      tint(50, 210, 255);
    }
    else {  // tile is correctly matched
      tColor = color(30,30,30);
      tint(255, 255, 255);
    }
    fill(tColor);
    rectMode(CENTER);
    rect(x,y,tWidth,tHeight);
    fill(0);
    float tBorder = tWidth/8;
    tTypeName=names[tID];
    if (tType==false) {
      if (tImage[tID] != null) {  // if an image exists
      
        float imgWidth = tWidth-tBorder;
        float imgHeight = (imgWidth/tImage[tID].width) * tImage[tID].height;
      
        image(tImage[tID], x+(tBorder/2)-tWidth/2, y+(tBorder/2)-tHeight/2, imgWidth, imgHeight);
//        image(tImage[tID], x+(tBorder/2)-tWidth/2, y+(tBorder/2)-tHeight/2, tWidth-tBorder,tHeight-tBorder);
      }
      else { // if there isn't an image, use text instead
        textAlign(CENTER); // center the text on the xy coordinates
      textFont(tFont20,tFontSize-4);
      text( "*image missing *\n(" + tTypeName +")",x,y+8);
      }
      if (state == 2) {
        noStroke();
        fill(0,0,0,100);
        rect(x,y+tHeight/2.75,tWidth-tBorder,tHeight/5);
        textAlign(CENTER); // center the text on the x coordinate
        fill(255);
        textFont(tFont20,tFontSize);
        text(tTypeName,x,y+(tHeight/2.45));
      }
    }
    else {
      fill(0);
      if (state ==2) {
        fill(30);       // set this to something else if you've like the names to stay visible
      }
      textAlign(CENTER); // center the text on the xy coordinates
      textFont(tFont20,tFontSize+2);
      text(tTypeName,x,y+8);
    } 
    ////////// LOAD THE VOICE SOUNDS /////////////
    if (online == false) { // don't deal with voices in online applet mode
    if (voiceMode == 1) { //ORIGINAL MODE: place with face and name with name
      if (tType == true &&  playVoices) {
        File f = new File(dataPath("sounds/"+images[tID]+"firstname.wav"));   // check if the file exists
        if (f.exists() && fName == null)   {                          //if the file does exist and it isn't loaded
          fName =  new AudioChannel("sounds/"+images[tID]+"firstname.wav"); 
        }


        f = new File(dataPath("sounds/"+images[tID]+"lastname.wav"));   // check if the file exists
        if (f.exists() && lName == null)  {                          //if the file does exist and it isn't loaded
          lName =  new AudioChannel("sounds/"+images[tID]+"lastname.wav"); 
        }
      }

      if (tType == false && playVoices) {
        File f = new File(dataPath("sounds/"+images[tID]+"placename.wav"));   // check if the file exists
        if (f.exists() && pName == null)   {                          //if the file does exist and it isn't loaded
          pName =  new AudioChannel("sounds/"+images[tID]+"placename.wav");
        }
      }
    }


    if (voiceMode == 2) {  //EASY MODE: name with both
      if (playVoices) {
        File f = new File(dataPath("sounds/"+images[tID]+"firstname.wav"));   // check if the file exists
        if (f.exists() && fName == null)    {                          //if the file does exist and it isn't loaded
          fName = new AudioChannel("sounds/"+images[tID]+"firstname.wav"); 
        }

        f = new File(dataPath("sounds/"+images[tID]+"lastname.wav"));   // check if the file exists
        if (f.exists() && lName == null)   {                          //if the file does exist and it isn't loaded
          lName = new AudioChannel("sounds/"+images[tID]+"lastname.wav"); 
        }
      }
    }


    if (voiceMode == 3) {  //NAME ONLY
      if (tType == true &&  playVoices) {
        File f = new File(dataPath("sounds/"+images[tID]+"firstname.wav"));   // check if the file exists
        if (f.exists() && fName == null)    {                          //if the file does exist and it isn't loaded
          fName =  new AudioChannel("sounds/"+images[tID]+"firstname.wav"); 
        }
        f = new File(dataPath("sounds/"+images[tID]+"lastname.wav"));   // check if the file exists
        if (f.exists() && lName == null)   {                          //if the file does exist and it isn't loaded
          lName =  new AudioChannel("sounds/"+images[tID]+"lastname.wav");  
        }
      }
    }
    }
  }


  void changeState() {
    // changes the tiles between clicked and unclicked states
    if (state==0) {
      state=1;
    }
    else if(state==1) {
      state = 0;
    }
  }

  void playSound() {

    if (state==1 && theBoard.initialPick == false && playVoices) {
      if (voiceMode == 1) {
        if (tType==false && pName != null) {
          pName.stop();
          pName.play();
        }
        if (tType==true && nameMode=="First" && fName != null) {
          fName.stop();
          fName.play();
        }
        else if (tType==true && nameMode=="Last" && lName != null) {
          lName.stop();
          lName.play();
        }
        else if (tType==true && nameMode=="Both" && lName != null && fName != null) {
          fName.stop();
          fName.play();
        }
      }
      else if (voiceMode == 2) {
        if (nameMode=="First" && fName != null) {
          fName.stop();
          fName.play();
        }
        else if (nameMode=="Last" && lName != null) {
          lName.stop();
          lName.play();
        }
        else if (nameMode=="Both" && lName != null && fName != null) {
          fName.stop();
          fName.play();
        }
      }
      else if (voiceMode == 3) {
        if (tType==true && nameMode=="First" && fName != null) {
          fName.stop();
          fName.play();
        }
        else if (tType==true && nameMode=="Last" && lName != null) {
          lName.stop();
          lName.play();
        }
        else if (tType==true && nameMode=="Both" && lName != null && fName != null) {
          fName.stop();
          fName.play();
        }
      }
    }
  }


  boolean isInside(float clickX, float clickY) {
    // check if the click is inside this particular tile
    float xDist = abs(clickX-x);
    float yDist = abs(clickY-y); 
    if (xDist < tWidth/2 && yDist < tHeight/2) {
      return true;
    } 
    else {
      return false;
    }
  }
}
