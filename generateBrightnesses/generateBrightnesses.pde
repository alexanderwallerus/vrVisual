//this code produces textures based on original.png with the brightness scaled up or
//down by the provided factors. It was written for an earlier version of this 
//program which used precalculated textures, but may still find usage in the future.

PImage original; 

void setup(){
  original = loadImage("original.png"); //this file will be the same as brightness1.0
  float[] brightnesses = new float[]{0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0,
                                     1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9};
  for(float bright : brightnesses){
    PImage brightScaled = createImage(original.width, original.height, RGB);
    original.loadPixels();
    brightScaled.loadPixels();
    for(int y=0; y<original.height; y++){
      for(int x=0; x<original.width; x++){
          int pixelPos = x + y*original.width;
          color col = original.pixels[pixelPos];
          float r = red(col)*bright;
          r = constrain(r, 0, 255);
          float g = green(col)*bright;
          g = constrain(g, 0, 255);
          float b = blue(col)*bright;
          b = constrain(b, 0, 255);
          brightScaled.pixels[pixelPos] = color(r, g, b);
        }
      }
    original.updatePixels();
    brightScaled.updatePixels();
    PImage cutOff = createImage(1000, brightScaled.height, RGB);
    cutOff.copy(brightScaled, 0, 0, cutOff.width, cutOff.height,
                              0, 0, cutOff.width, cutOff.height);
    //cutOff.resize(int(cutOff.width*0.25), int(cutOff.height*0.25));
    cutOff.save("/data/brightness" + bright + ".png");
  }
  println("complete");
}
