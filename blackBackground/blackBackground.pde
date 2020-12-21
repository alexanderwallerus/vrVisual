//the original software setup sometimes causes flickering on screens for 1 frame.
//=> This sketch puts a black background over the VR screens.
//runVisual.pde will run on top of this background.
void init() {
  frame.removeNotify();
  frame.setUndecorated(true);
  frame.addNotify();
  super.init();
}

void setup(){
  int w = 3 *1024;
  size(w, 1280);
  frame.setLocation(0, 0);    //will get overwritten
  frame.toFront();
  frame.requestFocus();
  frame.setVisible(true);
  frame.setAlwaysOnTop(true);
  background(0, 0, 0);
}

void draw(){
  frame.setLocation(2304, 74);
  background(0, 0, 0);
  frameRate(1);
}
