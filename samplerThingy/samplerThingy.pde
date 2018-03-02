import processing.video.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pdPatch;

Capture video;
PShader shader;
//the buffer for storing video frames
ArrayList<Frame> frames = new ArrayList();
PGraphics processedBuffer;
final int MAX_BUFFER_SIZE = 50;
int bufferSize = MAX_BUFFER_SIZE;
int recordHead = 0;
FloatList selectedFrames;



// for shaker
float shaker = 0;
PVector center;
boolean clearFramesFlag = false;

// shader uniforms
boolean mirrorMode = false;
boolean testMode = false;
boolean greenMode = false;

float threshold = 0.05;
float sourceMix = 0;
// other options
boolean overWriteFrames = true;
int blendMode = getBlendMode(0);
boolean record = true;
int recordRate = 1;
int playbackIncrement = 0;
int playbackRate = 1;
int drawInput = 0;

void settings(){
    size(1440,900, P2D);
}

void setup() {
    frameRate(60);
    textSize(24);
    // set OSC
    oscP5 = new OscP5(this,6666);
    pdPatch = new NetAddress("127.0.0.1",6667);
    // set videoDevice
    try {
        video = new Capture(this, width, height, "/dev/video0", 60);
    }
    catch (Exception e){
        println("trying /dev/video1 instead");
        video = new Capture(this, width, height, "/dev/video1", 60);
    }
    video.start();

    makeFrames();

    center = new PVector(mouseX,mouseY);
    shader = loadShader("backCut.glsl");
    processedBuffer = createGraphics(width,height, P2D);
}


void makeFrames(){
    print("adding frames");
    for(int i = 0; i < MAX_BUFFER_SIZE; i++){
        frames.add(new Frame());
        print(".");
    }
    println();
    selectedFrames = new FloatList();
    selectedFrames.append(0.0);
}

void clearFrames(){
    for(Frame _f : frames){
        _f.clear();
    }
}

void draw() {
    updateVideo();

    if(clearFramesFlag){
        clearFrames();
        clearFramesFlag = false;
    }
    center.set(mouseX, mouseY);
    background(0);
    pushMatrix();
    translate(center.x,center.y);


    if(shaker != 0) {
        shaker -= shaker/20.0;
        if(shaker < 0.01) shaker = 0;
    }
    blendMode(blendMode);
    displaySelected();
    popMatrix();

// scale(1.0+random(shaker)/20.0);

    sendSync();
    fill(255);
    text((int)frameRate,10,24);
}

void updateVideo(){

    if(video.available()){
        video.read();
        processedBuffer.shader(shader);
        passUniforms();
        processedBuffer.beginDraw();
        processedBuffer.background(0,0);
        processedBuffer.image(video, 0, 0);
        processedBuffer.endDraw();

        Frame _tmp = frames.get(recordHead);
        if(record){
            if(overWriteFrames) _tmp.overWrite(processedBuffer);
            else _tmp.overLay(processedBuffer);
        }
        if(recordRate == 0){

        }
        else if(frameCount % recordRate == 0){
            recordHead++;
            recordHead %= bufferSize;
        }
    }
}

void displaySelected(){
    pushMatrix();

    if(drawInput == 1){
        image(processedBuffer,-center.x, -center.y);
    }

    FloatList _copy = selectedFrames;// new FloatList(selectedFrames);
    for(int i = 0; i < _copy.size(); i++){
        scale(1.0+random(shaker)/20.0);
        if(!Float.isNaN(_copy.get(i))){
            int _index = getFrameIndex(_copy.get(i));
            Frame _tmp = frames.get(_index);
            image(_tmp.get(), -center.x, -center.y);
        }
        if(drawInput == i){
            image(processedBuffer,-center.x, -center.y);
        }
    }
    if(drawInput == 9){
        image(processedBuffer,-center.x, -center.y);
    }
    if(playbackRate == 0){

    }
    else if(frameCount % playbackRate == 0){
        playbackIncrement++;
        playbackIncrement %= bufferSize;
    }
    popMatrix();
}

int getFrameIndex(float _float){
    _float = abs(_float);
    _float *= MAX_BUFFER_SIZE;
    _float += playbackIncrement;
    _float %= MAX_BUFFER_SIZE;
    return (int)_float;
}

void passUniforms(){
    shader.set("mirror", mirrorMode);
    shader.set("showLines", testMode);
    shader.set("greenScreen", greenMode);

    shader.set("threshold", threshold);
    shader.set("time", millis()/1000.0);
    shader.set("sourceMix", sourceMix);
    shader.set("resolution", width, height);
}
