void setup(){
  //create encoded images for the original software. These images consist of 2 large
  //40*40 "pixels" that encode all parameters to be visualized in their colors.
  //float[] brightnesses = new float[]{0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9,
  //                            1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9};
  //float[] shapeInterpolations = new float[]{0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0};
  float[] brightnesses = new float[]{0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40,
                                     0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80,
                                     0.85, 0.90, 0.95, 1.00, 1.05, 1.10, 1.15, 1.20,
                                     1.25, 1.30, 1.35, 1.40, 1.45, 1.50, 1.55, 1.60,
                                     1.65, 1.70, 1.75, 1.80, 1.85, 1.90};
  float[] shapeInterpolations = new float[]{0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 
                                            0.6, 0.7, 0.8, 0.9, 1.0};
  for(int i=0; i<2; i++){
    boolean shapeDir = i==0?false:true;
    for(int j=0; j<2; j++){
      boolean rotated = j==0?false:true;
      for(float interp : shapeInterpolations){
        for(float br : brightnesses){
          PImage img = createImage(80, 40, RGB);
          img.loadPixels();
          int r = 255;
          for(int y=0; y<img.height; y++){
            for(int x=0; x<img.width; x++){
              int idx = x + y*img.width;
              if(x < img.width/2){
                int g = shapeDir?255:0;
                int b = rotated?255:0;
                img.pixels[idx] = color(r, g, b);
              } else {
                int g = int(map(interp, 0.0, 1.0, 0, 255));
                int b = int(map(br, 0.1, 1.9, 0, 255));
                img.pixels[idx] = color(r, g, b);
              }
            }
          }
          img.updatePixels();
          String fileName = "";
          if(!shapeDir){
            fileName = "shape_dir=reverse_";
          } else {
            fileName = "shape_dir=forward_";
          }
          if(!rotated){
            fileName += "rotated=false_";
          } else {
            fileName += "rotated=true_";
          }
          fileName += "interp=" + nf(interp, 1, 2) + "_";
          fileName += "brightScale=" + nf(br, 1, 2);
          img.save("results/" + fileName + ".png");
        }
      }
    }
  }
}
