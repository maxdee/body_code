
void sendSync(){
    OscMessage _mess = new OscMessage("/sampler/sync");
    _mess.add(frameCount); /* add an int to the osc message */
    oscP5.send(_mess, pdPatch);
}

void oscEvent(OscMessage _mess) {
    String _tag = _mess.typetag();
    if(_mess.checkAddrPattern("/sampler/frames")){
        selectedFrames.clear();
        for(int i = 0; i < _tag.length(); i++){
            if(_tag.charAt(i) == 'f'){
                selectedFrames.append(_mess.get(i).floatValue());
            }
            else if(_tag.charAt(i) == 'i'){
                selectedFrames.append((float)_mess.get(i).intValue());
            }
        }
        // println(selectedFrames);
    }
    // else if(_mess.checkAddrPattern("/sampler/shaker")){
    else if(_mess.checkAddrPattern("/sampler/shaker")){
        shaker = _mess.get(0).floatValue();
    }
    else if(_mess.checkAddrPattern("/sampler/threshold")){
        threshold = _mess.get(0).floatValue();
    }
    else if(_mess.checkAddrPattern("/sampler/testMode")){
        testMode = _mess.get(0).intValue() == 1;
    }
    else if(_mess.checkAddrPattern("/sampler/mirror")){
        mirrorMode = _mess.get(0).intValue() == 1;
    }
    else if(_mess.checkAddrPattern("/sampler/green")){
        greenMode = _mess.get(0).intValue() == 1;
    }
    else if(_mess.checkAddrPattern("/sampler/sourceMix")){
        sourceMix = _mess.get(0).floatValue();
    }
    else if(_mess.checkAddrPattern("/sampler/reloadShader")){
        shader = loadShader("backCut.glsl");
        println("shader reloaded");
    }

    else if(_mess.checkAddrPattern("/sampler/overWrite")){
        overWriteFrames = _mess.get(0).intValue() == 1;
    }
    else if(_mess.checkAddrPattern("/sampler/blend")){
        int _i = _mess.get(0).intValue();
        blendMode = getBlendMode(_i);
    }
    else if(_mess.checkAddrPattern("/sampler/record")){
        record = _mess.get(0).intValue() == 1;
    }
    else if(_mess.checkAddrPattern("/sampler/recordRate")){
        recordRate = _mess.get(0).intValue();
    }
    else if(_mess.checkAddrPattern("/sampler/playbackRate")){
        playbackRate = _mess.get(0).intValue();
        if(playbackRate == 0) playbackIncrement = 0;
    }
    else if(_mess.checkAddrPattern("/sampler/drawInput")){
        drawInput = _mess.get(0).intValue();
    }
    else if(_mess.checkAddrPattern("/sampler/recordIndex")){
        int _v = _mess.get(0).intValue();
        recordHead = abs(_v)%MAX_BUFFER_SIZE;
    }
    else if(_mess.checkAddrPattern("/sampler/clear")){
        clearFramesFlag = true;
    }
}


int getBlendMode(int _i) {
        switch(_i) {
        case 0:
            return BLEND;
        case 1:
            return LIGHTEST;
        case 2:
            return SUBTRACT;
        case 3:
            return DARKEST;
        case 4:
            return ADD;
        case 5:
            return DIFFERENCE;
        case 6:
            return EXCLUSION;
        case 7:
            return MULTIPLY;
        case 8:
            return SCREEN;
        case 9:
            return REPLACE;
        default:
            return BLEND;
        }
    }
