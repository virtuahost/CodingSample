import Jama.util.*;
import Jama.*;
import Jama.test.*;
import Jama.examples.*;
import java.util.*;

import papaya.*;

//POC for Kalman Filter on 2D pattern recognition
//Deep Ghosh: 01/30/2015

//**************************** global variables ****************************
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
red=#FF0000, grey=#818181, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB, 
orange=#FFA600, brown=#B46005, metal=#B5CCDE, dgreen=#157901, lgrey = #D3D3D3;
BSpline PS, QS, RS, AS;
int scp = -1; //selected control point
int m = 2; // m used for changing curve offset modes, 0 = normal, 1 = radial, 2 = ball, 3 = all three combined
boolean animating=false; // must be set by application during animations to force frame capture

float mirrorLine;
int sel=-1;
int face = -1;
int lnCurv = 0;
float f=0;
Boolean edgeMode = false, addingPoint=true, showPts=true, register = false, angles = true, moments = true, distances = true, selMod = true,switchGraphMode = false,registrationOff=false,drawDebug=false,findAll=false,useDTW=false, fixedScale = true;
pt2 edgeSt;
pt2 cutEdgeSt;
pt2 cutEdgeEnd;
float keeper = 0.0f;
int componentSize = 1;
int maxComponentSize = 9;
int patternSize = 17;
int selCurve = 1;
int errorCnt = 20;
float arcLengthSampleSize = 0.5;
float maxThresholdRad = 500;
float errVal = 0.0085; 
float dtwErrVal = 80;
int maxPatternElem = 25;
String infoText = "";
String debugText = "";
int selErr = 0;
String displayText = "Featrue selected 'Error allowed'.";

//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(1800, 800, P3D);   
  noSmooth();                  // turn on antialiasing
  frameRate(60);
  PS = new BSpline(); 
  QS = new BSpline();
  RS = new BSpline();
  AS = new BSpline();
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
  String tempTxt = "";
  if (showPts)
  {
    PS.showPts(green);
    if (!selMod)
    {
      QS.showPts(red);
    } 
  }  
  PS.showCurve(0, green);
  if (!selMod)
  {
    QS.showCurve(0, red);
  } else
  {
    AS.showCurve(0, red);
    //PS.showCurveDebug(0,red,PS.startX,PS.endX);
  }
  if (register) 
  {
    if(AS.curve.size()>0)PS.registerAndDraw(AS,magenta);
  }
  if(findAll)
  {
    tempTxt = PS.findAllAndDraw(magenta);
  }
  fill(metal);
  stroke(metal);
  rect(1500, 0, 300, 300);
  fill(black);
  createDebugText(tempTxt);
  fill(brown);
  stroke(brown);
  rect(1500, 300, 300, 200);
  fill(black);
  createInfoText();
  fill(orange);
  stroke(orange);
  rect(1500, 500, 300, 300);
  fill(black);
  createHelpText();
  noFill();
}  // end of draw()

void createHelpText()
{
  text("H",1470,630);
  text("E",1470,650);
  text("L",1470,670);
  text("P",1470,690);
  text("Key Info: \n a = add points,\n 1 = select base curve,\n 2 = select map curve,\n r = lsr mapping of 1 on 2,\n " 
  + "m = curvature mapping of 1,\n x = turn on DTW drawing mode,\n c = clear all,\n t = populate machine generated curve 1,\n n = curvature mapping of 1 using DTW,\n" 
  + "6 = populate hand generated curve,\n =/- = modifies the number of errors allowed.\n w/e = Select different error criteria to modify.\n f = fixed scaling. \n p = process for DTW.",1500,530);
}

void createInfoText()
{
  text("M",1470,330);
  text("O",1470,350);
  text("D",1470,370);
  text("E",1470,390);
  text("I",1470,420);
  text("N",1470,440);
  text("F",1470,460);
  text("O",1470,480);
  fill(green);
  infoText = "Curve selected = " + selCurve +"\n ";
  infoText = infoText + "add mode = " + addingPoint +"\n ";
  infoText = infoText + "drag mode = " + !addingPoint +"\n ";
  infoText = infoText + "using curvature = " + findAll +"\n ";
  infoText = infoText + "using lsr = " + register +"\n ";
  infoText = infoText + "using DTW = " + useDTW +"\n ";
  infoText = infoText + "using fixed scale = " + fixedScale +"\n ";
  text(infoText,1500,330);
}

void createDebugText(String tempTxt)
{  
  text("D",1470,30);
  text("E",1470,50);
  text("B",1470,70);
  text("U",1470,90);
  text("G",1470,110);
  text("I",1470,140);
  text("N",1470,160);
  text("F",1470,180);
  text("O",1470,200);
  debugText = displayText + "\n";
  debugText = debugText + "Error allowed: " + errorCnt + "\n";
  debugText = debugText + "Arc length sample size: " + arcLengthSampleSize + "\n";
  debugText = debugText + "Threshold allowed in lsr: " + maxThresholdRad + "\n";
  debugText = debugText + "Curvature threshold allowed: " + errVal + "\n";
  debugText = debugText + "Maximum pattern element allowed: " + maxPatternElem + "\n";
  debugText = debugText + "DTW Error constraint value: " + dtwErrVal + "\n";    
  text(debugText,1500,30);
  fill(magenta);  
  text("Elements found = " + tempTxt,1500,200);
}

//**************************** user actions ****************************
void keyPressed() { // executed each time a key is pressed: sets the "keyPressed" and "key" state variables, 
  // till it is released or another key is pressed or released  
  if (keyPressed)
  {
    if (key=='a') {
      addingPoint = !addingPoint;
//      showPts = addingPoint;
    }
    if (key=='s') {
      showPts = !showPts;
    }
    if (key=='c') {
      clearAll();
    }
    if (key=='1')
    {
      selCurve = 1;
    }
    if (key=='2')
    {
      if (!selMod)
      {
        selCurve = 3;
      } else
      {
        selCurve = 2;
        AS = new BSpline();
        cutEdgeEnd = P2();
        cutEdgeSt = P2();
        lnCurv = 0;
      }
    }
    if(key == 'w')
    {
      selErr++;
      selErr = (selErr==6?0:selErr);
      switch(selErr)
      {
        case 0: 
           displayText = "Featrue selected 'Error allowed'.";
           break;
        case 1: 
           displayText = "Featrue selected 'Arc length sample size'";
           break;
        case 2: 
           displayText = "Featrue selected 'Threshold allowed in lsr'";
           break;
        case 3: 
           displayText = "Featrue selected 'Curvature threshold allowed'";
           break;
        case 4: 
           displayText = "Featrue selected 'Max Number of Pattern Element'";
           break;
        case 5: 
           displayText = "Featrue selected 'DTW Error constraint value.'";
           break;
      }
    }
    if(key == 'e')
    {
      selErr--;
      selErr = (selErr<0?5:selErr);
      switch(selErr)
      {
        case 0: 
           displayText = "Featrue selected 'Error allowed'.";
           break;
        case 1: 
           displayText = "Featrue selected 'Arc length sample size'";
           break;
        case 2: 
           displayText = "Featrue selected 'Threshold allowed in lsr'";
           break;
        case 3: 
           displayText = "Featrue selected 'Curvature threshold allowed'";
           break;
        case 4: 
           displayText = "Featrue selected 'Max Number of Pattern Element'";
           break;
        case 5: 
           displayText = "Featrue selected 'DTW Error constraint value.'";
           break;
      }
    }
    if(key == 'f')
    {
      fixedScale = !fixedScale;
    }
    if(key=='6')
    {
      registrationOff = !registrationOff;
    }
    if (key=='r')
    {
      register = !register;
      findAll = false;
      //      selCurve = 3;
    }
    if(key=='m')
    {
      findAll = !findAll;
      register = false;
    }
    if(key=='n')
    {
      findAll = !findAll;
      register = false;
      useDTW = findAll;
    }
    if (key == '=')
    {
      switch(selErr)
      {
        case 0: 
           errorCnt = (errorCnt > 100?100:errorCnt+1);
           break;
        case 1: 
           arcLengthSampleSize = (arcLengthSampleSize > 10?10:arcLengthSampleSize+0.1);
           break;
        case 2: 
           maxThresholdRad = (maxThresholdRad > 1000?1000:maxThresholdRad+10);
           break;
        case 3: 
           errVal = (errVal > 1?1:errVal+0.00001);
           break;
        case 4:
           maxPatternElem = (maxPatternElem > 100?100:maxPatternElem+1);
           break;
        case 5:
           dtwErrVal = (dtwErrVal > 1000?1000:dtwErrVal+1);
           break;
      }        
    }
    if (key == '-')
    {
      switch(selErr)
      {
        case 0: 
           errorCnt = (errorCnt == 1?1:errorCnt-1);
           break;
        case 1: 
           arcLengthSampleSize = (arcLengthSampleSize < 0.1?0.1:arcLengthSampleSize-0.1);
           break;
        case 2: 
           maxThresholdRad = (maxThresholdRad < 1?1:maxThresholdRad-10);
           break;
        case 3: 
           errVal = (errVal < 0.00001?0.00001:errVal-0.00001);
           break;
        case 4:
           maxPatternElem = (maxPatternElem < 1?1:maxPatternElem-1);
           break;
        case 5:
           dtwErrVal = (dtwErrVal < 10?10:dtwErrVal-1);
           break;
      }  
    }
    if(key == 'x')
    {
      useDTW = !useDTW;
      findAll = (useDTW?false:findAll);
      register = (useDTW?true:register);
    }
    if(key=='p' && useDTW)
    {     
      println("Processing: Start"); 
      if(AS.curve.size()>0)PS.registerDTW(AS);
      println("Processing: End");
    }
    if(key == 't')
    {
      clearAll();
      for (int i = 0; i < maxComponentSize; i ++)
      {
        PS.addPt(P2(40.0 + i*70, 292.0));    //0
        PS.addPt(P2(55.0 + i*70, 293.0));    //1
        PS.addPt(P2(64.0 + i*70, 283.0));    //2
        PS.addPt(P2(60.0 + i*70, 268.0));    //3
        PS.addPt(P2(50.0 + i*70, 259.0));    //4
        PS.addPt(P2(42.0 + i*70, 238.0));    //5
        PS.addPt(P2(48.0 + i*70, 219.0));    //6
        PS.addPt(P2(64.0 + i*70, 207.0));    //7
        PS.addPt(P2(90.0 + i*70, 219.0));    //8
        PS.addPt(P2(101.0 + i*70, 243.0));   //9
        PS.addPt(P2(96.0 + i*70, 262.0));    //10  
        PS.addPt(P2(81.0 + i*70, 253.0));    //11
        PS.addPt(P2(76.0 + i*70, 235.0));    //12
        PS.addPt(P2(65.0 + i*70, 248.0));    //13
        PS.addPt(P2(71.0 + i*70, 263.0));    //14
        PS.addPt(P2(77.0 + i*70, 279.0));    //15
        PS.addPt(P2(88.0 + i*70, 283.0));    //16
        PS.addPt(P2(102.0 + i*70, 285.0));   //17
      }
    }
    if(key == 'd')
    {
      drawDebug = !drawDebug;
    }
  }
}

void clearAll()
{
  PS = new BSpline();
  QS = new BSpline();
  AS = new BSpline();
  cutEdgeEnd = P2();
  cutEdgeSt = P2();
  register = false;
  findAll = false;
  lnCurv = 0;
}

void mousePressed() {  // executed when the mouse is pressed
  if (addingPoint) {
    edgeMode = true;
    edgeSt = Mouse2();
    if(edgeSt.x > 1500) return;
    if (selCurve == 1)PS.addPt(Mouse2());
    if (selCurve == 3)QS.addPt(Mouse2());
    if(selCurve == 2 && lnCurv < 2)
    {
      lnCurv++;
      if(lnCurv == 2)
      {
        cutEdgeEnd = edgeSt;
        AS = PS.generateCurvePiece(cutEdgeSt,cutEdgeEnd);
      }
      else
      {
        cutEdgeSt = edgeSt;
      }      
    }
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
  case 3:
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

