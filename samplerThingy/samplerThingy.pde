/**
 * Time Displacement
 * by David Muth
 *
 * Keeps a buffer of video frames in memory and displays pixel rows
 * taken from consecutive frames distributed over the y-axis
 */

import processing.video.*;

Capture video;
//the buffer for storing video frames
ArrayList<PGraphics> frames = new ArrayList();
final int MAX_BUFFER_SIZE = 24;
int bufferSize = MAX_BUFFER_SIZE;

int manyCount;
int manyCountTarget = 1;
boolean record = false;
boolean newImage = false;
PImage capturedImage;

void setup() {
  // size(640, 480);
  // size(960, 540);
  size(1920,1080, P2D);

  // This the default video input, see the GettingStartedCapture
  // example if it creates an error
  video = new Capture(this, width, height, "/dev/video0", 30);

  // Start capturing the images from the camera
  video.start();
  frameRate(60);
  colorMode(HSB, 255);
  for(int i = 0; i < bufferSize; i++){
      frames.add(createGraphics(width, height, P2D));
  }
}


void draw() {
    if(newImage){
        newImage = false;
        PGraphics img = frames.get(frameIndex);
        img.beginDraw();
        img.image(video,0,0);
        img.endDraw();

        frameIndex++;
        frameIndex %= bufferSize;
        // if(true){
        //     frames.add(img);
        //     // Once there are enough frames, remove the oldest one when adding a new one
        //     if (frames.size() > bufferSize) {
        //         frames.remove(0);
        //     }
        // }
        // else {
        //     if(frames.size() <= frameIndex) frames.add(img);
        //     else {
        //         frames.set(frameIndex, img);
        //     }
        //
        // }
    }

    if(frameCount%8 == 1){
        if(manyCount < manyCountTarget) manyCount++;
        else if(manyCount > manyCountTarget) manyCount--;
    }

    background(0);
    noTint();
    image(video,0,0);

    int _frame = frameCount%bufferSize;
    int _other = frameCount/10%bufferSize;
    blendMode(LIGHTEST);
    for(int i = 0; i < manyCount; i++){
        drawIndex(frameIndex+i*5);

    }
    // drawIndex((int)random(bufferSize));

    if(record) saveFrame("capture/frame-####.tiff");
    fill(255);
    text(frameRate,10,10);
}

void drawIndex(int _index){
    _index %= bufferSize;
    if(_index < 0) _index= 0;

    if(_index < frames.size()){
        // if(_index%3 == 0) tint(255,0,0);
        // if(_index%3 == 1) tint(0,255,0);
        // if(_index%3 == 2) tint(0,0,255);
        // tint((_index*3)%255,255,255);
        image(frames.get(_index),0,0);
    }
}

int frameIndex = 0;
void captureEvent(Capture camera) {
    camera.read();
    newImage = true;
}


void keyPressed(){
    if(key == 32){
        if(manyCountTarget == 16) manyCountTarget = 1;
        else if(manyCountTarget == 1) manyCountTarget = 16;
    }
    else if(key == 'c'){
        record = !record;
    }
}
