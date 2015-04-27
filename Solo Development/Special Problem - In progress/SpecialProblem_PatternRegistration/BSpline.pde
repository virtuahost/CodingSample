class BSpline {

  ArrayList<pt2> cPts;
  ArrayList<pt2> curve, cLoopNormal, cLoopRadial, cLoopBall, topCap, botCap;
  ArrayList<Integer> cIndex;
  ArrayList<Float> radCPts, radFunction;
  ArrayList<pt2>[] Left, Right;
  ArrayList<pt2> arcLengthSample;
  ArrayList<pt2> arcLengthSampleDraw;
  ArrayList<Float> arcSampleCurvChange;
  LinkedHashMap<Float, Genom> dicOmegaSet;
  LinkedHashMap<Integer, Integer> dicDTWKey;
  Float rad = 5.0;
  boolean radMode = false; // to enable editing radius of control points
  int cType = 1;
  color curveClr = green;
  float circleRadius = 10;
  int isNotInThreshold = 0;
  int medianVal = 0;

  BSpline() { 
    cPts = new ArrayList<pt2>();
    curve = new ArrayList<pt2>();
    arcLengthSample = new ArrayList<pt2>();
    arcLengthSampleDraw = new ArrayList<pt2>();
    cIndex = new ArrayList<Integer>();
    radCPts = new ArrayList<Float>();
    radFunction = new ArrayList<Float>();
    Left = new ArrayList [3]; 
    Left[0] = new ArrayList<pt2>();
    Right = new ArrayList [3];
    topCap = new ArrayList<pt2>();
    botCap = new ArrayList<pt2>();
    arcSampleCurvChange = new ArrayList<Float>();
    dicOmegaSet = new LinkedHashMap<Float, Genom>();
    dicDTWKey = new LinkedHashMap<Integer, Integer>();
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

  lstSqrTransf getLeastSquareTransform(BSpline P, BSpline Q, boolean fixedScale)
  {
    return getLeastSquareTransform(P.arcLengthSample, Q.arcLengthSample, fixedScale);
  }

  lstSqrTransf getLeastSquareTransform(ArrayList<pt2> P, ArrayList<pt2> Q, boolean fixedScale)
  {
    pt2 C = P2(0, 0);
    pt2 A=this.centerSampleCurve(P); 
    pt2 B=this.centerSampleCurve(Q);
    float cs = 0;
    float ss = 0;
    float ll = 0;
    float rr = 0;
    for (int i = 0; i<P.size (); i++)
    {
      float newPX = P.get(i).x - A.x;
      float newQX = Q.get(i).x - B.x;
      float newPY = P.get(i).y - A.y;
      float newQY = Q.get(i).y - B.y;
      cs += newPX*newQX + newPY*newQY;
      ss += -newPX*newQY + newPY*newQX;
      ll += d2(P.get(i), C);
      rr += d2(Q.get(i), C);
    }
    float scaleVal = 0;
    float cosVal = 0;
    float sinVal = 0;
    float tranValX = 0;
    float tranValY = 0;
    if (ll!= 0)
    {
      scaleVal = (fixedScale?1:sqrt(rr/ll));
      cosVal = cs/sqrt(cs*cs+ss*ss);
      sinVal = ss/sqrt(cs*cs+ss*ss);
      tranValX = B.x - scaleVal*(cosVal*A.x-sinVal*A.y);
      tranValY = B.y - scaleVal*(cosVal*A.y+sinVal*A.x);
    }
    lstSqrTransf outputVal = new lstSqrTransf(scaleVal, cosVal, sinVal, tranValX, tranValY);
    return outputVal;
  }

  pt2 applyTransform(pt2 P, lstSqrTransf transf)
  {
    float x = 0;
    float y = 0;
    float cs = transf.cosVal;
    float ss = transf.sinVal;
    x = transf.tranValX + transf.scaleVal*(cs*P.x-ss*P.y);
    y = transf.tranValY + transf.scaleVal*(cs*P.y+ss*P.x);
    return P2(x, y);
  }

  Boolean isSameCurve(BSpline Q)
  {
    return isSameCurve(this.arcLengthSample, Q.arcLengthSample);
  }

  Boolean isSameCurve(ArrayList<pt2> P, ArrayList<pt2> Q)
  {
    Boolean result = true;
    ArrayList<pt2> temp = new ArrayList<pt2>();
    lstSqrTransf transf = getLeastSquareTransform(P, Q, fixedScale);
    for (int i=0; i<P.size (); i++)
    {
      //Least Square Implementation
      temp.add(applyTransform(P.get(i), transf));
    }
//    if (drawDebug)
//    {
//      fill(black);
//      pen(black, 1);
//      for (int i=0; i<temp.size ()-1; i++) {
//        edge(temp.get(i), temp.get(i+1));
//      }
//      noFill();
//    }
    for (int i = 1; i < Q.size ()-2; i++)
    {
      if (d2(Q.get(i), temp.get(i)) > maxThresholdRad)
      {
        if (this.isNotInThreshold > errorCnt) {
          result = false;
          break;
        }
        this.isNotInThreshold++;
      }
    }
    return result;
  }

  void registerToCurve(BSpline Q, float a) {  // vertex registration
    pt2 A=centerVCurve(); 
    pt2 B=Q.centerVCurve(); 
    translatePointsCurve(V2(A, B));
    rotatePointsCurve(a, B);
  } 

  void translatePointsCurve(vec2 V) {
    ArrayList<pt2> temp = new ArrayList<pt2>();
    for (int i=0; i<curve.size (); i++)temp.add(P2(curve.get(i).x, curve.get(i).y));
    curve.clear();
    for (int i=0; i<temp.size (); i++) {
      curve.add(temp.get(i).add(V));
    }
  }; 
  void rotatePointsCurve(float aa, pt2 G) {
    ArrayList<pt2> temp = new ArrayList<pt2>();
    for (int i=0; i<curve.size (); i++)temp.add(P2(curve.get(i).x, curve.get(i).y));
    curve.clear();
    for (int i=0; i<temp.size (); i++) curve.add(temp.get(i).rotate(aa, G));
  };

  pt2 centerVCurve() {
    pt2 G=P2(); 
    for (int i=0; i<curve.size (); i++) G.add(curve.get(i).x, curve.get(i).y); 
    return S(1./curve.size (), G);
  }

  pt2 centerSampleCurve() {
    pt2 G=P2(); 
    for (int i=0; i<arcLengthSample.size (); i++) G.add(arcLengthSample.get(i).x, arcLengthSample.get(i).y); 
    return S(1./arcLengthSample.size (), G);
  }

  pt2 centerSampleCurve(ArrayList<pt2> lstSample) {
    pt2 G=P2(); 
    for (int i=0; i<lstSample.size (); i++) G.add(lstSample.get(i).x, lstSample.get(i).y); 
    return S(1./lstSample.size (), G);
  }

  vec2 normalVCurve() {
    vec2 V= V2(0, 0); 
    for (int i=0; i<curve.size (); i++) V.add(curve.get(i).x, curve.get(i).y); 
    return U(V.divideBy(1./curve.size ()));
  }

  float distancesCurve(BSpline Q) {  // vertex registration
    pt2 A=centerVCurve(); 
    pt2 B=Q.centerVCurve();
    float s=0; 
    for (int i=0; i<min (curve.size (), Q.curve.size()); i++) s+=dot(V2(A, curve.get(i)), R2(V2(B, Q.curve.get(i))));
    float c=0; 
    for (int i=0; i<min (curve.size (), Q.curve.size()); i++) c+=dot(V2(A, curve.get(i)), V2(B, Q.curve.get(i)));
    return atan2(s, c);
  } 

  float momentsCurve(BSpline Q) {  // minus sum of moments
    pt2 A=centerVCurve(); 
    pt2 B=Q.centerVCurve(); 
    float d, a=0, D=0; 
    for (int i=0; i<min (curve.size (), Q.curve.size()); i++) {
      d=sqrt(d2(A, curve.get(i))*d2(B, Q.curve.get(i))); 
      a+=d*atan2(dot(V2(A, curve.get(i)), R2(V2(B, Q.curve.get(i)))), dot(V2(A, curve.get(i)), V2(B, Q.curve.get(i)))); 
      D+=d;
    }
    return a=a/D;
  } 

  float anglesCurve(BSpline Q) {  // minus sum of angle differences from center of mass 
    pt2 A=centerVCurve(); 
    pt2 B=Q.centerVCurve(); 
    float a=0; 
    for (int i=0; i<min (curve.size (), Q.curve.size()); i++) a+=atan2(dot(V2(A, curve.get(i)), R2(V2(B, Q.curve.get(i)))), dot(V2(A, curve.get(i)), V2(B, Q.curve.get(i))));
    return a=a/curve.size ();
  } 

  void copyCurve(BSpline Q, int start, int end)
  {
    curve.clear();
    for (int i=start; i<=end; i++)
    {
      curve.add(P2(Q.curve.get(i)));
    }
  }

  void copySampleCurve(BSpline Q, int start, int end)
  {
    arcLengthSample.clear();
    pt2 endPC = P2(Q.arcLengthSample.get(end));
    for (int i=start; i<=end; i++)
    {
      arcLengthSample.add(P2(Q.arcLengthSample.get(i)));
    }
  }

  void showSampleCurve(color reqdClr)
  {
    if (arcLengthSample.size() > 1 ) {

      fill(reqdClr);
      pen(reqdClr, 1);
      for (int i=0; i<arcLengthSample.size () - 1; i++) {
        edge(arcLengthSample.get(i), arcLengthSample.get(i+1));
      }
      noFill();
    }
  }

  void showSampleCurve(ArrayList<pt2> Q, color reqdClr)
  {
    if (arcLengthSample.size() > 1 ) {

      fill(reqdClr);
      pen(reqdClr, 1);
      for (int i=0; i<Q.size () - 1; i++) {
        edge(Q.get(i), Q.get(i+1));
      }
      noFill();
    }
  }
  
  void showSampleCurvewithoutShift(color reqdClr)
  {
     if (curve.size() > 1 ) {

      fill(reqdClr);
      pen(reqdClr, 1);
      for (int i=0; i<curve.size () - 1; i++) {
        edge(curve.get(i), curve.get(i+1));
      }
      noFill();
    }
  }

  void createArcLengthSample()
  {  
    arcLengthSample.clear();
    boolean keepCalc = false;
    float tempLen = 0;
    pt2 strtPC = curve.get(0);
    pt2 endPC = curve.get(1);
    arcLengthSample.add(strtPC);
    for (int i=1; i<curve.size (); i++)
    {
      endPC = curve.get(i);
      if (d(strtPC, endPC) > (arcLengthSampleSize - tempLen))
      {
        float remLen = d(strtPC, endPC);
        while (remLen > arcLengthSampleSize)
        {
          pt2 newPt = MoveByDistanceTowards(strtPC, arcLengthSampleSize - tempLen, endPC);
          arcLengthSample.add(newPt);
          remLen= remLen - d(strtPC, newPt);
          tempLen = (remLen < arcLengthSampleSize?tempLen+remLen:0);          
          strtPC = P2(newPt);
        }
      } else
      {
        tempLen = (tempLen+d(strtPC, endPC)==arcLengthSampleSize?0:tempLen+d(strtPC, endPC));
        if (tempLen == 0)arcLengthSample.add(endPC);
      }
    }
  }

  BSpline generateCurvePiece(pt2 x, pt2 y)
  {
    BSpline output = new BSpline();
    if (curve.size() > 1 ) {
      pt2 tempStart = P2();
      pt2 tempEnd = P2();
      int start = -1;
      int end = -1;
      //      println("Begin");
      for (int i=0; i<curve.size (); i++) {
        if (i == 0)
        {          
          //          tempStart = projectionOnLine(x, curve.get(i), curve.get(i+1));
          tempStart = P2(curve.get(i));
          start = i;
          //          tempEnd = projectionOnLine(y, curve.get(i), curve.get(i+1));
          tempEnd = P2(curve.get(i));
          end = i;
        } else
        {
          if (d(x, tempStart) > d(x, curve.get(i)))
          {         
            //            println("Start: " + start + "val: " + d2(x, tempStart) + ", " +  d2(x,temp1));
            //            tempStart = projectionOnLine(x, curve.get(i), curve.get(i+1));
            tempStart = P2(curve.get(i));
            start = i;
          }
          //          if (d(y, tempEnd) > d(y,temp2))
          if (d(y, tempEnd) > d(y, curve.get(i)))
          {
            //            println("End: " + end + "val: " + d2(y, tempEnd) + ", " +  d2(y,temp2));
            //            tempEnd = projectionOnLine(y, curve.get(i), curve.get(i+1));
            tempEnd = P2(curve.get(i));
            end = i;
          }
        }
      }
      //      println(curve.size());
      //      println(start);
      //      println(end);
      //      println("Finish");
      if (start > end)
      {
        int temp = start;
        start = end;
        end = temp;
        pt2 tempPt = P2(tempStart);
        tempStart = P2(tempEnd);
        tempEnd = P2(tempPt);
      }
      this.startX = start;
      this.endX = end;
      output.curve.add(tempStart);
      for (int i=start; i<=end; i++)
      {
        output.curve.add(P2(curve.get(i)));
      }
      output.curve.add(tempEnd);
    }

    return output;
  }

  int startX = -1;
  int endX = -1;
  void showCurveDebug(int curveType, color reqdClr, int start, int end) {
    if (curve.size() > 1 ) {

      fill(reqdClr);
      pen(reqdClr, 1);
      for (int i=start; i<end; i++) {
        //curve.get(i).show(3);
        edge(curve.get(i), curve.get(i+1));
      }
      //curve.get(curve.size() - 1).show(3);
      noFill();
    }
  }
  String findAllAndDraw(color reqdClr)
  {
    int found = 0;
    this.createArcLengthSample();
    this.createSampleSimilaritySet();
    found = startSearch(reqdClr);
    return String.valueOf(found);
  }

  int startSearch(color reqdClr)
  {
    int i = 0;
    int start = -1;
    int end = -1;
    int finalVal = 0;
    int finalStart = -1;
    int finalEnd = -1;
    int newVal = 0;    
    float remIndex = -1;
    boolean process = false;
    float removeVal = -1;
    int size = 0;
//    do
//    {
      process = false;
      end = -1;
      for (float keyVal : dicOmegaSet.keySet ())
      {
        if(drawDebug){fill(red);stroke(red);arcLengthSample.get(dicOmegaSet.get(keyVal).allIndex.get(0)).tag(String.valueOf(dicOmegaSet.get(keyVal).cntVal),10);noFill();}
//        if(dicOmegaSet.get(keyVal).cntVal < medianVal)
//        {
//          end = dicOmegaSet.get(keyVal).allIndex.get(0);
//          size = dicOmegaSet.get(keyVal).allIndex.size();
//          removeVal = keyVal;
//          process = true;
//          break;
//        }
          if(dicOmegaSet.get(keyVal).cntVal <= medianVal)
          {
            float d = medianVal - dicOmegaSet.get(keyVal).cntVal;
            if(d < newVal)
            {
              newVal = medianVal - dicOmegaSet.get(keyVal).cntVal;
            }
          }
      }
      for(float keyVal : dicOmegaSet.keySet ())
      {
        if((dicOmegaSet.get(keyVal).cntVal == (medianVal - newVal))||(dicOmegaSet.get(keyVal).cntVal == (medianVal - newVal -1))||(dicOmegaSet.get(keyVal).cntVal == (medianVal - newVal+1)))
        {     
          if((start == -1) || (this.arcLengthSample.get(dicOmegaSet.get(keyVal).allIndex.get(0)).x < this.arcLengthSample.get(start).x))
          {
            start = dicOmegaSet.get(keyVal).allIndex.get(0);
          }
          if((end==-1) || (this.arcLengthSample.get(dicOmegaSet.get(keyVal).allIndex.get(0)).x > this.arcLengthSample.get(end).x))
          {
            end = dicOmegaSet.get(keyVal).allIndex.get(0);
          }
        }
      }
//      if(removeVal > -1)dicOmegaSet.remove(removeVal);
//      start = 0;
//      if (start>-1&&end>-1&&(end-start>this.arcLengthSample.size()/maxPatternElem))newVal = registerAndDraw(start, end, reqdClr,false);
//      println("End: " + end + "Newval: "+ newVal + "finalVal: " + finalVal);
//      if((newVal < size)&&(newVal > 1)&&(finalVal<=newVal))
//      {
//        remIndex = end - start;
//        finalStart = start;
//        finalEnd = end;
//        finalVal = newVal;
//      }
//    }
//    while(process);    
//    if(finalEnd > -1)finalVal = registerAndDraw(finalStart, finalEnd, reqdClr,true);
    if(end > -1)finalVal = registerAndDraw(start, end, reqdClr,true);
    return finalVal;
  }

  void createSampleSimilaritySet()
  {
    dicOmegaSet.clear();
    for (int i=1; i<arcLengthSample.size () - 1; i++) {
      //Calc curvature value of triangle through the 3 points. Formula 4*area of Triangle/product of 3 sides
      pt2 A = arcLengthSample.get(i-1);
      pt2 B = arcLengthSample.get(i);
      pt2 C = arcLengthSample.get(i+1);
      vec2 V1 = U(V2(A,B));
      vec2 V2 = U(V2(B,C));
      float AB = d(A, B);
      float BC = d(B, C);
      float CA = d(C, A);
      float P = (AB+BC+CA)/2;
      float areaABC = sqrt(P*(P-AB)*(P-BC)*(P-CA));
      float curvVal = 4*areaABC/(AB*BC*CA);
      float angle = angle(V1,V2);
      if ((AB*BC*CA) == 0)curvVal = 1; 
      arcSampleCurvChange.add(curvVal);
      float tempVal = findKeyVal(curvVal,angle);
      if (tempVal == -1)
      {
        Genom keyVal = new Genom(1, i,angle);
        dicOmegaSet.put(curvVal, keyVal);
      } else
      {
        Genom keyVal = dicOmegaSet.get(tempVal);
        keyVal.cntVal = keyVal.cntVal + 1;
        keyVal.allIndex.add(i);
        dicOmegaSet.put(tempVal, keyVal);
      }
    }
    this.sortHashMapByValues();
  }

  float findKeyVal(float curvVal,float angle)
  {
    boolean neg = false;
    if(angle < 0)neg=true;
    if (dicOmegaSet.size() > 0)
    {
      for (Float keyVal : dicOmegaSet.keySet ())
      {
        boolean check = false;
        if(neg && dicOmegaSet.get(keyVal).angle < 0)
        {
          check = true;
        }
        else if(!neg && dicOmegaSet.get(keyVal).angle >= 0)
        {
          check = true;
        }
        if (check && curvVal-errVal <= keyVal && keyVal <= curvVal+errVal)
        {
          return keyVal;
        }
      }
    }
    return -1;
  }

  void sortHashMapByValues() {
    LinkedHashMap<Float, Genom> sortedMap = new LinkedHashMap<Float, Genom>();
    LinkedHashMap<Float, Genom> ignoreKeys = new LinkedHashMap<Float, Genom>();
    int highVal = 0;
    int lowVal = 0;
    for (float keyVal : dicOmegaSet.keySet ())
    {
      Genom tempVal = new Genom();
      float updKey = -1;
      boolean setData = true;
      for (float keyAct : dicOmegaSet.keySet ())
      {
        if (ignoreKeys.containsKey(keyAct))continue;
        if (setData)  
        {      
          tempVal = dicOmegaSet.get(keyAct);
          updKey = keyAct;
          setData = false;
        }
        Genom compVal = dicOmegaSet.get(keyAct);
        if (compVal.cntVal > tempVal.cntVal)
        {
          updKey = keyAct;
          tempVal = new Genom(compVal.cntVal, compVal.allIndex,compVal.angle);
        }
      }
      if(lowVal > tempVal.cntVal && tempVal.cntVal > 1)lowVal = tempVal.cntVal;
      if(highVal < tempVal.cntVal && tempVal.cntVal < maxPatternElem)highVal = tempVal.cntVal;
      if (tempVal.cntVal > 1)
      {
        sortedMap.put(updKey, tempVal);
        ignoreKeys.put(updKey, tempVal);
      }
    }   
    medianVal = (highVal + lowVal)/2;    
//    if (drawDebug)
//    {
//      println("Start: " + dicOmegaSet.size());
//      for (Genom keyVal : sortedMap.values ())
//      {
//        println("Val: " + keyVal.cntVal);
//      }
//      println("Size: " + sortedMap.size());
//    }
    dicOmegaSet = sortedMap;
  } 

  void copySampleCurvewithShift(BSpline Q, int start, int end,pt2 P)
  {
    arcLengthSample.clear();
    float dist = d(Q.arcLengthSample.get(start),P);
    vec2 transVec = V2(V2(Q.arcLengthSample.get(start),P).normalize().x,0.0f);
//    println("Start");
    for (int i=start; i<=end; i++)
    {
//      println("Old: " + Q.arcLengthSample.get(i));
      arcLengthSample.add(P2(Q.arcLengthSample.get(i),dist,transVec));
      curve.add(P2(Q.arcLengthSample.get(i)));
//      println("New: " + arcLengthSample.get(i-start));
    }
//    println("End");
  }
  
  int registerAndDraw(int start, int end, color reqdCol)
  {
    return registerAndDraw(start, end, reqdCol, true);
  }

  int registerAndDraw(int start, int end, color reqdCol, boolean draw)
  {
    int k = 0;
    int curvSize = end - start+1;
    Boolean bDraw = false;
    ArrayList<pt2> Q = new ArrayList<pt2>();
    for (int i = start; i <= end; i++)
    {
      Q.add(P2(arcLengthSample.get(i)));
    }
    if(!useDTW)
    {
      for (int i=0; i<arcLengthSample.size ()-curvSize; i++) 
      {
        BSpline tempS = new BSpline();
        tempS.copySampleCurve(this, i, i+curvSize-1);
        bDraw = tempS.isSameCurve(tempS.arcLengthSample, Q);
        if (bDraw)
        {
          k++;
          if(draw)tempS.showSampleCurve(reqdCol);
          i = i+curvSize-1;
        }
      }
    }
    else
    {
       //Not implemented as performance made using DTW with auto registration impractical as of now. Need FastDTW
    }
    if(draw)this.showSampleCurve(Q, black);
    return k;
  }
  
  void registerAndDraw(BSpline Q, color reqdCol)
  {
    this.createArcLengthSample();
    Q.createArcLengthSample();
    Boolean bDraw = false;
    int curvSize = Q.arcLengthSample.size();//Q.curve.size();
    if(!useDTW)
    {
      for (int i=0; i<arcLengthSample.size ()-curvSize; i++) 
      {
        BSpline tempS = new BSpline();
        tempS.copySampleCurve(this, i, i+curvSize-1);
        bDraw = tempS.isSameCurve(Q); 
        if (bDraw)
        {
          tempS.showSampleCurve(reqdCol);
          i = i+curvSize-1;
        }
      }
    }
    else
    {
      //Moved to function registerDTW to help with performance
      for(int keyAct : dicDTWKey.keySet ())
      {
        BSpline tempS = new BSpline();
        tempS.copySampleCurve(this, keyAct, dicDTWKey.get(keyAct));
        tempS.showSampleCurve(reqdCol);
      }
    }
  }
  
  void registerDTW(BSpline Q)
  {    
    this.createArcLengthSample();
    Q.createArcLengthSample();
    float refDist = 0;
    int curvSize = Q.arcLengthSample.size();
    int lastCurveThreshold = curvSize/2;
    int totThreshold = curvSize+lastCurveThreshold; 
    pt2 P = P2(Q.arcLengthSample.get(0));   
    BSpline refS = new BSpline();
    refS.copySampleCurvewithShift(this, 0, curvSize-1,P);  
    refDist = calcDTWcost(refS.arcLengthSample, Q.arcLengthSample);
    for (int i=0; i<arcLengthSample.size ()-curvSize; i++) 
    {
      for(int k = 0; k < lastCurveThreshold; k=k+lastCurveThreshold/4)
      {
        int j = i + curvSize-1;
        BSpline tempS = new BSpline();
        tempS.copySampleCurvewithShift(this, i, j,P);
        float tempDist = calcDTWcost(tempS.arcLengthSample, Q.arcLengthSample);
        if(sq(refDist - tempDist) < dtwErrVal*dtwErrVal)
        {
  //        tempS.showSampleCurvewithoutShift(reqdCol);
          this.dicDTWKey.put(i,j);
          i = j;
          break;
        }
      }
    }
  }

  //DTW implementation
  float calcDTWcost(ArrayList<pt2> P, ArrayList<pt2> Q)
  {
    float[][] locArr = new float[P.size()][Q.size()];
    float[][] globalArr = new float[P.size()][Q.size()];
    float calcDist = 0;
    for (int i = 0; i < P.size (); i ++)
    {
      for (int j = 0; j < Q.size (); j ++)
      {
        locArr[i][j] = d2(P.get(i), Q.get(j));
      }
    }
    globalArr[0][0] = locArr[0][0];
    for (int i =1; i < P.size (); i ++)
    {
      globalArr[i][0]= locArr[i][0] + globalArr[i-1][0];
    }    
    for (int j =1; j < Q.size (); j ++)
    {
      globalArr[0][j]= locArr[0][j] + globalArr[0][j-1];
    }
    for (int i =1; i < P.size (); i ++)
    {
      for (int j =1; j < Q.size (); j ++)
      {
        calcDist = Math.min(Math.min(globalArr[i-1][j], globalArr[i][j-1]), globalArr[i-1][j-1]) + locArr[i][j];
        globalArr[i][j] = calcDist;
      }
    }
    int i = P.size()-1;
    int j = Q.size()-1;
    int k = 0; 
    int minIndex = 0;
      calcDist = globalArr[P.size()-1][Q.size()-1];

    while ( (i+j) != 0)
    {
      if (i == 0) {
        j -= 1;
      } else if (j == 0) {
        i -= 1;
      } else {        // i != 0 && j != 0
        double[] array = { 
          globalArr[i - 1][j], globalArr[i][j - 1], globalArr[i - 1][j - 1]
        };
        minIndex = this.getIndexOfMinimum(array);

        if (minIndex == 0) {
          i -= 1;
        } else if (minIndex == 1) {
          j -= 1;
        } else if (minIndex == 2) {
          i -= 1;
          j -= 1;
        }
      } // end else
      k++;
    } // end while
    return calcDist / k;
  }

  int getIndexOfMinimum(double[] array) {
    int index = 0;
    double val = array[0];

    for (int i = 1; i < array.length; i++) {
      if (array[i] < val) {
        val = array[i];
        index = i;
      }
    }
    return index;
  }
}

