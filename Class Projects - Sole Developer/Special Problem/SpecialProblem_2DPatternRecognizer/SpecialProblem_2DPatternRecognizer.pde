import papaya.*;

//POC for Kalman Filter on 2D pattern recognition
//Deep Ghosh: 01/30/2015

//**************************** global variables ****************************
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
red=#FF0000, grey=#818181, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB, 
orange=#FFA600, brown=#B46005, metal=#B5CCDE, dgreen=#157901, lgrey = #D3D3D3;
BSpline PS;
int scp = -1; //selected control point
int m = 2; // m used for changing curve offset modes, 0 = normal, 1 = radial, 2 = ball, 3 = all three combined
boolean animating=false; // must be set by application during animations to force frame capture

float mirrorLine;
int sel=-1;
int face = -1;
float f=0;
Boolean edgeMode = false, addingPoint=false, showPts=false, predictMode = false;
pt2 edgeSt;
float keeper = 0.0f;
int componentSize = 1;
int maxComponentSize = 9;
int patternSize = 17;


KalmanFilter xMani = new KalmanFilter();
KalmanFilter yMani = new KalmanFilter();

//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(1800, 800, P3D);   
  noSmooth();                  // turn on antialiasing
  frameRate(20);
  PS = new BSpline(); 

  //  PS.addPt(P2(73.0, 693.0));
  //  PS.addPt(P2(47.0, 578.0));
  //  PS.addPt(P2(39.0, 476.0));
  //  PS.addPt(P2(43.0, 354.0));
  //  PS.addPt(P2(78.0, 242.0));
  BufferedReader reader;
  String line = "";  
  reader = createReader("points.txt");
  if (reader != null)
  {
    while (line!=null)
    {
      try {
        line = reader.readLine(); 
      } 
      catch (IOException e) {
        line = null;
      }     
      if (line != null && line != "")
      {  
        String[] pieces = split(line, ",");
        float x = float(pieces[0]);
        float y = float(pieces[1]);
        PS.addPt(P2(x, y));
      }
    }
  } else
  {
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
  if(keyPressed && key=='i')//if(predictMode)
  {
    int temp = componentSize * patternSize;
    for (int i=temp; i>=1; i--) {
      xMani.Update(PS.cPts.get(maxComponentSize*patternSize - i).x,i);
      yMani.Update(PS.cPts.get(maxComponentSize*patternSize - i).y,i);
    }    
    float x = xMani.predict(keeper);
    float y = yMani.predict(keeper);
    PS.addPt(P2(x,y));
    keeper = PS.cPts.size ();
  }
  if (showPts)
  {
    PS.showPts();
  }
  PS.showCurve(0);
}  // end of draw()

//**************************** user actions ****************************
void keyPressed() { // executed each time a key is pressed: sets the "keyPressed" and "key" state variables, 
  // till it is released or another key is pressed or released  
  if (key=='c') {
    addingPoint = !addingPoint;
  }
  if (key=='s') {
    showPts = !showPts;
  }
  if (key=='e') {
    PS = new BSpline();
  }
  if (key=='p') {
    PrintWriter output;
    output = createWriter("points.txt"); 
    for (int i=0; i<PS.cPts.size (); i++) {
      output.println(PS.cPts.get(i).x + "," + PS.cPts.get(i).y);
    }
    output.flush(); 
    output.close();
  }
  if(key=='1')
  {
    componentSize++;
    if(componentSize > maxComponentSize-1)
      componentSize = maxComponentSize-1;
  }
  if(key=='2')
  {
    componentSize--;
    if(componentSize < 1)
      componentSize = 1;
  }
  if (key=='g') {
    //Code to generate curve based on repetitive element;
    //Kalman Filter test
    int temp = componentSize * patternSize;
    int start = 0;
    int end = PS.cPts.size ()/temp;
    for(int j = 0; j < end; j ++)
    {
      for (int i=j*temp; i < (j*temp+temp); i++) {
        xMani.Update(PS.cPts.get(i).x,i);
        yMani.Update(PS.cPts.get(i).y,i);
      }
    }
    keeper = PS.cPts.size ();
    float x = xMani.predict(keeper);
    float y = yMani.predict(keeper);
    PS.addPt(P2(x,y)); 
    keeper = PS.cPts.size ();
  }
  if(key == 'i')
  {    
//    predictMode = !predictMode;
    //Code to identify repititve elements
  }
}

void mousePressed() {  // executed when the mouse is pressed
  if (addingPoint) {
    edgeMode = true;
    edgeSt = Mouse2();
    PS.addPt(Mouse2());
  }
  scp = PS.pickCPt(Mouse2());
}

void mouseDragged() {
  PS.moveCPt(scp, MouseDrag2D());
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

