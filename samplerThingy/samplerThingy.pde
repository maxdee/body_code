import processing.video.*;
import oscP5.*;
import netP5.*;

Capture video;
OscP5 oscP5;
NetAddress pdPatch;
//the buffer for storing video frames
ArrayList<PGraphics> frames = new ArrayList();
final int MAX_BUFFER_SIZE = 60;
int bufferSize = MAX_BUFFER_SIZE;
int frameIndex = 0;
boolean newImage = false;
boolean record = false;
FloatList selectedFrames;
boolean inited = false;

void settings(){
    // fullScreen(P2D, 2);
    // size(1920,1080, P2D, 2);
    size(1440,900, P2D);

}



void setup() {
    frameRate(60);
    textSize(24);
    colorMode(HSB, 255);

    oscP5 = new OscP5(this,6666);
    pdPatch = new NetAddress("127.0.0.1",6667);
    // for(String _str : Capture.list()) println(_str);
    video = new Capture(this, width, height, "/dev/video0", 60);
    video.start();
    makeFrames();
}


void makeFrames(){
    print("adding frames");
    for(int i = 0; i < MAX_BUFFER_SIZE; i++){
        PGraphics _pg = createGraphics(width, height, P2D);
        _pg.beginDraw();
        _pg.background(0,0);
        _pg.endDraw();
        frames.add(_pg);
        print(".");
    }
    println();
    selectedFrames = new FloatList();
    selectedFrames.clear();
}


void draw() {
    if(!inited){
        background(0);
        inited = true;
        // makeFrames();
    }
    if(newImage){
        newImage = false;
        PGraphics img = frames.get(frameIndex);
        img.beginDraw();
        img.image(video,0,0);
        img.endDraw();
        frameIndex++;
        frameIndex %= bufferSize;
    }

    background(0);
    // blendMode(BLEND);
    // fill(0, 23);
    // rect(0,0,width,height);
    // image(video,0,0);

    blendMode(LIGHTEST);
    FloatList _copy = selectedFrames;// new FloatList(selectedFrames);
    for(int i = 0; i < _copy.size(); i++){
        if(!Float.isNaN(_copy.get(i))){
            image(frames.get(getFrameIndex(_copy.get(i))), 0, 0);
        }
    }

    if(record) saveFrame("capture/frame-####.tiff");
    fill(255);
    text(frameRate,10,24);
    sendSync();
}

int getFrameIndex(float _float){
    _float *= MAX_BUFFER_SIZE;
    _float += frameIndex;
    _float %= MAX_BUFFER_SIZE;
    return (int)_float;
}

void captureEvent(Capture camera) {
    camera.read();
    newImage = true;
}

void sendSync(){
    OscMessage _mess = new OscMessage("/sampler/sync");
    _mess.add(frameIndex); /* add an int to the osc message */
    oscP5.send(_mess, pdPatch);
}

void oscEvent(OscMessage _mess) {
    String _tag = _mess.typetag();
    selectedFrames.clear();
    for(int i = 0; i < _tag.length(); i++){
        if(_tag.charAt(i) == 'f'){
            selectedFrames.append(_mess.get(i).floatValue());
        }
        else if(_tag.charAt(i) == 'i'){
            selectedFrames.append((float)_mess.get(i).intValue());
        }
    }
}

void keyPressed(){
    if(key == 'c'){
        record = !record;
    }
}
