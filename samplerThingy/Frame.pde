


class Frame {
    PGraphics fbo;
    public Frame(){
        fbo = createGraphics(width, height, P2D);
        fbo.beginDraw();
        fbo.clear();
        fbo.endDraw();
    }

    void clear(){
        fbo.beginDraw();
        fbo.background(0,0);
        fbo.endDraw();
    }

    void overWrite(PGraphics _pg){
        fbo.beginDraw();
        fbo.background(0,0);
        fbo.image(_pg, 0, 0);
        fbo.endDraw();
    }

    void overLay(PGraphics _pg){
        fbo.beginDraw();
        fbo.blendMode(blendMode);
        fbo.image(_pg, 0, 0);
        fbo.endDraw();
    }

    PGraphics get(){
        return fbo;
    }
}
