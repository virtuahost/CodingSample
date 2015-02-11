class BSpline {

 ArrayList<pt2> cPts;
 ArrayList<pt2> curve, cLoopNormal, cLoopRadial, cLoopBall, topCap, botCap;
 ArrayList<Integer> cIndex;
 ArrayList<Float> radCPts, radFunction;
 ArrayList<pt2>[] Left, Right;
 Float rad = 20.0;
 boolean radMode = false; // to enable editing radius of control points
 int cType = 1;
 color curveClr = green;

 BSpline()  { 
   cPts = new ArrayList<pt2>();
   curve = new ArrayList<pt2>();
   cIndex = new ArrayList<Integer>();
   radCPts = new ArrayList<Float>();
   radFunction = new ArrayList<Float>();
   Left = new ArrayList [3]; Left[0] = new ArrayList<pt2>();
   Right = new ArrayList [3];
   topCap = new ArrayList<pt2>();
   botCap = new ArrayList<pt2>();
   //Changes for 3D manipulation Start
    cPts3D = new ArrayList<pt>();
    curve3D = new ArrayList<pt>();
    Left3D = new ArrayList [3]; 
    Left3D[0] = new ArrayList<pt>();
    Right3D = new ArrayList [3];
    cIndex3D = new ArrayList<Integer>();
    radCPts3D = new ArrayList<Float>();
    radFunction3D = new ArrayList<Float>();
    arrTangents = new ArrayList<vec>();
    arrNormals = new ArrayList<vec>();
    arrCenters = new ArrayList<pt>();
    arrRadius = new ArrayList<Float>();
    arrBiNormals = new ArrayList<vec>();
    arrAdvectionNormals = new ArrayList<vec>();
    //Changes for 3D manipulation End
 } 
 
 void addPt(pt2 p) {
  //println("New Pt: "+p.x+","+p.y);
  cPts.add(p); radCPts.add(rad);
  cIndex.add(cPts.size() - 1);
  
  if (cPts.size() >= 5) {
    subdivide(curve, cPts);
    updateIndex();
    updateRad();
    cLoopNormal = makeCurve(curve,radFunction,0, new ArrayList<pt2>(), new ArrayList<pt2>());
    cLoopRadial = makeCurve(curve,radFunction,1, new ArrayList<pt2>(), new ArrayList<pt2>());
    cLoopBall = makeCurve(curve,radFunction,2, new ArrayList<pt2>(), new ArrayList<pt2>());
  }
  
  //println("Size of C Pts: "+cPts.size());
 }
 
 
 void updateRad(){
  radFunction.clear();

  //Create ArrayList of pts based on radius and corresponding index
  ArrayList<pt2> radCPt2 = new ArrayList<pt2>();
  ArrayList<pt2> radFn2 = new ArrayList<pt2>();
  for (int i=0; i< radCPts.size(); i++) {
   pt2 curPt = P2(cIndex.get(i),radCPts.get(i));
   radCPt2.add(curPt);
  }
     
  subdivide(radFn2,radCPt2);
  //populate the radFunction based on radFn2 obtained after subdivision
  for (int i=0; i<radFn2.size(); i++) {
   radFunction.add(radFn2.get(i).y); 
  }
  cLoopNormal = makeCurve(curve,radFunction,0, new ArrayList<pt2>(), new ArrayList<pt2>());
  cLoopRadial = makeCurve(curve,radFunction,1, new ArrayList<pt2>(), new ArrayList<pt2>());
  cLoopBall = makeCurve(curve,radFunction,2, new ArrayList<pt2>(), new ArrayList<pt2>());
 }
 
 void setDefaultRad(float r) {
   rad = r;
 }
  
 void changeRadCPt(int cpt, pt2 curMouse, pt2 prevMouse) {
   pt2 center = curve.get(cIndex.get(cpt));
   float incRad = d(curMouse, prevMouse);
   float inc = (d(center,prevMouse) > d(center,curMouse))? -incRad: incRad;
   radCPts.set(cpt,radCPts.get(cpt)+inc);
   
   updateRad();
 }
 
 ArrayList<pt2> makeCurve(ArrayList<pt2> spine, ArrayList<Float> radProfile, int curveType, ArrayList<pt2> tCap, ArrayList<pt2> bCap) {
  //Curve Type can be 0: Normal, 1: Radial, 2: Ball
  //Make left offset, and right offset separately, and then merge them in the end.
 
 int numArcs = 10; //To approximate semicircles at each end of the curve 
 ArrayList<pt2> cLoop = new ArrayList<pt2>(); 
 ArrayList<pt2> left = new ArrayList<pt2>();
 ArrayList<pt2> right = new ArrayList<pt2>();
 
 for (int i=0; i<spine.size() - 1; i++) {
   vec2 curTVec, curNorm, normAtOffset; float dr;
   pt2 curLeftOffset = new pt2(); pt2 curRightOffset = new pt2();
   
   //Find unit tangent at each point
     curTVec = U(V2(spine.get(i),spine.get(i+1)));
   
   //Find unit normal
     curNorm = U(R2(curTVec));
   
   //Find radius derivative
    dr = radProfile.get(i+1) - radProfile.get(i);

    //Find norm vector at offset point
    normAtOffset = U(W(-dr,curTVec,(float) Math.sqrt(1 - dr*dr),curNorm));
   
   //Normal Offset
   if (curveType == 0) {
     //Find Left and Right Offset
     curLeftOffset = P2(spine.get(i), S(radProfile.get(i),curNorm) );
     curRightOffset = P2(spine.get(i), S(-radProfile.get(i),curNorm) );
    
   } else if (curveType == 1) { //Radial Offset
        
    //Find left and right offset points
    curLeftOffset = P2(spine.get(i), S(radProfile.get(i),normAtOffset) );
    curRightOffset = P2(spine.get(i), S(-radProfile.get(i),normAtOffset) );
    
   } else { //Ball Offset
    //Step1: Find the normal offset at half the distance
     pt2 midLeftOffset = P2(spine.get(i), S(radProfile.get(i)/2,curNorm) );
     pt2 midRightOffset = P2(spine.get(i), S(-radProfile.get(i)/2,curNorm) );
    
    //Step2: Find the radial offset from the mid points
    curLeftOffset = P2(midLeftOffset, S(radProfile.get(i)/2,normAtOffset) );
    curRightOffset = P2(midRightOffset, S(-radProfile.get(i)/2,normAtOffset) );
        
   }
  
  left.add(curLeftOffset);
  right.add(curRightOffset);
 } //end of for loop
   
   
   //Merge left side offset
   for (int i=2;i<right.size()-3; i++) {
    cLoop.add(right.get(i)); 
   }
        
   //Merge left to right circular arc
   vec2 leftVec = V2(spine.get(spine.size()-1),right.get(right.size()-5));
   vec2 rightVec = V2(spine.get(spine.size()-1),left.get(left.size()-4));
   
   for (int i=1; i<numArcs; i++) {
     float incAngle = PI/numArcs;
     pt2 newPt = P2(spine.get(spine.size()-1),R2(leftVec,incAngle*i));
     //print("Arc Pt: "+newPt.x+","+newPt.y+" ");
     cLoop.add(newPt);
     topCap.add(newPt);
     tCap.add(newPt);
   }
   
   //Merge left side offset
   for (int i=left.size()-3; i>=3; i--) {
    cLoop.add(left.get(i)); 
   }
      
   //Merge right to left circular arc
   vec2 leftVecBot = V2(spine.get(0),right.get(3));
   vec2 rightVecBot = V2(spine.get(0),left.get(3));
   
   for (int i=1; i<numArcs; i++) {
     float incAngle = PI/numArcs;
     pt2 newPt = P2(spine.get(0),R2(rightVecBot,incAngle*i));
     cLoop.add(newPt);
     botCap.add(newPt);
     bCap.add(newPt);
   }
    
   return cLoop; 
 }
  
 void subdivide(ArrayList<pt2> fCurve, ArrayList<pt2> cPts) {
   
   fCurve.clear();
   
   //copy all elements from cPts to curve
   for (int i=0; i<cPts.size(); i++) {
    fCurve.add(cPts.get(i)); 
   }
    
   //Add additional points to clamp the starting and ending point
     pt2 front = fCurve.get(0);
     pt2 end = fCurve.get(fCurve.size()-1);
        
   
   //Smoothen the curve
   for (int i=0; i<2; i++) {
     fCurve.add(0,front); fCurve.add(0,front); fCurve.add(0,front); fCurve.add(0,front); 
     fCurve.add(end); fCurve.add(end); fCurve.add(end); fCurve.add(end);
     
     refine(fCurve);
     dual(fCurve); dual(fCurve); 
     dual(fCurve); dual(fCurve);
     
     fCurve.remove(0); fCurve.remove(0); fCurve.remove(0); fCurve.remove(0);
     fCurve.remove(fCurve.size()-1); fCurve.remove(fCurve.size()-1); fCurve.remove(fCurve.size()-1); fCurve.remove(fCurve.size()-1);
   }
      
   /*
   //Print curve
   println("Curve has: "+curve.size()+" pts");
   for (int i=0; i<curve.size(); i++) { 
     print("("+curve.get(i).x+","+curve.get(i).y+") ");
   }
   println();
   */
 }
 
 void updateIndex(){
   for (int i=0; i<cPts.size(); i++) {
   float minDist = 999999;
   int uIndex = 0;
   
     for (int j=0; j<curve.size(); j++) {  
       float curDist = d(cPts.get(i), curve.get(j));
       if ( curDist < minDist) {
          minDist = curDist;
          uIndex = j; 
       }
     }
  
   cIndex.set(i,uIndex);
 
   }
 }
 
 void showPts() {
   
   if (!radMode) {
   noFill();
   stroke(black);
   for (int i=0;i<cPts.size(); i++) {
    cPts.get(i).show(10); 
   }
   noFill();
   } else {
   
     noFill();
     stroke(black);
     for (int i=0;i<cPts.size(); i++) {
      curve.get(cIndex.get(i)).show(radCPts.get(i)); 
     }
   noFill();
     
   }
 }
 
 void showCurve(int curveType) {
   if (curve.size() > 1 ) {
   
   fill(curveClr);
   pen(black,1);
   for (int i=0;i<curve.size() - 1; i++) {
    //curve.get(i).show(3);
    edge(curve.get(i),curve.get(i+1)); 
   }
   //curve.get(curve.size() - 1).show(3);
   noFill();
   
   //Show corresponding ctrl points
   for (int i=0; i<cIndex.size(); i++) {
     fill(black);
     curve.get(cIndex.get(i)).show(2);
   }
   
  
   //Show curvedLoop
   fill(curveClr);
   noStroke();
   
   if (curveType == 0) {
     
     fill(red); stroke(red);
     for (int i=0; i<cLoopNormal.size()-1;i++) {
        //cLoopNormal.get(i).show(2); 
        edge(cLoopNormal.get(i),cLoopNormal.get(i+1));
     }
     edge(cLoopNormal.get(cLoopNormal.size()-1),cLoopNormal.get(0));
   } else if (curveType == 1) {
     fill(dgreen); stroke(dgreen);
     for (int i=0; i<cLoopRadial.size() - 1;i++) {
        //cLoopRadial.get(i).show(2); 
        edge(cLoopRadial.get(i),cLoopRadial.get(i+1));
     }
     edge(cLoopRadial.get(cLoopRadial.size()-1),cLoopRadial.get(0));
   } else if (curveType == 2) {
     fill(blue);
     for (int i=0; i<cLoopBall.size();i++) {
        cLoopBall.get(i).show(2); 
     }
   }
   
   }
 }
  
 void refine(ArrayList<pt2> aList) {
  
     int i = aList.size() - 2;
   
     while(true) {
     aList.add(i+1,P2(aList.get(i),aList.get(i+1)));
      i--;
      if ( i < 0) break;
     } 
  
 }
 
 void dual(ArrayList<pt2> aList) {

  ArrayList<pt2> newList = new ArrayList<pt2>();
  
      for (int i=0; i<aList.size() -1; i++) {
        newList.add(P2(aList.get(i),aList.get(i+1)));
      }    
   
  //Clear curve, and copy newList into curve
  aList.clear();
  for (int i=0; i<newList.size();i++) {
   aList.add(newList.get(i));
  }
  
 }
 
int pickCPt(pt2 click) {
 
   float minDist = 999999;
   int selCPt = -1;
   
   for (int i=0 ; i< cPts.size(); i++) {
    float curDist = d(cPts.get(i),click);
      if (curDist < minDist) {
         minDist = curDist;
         selCPt = i;
      } 
   }
 
 
   return selCPt;  
 }
 
void moveCPt(int cpt, vec2 drag){
   if(cpt < 0 ) return;
   
   //Modify the coordinates of control point
   cPts.set(cpt,cPts.get(cpt).add(drag));  
   
   subdivide(curve, cPts);
   cLoopNormal = makeCurve(curve,radFunction,0, new ArrayList<pt2>(), new ArrayList<pt2>());
   cLoopRadial = makeCurve(curve,radFunction,1, new ArrayList<pt2>(), new ArrayList<pt2>());
   cLoopBall = makeCurve(curve,radFunction,2, new ArrayList<pt2>(), new ArrayList<pt2>());
 }
 
 void setRadMode(boolean radOn) { radMode = radOn; }
 boolean getRadMode(boolean radOn) { return radMode; }
 
 ArrayList<pt2> getLoop(int cType) {
  if (cType == 0) return cLoopNormal;
  if (cType == 1) return cLoopRadial;
  return cLoopBall; 
 }
 
 ArrayList<pt2> getMidSpine() {
   return curve;
 }
 
 ArrayList<pt2> getTopCap() {
   return topCap;
 }
 
 ArrayList<pt2> getBotCap() {
   return botCap;
 }
 
 ArrayList setCurvedLoop(ArrayList<pt2> spine, ArrayList<Float> rad, int type) {
    this.curve = spine;
    this.radFunction = rad;
    ArrayList<pt2> ret;
    cLoopNormal = makeCurve(curve, radFunction, 0, new ArrayList<pt2>(), new ArrayList<pt2>());
    cLoopRadial = makeCurve(curve, radFunction, 1, new ArrayList<pt2>(), new ArrayList<pt2>());
    cLoopBall = makeCurve(curve, radFunction, 2, new ArrayList<pt2>(), new ArrayList<pt2>());
    if(type==0) return cLoopNormal;
    else if(type==1) return cLoopRadial;
    else return cLoopBall;
  }
 
   ArrayList<pt2> getCurve() {
    return curve;
  }

  ArrayList<Float> getRadius() {
    return radFunction;
  }
  
  ArrayList<pt2> doMakeCurve(ArrayList<pt2> spine, ArrayList<Float> rad, int curveType) {
    ArrayList<pt2> fa;
    ArrayList<pt2> tCap = new ArrayList<pt2>();
    ArrayList<pt2> bCap = new ArrayList<pt2>();
    if(doBallMorph) {
    
      ArrayList<pt2> cu = new ArrayList<pt2>();
      subdivide(cu, spine);
      
      ArrayList<pt2> radCPt2 = new ArrayList<pt2>();
      ArrayList<pt2> radFn2 = new ArrayList<pt2>();
      
      for (int i=0; i< rad.size(); i++) {
       pt2 curPt = P2(i,rad.get(i)); //cIndex.get(i)
       radCPt2.add(curPt);
      }
         
      subdivide(radFn2,radCPt2);
      ArrayList<Float> r = new ArrayList<Float>();
      //populate the radFunction based on radFn2 obtained after subdivision
      for (int i=0; i<radFn2.size(); i++) {
       r.add(radFn2.get(i).y); 
      }
  
      curve = cu;
      fa = makeCurve(cu, r, m, tCap, bCap);
      
  //    if(key==']' || key=='[') {
  //      println("spine: " + spine);
  //      //println("rad: " + rad);
  //      //println("cu: " + cu);
  //      println("r: " + r);
  //      println("fa: " + fa);
  //    }
  //    stroke(magenta);
  //    fill(magenta);
  //    for(int i =0; i < tCap.size(); i++) {
  //      tCap.get(i).show(3); 
  //      bCap.get(i).show(3); 
  //    }
  //    println("tCap: " + tCap);
  //    println("bCap: " + bCap);
  //    
    }
    else {
      println("test");
      this.curve = spine;
      fa = makeCurve(spine, rad, curveType, tCap, bCap);
    }
    
    return fa;
  }
  
  
  
  ArrayList<pt> cPts3D;
  ArrayList<pt> curve3D, curvedLoop3D;
  ArrayList<pt>[] Left3D, Right3D;
  pt radStartPt3D = new pt();
  ArrayList<Integer> cIndex3D;
  ArrayList<Float> radCPts3D, radFunction3D;
  ArrayList<vec> arrTangents;
  ArrayList<vec> arrNormals;
  ArrayList<vec> arrBiNormals;
  ArrayList<pt> arrCenters;
  ArrayList<Float> arrRadius;
  ArrayList<vec> arrAdvectionNormals;
  float avgY = 0;
  float dist = 0;
 
 //Changes for 3D manipulation Start
  void move3DCPt(int cpt, vec drag) {
    if (cpt < 0 ) return;

    //Modify the coordinates of control point
    cPts3D.set(cpt, cPts3D.get(cpt).add(drag));  

    update3D();
    curvedLoop3D = make3DCurve(curve3D, radFunction, 0);
    generateTangents();
  }

  void add3DPt(pt p) {
    //println("New Pt: "+p.x+","+p.y);
    cPts3D.add(p); 
    radCPts3D.add(rad);
    cIndex3D.add(cPts3D.size() - 1);

    if (cPts3D.size() >= 5) {
      update3D();
      updateIndex3D();
      updateRad3D();
      curvedLoop3D = make3DCurve(curve3D, radFunction3D, 0);
    }
  }

  ArrayList<pt> make3DCurve(ArrayList<pt> spine, ArrayList<Float> radProfile, int curveType) {
    //Curve Type can be 0: Normal, 1: Radial, 2: Ball
    //Make left offset, and right offset separately, and then merge them in the end.

    int numArcs = 5; //To approximate semicircles at each end of the curve 
    ArrayList<pt> cLoop = new ArrayList<pt>(); 
    ArrayList<pt> left = new ArrayList<pt>();
    ArrayList<pt> right = new ArrayList<pt>();

    for (int i=0; i<spine.size () - 1; i++) {
      vec curTVec, curNorm;
      pt curLeftOffset = new pt(); 
      pt curRightOffset = new pt();

      //Normal Offset
      if (curveType == 0) {

        //Step 1: Find tangent at each point
        curTVec = V(spine.get(i), spine.get(i+1));

        //Step 2: Find unit normal
        curNorm = U(R(curTVec));

        //Step 3: Left and Right Offset
        curLeftOffset = P(curve3D.get(i), V(rad, curNorm) );
        curRightOffset = P(curve3D.get(i), V(-rad, curNorm) );
      } else if (curveType == 1) {
      } else {
      }

      left.add(curLeftOffset);
      right.add(curRightOffset);
    } //end of for loop

    //Merge left side offset
    for (int i=0; i<left.size (); i++) {
      cLoop.add(left.get(i));
    }

    //Merge left to right circular arc


    //Merge right side offset
    for (int i=right.size ()-1; i>=0; i--) {
      cLoop.add(right.get(i));
    }

    //Merge right to left circular arc

    return cLoop;
  }

  void update3D() {

    curve3D.clear();

    //copy all elements from cPts to curve
    for (int i=0; i<cPts3D.size (); i++) {
      curve3D.add(cPts3D.get(i));
    }

    //Add additional points to clamp the starting and ending point
    pt front = curve3D.get(0);
    pt end = curve3D.get(curve3D.size()-1);


    //Smoothen the curve
    for (int i=0; i<4; i++) {
      curve3D.add(0, front); 
      curve3D.add(0, front); 
      curve3D.add(0, front); 
      curve3D.add(0, front); 
      curve3D.add(end); 
      curve3D.add(end); 
      curve3D.add(end); 
      curve3D.add(end);

      refine3D();
      dual3D(); 
      dual3D(); 
      dual3D(); 
      dual3D();

      curve3D.remove(0); 
      curve3D.remove(0); 
      curve3D.remove(0); 
      curve3D.remove(0);
      curve3D.remove(curve3D.size()-1); 
      curve3D.remove(curve3D.size()-1); 
      curve3D.remove(curve3D.size()-1); 
      curve3D.remove(curve3D.size()-1);
    }

    /*
   //Print curve
     println("Curve has: "+curve.size()+" pts");
     for (int i=0; i<curve.size(); i++) { 
     print("("+curve.get(i).x+","+curve.get(i).y+") ");
     }
     println();
     */
  }

  void updateIndex3D() {
    for (int i=0; i<cPts3D.size (); i++) {
      float minDist = 999999;
      int uIndex = 0;

      for (int j=0; j<curve3D.size (); j++) {  
        float curDist = d(cPts3D.get(i), curve3D.get(j));
        if ( curDist < minDist) {
          minDist = curDist;
          uIndex = j;
        }
      }

      cIndex3D.set(i, uIndex);
    }
  }

  void updateRad3D() {
    radFunction3D.clear(); 
    Left3D[0].clear();
    for (int i=0; i<curve3D.size (); i++) {
      radFunction3D.add(rad);
    }
  }

  void showPts3D(int clr) {

    if (!radMode) {
      noFill();
      stroke(clr);
      for (int i=0; i<cPts3D.size (); i++) {
        show(cPts3D.get(i), 10.0f);
      }
      noFill();
    } else {

      noFill();
      stroke(clr);
      for (int i=0; i<cPts3D.size (); i++) {
        show(curve3D.get(cIndex3D.get(i)), radCPts.get(i));
      }
      noFill();
    }
  }

  void create3DDS()
  {    
    float x = width/2;
    float y = avg(cPts).y;
    cPts3D.clear();
    for (pt2 p : cPts) {
      p = P2(p.x-x, p.y-y);
      p = P2(false?-p.x:p.x, true?-p.y:p.y);
      add3DPt(new pt(p.x, 0, p.y,p.x,p.y));
    }
    generateTangents();
  }

  void showCurve3D(int clr, int controlPointColor, Boolean tubes) {
    if (curve3D.size() > 1 ) {

      fill(clr);
      pen(clr, 1);
      for (int i=0; i<curve3D.size () - 1; i++) {
        //curve.get(i).show(3);
        if (tubes)
        {
          vec temp =V(curve3D.get(i), curve3D.get(i+1));
          cone(curve3D.get(i), temp, 1);
        } else
        {
          show(curve3D.get(i), curve3D.get(i+1));
        }
      }
      //curve.get(curve.size() - 1).show(3);
      noFill();

      //Show corresponding ctrl points
      for (int i=0; i<cIndex3D.size (); i++) {
        fill(controlPointColor);
        show(curve3D.get(cIndex3D.get(i)), 3);
      }


      //Show Left Curve
      //      fill(red);
      //      for (int i=0; i<curvedLoop3D.size (); i++) {
      //        show(curvedLoop3D.get(i), 3);
      //      }
    }
  }

  void refine3D() {

    int i = curve3D.size() - 2;

    while (true) {
      curve3D.add(i+1, P(curve3D.get(i), curve3D.get(i+1)));
      i--;
      if ( i < 0) break;
    }
  }

  void dual3D() {

    ArrayList<pt> newList = new ArrayList<pt>();

    for (int i=0; i<curve3D.size () -1; i++) {
      newList.add(P(curve3D.get(i), curve3D.get(i+1)));
    }    

    //Clear curve, and copy newList into curve
    curve3D.clear();
    for (int i=0; i<newList.size (); i++) {
      curve3D.add(newList.get(i));
    }
  }

  int pickCPt3D(pt click) {

    //    float minDist = 999999;
    //    int selCPt = -1;
    //    for (int i=0; i< cPts3D.size (); i++) {
    //      float curDist = d(cPts3D.get(i), click);
    //      if (curDist < minDist) {
    //        minDist = curDist;
    //        selCPt = i;
    //      }
    //    }
    float minDist = 0;
    int selCPt = 0;
    //    println(cPts3D.size());
    if ( click != null)
    {
      for (int i=1; i<cPts3D.size (); i++) 
      {
        float curDist = d(cPts3D.get(i), click);
        minDist = d(click, cPts3D.get(selCPt));
        //        println(curDist);
        if (curDist <= minDist)
        {
          selCPt=i;
        }
      }
    }
    return selCPt;
  }

  void generateTangents()
  {
    arrTangents.clear();
    arrNormals.clear();
    arrCenters.clear();
    arrRadius.clear();
    arrBiNormals.clear();
    arrAdvectionNormals.clear();
    pt regPt = P();
    for (int i=1; i<curve3D.size ()-1; i++) {      
      pt P1 =P(curve3D.get(i-1));
      pt P2 =P(curve3D.get(i));
      pt P3 =P(curve3D.get(i+1));
      vec V = V(P2, P1);
      vec W = V(P2, P3);
      vec N = U(N(V, W));
      vec R1 = N(W, N);
      vec R2 = N(N, V);
      vec advN = V(N);
      float nR1 = n2(V)/2;
      float nR2 = n2(W)/2;
      vec tempR1 = R1.mul(nR1);
      vec tempR2 = R2.mul(nR2);
      vec R = tempR1.add(tempR2);
      pt O = P(P2, R);
      float r = R.norm();      
      vec T2 = U(N(N, V(P2, O)));
      vec BN = U(N(T2, N));
      if(N.norm() == 0)
      {
        T2 = U(V(P2,P3));
        N = U(R(T2,PI/2,I,K));
        BN = U(N(T2,N));
      }
//      if(twistFreeNormals)
//      {
        if(i==1)
        {
          regPt = P(curve3D.get(i),N);
        }
        else
        {
          T2 = U(V(P2,P3));
          N = U(R(T2,PI/2,I,K));
          BN = U(N(T2,N));
          regPt.add(V(d(P1,P2),arrTangents.get(i-2)));          
          advN = U(V(curve3D.get(i),regPt));
//          regPt = P(curve3D.get(i),regPt.x,N,-regPt.y,BN,regPt.z,T2);
//          N = V(advN);
//          T2 = U(V(P2,P3));
          
        }
        arrAdvectionNormals.add(advN);
//      }
      arrTangents.add(T2);
      arrNormals.add(N);
      arrCenters.add(O);
      arrRadius.add(r);
      arrBiNormals.add(BN);
    } 
//    if(!twistFreeNormals)
//    {   
//      for(int i = 1; i < arrTangents.size()-1;i++)
//      {
//        if(arrRadius.get(i-1) != 0 && arrRadius.get(i) != 0 &&  arrRadius.get(i+1) != 0)
//        {
//          float avgW = 1/(arrRadius.get(i-1) + arrRadius.get(i) + arrRadius.get(i+1));
//          vec T = V(avgW, V(V(arrRadius.get(i-1),arrTangents.get(i-1)),V(arrRadius.get(i),arrTangents.get(i)),V(arrRadius.get(i+1),arrTangents.get(i+1))));
//          arrTangents.set(i,V(T));
//        }
//      }
//    }
//    println("Hello " + arrTangents.size());
  }

  void showTangentsandNormals()
  {
    if(drawNormal)
    {
      for (int i=1; i<curve3D.size ()-1; i++) 
      {
//        int i = 50;
//        cone(curve3D.get(i), V(20,arrAdvectionNormals.get(i-1)), 1);
//        cone(curve3D.get(i), V(20,arrNormals.get(i-1)), 1);
//        stroke(lgrey);
//        cone(curve3D.get(i), V(20,arrTangents.get(i-1)), 1);
//        stroke(black);
        cone(curve3D.get(i), V(20,arrBiNormals.get(i-1)), 1);
      }
    }
  }

pt findProjection(pt P, Boolean baseSpine)
  {
    pt O = P(0,0,0);    
    float x = 0;
    float y = 0;
    float z = 0;
    float denom = extProd(I,J,K);
//    println(baseSpine + ", " + arrTangents.size() + ", " + curve3D.size() + ", " + arrNormals.size() + ", " + arrBiNormals.size());
    pt tempP = P(P);
    for (int i=1; i<curve3D.size() - 1; i++) 
    {      
      pt spinePt = projectionOnLine(curve3D.get(i),curve3D.get(i+1),P);
      int mulFactor = -1;
      Boolean flip = false;
      if(P.z < 0)
      {
        flip = true;
      }
      if(baseSpine)
      {
        x = extProd(V(curve3D.get(i),tempP),J,K)/denom;
        y = (extProd(V(curve3D.get(i),tempP),K,I)/denom);
        z = extProd(V(curve3D.get(i),tempP),I,J)/denom;
        tempP = P(curve3D.get(i),x,I,y,J,z,K);
      }
      else
      {
//        tempP = P(curve3D.get(i),P.x,arrNormals.get(i-1),P.y,arrBiNormals.get(i-1),P.z,arrTangents.get(i-1));
        denom = extProd(arrNormals.get(i-1),arrBiNormals.get(i-1),arrTangents.get(i-1));
        if(denom!=0)
        {
            x = -extProd(V(spinePt,P),arrBiNormals.get(i-1),arrTangents.get(i-1))/denom;
            y = (extProd(V(spinePt,P),arrTangents.get(i-1),arrNormals.get(i-1))/denom);
            z = -(extProd(V(spinePt,P),arrNormals.get(i-1),arrBiNormals.get(i-1))/denom);

        }
        else
        {
          x = P.x;
          y = -P.y;
          z = P.z;
        }
//        if(!twistFreeNormals)
//        {
          tempP = P(spinePt,x,arrNormals.get(i-1),y,arrBiNormals.get(i-1),z,arrTangents.get(i-1));
//          tempP.x = -tempP.x;
//          tempP.y = tempP.y;
//          tempP.z = -tempP.z;
//        }
//        else
//        {
////          tempP = P(curve3D.get(i),P.x,arrBiNormals.get(i-1),P.y,arrNormals.get(i-1),P.z,arrTangents.get(i-1));
////        tempP = P(curve3D.get(i),P.x,arrNormals.get(i-1),P.y,arrTangents.get(i-1),P.z,arrBiNormals.get(i-1));
//        tempP = P(curve3D.get(i),P.x,arrNormals.get(i-1),P.y,arrBiNormals.get(i-1),P.z,arrTangents.get(i-1));
////        tempP = P(curve3D.get(i),P.x,arrBiNormals.get(i-1),P.y,arrTangents.get(i-1),P.z,arrNormals.get(i-1));
////        tempP = P(curve3D.get(i),P.x,arrTangents.get(i-1),P.y,arrBiNormals.get(i-1),P.z,arrNormals.get(i-1));
////        tempP = P(curve3D.get(i),P.x,arrTangents.get(i-1),P.y,arrNormals.get(i-1),P.z,arrBiNormals.get(i-1));
//        }
      }      
      if(P.z >= 0 && spinePt.z > P.z)
      {
//        println("Reached");
//        println(curve3D.get(i-1).z + ", " + z + ", " + P.z);
        break;
      }
      else if(P.z < 0 && spinePt.z > P.z)
      {
        break;
      }
    }
    return tempP;
  }
  //Changes for 3D manipulation End
}
