#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform sampler2D ppixels;
uniform vec2 texOffset;

varying vec4 vertColor;
varying vec4 vertTexCoord;
// use these, but not here...
uniform float threshold;
uniform float time;
uniform float sourceMix;
uniform bool showLines;
uniform bool mirror;
uniform bool greenScreen;
uniform vec2 resolution;



bool colorCondition(vec4 _col){
    if(!greenScreen){
        return (_col.r < threshold && _col.g < threshold && _col.b < threshold);
    }
    else {
        vec3 cgreen = vec3(0, 1.0, 0);
        vec3 diff = _col.rgb - cgreen;
        float t = dot(diff, diff);
        return t < threshold;
    }
}

//vec2(0.5614,0.3252)
void main(void) {
  // vec2 pos = vertTex
    float n = 0;
    // vec4 col = texture2D(texture, vec2(1, 1) - vertTexCoord.st);
    vec2 pos = vertTexCoord.st;
    if(mirror) {
        pos.x = 1.0-pos.x;
    }
  	vec4 inputColor = texture2D(texture, pos);
    vec4 col = inputColor;
 //  	vec3 cgreen = vec3(0, 1.0, 0);
 //  	vec3 diff = col.rgb - cgreen;
 //  	float t = dot(diff, diff);

    if(colorCondition(col)){
        if(showLines){
            col.rgb = vec3(fract(time+pos.y*10.0+pos.x*10.0)>0.9);
        }
        else {
            if(col.r < threshold && col.g < threshold && col.b < threshold) col.a = 0.0;
        }
    }
    else col.a = 1.0;

    col = mix(col, inputColor, sourceMix);
    gl_FragColor = col;
}
