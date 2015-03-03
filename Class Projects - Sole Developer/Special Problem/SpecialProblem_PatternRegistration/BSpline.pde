class BSpline {

  ArrayList<pt2> cPts;
  ArrayList<pt2> curve, cLoopNormal, cLoopRadial, cLoopBall, topCap, botCap;
  ArrayList<Integer> cIndex;
  ArrayList<Float> radCPts, radFunction;
  ArrayList<pt2>[] Left, Right;
  Float rad = 5.0;
  boolean radMode = false; // to enable editing radius of control points
  int cType = 1;
  color curveClr = green;
  float circleRadius = 10;

  BSpline() { 
    cPts = new ArrayList<pt2>();
    curve = new ArrayList<pt2>();
    cIndex = new ArrayList<Integer>();
    radCPts = new ArrayList<Float>();
    radFunction = new ArrayList<Float>();
    Left = new ArrayList [3]; 
    Left[0] = new ArrayList<pt2>();
    Right = new ArrayList [3];
    topCap = new ArrayList<pt2>();
    botCap = new ArrayList<pt2>();
    //Changes for 3D manipulation Start
    //Changes for 3D manipulation End
  } 

  void addPt(pt2 p) {
    //println("New Pt: "+p.x+","+p.y);
    cPts.add(p); 
    radCPts.add(rad);
    cIndex.add(cPts.size() - 1);

    if (cPts.size() >= 5) {
      subdivide(curve, cPts);
      updateIndex();
      updateRad();
      cLoopNormal = makeCurve(curve, radFunction, 0, new ArrayList<pt2>(), new ArrayList<pt2>());
      cLoopRadial = makeCurve(curve, radFunction, 1, new ArrayList<pt2>(), new ArrayList<pt2>());
      cLoopBall = makeCurve(curve, radFunction, 2, new ArrayList<pt2>(), new ArrayList<pt2>());
    }

    //println("Size of C Pts: "+cPts.size());
  }


  void updateRad() {
    radFunction.clear();

    //Create ArrayList of pts based on radius and corresponding index
    ArrayList<pt2> radCPt2 = new ArrayList<pt2>();
    ArrayList<pt2> radFn2 = new ArrayList<pt2>();
    for (int i=0; i< radCPts.size (); i++) {
      pt2 curPt = P2(cIndex.get(i), radCPts.get(i));
      radCPt2.add(curPt);
    }

    subdivide(radFn2, radCPt2);
    //populate the radFunction based on radFn2 obtained after subdivision
    for (int i=0; i<radFn2.size (); i++) {
      radFunction.add(radFn2.get(i).y);
    }
    cLoopNormal = makeCurve(curve, radFunction, 0, new ArrayList<pt2>(), new ArrayList<pt2>());
    cLoopRadial = makeCurve(curve, radFunction, 1, new ArrayList<pt2>(), new ArrayList<pt2>());
    cLoopBall = makeCurve(curve, radFunction, 2, new ArrayList<pt2>(), new ArrayList<pt2>());
  }

  void setDefaultRad(float r) {
    rad = r;
  }

  void changeRadCPt(int cpt, pt2 curMouse, pt2 prevMouse) {
    pt2 center = curve.get(cIndex.get(cpt));
    float incRad = d(curMouse, prevMouse);
    float inc = (d(center, prevMouse) > d(center, curMouse))? -incRad: incRad;
    radCPts.set(cpt, radCPts.get(cpt)+inc);

    updateRad();
  }

  ArrayList<pt2> makeCurve(ArrayList<pt2> spine, ArrayList<Float> radProfile, int curveType, ArrayList<pt2> tCap, ArrayList<pt2> bCap) {
    //Curve Type can be 0: Normal, 1: Radial, 2: Ball
    //Make left offset, and right offset separately, and then merge them in the end.

    int numArcs = 10; //To approximate semicircles at each end of the curve 
    ArrayList<pt2> cLoop = new ArrayList<pt2>(); 
    ArrayList<pt2> left = new ArrayList<pt2>();
    ArrayList<pt2> right = new ArrayList<pt2>();

    for (int i=0; i<spine.size () - 1; i++) {
      vec2 curTVec, curNorm, normAtOffset; 
      float dr;
      pt2 curLeftOffset = new pt2(); 
      pt2 curRightOffset = new pt2();

      //Find unit tangent at each point
      curTVec = U(V2(spine.get(i), spine.get(i+1)));

      //Find unit normal
      curNorm = U(R2(curTVec));

      //Find radius derivative
      dr = radProfile.get(i+1) - radProfile.get(i);

      //Find norm vector at offset point
      normAtOffset = U(W(-dr, curTVec, (float) Math.sqrt(1 - dr*dr), curNorm));

      //Normal Offset
      if (curveType == 0) {
        //Find Left and Right Offset
        curLeftOffset = P2(spine.get(i), S(radProfile.get(i), curNorm) );
        curRightOffset = P2(spine.get(i), S(-radProfile.get(i), curNorm) );
      } else if (curveType == 1) { //Radial Offset

        //Find left and right offset points
        curLeftOffset = P2(spine.get(i), S(radProfile.get(i), normAtOffset) );
        curRightOffset = P2(spine.get(i), S(-radProfile.get(i), normAtOffset) );
      } else { //Ball Offset
        //Step1: Find the normal offset at half the distance
        pt2 midLeftOffset = P2(spine.get(i), S(radProfile.get(i)/2, curNorm) );
        pt2 midRightOffset = P2(spine.get(i), S(-radProfile.get(i)/2, curNorm) );

        //Step2: Find the radial offset from the mid points
        curLeftOffset = P2(midLeftOffset, S(radProfile.get(i)/2, normAtOffset) );
        curRightOffset = P2(midRightOffset, S(-radProfile.get(i)/2, normAtOffset) );
      }

      left.add(curLeftOffset);
      right.add(curRightOffset);
    } //end of for loop


    //Merge left side offset
    for (int i=2; i<right.size ()-3; i++) {
      cLoop.add(right.get(i));
    }

    //Merge left to right circular arc
    vec2 leftVec = V2(spine.get(spine.size()-1), right.get(right.size()-5));
    vec2 rightVec = V2(spine.get(spine.size()-1), left.get(left.size()-4));

    for (int i=1; i<numArcs; i++) {
      float incAngle = PI/numArcs;
      pt2 newPt = P2(spine.get(spine.size()-1), R2(leftVec, incAngle*i));
      //print("Arc Pt: "+newPt.x+","+newPt.y+" ");
      cLoop.add(newPt);
      topCap.add(newPt);
      tCap.add(newPt);
    }

    //Merge left side offset
    for (int i=left.size ()-3; i>=3; i--) {
      cLoop.add(left.get(i));
    }

    //Merge right to left circular arc
    vec2 leftVecBot = V2(spine.get(0), right.get(3));
    vec2 rightVecBot = V2(spine.get(0), left.get(3));

    for (int i=1; i<numArcs; i++) {
      float incAngle = PI/numArcs;
      pt2 newPt = P2(spine.get(0), R2(rightVecBot, incAngle*i));
      cLoop.add(newPt);
      botCap.add(newPt);
      bCap.add(newPt);
    }

    return cLoop;
  }

  void subdivide(ArrayList<pt2> fCurve, ArrayList<pt2> cPts) {

    fCurve.clear();

    //copy all elements from cPts to curve
    for (int i=0; i<cPts.size (); i++) {
      fCurve.add(cPts.get(i));
    }

    //Add additional points to clamp the starting and ending point
    pt2 front = fCurve.get(0);
    pt2 end = fCurve.get(fCurve.size()-1);


    //Smoothen the curve
    for (int i=0; i<4; i++) {
      fCurve.add(0, front); 
      fCurve.add(0, front); 
      fCurve.add(0, front); 
      fCurve.add(0, front); 
      fCurve.add(end); 
      fCurve.add(end); 
      fCurve.add(end); 
      fCurve.add(end);

      refine(fCurve);
      dual(fCurve); 
      dual(fCurve); 
      dual(fCurve); 
      dual(fCurve);

      fCurve.remove(0); 
      fCurve.remove(0); 
      fCurve.remove(0); 
      fCurve.remove(0);
      fCurve.remove(fCurve.size()-1); 
      fCurve.remove(fCurve.size()-1); 
      fCurve.remove(fCurve.size()-1); 
      fCurve.remove(fCurve.size()-1);
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

  void updateIndex() {
    for (int i=0; i<cPts.size (); i++) {
      float minDist = 999999;
      int uIndex = 0;

      for (int j=0; j<curve.size (); j++) {  
        float curDist = d(cPts.get(i), curve.get(j));
        if ( curDist < minDist) {
          minDist = curDist;
          uIndex = j;
        }
      }

      cIndex.set(i, uIndex);
    }
  }

  void showPts(color reqdClr) {

    if (!radMode) {
      noFill();
      stroke(reqdClr);
      for (int i=0; i<cPts.size (); i++) {
        cPts.get(i).show(5);
        //        text("Points: x: " + cPts.get(i).x + " , y: " + cPts.get(i).y, 500, 100 + i*10);
      }
      noFill();
    } else {

      noFill();
      stroke(reqdClr);
      for (int i=0; i<cPts.size () - 1; i++) {
        curve.get(cIndex.get(i)).show(radCPts.get(i));
      }
      noFill();
    }
  }

  void showCurve(int curveType, color reqdClr) {
    if (curve.size() > 1 ) {

      fill(reqdClr);
      pen(reqdClr, 1);
      for (int i=0; i<curve.size () - 1; i++) {
        //curve.get(i).show(3);
        edge(curve.get(i), curve.get(i+1));
      }
      //curve.get(curve.size() - 1).show(3);
      noFill();

      //Show corresponding ctrl points
      for (int i=0; i<cIndex.size () - 1; i++) {
        fill(reqdClr);
        curve.get(cIndex.get(i)).show(2);
      }
      //      fill(red);
      //      curve.get(cIndex.get(cIndex.size () - 1)).show(5);


      //Show curvedLoop  
      //      fill(curveClr);
      //      noStroke();
      //
      //      if (curveType == 0) {
      //
      //        fill(red); 
      //        stroke(red);
      //        for (int i=0; i<cLoopNormal.size ()-1; i++) {
      //          //cLoopNormal.get(i).show(2); 
      //          edge(cLoopNormal.get(i), cLoopNormal.get(i+1));
      //        }
      //        edge(cLoopNormal.get(cLoopNormal.size()-1), cLoopNormal.get(0));
      //      } else if (curveType == 1) {
      //        fill(dgreen); 
      //        stroke(dgreen);
      //        for (int i=0; i<cLoopRadial.size () - 1; i++) {
      //          //cLoopRadial.get(i).show(2); 
      //          edge(cLoopRadial.get(i), cLoopRadial.get(i+1));
      //        }
      //        edge(cLoopRadial.get(cLoopRadial.size()-1), cLoopRadial.get(0));
      //      } else if (curveType == 2) {
      //        fill(blue);
      //        for (int i=0; i<cLoopBall.size (); i++) {
      //          cLoopBall.get(i).show(2);
      //        }
      //      }
    }
  }

  void refine(ArrayList<pt2> aList) {

    int i = aList.size() - 2;

    while (true) {
      aList.add(i+1, P2(aList.get(i), aList.get(i+1)));
      i--;
      if ( i < 0) break;
    }
  }

  void dual(ArrayList<pt2> aList) {

    ArrayList<pt2> newList = new ArrayList<pt2>();

    for (int i=0; i<aList.size () -1; i++) {
      newList.add(P2(aList.get(i), aList.get(i+1)));
    }    

    //Clear curve, and copy newList into curve
    aList.clear();
    for (int i=0; i<newList.size (); i++) {
      aList.add(newList.get(i));
    }
  }

  int pickCPt(pt2 click) {

    float minDist = 999999;
    int selCPt = -1;

    for (int i=0; i< cPts.size (); i++) {
      float curDist = d(cPts.get(i), click);
      if (curDist < minDist) {
        minDist = curDist;
        selCPt = i;
      }
    }


    return selCPt;
  }

  void moveCPt(int cpt, vec2 drag) {
    if (cpt < 0 ) return;

    //Modify the coordinates of control point
    cPts.set(cpt, cPts.get(cpt).add(drag));  

    subdivide(curve, cPts);
    cLoopNormal = makeCurve(curve, radFunction, 0, new ArrayList<pt2>(), new ArrayList<pt2>());
    cLoopRadial = makeCurve(curve, radFunction, 1, new ArrayList<pt2>(), new ArrayList<pt2>());
    cLoopBall = makeCurve(curve, radFunction, 2, new ArrayList<pt2>(), new ArrayList<pt2>());
  }

  void setRadMode(boolean radOn) { 
    radMode = radOn;
  }
  boolean getRadMode(boolean radOn) { 
    return radMode;
  }

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
    if (type==0) return cLoopNormal;
    else if (type==1) return cLoopRadial;
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
    this.curve = spine;
    fa = makeCurve(spine, rad, curveType, tCap, bCap);

    return fa;
  }

  float distances(BSpline Q) {  // vertex registration
    pt2 A=centerV(); 
    pt2 B=Q.centerV();
    float s=0; 
    for (int i=0; i<min (cPts.size (), Q.cPts.size()); i++) s+=dot(V2(A, cPts.get(i)), R2(V2(B, Q.cPts.get(i))));
    float c=0; 
    for (int i=0; i<min (cPts.size (), Q.cPts.size()); i++) c+=dot(V2(A, cPts.get(i)), V2(B, Q.cPts.get(i)));
    return atan2(s, c);
  } 

  float moments(BSpline Q) {  // minus sum of moments
    pt2 A=centerV(); 
    pt2 B=Q.centerV(); 
    float d, a=0, D=0; 
    for (int i=0; i<min (cPts.size (), Q.cPts.size()); i++) {
      d=sqrt(d2(A, cPts.get(i))*d2(B, Q.cPts.get(i))); 
      a+=d*atan2(dot(V2(A, cPts.get(i)), R2(V2(B, Q.cPts.get(i)))), dot(V2(A, cPts.get(i)), V2(B, Q.cPts.get(i)))); 
      D+=d;
    }
    return a=a/D;
  } 

  float angles(BSpline Q) {  // minus sum of angle differences from center of mass 
    pt2 A=centerV(); 
    pt2 B=Q.centerV(); 
    float a=0; 
    for (int i=0; i<min (cPts.size (), Q.cPts.size()); i++) a+=atan2(dot(V2(A, cPts.get(i)), R2(V2(B, Q.cPts.get(i)))), dot(V2(A, cPts.get(i)), V2(B, Q.cPts.get(i))));
    return a=a/cPts.size ();
  } 

  void registerTo(BSpline Q, float a) {  // vertex registration
    pt2 A=centerV(); 
    pt2 B=Q.centerV(); 
    translatePoints(V2(A, B));
    rotatePoints(a, B);
  } 

  void translatePoints(vec2 V) {
    ArrayList<pt2> temp = new ArrayList<pt2>();
    for (int i=0; i<cPts.size (); i++)temp.add(P2(cPts.get(i).x, cPts.get(i).y));
    cPts.clear();
    for (int i=0; i<temp.size (); i++) {
//      line(temp.get(i).x, temp.get(i).y, temp.get(i).add(V).x, temp.get(i).add(V).y);
      addPt(temp.get(i).add(V));
    }
  }; 
  void rotatePoints(float aa, pt2 G) {
    ArrayList<pt2> temp = new ArrayList<pt2>();
    for (int i=0; i<cPts.size (); i++)temp.add(P2(cPts.get(i).x, cPts.get(i).y));
    cPts.clear();
    for (int i=0; i<temp.size (); i++) addPt(temp.get(i).rotate(aa, G));
  };
  pt2 centerV() {
    pt2 G=P2(); 
    for (int i=0; i<cPts.size (); i++) G.add(cPts.get(i).x, cPts.get(i).y); 
    return S(1./cPts.size (), G);
  }
  pt2 screenCenter() {
    return P2(height/2, height/2);
  }

  void copyTo(BSpline Q)
  {
    cPts.clear();
    for (int i=0; i<Q.cPts.size (); i++)addPt(P2(Q.cPts.get(i).x, Q.cPts.get(i).y));
  }
  
  //Genom code based on point signature
  //Create circle/sphere around the control point. Let the control circle intersect the created curve. 
  //The intersected curve C will define a plane based on tangent and normal of the curve. 
  //Use weighted average to find center. 
  //Create a projection of the curve at the control point along the normal to the intersected curve.
  //Create signal profile based on distance of   
  ArrayList<Signature> arrptSignature = new ArrayList<Signature>();
  void createGenom()
  {
    for (int i=0; i<cPts.size (); i++)
    {
      ArrayList<pt2> intersectCurve = new ArrayList<pt2>();
      pt2 rp = P2(cPts.get(i).x,cPts.get(i).y);
      for (int j=0; j<curve.size () - 1; j++) {
        if(d2(rp,curve.get(j))<=circleRadius)
        {
          vec2 curTVec;
          vec2 curNorm;
          intersectCurve.add(P2(curve.get(j).x,curve.get(j).y));
          //Find unit tangent at each point
          curTVec = U(V2(curve.get(j), curve.get(j+1)));
    
          //Find unit normal
          curNorm = U(R2(curTVec));
        }
      }
    }
  } 
}

