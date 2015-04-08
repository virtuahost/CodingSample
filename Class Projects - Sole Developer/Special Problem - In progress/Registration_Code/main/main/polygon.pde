class POLYGON {
boolean loopIsClosed = true;
int n=4;                        // current number of control points
pt [] P = new pt[1000];            // decalres an array of  vertices
int p=0;                         // index to the currently selected vertex being dragged
POLYGON() {declarePoints(); resetPoints(); }
POLYGON(int pn) {n=pn; declarePoints(); resetPoints(); }
int next(int j) {  if (j==n-1) {return (0);}  else {return(j+1);}  };  // next point in loop
int prev(int j) {  if (j==0) {return (n-1);}  else {return(j-1);}  };  // previous point in loop                                                     
void declarePoints() {for (int i=0; i<P.length; i++) P[i]=new pt();} // init the vertices to be on a circle
void resetPoints() {for (int i=0; i<n; i++) {P[i]=new pt(width/2,height/10.); P[i].rotateBy(-2.*PI*i/n, screenCenter());}; } // init the points to be on a circle
void appendPoint(pt Q)  { P[n++].setTo(Q);  }; // add point at end of list
// ************************************** EDITING *********************************
void clickPolygon() {
   if (key=='m') pickClosestPoint();
   if (key=='i') insertPoint();
   if (key=='d') {pickClosestPoint(); deletePoint();};
   }
void dragPolygon() {
   if (key=='i') dragPoint(); 
   if (key=='m') dragPoint(); 
   if (key=='t') translatePoints(mouseDrag()); 
   if (key=='r') rotatePoints( angle( V(centerV(),Mouse()) , V(centerV(),Pmouse()) ) );
   if (key=='s') scalePoints(-dot(mouseDrag(),Mouse().makeVecToCenter())/10000.); 
   };
void pickClosestPoint(pt M) {if(mouseIsInWindow()) { p=0; for (int i=1; i<n; i++) if (M.disTo(P[i])<M.disTo(P[p])) p=i; };}
void pickClosestPoint() {pt M = Mouse(); p=0; for (int i=1; i<n; i++) if (M.disTo(P[i])<M.disTo(P[p])) p=i;}
void dragPoint() { P[p].moveWithMouse(); P[p].clipToWindow(); }      // moves selected point (index p) by amount mouse moved recently
void dragPoint(vec V) {P[p].translateBy(V);}
void deletePoint() { for (int i=p; i<n-1; i++) P[i].setTo(P[next(i)]); n--; p=prev(p);}
void insertPoint() {                // grabs closeest vertex or adds vertex at closest edge. It will be dragged by te mouse
     pt M = Mouse();
      p=0; for (int i=1; i<n; i++) if (M.disTo(P[i])<M.disTo(P[p])) p=i; 
     int e=-1;
     float d = M.disTo(P[p]);
     for (int i=0; i<n; i++) 
        if ( (0.25<M.ratioOfProjectionBetween(P[i],P[next(i)])) && (M.ratioOfProjectionBetween(P[i],P[next(i)])<0.75) && (M.disToLine(P[i],P[next(i)])<d))
          {e=i; d=M.disToLine(P[e],P[next(e)]);};
      if (e!=-1) { for (int i=n-1; i>e; i--) P[i+1].setTo(P[i]); n++; p=next(e); P[p].setToMouse();  };
      }
void translatePoints(vec V) {for (int i=0; i<n; i++) P[i].translateBy(V); };   
void scalePoints(float s) {for (int i=0; i<n; i++) P[i].translateTowards(s,screenCenter());};  
void rotatePoints(float aa) {pt C=centerV(); for (int i=0; i<n; i++) P[i].rotateBy(aa,C);}; 
void rotatePoints(float aa, pt G) {for (int i=0; i<n; i++) P[i].rotateBy(aa,G);}; 

// ************************************** VIEWING *********************************
void drawArrowsTo(POLYGON R) {for (int i=0; i<min(n,R.n); i++) arrow(P[i],R.P[i]);};
void drawPoints() {for (int i=0; i<n; i++) P[i].show();}
void drawPoints(int r) {for (int i=0; i<n; i++) P[i].show(r);}
void writePointIDs() {for (int i=0; i<n; i++) {vec V=P[i].makeVecToAverage(P[prev(i)],P[next(i)]); V.normalize(); V.scaleBy(-10); V.add(-3,5); P[i].showLabel(str(i),V); };}; 
void drawEdges() {beginShape();  for (int i=0; i<n; i++) P[i].v(); endShape(); }    
void drawEdges(boolean closed) {beginShape();  for (int i=0; i<n; i++) P[i].v(); if(closed) endShape(CLOSE); else endShape();} 

// ************************************** MEASURING *********************************
pt centerV() {pt G=P(); for (int i=0; i<n; i++) G.addPt(P[i]); return S(1./n,G);} 
pt centerE(boolean closed) {pt G=P(); float D=0; 
  for (int i=0; i<n-1; i++) {float d=d(P[i],P[i+1]); D+=d; G.addPt(S(d,A(P[i],P[i+1])));} 
  if (closed) {float d=d(P[n-1],P[0]); D+=d; G.addPt(S(d,A(P[n-1],P[0])));};
  return S(1./D,G);} 
float length () {float L=0; 
    if (!loopIsClosed) for (int i=2; i<n-3; i++) L+=P[i].disTo(P[next(i)]); 
    else for (int i=0; i<n; i++) L+=P[i].disTo(P[next(i)]); 
    return(L); }
pt projectionOfPoint(pt M) { // on closed loop
     int v=0; for (int i=1; i<n; i++) if (M.disTo(P[i])<M.disTo(P[v])) v=i; 
     int e=-1;
     float d = M.disTo(P[v]);
     for (int i=0; i<n; i++) if ( M.projectsBetween(P[i],P[next(i)])  && (M.disToLine(P[i],P[next(i)])<d)) {e=i; d=M.disToLine(P[e],P[next(e)]);};
     if (e!=-1) return(M.makeProjectionOnLine(P[e],P[next(e)])); else return(P[v].makeClone());
     }
 float distanceToPoint(pt M) {return(M.disTo(projectionOfPoint(M)));}
boolean polygonContains(pt M) {boolean isIn=false; for (int i=1; i<n-1; i++) if (M.isInTriangle(P[0],P[i],P[next(i)])) isIn=!isIn; return(isIn); }
// ************************************** PROCESSING *********************************
void refine(float s) { 
      pt[] Q = new pt [2*n];     
      for (int i=0; i<n; i++) { Q[2*i]= b(P[prev(i)],P[i],P[next(i)],s); Q[2*i+1]=f(P[prev(i)],P[i],P[next(i)],P[next(next(i))],s); };
      n*=2; for (int i=0; i<n; i++) P[i].setTo(Q[i]);
     }
void coarsen() {n/=2; for (int i=0; i<n; i++) P[i].setTo(P[2*i+1]); } 
boolean stabbed(pt A, pt B) {boolean stab=false;  for (int i=0; i<n; i++) if(edgesIntersect(A,B,P[i],P[next(i)])) stab=true; return stab; }
boolean stabbed(pt A, pt B, int j) {boolean stab=false;  for (int i=0; i<n; i++) if ((i!=j)&&(edgesIntersect(A,B,P[i],P[next(i)]))) stab=true; return stab; }
// ************************************** ARCHIVAL *********************************
void savePts() {savePts("P.pts");}
void savePts(String fn) { String [] inppts = new String [n+1];
    int s=0; inppts[s++]=str(n); for (int i=0; i<n; i++) {inppts[s++]=str(P[i].x)+","+str(P[i].y);};
    saveStrings(fn,inppts);  };
void loadPts() {loadPts("P.pts");}
void loadPts(String fn) { String [] ss = loadStrings(fn);
    String subpts;
    int s=0; int comma; n = int(ss[s]);
    for(int i=0;i<n; i++) { comma=ss[++s].indexOf(',');
      P[i]=new pt (float(ss[s].substring(0, comma)), float(ss[s].substring(comma+1, ss[s].length()))); }; };
// ***********************************  TRIANGULATION *************************
void drawDelaunayTriangles() { 
   pt X = new pt(0,0);
   float r=1;  // radius of circumcircle
   for (int i=0; i<n-2; i++) for (int j=i+1; j<n-1; j++) for (int k=j+1; k<n; k++) {
      X=CenterCircum (P[i],P[j],P[k]);  r = X.disTo(P[i]);
      boolean found=false; 
      for (int m=0; m<n; m++) if ((m!=i)&&(m!=j)&&(m!=k)&&(X.disTo(P[m])<=r)) found=true;  
     if (!found) show(P[i],P[j],P[k]);
     }; // end triple loop
   }; 
// ********************************* COPYING & MORPHING ****************************
float distances(POLYGON Q) {  // vertex registration
  pt A=centerV(); pt B=Q.centerV(); 
  float s=0; for (int i=0; i<min(n,Q.n); i++) s+=dot(V(A,P[i]),R(V(B,Q.P[i])));
  float c=0; for (int i=0; i<min(n,Q.n); i++) c+=dot(V(A,P[i]),V(B,Q.P[i]));
  return atan2(s,c);
  } 
 
float moments(POLYGON Q) {  // minus sum of moments
  pt A=centerV(); pt B=Q.centerV(); 
  float d, a=0, D=0; for (int i=0; i<min(n,Q.n); i++) {
     d=sqrt(d2(A,P[i])*d2(B,Q.P[i])); 
     a+=d*atan2(dot(V(A,P[i]),R(V(B,Q.P[i]))),dot(V(A,P[i]),V(B,Q.P[i]))); 
     D+=d;}
  return a=a/D;
  } 
 
float angles(POLYGON Q) {  // minus sum of angle differences from center of mass 
  pt A=centerV(); pt B=Q.centerV(); 
  float a=0; for (int i=0; i<min(n,Q.n); i++) a+=atan2(dot(V(A,P[i]),R(V(B,Q.P[i]))),dot(V(A,P[i]),V(B,Q.P[i])));
  return a=a/n;
  } 
void drawVec(POLYGON Q)
{
  pt A=centerV(); pt B=Q.centerV(); 
  vec AO = V(A,P[0]);
//  println(A.x + ", " + A.y + ", " + AO.x + ", " + AO.y + ", " + P[0].x + ", " + P[0].y);
//  line(A.x,A.y,AO.x,AO.y);
  AO.showArrowAt(A);
  vec BO = V(B,Q.P[0]);
//  line(B.x,B.y,BO.x,BO.y);
  BO.showArrowAt(B);
  vec BR = R(V(B,Q.P[0]));
//  line(B.x,B.y,BR.x,BR.y);
  BR.showArrowAt(B);
}


void copyFrom(POLYGON Q) {n=Q.n; for (int i=0; i<n; i++) P[i].setTo(Q.P[i]);}
void flip() {pt C=centerV(); vec N=V(0,1); for (int i=0; i<n; i++) P[i]=T(P[i],-2*dot(N,V(C,P[i])),N);}
void recenter(POLYGON Q) {pt A=centerV(); pt B=Q.centerV(); for (int i=0; i<n; i++) P[i]=T(A,d(B,Q.P[i]),P[i]);}

void registerTo(POLYGON Q, float a) {  // vertex registration
  pt A=centerV(); 
  pt B=Q.centerV(); 
  translatePoints(V(A,B));
  rotatePoints(a,B); 
  } 
void registerMTo(POLYGON Q) { //mid-edge points registration weighted by edge-length
  pt A=centerE(false); 
  pt B=Q.centerE(false); 
  float s=0, c=0;
  for (int i=0; i<min(n,Q.n)-1; i++) {
      float d=(d(P[i],P[next(i)])+d(Q.P[i],Q.P[Q.next(i)]))/2;
      s+=d*dot(V(A,A(P[i],P[next(i)])),R(V(B,A(Q.P[i],Q.P[Q.next(i)]))));
      c+=d*dot(V(A,A(P[i],P[next(i)])),V(B,A(Q.P[i],Q.P[Q.next(i)]))); 
  }
  translatePoints(V(A,B));
  float a=atan2(s,c);
  rotatePoints(a,B);
 }  
void linearMorph(POLYGON A, float t, POLYGON B) {
   n=min(A.n,B.n); 
   for (int i=0; i<n; i++) P[i]=L(A.P[i],t,B.P[i]);
   }
void curvatureMorph(POLYGON A, float t, POLYGON B) {
   copyFrom(A);
   P[1]=T(P[0],pow(d(B.P[0],B.P[1])/d(A.P[0],A.P[1]),t),V(A.P[0],A.P[1])); 
   n=min(A.n,B.n); 
   for (int i=2; i<n; i++) {
     float d=d(A.P[i-1],A.P[i])*pow(d(B.P[i-1],B.P[i])/d(A.P[i-1],A.P[i]),t);
     float a=(1.-t)*angle(V(A.P[i-2],A.P[i-1]),V(A.P[i-1],A.P[i]))+t*angle(V(B.P[i-2],B.P[i-1]),V(B.P[i-1],B.P[i]));
     P[i]=T(P[i-1],S(d,R(U(V(P[i-2],P[i-1])),a)));
     }
   }
void spiral(pt G, float s, float a, float t) {for (int i=0; i<n; i++) P[i]=spiralPt(P[i],G,s,a,t);}
void spiral(POLYGON A, float t, POLYGON B) {  // moves P by a fraction t of spiral from A to B
  float a =spiralAngle(A.P[0],A.P[A.n-1],B.P[0],B.P[B.n-1]); 
  float s =spiralScale(A.P[0],A.P[A.n-1],B.P[0],B.P[B.n-1]);
  pt G = spiralCenter(a, s, A.P[0], B.P[0]);
  spiral(G,s,a,t);
  }

}
