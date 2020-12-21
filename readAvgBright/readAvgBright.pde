//this sketch simply outputs the average brightness of each channel and the overall
//brightness of a provided image file.
void setup(){
  //String fileName = "brightness1.0.png";    //test image
  String fileName = "26.png";
  PImage img = loadImage(fileName);
  img.loadPixels();
  color cols[] = new color[img.pixels.length];
  for(int y=0; y<img.height; y++){
    for(int x=0; x<img.width; x++){
      int idx = x + y*img.width;
      cols[idx] = img.pixels[idx];
    }
  }
  //calculate the sum of all values for each channel
  int[] rgb = new int[]{0, 0, 0};
  int notBlack = 0;
  for(int i=0; i<cols.length; i++){
    if(brightness(cols[i]) != 0){    //the pixel is not 0, 0, 0
      for(int channel=0; channel<rgb.length; channel++){
        if(channel==0){
          rgb[channel] += red(cols[i]);
        } else if (channel==1){
          rgb[channel] += green(cols[i]);
        } else {
          rgb[channel] += blue(cols[i]);
        }
      }
      notBlack++;
    }
  }
  for(int channel=0; channel<rgb.length; channel++){
    rgb[channel] /= notBlack; 
  }
  println("average red, green, blue within " + fileName); 
  printArray(rgb);
  int avg = (rgb[0] + rgb[1] + rgb[2]) / 3;
  println("average brightness:\n" + avg);
  img.updatePixels();
}
