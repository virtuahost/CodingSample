import Jama.util.*;
import Jama.*;
import Jama.test.*;
import Jama.examples.*;

import papaya.*;

//POC for Kalman Filter on 2D pattern recognition
//Deep Ghosh: 01/30/2015

//**************************** global variables ****************************
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
red=#FF0000, grey=#818181, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB, 
orange=#FFA600, brown=#B46005, metal=#B5CCDE, dgreen=#157901, lgrey = #D3D3D3;
BSpline PS, QS, RS;
int scp = -1; //selected control point
int m = 2; // m used for changing curve offset modes, 0 = normal, 1 = radial, 2 = ball, 3 = all three combined
boolean animating=false; // must be set by application during animations to force frame capture

float mirrorLine;
int sel=-1;
int face = -1;
float f=0;
Boolean edgeMode = false, addingPoint=false, showPts=true, register = false, angles = true, moments = true, distances = true;
pt2 edgeSt;
float keeper = 0.0f;
int componentSize = 1;
int maxComponentSize = 9;
int patternSize = 17;
int selCurve = 1;

//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(1800, 800, P3D);   
  noSmooth();                  // turn on antialiasing
  frameRate(60);
  PS = new BSpline(); 
  QS = new BSpline();
  RS = new BSpline();
  //  PS.addPt(P2(73.0, 693.0));
  //  PS.addPt(P2(47.0, 578.0));
  //  PS.addPt(P2(39.0, 476.0));
  //  PS.addPt(P2(43.0, 354.0));
  //  PS.addPt(P2(78.0, 242.0));
  //  BufferedReader reader;
  //  String line = "";  
  //  reader = createReader("points.txt");
  //  if (reader != null)
  //  {
  //    while (line!=null)
  //    {
  //      try {
  //        line = reader.readLine(); 
  //      } 
  //      catch (IOException e) {
  //        line = null;
  //      }     
  //      if (line != null && line != "")
  //      {  
  //        String[] pieces = split(line, ",");
  //        float x = float(pieces[0]);
  //        float y = float(pieces[1]);
  //        PS.addPt(P2(x, y));
  //      }
  //    }
  //  } else
  //  {
  //    for (int i = 0; i < maxComponentSize; i ++)
  //    {
  //      PS.addPt(P2(40.0 + i*70, 292.0));    //0
  //      PS.addPt(P2(55.0 + i*70, 293.0));    //1
  //      PS.addPt(P2(64.0 + i*70, 283.0));    //2
  //      PS.addPt(P2(60.0 + i*70, 268.0));    //3
  //      PS.addPt(P2(50.0 + i*70, 259.0));    //4
  //      PS.addPt(P2(42.0 + i*70, 238.0));    //5
  //      PS.addPt(P2(48.0 + i*70, 219.0));    //6
  //      PS.addPt(P2(64.0 + i*70, 207.0));    //7
  //      PS.addPt(P2(90.0 + i*70, 219.0));    //8
  //      PS.addPt(P2(101.0 + i*70, 243.0));   //9
  //      PS.addPt(P2(96.0 + i*70, 262.0));    //10  
  //      PS.addPt(P2(81.0 + i*70, 253.0));    //11
  //      PS.addPt(P2(76.0 + i*70, 235.0));    //12
  //      PS.addPt(P2(65.0 + i*70, 248.0));    //13
  //      PS.addPt(P2(71.0 + i*70, 263.0));    //14
  //      PS.addPt(P2(77.0 + i*70, 279.0));    //15
  //      PS.addPt(P2(88.0 + i*70, 283.0));    //16
  //      PS.addPt(P2(102.0 + i*70, 285.0));   //17
  //    }
  //  }
}


void pen(color c, float w) {
  stroke(c); 
  strokeWeight(w);
}
//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  stroke(blue);
  pen(black, 3); 
  //  switch(selCurve)
  //  {
  //    case 1:      
  //      fill(green);
  //      if (showPts)PS.showPts();
  //      PS.showCurve(0);
  //      noFill();
  //      break;
  //    case 2:     
  //      fill(red);   
  //      if (showPts)QS.showPts();      
  //      QS.showCurve(0);
  //      noFill();
  //      break;
  //    case 3:
  //      if (showPts)
  //      {
  //        fill(green);PS.showPts();noFill();
  //        fill(red);QS.showPts();noFill();
  //      }
  //      fill(green);PS.showCurve(0);noFill();
  //      fill(red);QS.showCurve(0);noFill();
  //      break;
  //    case 4:
  if (showPts)
  {
    PS.showPts(green);
    QS.showPts(red);
  }
  PS.showCurve(0, green);
  QS.showCurve(0, red);
  if (register) 
  {
    float a;   
    if (distances)
    {     
      RS.copyTo(PS);
      a=RS.distances(QS);
      RS.registerTo(QS, a);
      RS.showCurve(0, cyan);
    }  
    if (angles)
    {    
      RS.copyTo(PS);
      a=PS.angles(QS);
      RS.registerTo(QS, a);
      RS.showCurve(0, metal);
    }
    if (moments)
    {    
      RS.copyTo(PS);
      a=PS.moments(QS);
      RS.registerTo(QS, a);
      RS.showCurve(0, magenta);
    }
    RS = new BSpline();
  }
  noFill();
  //      break;  
  //    default:
  //      break;
  //  }
}  // end of draw()

//**************************** user actions ****************************
void keyPressed() { // executed each time a key is pressed: sets the "keyPressed" and "key" state variables, 
  // till it is released or another key is pressed or released  
  if (keyPressed)
  {
    if (key=='a') {
      addingPoint = !addingPoint;
      showPts = addingPoint;
    }
    if (key=='s') {
      showPts = !showPts;
    }
    if (key=='c') {
      PS = new BSpline();
      QS = new BSpline();
    }
    if (key=='1')
    {
      selCurve = 1;
    }
    if (key=='2')
    {
      selCurve = 2;
    }
    if (key=='3')
    {
      distances = !distances;
    }
    if (key=='4')
    {
      angles = !angles;
    }
    if (key=='5')
    {
      moments = !moments;
    }
    if (key=='r')
    {
      register = !register;
      //      selCurve = 3;
    }
    if (key=='f')
    {
      //      selCurve = 4;
    }
  }
}

void mousePressed() {  // executed when the mouse is pressed
  if (addingPoint) {
    edgeMode = true;
    edgeSt = Mouse2();
    if (selCurve == 1)PS.addPt(Mouse2());
    if (selCurve == 2)QS.addPt(Mouse2());
  }
  if (selCurve == 1)scp = PS.pickCPt(Mouse2());
  if (selCurve == 2)scp = QS.pickCPt(Mouse2());
}

void mouseDragged() {
  switch(selCurve)
  {
  case 1:
    if (PS.cPts.size () >= 5)
    {
      PS.moveCPt(scp, MouseDrag2D());
    }
    break;
  case 2:
    if (QS.cPts.size () >= 5)
    {
      QS.moveCPt(scp, MouseDrag2D());
    }
    break;
  default:
    break;
  }
} 

void mouseReleased() {
  edgeMode = false;
}

void keyReleased() {
}

void mouseMoved() {
}

void mouseWheel(MouseEvent event) { // reads mouse wheel and uses to zoom
  float s = event.getAmount();
}

