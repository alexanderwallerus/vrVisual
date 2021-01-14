//Code by Alexander Wallerus, MIT license

import java.awt.Robot;           //robot for reading in the screen
import java.awt.Rectangle;

import java.awt.MouseInfo;       //mouse position
import java.awt.Point;
Point mouse;

import java.awt.Toolkit;         //screen sizes and positions
import java.awt.GraphicsConfiguration;
GraphicsConfiguration graConf;
import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;

Robot robot;

//hardcoded values that won't change in the very specific setup this was 
//programmed for
PVector readScreens0pos = new PVector(1280, 74);
PVector readScreens1pos = new PVector(5376, 74);
PVector readScreens2pos = new PVector(6400, 74);
PVector screenWH = new PVector(1024, 1280);
int shapeWidth = 300;       //actual values: ~303 (outsidemost) to ~295 (insidemost)
//shapeMinWidth = 215;      //214 pixels width if shape crosses screens at its center
int shapeMaxHiddenPixels = 85;     //=> the size of pixels between screens
//=> totalreadScreensW = 3242;     //3*w + 2*85
PVector visScreensTopLeft = new PVector(2304, 74);

CurrentShape s;
boolean blackOut = true;             //start with nothing seen

int sketchSize = 700;                //width and height of the moving sketch
float halfWidth = 171;
PImage original;
PImage[] textures;
PImage curTexture;

boolean left = true;
float thetaIncrement = 0.05;  //resolution of the shape contour, 0.002 looks good,
                              //0.5 runs faster, 0.05 seems reasonable middle ground.

int customCenterOffset = 540; //offset the shape further from or closer to the center
int fps = 120;                //maximum fps, default 120, only ~60 fps achievable here
int textSpeed = 4;            //default value: 7
float shapeScale = 1.4;       //default value 1.0. 
                              //at shapeScale = 0.5 the shape will be half the size,
                              //at 1.5 it will be 1.5 times as large
void init(){
  frame.removeNotify();
  frame.setUndecorated(true);
  frame.addNotify();
  if(shapeScale > 1.0){
    sketchSize *= shapeScale;
  }
  super.init();
}

void setup(){
  size(sketchSize, sketchSize, P2D); 
  println("sketch started");
  //can output debugging info into a txt file like this, when run from batch file
  //saveStrings("test.txt", args);
  
  //processing2 when run as sketch has the directory as arg[0],
  //as .exe it doesn't => args then are the given arg[0], arg[1]...
  if(args.length>0){              
    if(args[0].equals("left")){
      left = true;
      println("running left sketch");
    } else if(args[0].equals("right")){
      left = false;
      println("running right sketch"); 
    }
  }
  
  frame.setLocation(0, 0);         //will get overwritten at first frame
  frame.toFront();
  frame.requestFocus();
  frame.setVisible(true);
  frame.setAlwaysOnTop(true);

  frameRate(fps);                  

  try {
    robot = new Robot();
  } 
  catch(Exception e) {
    println("Robot class not supported by your system!");
    e.printStackTrace();
  }

  s = new CurrentShape();
  
  textures = new PImage[256];
  for(int i=0; i<textures.length; i++){
    textures[i] = null;    //create textures as they are needed
  }
  original = loadImage("original.png");
  //this is the reference default texture (brightness==1.0)
  
  curTexture = new PImage();
}

PImage screen0;
PImage screen1;
PImage screen2;

void draw(){
  //using only a size 700*700 sketch and moving the sketch around allows higher 
  //frameRates, than what would be possible drawing one sketch over 3 screens 
  //=> good approach for limited setup
  background(0, 0, 0);

  //println("frameRate: " + frameRate);      

  //readScreenBorders();
  //mouse = MouseInfo.getPointerInfo().getLocation();
  //println("mouse at: " + mouse);
  
  //y = 130 instead of screenWH/2 because the right sketch may move over the left 
  //middle part of readScreens1, but its top still nicely shows the shape to read from
  screen0 = new PImage(robot.createScreenCapture(new Rectangle(
                       int(readScreens0pos.x), int(readScreens0pos.y + 130), 
                       int(screenWH.x), 1)));  
  screen1 = new PImage(robot.createScreenCapture(new Rectangle(
                       int(readScreens1pos.x), int(readScreens1pos.y + 130), 
                       int(screenWH.x), 1)));  
  screen2 = new PImage(robot.createScreenCapture(new Rectangle(
                       int(readScreens2pos.x), int(readScreens2pos.y + 130), 
                       int(screenWH.x), 1)));   
  ////mirrors for debugging what the program sees                 
  //image(screen0, 0, 0, sketchWidth, 1);    
  //image(screen1, 0, 1, sketchWidth, 1);
  //image(screen2, 0, 2, sketchWidth, 1); 

  PImage[] screens = new PImage[]{screen0, screen1, screen2};
  color[] allPixels = new color[]{};
  for(int i=0; i<screens.length; i++){
    screens[i].loadPixels();
    allPixels = concat(allPixels, screens[i].pixels);
    screens[i].updatePixels();
  }
  //println(allPixels.length);    3072 = 1024x3, 606 pixels with red(col) == 255

  boolean found = false;
  int outerMost = left?0:allPixels.length-1;       //for left shape, the leftMost
  int innerMost = left?allPixels.length-1:0;       //for left shape the rightMost
  
  if(left){                              //go from the left to the right
    for(int i=0; i<allPixels.length; i++){
      if(!found && red(allPixels[i]) == 255){
        found = true;
        outerMost = i;
      }
      if(found && red(allPixels[i]) == 0){
        innerMost = i;
        break;                           //shape complete
      }
    }
  } else {                               //go from the right to the left
    for(int i=allPixels.length-1; i>=0; i--){
      if(!found && red(allPixels[i]) == 255){
        found = true;
        outerMost = i;
      }
      if(found && red(allPixels[i]) == 0){
        innerMost = i;
        break;    
      }
    }
  }
  if(found){
    int idxShapeDirRotated, idxShapeInterpBright;
    if(left){
      idxShapeDirRotated = outerMost + 7;
      idxShapeInterpBright = innerMost - 7;
    } else {
      idxShapeDirRotated = innerMost + 7;
      idxShapeInterpBright = outerMost - 7;
    }
    //make certain the idx is valid:
    idxShapeDirRotated = constrain(idxShapeDirRotated, 0, allPixels.length-1);
    idxShapeInterpBright = constrain(idxShapeInterpBright, 0, allPixels.length-1);
    
    s.dirForw = green(allPixels[idxShapeDirRotated]) > 127;
    s.rotated = blue(allPixels[idxShapeDirRotated]) > 127;
    s.shapeInterp = map(green(allPixels[idxShapeInterpBright]), 0, 255, 0, 1);
    int brightInt = int(blue(allPixels[idxShapeInterpBright]));
    s.bright = map(brightInt, 0, 255, 0.1, 1.9);

    //the original vr setup renders as if there are ~85 pixels between screens 
    //(shapeMaxHiddenPixels) => for simplicity, we will map the position onto a total
    //width of only 3 screens for now.
    int sideFactor = left?+1:-1;
    int screenBorder = left?1024:2047;

    //by default the shape starts on the outer screen => take innermost shape edge
    //and add the pixels between the screens to its position
    int pos = innerMost - (shapeMaxHiddenPixels*sideFactor); 
    if(innerMost == screenBorder){
      //the shape is partly at the screen border => take outermost
      pos = outerMost + (shapeWidth*sideFactor) - (shapeMaxHiddenPixels*sideFactor);
    } else if (  (left && innerMost > screenBorder) || 
                (!left && innerMost < screenBorder) ){
      pos = innerMost;
    }
    //map it from a position on 3 screens + 2*85 in-between to a position on 3 screens
    pos = int(map(pos, -shapeMaxHiddenPixels, allPixels.length + shapeMaxHiddenPixels,
                  0, 3*screenWH.x));
    pos = int(map(pos, 0, 3*screenWH.x, 
                  0-customCenterOffset, 3*screenWH.x+customCenterOffset));
    
    if( (left && outerMost > 1300) || (!left && outerMost <1700)){  
      //the shape has jumped in the VR, a single shape shown at the center now
      s.dirForw = green(allPixels[allPixels.length/2 - 7]) > 127;
      s.rotated = blue(allPixels[allPixels.length/2 - 7]) > 127;
      s.shapeInterp = map(green(allPixels[allPixels.length/2 + 7]), 0, 255, 0, 1);
      brightInt = int(blue(allPixels[allPixels.length/2 + 7]));
      s.bright = map(brightInt, 0, 255, 0.1, 1.9);
      
      pos = int(3*screenWH.x/2 + (shapeWidth/2));
      sideFactor = 1;
      //textPos may differ from the originally moved shape's textPos if the other 
      //sketch happens to be in the foreground
    }
    s.x = int(visScreensTopLeft.x + 
              pos - ((shapeWidth/2) *sideFactor)         //now at center of shape
              - width/2);       //sketch position is defined by the top left edge

    //lerping to help smooth out possible position jitter from issues of the 
    if(blackOut){         //input program. don't lerp if comming from a blackout
      s.prevX = s.x;
      blackOut = false;
    } else {
      s.x = lerp(s.prevX, s.x, 0.7);
      s.prevX = s.x;
    }

    if(s.dirForw){
      s.textPos += textSpeed;
    } else {
      s.textPos -= textSpeed;
    }
    //the texture was made to loop every 288 pixels
    s.textPos %= 288;
    if(s.textPos < 0){
      s.textPos += 288;
    }

    brightInt = constrain(brightInt, 0, 255);  //make sure it is valid
    if(textures[brightInt] == null){
      //println("creating new brigthness: " + millis());
      //this texture has not been needed so far. quickly create it.
      createBrightness(brightInt);
      //println("new brigthness complete: " + millis());
    }
    curTexture = textures[brightInt]; 

    //set the x translation to the point at which the rectangle should be centered
    translate(width/2, height/2);
    
    //use this code block to resize the sketch window whenever it would infringe
    //into a readScreen to the left or right. 
    //This would enable arbitrary large shapeScales if needed.
    //int sketchW = sketchSize;    //default width and location
    //int sketchL = int(s.x);
    //if(s.x < visScreensTopLeft.x){
    //  sketchW = int(sketchSize - (visScreensTopLeft.x - s.x));
    //  sketchL = int(visScreensTopLeft.x);
    //  translate(s.x - visScreensTopLeft.x, 0);
    //} else if(s.x + sketchSize >= readScreens1pos.x){
    //  sketchW = int(sketchSize - (s.x + sketchSize - readScreens1pos.x));
    //}
    //frame.setBounds(new Rectangle(sketchL,  //combines .setLocation() and .setSize()
    //                int(visScreensTopLeft.y + (screenWH.y/2) - sketchSize/2),
    //                sketchW, sketchSize));
                    
    frame.setLocation(int(s.x),
                      int(visScreensTopLeft.y + (screenWH.y/2) - sketchSize/2));  
    
    renderImage(curTexture, s.shapeInterp, 
                s.rotated, s.textPos,
                s.bright);
  } else {
    blackOut = true;
  }
}

void keyPressed(){
  if (key == 's'){
    left = !left;  //swap left/right
  }
  if(key == '='){
    customCenterOffset++;
  }
  if(key == '-'){
    customCenterOffset--;
  }
}

class CurrentShape{
  float prevX = 0;
  float x = 0;
  boolean rotated = false;
  float shapeInterp = 0.5;
  float bright = 1.0;
  boolean dirForw = true;
  int textPos = 0;

  CurrentShape(){
  }
}

PVector polarToCircleVert(float theta) {
  float r = halfWidth;
  PVector vert = polarToCartesian(r, theta);
  return vert;
}

//for efficiency do not create a new PVector at every angle of theta
PVector squareVert;
PVector circVert;
PVector vert;
PVector textVert;

void renderImage(PImage text, float shapeInterp, boolean rotated, float textPos, 
                 float bright){
  strokeWeight(8*shapeScale);
  stroke(0, constrain(159*bright, 0, 255), constrain(9*bright, 0, 255));
  noFill();
  if(rotated){
    rotate(HALF_PI);
  }
  //y scaling will stretch a square/circle into a rectangle/ellipse
  //y = 684 pixels, x = 334 pixels. 2.020 is a bit below this ratio
  //but reflects the original image measurements
  float yScaling = 2.020;  
  textureMode(IMAGE);
  rectMode(CENTER);
  beginShape();
  texture(text);

  for(float theta=0; theta<TWO_PI; theta+=thetaIncrement){
    //slightly increase theta to increase speed
    squareVert = polarToSquareVert(theta);
    circVert = polarToCircleVert(theta);
    vert = PVector.lerp(squareVert, circVert, shapeInterp);
    textVert = new PVector(map(vert.x, -halfWidth, halfWidth, 0, 334),
                           map(vert.y , -halfWidth, halfWidth, 0, 684));
    vert.mult(shapeScale);
    vertex(vert.x, vert.y*yScaling, textVert.x + textPos, textVert.y);
  }
  endShape(CLOSE);
}

PVector polarToSquareVert(float theta){
  float r = 0;
  if(theta < QUARTER_PI){
    //cos(theta) = (w/2)/r => for w==100 the hypothenuse r = 50/cos(theta)
    r = halfWidth/cos(theta);
  } else if(theta < HALF_PI+QUARTER_PI){
    //sin(theta) = (h/2)/r
    r = halfWidth/(sin(theta));
  } else if(theta < PI+QUARTER_PI){
    r = -halfWidth/cos(theta);
  } else if(theta < TWO_PI-QUARTER_PI){
    r = -halfWidth/(sin(theta));
  } else {
    r = halfWidth/cos(theta);
  }
  PVector vert = polarToCartesian(r, theta);
  return vert;
}

PVector polarToCartesian(float r, float theta) {
  return new PVector(r*cos(theta), r*sin(theta));
}

PImage brightScaled;

void createBrightness(int brightIdx){
  float bright = map(brightIdx, 0.0, 255.0, 0.1, 1.9);
  brightScaled = createImage(original.width, original.height, RGB);
  //all pixels hex(brightScaled.pixels[pixelPos] are set to 00000000 on creation
  //=>alpha=0, r=0, g=0, b=0. a pixel set to a red value of 10 would be FF0A0000
  original.loadPixels();
  brightScaled.loadPixels();
  for(int y=0; y<original.height; y++){
    for(int x=0; x<1000; x++){                  //original.width would take 40ms
      int pixelPos = x + y*original.width;      //instead of 25ms per created scaling
      color col = original.pixels[pixelPos];    //and the created texture will only
      float r = red(col)*bright;                //have the leftmost 1000 pixels
      r = constrain(r, 0, 255);                 //anyway
      float g = green(col)*bright;
      g = constrain(g, 0, 255);
      float b = blue(col)*bright;
      b = constrain(b, 0, 255);
      brightScaled.pixels[pixelPos] = color(r, g, b);
    }
  }
  original.updatePixels();
  brightScaled.updatePixels();
  textures[brightIdx] = createImage(1000, brightScaled.height, RGB);
  textures[brightIdx].copy(brightScaled, 
                      0, 0, textures[brightIdx].width, textures[brightIdx].height,
                      0, 0, textures[brightIdx].width, textures[brightIdx].height);
}

void readScreenBorders() {
  println("main screen", Toolkit.getDefaultToolkit().getScreenSize());
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  GraphicsDevice[] gs = ge.getScreenDevices();
  for (int i=0; i<gs.length; i++) {
    GraphicsDevice gd = gs[i];
    println(gd);
    GraphicsConfiguration[] gc = gd.getConfigurations();
    Rectangle virtualBounds = new Rectangle();
    for (int j=0; j< gc.length; j++) {
      virtualBounds = gc[j].getBounds();
      println(virtualBounds + "\n");
    }
  }
}

//notes on performance/framerate:
//This code runs at ~62 fps on the commercial VR set up computer with shapeScale 1.0.
//resizing the shapes through its vertices doesn't seem to matter for the framerate.
//Using a look-up-table calculated during setup() for the vertices of various 
//interpolations(0.0, 0.1, 0.2,...0.9, 1.0) doesn't seem to make a real difference,
//too (maybe 62fps to 63fps).
//Calculating a texture with a new brightness takes ~25ms => can do this each time 
//a new brightness is encountered => 25ms during only a few loads won't be noticable.
//=> no need to keep and be limited to precreated brightness texture .pngs and
//vertex look-ups. Can just as well calculate them when needed.
