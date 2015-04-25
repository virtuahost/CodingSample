// LecturesInGraphics: polyloop
// Template for sketches
// Author: Jarek ROSSIGNAC, last edited on September 10, 2012

//**************************** global variables ****************************
PlanarGraph PG, QG; 
Extrusion X;
PlanarGraph[] pgl; //List to save multiple polyloops
BSpline PS, QS, SS, FS; 
BSpline[] bsl; //List to save multiple BSplines
ArrayList<pt2> pList, qList, sList; //ArrayLists saving points of polyloops on left and right
int z = 0; //selected planar graph or polyloop
int scp = -1; //selected control point
int m = 2; // m used for changing curve offset modes, 0 = normal, 1 = radial, 2 = ball, 3 = all three combined

PImage NicksFace; // picture of author's face, should be: data/pic.jpg in sketch folder
PImage SumitsFace; // picture of author's face, should be: data/pic.jpg in sketch folder
PImage DeepDonovanFace;

float mirrorLine;
int sel=-1;
int face = -1;
float f=0;
Boolean animate=true, fill=false, timing=false, edgeMode = false, mode2D = true, animate2D = false, radMode = false;
float at = 0; 
pt2 edgeSt;
int ms=0, me=0; // milli seconds start and end
int npts=20000; // number of points

//3D Mode variables
float dz=0; // distance to camera. Manipulated with wheel or when 
float rx=-0.06*TWO_PI, ry=-0.04*TWO_PI;    // view angles manipulated when space pressed but not mouse
float r=15, eh = 50; //radius r in minkowski sum, and height eh for extrusion
pt F = P(0, 0, 0);  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
Boolean center = true; 
pt msClick = P(0, 0, 0); 
pt ms3D = P(0, 0, 0); 
pt2 ms2D = P2(0, 0); 
Boolean wasClicked = false;
Boolean drawNormal = false;
Boolean controlPolyLine = true;
Boolean altMode = false;

//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(800, 800, P3D);            // window size
  mirrorLine = width/2;
  noSmooth();                  // turn on antialiasing
  frameRate(20);
  NicksFace = loadImage("data/nick.png");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  SumitsFace = loadImage("data/pic_sumit.jpg");
  DeepDonovanFace = loadImage("data/deep_donovan.jpg");

  //PG = new PlanarGraph(P2(100,200),P2(200,100),P2(300,200),P2(200,300));
  PG = new PlanarGraph(P2(200, 700), P2(200, 600)); 
  PG.fillColor(red);
  QG = new PlanarGraph(P2(600, 700), P2(600, 600)); 
  QG.fillColor(green);
  //PG = new PlanarGraph(P2(100,200),P2(250,100),P2(200,300));
  //PG.printCorners();
  pgl = new PlanarGraph [4];
  pgl[0] = PG; 
  pgl[1] = QG;
  pgl[2] = PG; 
  pgl[3] = QG;

  //Create Two BSplines, one for left, and one for right
  PS = new BSpline(); 
  QS = new BSpline(); 
  SS = new BSpline();
  FS = new BSpline();
  bsl = new BSpline [4]; 
  bsl[0] = PS; 
  bsl[1] = QS; 
  bsl[2] = SS;
  bsl[3] = FS;
  bsl[2].setDefaultRad(5.0);
  bsl[2].addPt(P2(width/2, 700));
  bsl[2].addPt(P2(width/2, 600));
  bsl[2].addPt(P2(width/2, 500));
  bsl[2].addPt(P2(width/2, 400));
  bsl[2].addPt(P2(width/2, 300));
  bsl[2].addPt(P2(width/2, 200));       
  bsl[2].create3DDS();
  bsl[3].addPt(P2(width/2, 700));  
  bsl[3].addPt(P2(width/2, 600));
  bsl[3].addPt(P2(width/2, 500));
  bsl[3].addPt(P2(width/2, 400));
  bsl[3].addPt(P2(width/2, 300));
  bsl[3].addPt(P2(width/2, 200));      
  bsl[3].create3DDS();
  //  bsl[2].addPt(P2(width/2,700)); bsl[2].addPt(P2(width/2,600)); bsl[2].addPt(P2(width/2,500)); bsl[2].addPt(P2(width/2,400)); bsl[2].addPt(P2(width/2,300)); bsl[2].addPt(P2(width/2,200));
  //bsl[2].moveCPt(1,V2(P2(width/2,300),P2(width/2+200,300)));



  PS.addPt(P2(73.0, 693.0));
  PS.addPt(P2(47.0, 578.0));
  PS.addPt(P2(39.0, 476.0));
  PS.addPt(P2(43.0, 354.0));
  PS.addPt(P2(78.0, 242.0));

  QS.addPt(P2(488.0, 669.0));
  QS.addPt(P2(447.0, 535.0));
  QS.addPt(P2(439.0, 413.0));
  QS.addPt(P2(436.0, 306.0));
  QS.addPt(P2(462.0, 198.0));
}

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  curvedSpine.clear();
  if (donut) {
    onDrawTube();
    if (keyPressed) {
      stroke(red); 
      fill(white); 
      ellipse(mouseX, mouseY, 26, 26); 
      fill(red); 
      text(key, mouseX-5, mouseY+4);
    }
    // for demos: shows the mouse and the key pressed (but it may be hidden by the 3D model)
    if (scribeText) {
      displayHeader();
    } // dispalys header on ƒanimacanvas, including my face
    if (scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  } else {
    //2D Mode
    if (mode2D) {
      background(white); // clear screen and paints white background

      //draw the mid spine
      stroke(blue);
      pen(black, 3); 
      //pgl[0].display(); 
      //pgl[1].display();
      //drawDebug();
      //edge(P2(width/2, 200), P2(width/2, 700));
      bsl[2].showPts(); 
      bsl[2].showCurve(0);

      //Animated LERP from P to Q
      if (animate2D) {
        //drawList(pList);
        //        drawList(c1p);
        animateMorph(PS.getCurve(), QS.getCurve(), PS.getRadius(), QS.getRadius());
      } else {
        //display bSpline control pts and the curves
        bsl[0].showPts(); 
        bsl[1].showPts();

        if (m < 3) {
          bsl[0].showCurve(m); 
          bsl[1].showCurve(m);
        }

        if (m == 3) {
          bsl[0].showCurve(0); 
          bsl[0].showCurve(1); 
          bsl[0].showCurve(2);
          bsl[1].showCurve(0); 
          bsl[1].showCurve(1); 
          bsl[1].showCurve(2);
        }
      }

      if (face != -1) {
        pgl[z].drawSidewalk(face, black);
      }
      if (!mousePressed && !keyPressed) scribeMouseCoordinates(); // writes current mouse coordinates if nothing pressed

      if (scribeText) { 
        fill(black); 
        displayHeader(); 
        displayCurveSelection(z, m);
      }
      if (scribeText && !filming) displayFooter(); // shows title, menu, and my face & name
    } else {
      //3D Mode

        background(white);
      pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
      camera();       // sets a standard perspective
      translate(200, 350, dz); // puts origin of model at screen center and moves forward/away by dz
      lights();  // turns on view-dependent lighting
      rotateX(rx); 
      rotateY(ry); // rotates the model around the new origin (center of screen)
      rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
      if (center) translate(-F.x, -F.y, -F.z);
      noStroke(); // if you use stroke, the weight (width) of it will be scaled with you scaleing factor

      /*
        if(showFloor) {
       showFrame(50); // X-red, Y-green, Z-blue arrows
       fill(yellow); pushMatrix(); translate(0,0,-1.5); box(400,400,1); popMatrix(); // draws floor as thin plate
       fill(magenta); show(F,4); // magenta focus point (stays at center of screen)
       fill(magenta,100); showShadow(F,5); // magenta translucent shadow of focus point (after moving it up with 'F'
       if(showControlPolygon) {
       pushMatrix(); 
       fill(grey,100); scale(1,1,0.01); P.drawClosedCurveAsRods(4); 
       P.drawBalls(4); 
       popMatrix();} // show floor shadow of polyloop
       }
       
       fill(black); show(O,4); fill(red,100); showShadow(O,5); // show red tool point and its shadow
       
       computeProjectedVectors(); // computes screen projections I, J, K of basis vectors (see bottom of pv3D): used for dragging in viewer's frame    
       pp=P.idOfVertexWithClosestScreenProjectionTo(Mouse()); // id of vertex of P with closest screen projection to mouse (us in keyPressed 'x'...
       */

      // replace the following 2 lines by display of the extrucded polygonal model
      //fill(cyan); stroke(blue); showWalls(P,Q);  
      //noStroke(); fill(yellow); P.drawClosedLoop(); fill(orange); Q.drawClosedLoop();

      //X.showFloor();      
      //ms3D=pick(mouseX,mouseY);

      X.display();
      //X.showAllCorners();
      //X.showTopC();
      X.showWalls();
      X.showCeiling();
      X.showFloor(); 
      if (wasClicked) {
        int selV = X.pickVertex(msClick); 
        //X.showSpecial(selV); 
        X.setCorner(X.pickCorner(selV, msClick));
        wasClicked = false;
      }

      popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
      //if (d(msClick,P(0,0,0)) > 0) show(msClick,2);

      if (keyPressed) {
        stroke(red); 
        fill(white); 
        ellipse(mouseX, mouseY, 26, 26); 
        fill(red); 
        text(key, mouseX-5, mouseY+4);
      }
      // for demos: shows the mouse and the key pressed (but it may be hidden by the 3D model)
      if (scribeText) {
        displayHeader();
      } // dispalys header on canvas, including my face
      if (scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming

      //end of 3D mode
    }
  }
}  // end of draw()

//**************************** user actions ****************************
void keyPressed() { // executed each time a key is pressed: sets the "keyPressed" and "key" state variables, 
  // till it is released or another key is pressed or released
  //2D Mode
  if(key=='h' || key =='H')
  {
    open("C:\\virtua's stuff\\finalGraphics\\finalGraphics\\finalGraphics\\controls.txt");
  }
  if (mode2D && !donut) {  
    if (key=='[' && t > 0) {
      t-=.05;
      println("time: " + t);
    }
    if (key==']' && t < 1) {
      t+=.05;
      println("time: " + t);
    }
    if (key=='.' && tp > 0) {
      tp--;
    }
    if (key=='/' && tp < 104) {
      tp++;
    }
    if (key=='\\') {
      showArcs = !showArcs;
    }
    if (key=='a') {
      animate2D = !animate2D;
      showArcAnimation = !showArcAnimation;
      t = 0;
    }
    if (key=='s') {
      doBallMorph = !doBallMorph;
    }
    if (key=='1') {
      z = 0;
    } //select first polyloop PG
    if (key=='2') {
      z = 1;
    } //select second polyloop QG
    if (key=='0') {
      z = 2;
    } //select spine SG

    if (key=='r') {
      //radius editing mode
      bsl[z].setRadMode(true);
    }

    if (key=='m') {
      //changing ball offset modes
      m = (m+1)%4;
    }


    if (key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
    //if(key=='!') snapPicture(); // make a picture of the canvas
    //if(key=='~') filming=!filming; // make a picture of the canvas

    if (key=='8') { //animate in 2D mode using LERP

      animate2D = !animate2D;

      //      pList = pgl[0].cornerList(); 
      //      pList.remove(pList.size()-1);
      //      qList = pgl[1].reverseCList();
      //      qList.remove(qList.size()-1);
    }
    if (key=='3') { //show Donut
      startTube();
      if (donut) {
        showArcAnimation = false;
        showArcs = false;
      }
    }


    if (key=='7') { 
      mode2D=!mode2D; 
      pList = pgl[0].cornerList(); 
      pList.remove(pList.size()-1);
      qList = pgl[1].reverseCList();
      qList.remove(qList.size()-1);
      X = new Extrusion(pgl[z].cornerList(), pgl[z].bridgeList(), eh); 
      X.setCorner(1);

      /*
      //print corners from p
       println("ArrayList: P");
       for (int i=0; i<pList.size();i++){
       println("...C "+i+" : "+pList.get(i).x+","+pList.get(i).y); 
       }
       
       //print corners from q
       println("ArrayList: Q");
       for (int i=0; i<qList.size();i++){
       println("...C "+i+" : "+qList.get(i).x+","+qList.get(i).y); 
       }
       */
    }// used to change between 2D / 3D modes

    if (key=='T') timing=true; // used for timing
    if (key=='f') fill=!fill; // used for timing
    if (key=='Q') exit();  // quit application
  } else if (!donut) {
    //3D Mode
    if (key=='7') mode2D=!mode2D;
    if (key=='o') { 
      println(X);
    }

    if (key=='n') { 
      X.setCorner(X.n3(X.selectedCorner())); 
      //println("Selected Corner: "+X.selectedCorner());
    }// Next corner               
    if (key=='s') {
      X.setCorner(X.s3(X.selectedCorner())); 
      //println("Selected Corner: "+X.selectedCorner());
    }// Swing corner
    if (key=='p') {
      X.setCorner(X.p3(X.selectedCorner())); 
      //println("Selected Corner: "+X.selectedCorner());
    }// Previous corner
  } else {
    onKeyPressedTube();

    if (key=='s') {
      doBallMorph = !doBallMorph;
    }
    if (key=='m') {
      //changing ball offset modes
      m = (m+1)%4;
    }
    if (key=='4')drawNormal=!drawNormal;
    if (key=='5')controlPolyLine=!controlPolyLine;
    if (key=='6')altMode=!altMode;
    if (key=='j')
    {
      bsl[2].cPts3D.clear();
      bsl[2].setDefaultRad(5.0);  
      bsl[2].create3DDS();
    }
  }
}

void mousePressed() {  // executed when the mouse is pressed
  //Bend mode
  //  if (detectClickOnEdge(mouseX, mouseY, P2(width/2, 200), P2(width/2, 700)))
  //  {
  //    //mouseBendStart = Mouse2();
  //    bend = true;
  //  } else
  //  {
  //2D Mode
  if (mode2D && !donut) {  

    if (keyPressed) {
      if (key=='d' && z < 2) {
        pgl[z].removeEdge(Mouse2());
      }
      if (key=='c' && z < 2) {
        edgeMode = true;
        edgeSt = Mouse2();
        bsl[z].addPt(Mouse2());
      }

      if (key=='r' && z < 2) {
        //radius editing mode
        bsl[z].setRadMode(true);
        scp = bsl[z].pickCPt(Mouse2());
      }


      if (key=='f' && z < 2) {
        face = pgl[z].pickFace(Mouse2());
        println("Face: "+face+" picked with area: "+pgl[z].area(face));
      }
    } else {
      //If no key pressed, then select the closest corner
      //int picked = pgl[z].pickCorner(Mouse2());
      //println("Picked Corner: "+picked);
      //sel = pgl[z].pickVertex(Mouse2(), -1);

      scp = bsl[z].pickCPt(Mouse2());
    }
    change=true;
  } else {
    pushMatrix();
    camera(cam, focus, down);
    wasClicked = true;
    ms3D = Mouse();
    msClick = pick((int) ms3D.x, (int) ms3D.y);
    scp = bsl[2].pickCPt3D(msClick);
    //println(ms3D.x+","+ms3D.y+" Pick: "+msClick.x+","+msClick.y+","+msClick.z);
    //X.showSpecial(25);
    popMatrix();
    //println(ms3D.x+","+ms3D.y+" Pick: "+msClick.x+","+msClick.y+","+msClick.z);
    //X.showSpecial(25);
  }
  //  }
}

void mouseDragged() {
  if (!donut)
  {
    //pgl[z].moveVertex(sel, MouseDrag2D());
    bsl[z].moveCPt(scp, MouseDrag2D());

    if (keyPressed && key=='r') {
      bsl[z].changeRadCPt(scp, Mouse2(), Pmouse2());
    }

    if (face>=0) pgl[z].moveFace(face, MouseDrag2D());
    change=true;
    if (keyPressed && key=='f') { // move focus point on plane
      if (center) F.sub(ToIJ(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0))); 
      else F.add(ToIJ(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0)));
    }
    if (keyPressed && key=='F') { // move focus point vertically
      if (center) F.sub(ToK(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0))); 
      else F.add(ToK(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0)));
    }
  } else
  {
    vec V;
    if (keyPressed && key == 'b')
    {
      V = ToJ(V((float)(mouseX-pmouseX), (float)(mouseY-pmouseY), 0));
      //      V = ToJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0));
    } else
    {
      //      println((mouseX-pmouseX) + ", " + (mouseY-pmouseY));
      if (altMode)
      {
        V = ToIK(V((float)(mouseX-pmouseX), 0, (float)(mouseY-pmouseY)));
      } else
      {
        V = MouseDrag();
      }
    }
    //    println(V.x + ", " + V.y + ", " + V.z);
    bsl[2].move3DCPt(scp, V(0.25, V));
  }
} 

void mouseReleased() {
  if (bend)
  {
    //mouseBendEnd = Mouse2();
    //    radiusOfBend = d(P2(width/2, 200), P2(mouseBendEnd.x, 200));

    //    if(mouseBendEnd.x > width/2)
    //    {
    //      centerOfPoint = P((sq(mouseBendEnd.x) -sq(width/2) + sq(mouseBendEnd.y-700))/(2*(mouseBendEnd.x-width/2)),700);
    //    }
    //    else
    //    {
    //      centerOfPoint = P((sq(mouseBendEnd.x) -sq(width/2) + sq(mouseBendEnd.y-700))/(2*(width/2 - mouseBendEnd.x)),700);
    //    }
    ////    println(centerOfPoint.x,centerOfPoint.y);
    //    radiusOfBend = d(P(width/2, 700),centerOfPoint);
    ////    angleOfBend = PI/2 - angle(mouseBendStart, P2(width/2, 200), mouseBendEnd);
    //    bend = false;
  } else
  {
    sel = -1; 
    scp = -1; 
    bsl[z].setRadMode(false);
    face = -1;
    if (edgeMode) {
      pgl[z].addEdge(edgeSt, Mouse2());   
      edgeMode = false;
    }
  }
}

void keyReleased() {
  bsl[z].setRadMode(false);
}

void mouseMoved() {
  if (donut) {
    onMouseMovedTube();
  } else  if (!mode2D) {
    if (keyPressed && key==' ') {
      rx-=PI*(mouseY-pmouseY)/height; 
      ry+=PI*(mouseX-pmouseX)/width;
    };
    if (keyPressed && key=='s') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
    if (keyPressed && key=='x') {
      eh+=(float)(pmouseY-mouseY)/3; // changes extrusion height
      X.updateHeight(eh);
    }
  }
}

void mouseWheel(MouseEvent event) { // reads mouse wheel and uses to zoom
  float s = event.getAmount();
  change=true;
}

//**************************** text for name, title and help  ****************************
String title ="P06: Revolve assymetric cross-sections around bent axis", 
name_sumit ="Donovan Hatch \nDeep Ghosh \nNick Olive \nSumit Khetarpal", name_nick="", 
menu="c: add vertex/edge, 3: 2D <-> 3D mode, H: for Help File and Control List", 
guide="1: Edit Red Curve, 2: Edit Green Curve, 0: Edit Mid-Spine, 4: Draw normals in 3D mode.";

