import java.util.*;
import processing.svg.*;
import controlP5.*;
ControlFrame cf;

boolean beginExportSVG = false;
boolean exporting = false;

float radius;
int strokeWeight = 4;

int time = 1000; 
int ringCount = 50; // num of tree rings , 100 - 200
int youth = 1; // color?
float wrinkle = 0.01; //noise offset, .02, .001)
float pressure = 30; // noise_scale, 40 , 1
boolean segmentRing = false;
boolean lfoAnimate = false;
int strokeColor = 255;


void setup(){
  //noiseSeed(Time.now);
  frameRate(16);
  cf = new ControlFrame(this, 300, 500, "Controls");
  size(640,640);
  radius = float(width) / 2.25;
}


void draw(){
  background(0);
  float _wrinkle = wrinkle;
  float _pressure = pressure;
  
  if(lfoAnimate){
    _wrinkle = map(noise(0,frameCount),0, 1, (wrinkle * .90), (wrinkle * 1.1)) ;
    _pressure = map(noise(0,frameCount),0, 1, (pressure * .80), (pressure * 1.2)) ;
    ringCount = ringCount + int(sin(frameCount)* 10) ; 
  }

  if(beginExportSVG){
    exporting = true;
    println("begining export");
    clear();
    // P3D needs begin Raw
    beginRecord(SVG, "data/exports/export_"+timestamp()+".svg");
    //beginRaw(SVG, "data/exports/export_"+timestamp()+".svg");
    strokeColor = 0;
  }
  
 
  translate(width/2, height/2);
  //rotate(random(-TWO_PI, TWO_PI));
  for (float ringRadius = -radius / ringCount; ringRadius < radius; ringRadius += radius / ringCount) {
    //for (float ringRadius = 0; ringRadius < radius; ringRadius += radius / ringCount) {
    noFill();
    stroke(strokeColor);
    strokeWeight(noise(ringRadius) * strokeWeight);
    strokeCap(SQUARE);
    drawRing(ringRadius, _wrinkle, _pressure);
  }

  //noLoop();
  
  
  if(exporting){
    endRecord();
    //endRaw();
    println("finished export");
    beginExportSVG = false;
    exporting = false;
    strokeColor = 255;
  }
  
}

void drawRing(float r, float wrinkle, float pressure){
    beginShape();    
    for ( float a = -TWO_PI / (ringCount-2); a < TWO_PI + TWO_PI / ringCount; a += TWO_PI / ringCount) {
      float x = r * cos(a);
      float y = r * sin(a);
      float noise = noise(x * wrinkle, y * wrinkle);
      if(lfoAnimate) noise += .2 * noise(frameCount); 
      float n = map(noise, 0, 1, -pressure, pressure);
      curveVertex(x + n, y + n);
      if (segmentRing && (noise(a+r) > 0.5 )) {
      //if (segmentRing && (random(1) > 0.75 - 0.25 * sin(r))) {        
        endShape();
        
        strokeWeight(noise(a+r) * strokeWeight);
        
        beginShape();
      }
    }
    endShape();
  
}




void keyPressed(KeyEvent ke){
  myKeyPressed(ke);
}

public void exportSVG(){
  beginExportSVG = true;
 
  //println("begining export");
  //clear();
  //// P3D needs begin Raw
  //beginRecord(SVG, "data/exports/export_"+timestamp()+".svg");
  ////beginRaw(SVG, "data/exports/export_"+timestamp()+".svg");
  
  ////render
  
  
  //endRecord();
  ////endRaw();
  //println("finished export");  
  //exporting = false;
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
