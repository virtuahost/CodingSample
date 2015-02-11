Boolean bend = false;
pt mouseBendStart;
pt mouseBendEnd;
Boolean bendUpdated = false;
float radiusOfBend = 0f;
float angleOfBend = 0f;
pt centerOfPoint;
ArrayList<pt> curvedSpine = new ArrayList<pt>();
float maxBend = 0.34*2;
float currBend = 0;
float bendChange = .06;

public void drawDebug()
{
  //println("currBend: " + currBend);
  if(mouseBendEnd != null)
  {
    //line(mouseBendStart.x, mouseBendStart.y, mouseBendEnd.x, mouseBendEnd.y);
//    show(P(0,0, 0), mouseBendEnd);
//    show(mouseBendEnd , 10);
  }
    
  
  if(centerOfPoint != null)
  {
//    centerOfPoint.show(10);
//      show(centerOfPoint , 10);
//    edge(P(width/2,700),centerOfPoint);
    
//    fill(green);
    noFill();
    stroke(cyan);
    beginShape();
    vec V = V(centerOfPoint,P());
    vec U = V(centerOfPoint,mouseBendEnd);
    float angle = angle(V,U);
    if(centerOfPoint.y < 0)
    {
      angle = - angle;
    }
    vec A = V(P(),centerOfPoint).normalize();
    if(centerOfPoint.y < 0){A = V(centerOfPoint,P()).normalize();}
////    print("startPt: ");start.write();
////    print("centerOfPoint: ");centerOfPoint.write();
////    print("mouseBendEnd: ");mouseBendEnd.write();
//    //prisntln("angle: " + angle);
    for(float i=1; i > 0; i -= .1) {
      //println("drawing");
      pt asdf = R(P(),angle*i,V(0,0,1), A,centerOfPoint);
        v(asdf);
        //println("asdf: ");asdf.write();
    }
    endShape();
    if(drawNormal)
    {
      for(float i=1; i > 0; i -= .1) {
          //println("drawing");
          pt asdf = R(P(),angle*i,V(0,0,1), A,centerOfPoint);
          vec normal = V(centerOfPoint, asdf).normalize().mul(20);
          cone(asdf, normal, 1);
          //println("asdf: ");asdf.write();
      }
    }
  }
  

}

//Code to detect intersection on edge
Boolean detectClickOnEdge(float x1, float y1, pt2 P, pt2 Q){
  P = P2(P);Q=P2(Q);
  float a1, b1, c1;
  float r1, r2, r3;
    // Compute a1, b1, c1, where line joining points 1 and 2
    // is "a1 x + b1 y + c1 = 0".
    a1 = Q.y - P.y;
    b1 = P.x - Q.x;
    c1 = (Q.x * P.y) - (P.x * Q.y);
  
    r1 = (a1 * x1) + (b1 * y1) + c1;
    P.x = P.x + 5;
    Q.x = Q.x + 5;
    P.y = P.y + 5;
    Q.x = Q.x + 5;
    
    a1 = Q.y - P.y;
    b1 = P.x - Q.x;
    c1 = (Q.x * P.y) - (P.x * Q.y);
 
    r2 = (a1 * x1) + (b1 * y1) + c1;
    
  
    // Check signs of r3 and r4. If both point 3 and point 4 lie on
    // same side of line 1, the line segments do not intersect.
    if( (r1 != 0) && (r2 != 0) && same_sign(r1, r2)){
      P.x = P.x - 10;
      Q.x = Q.x - 10;
      P.y = P.y - 10;
      Q.x = Q.x - 10;
      a1 = Q.y - P.y;
      b1 = P.x - Q.x;
      c1 = (Q.x * P.y) - (P.x * Q.y);
   
      r3 = (a1 * x1) + (b1 * y1) + c1;
      if( (r1 != 0) && (r3 != 0) && same_sign(r1, r3))
      {
        return false;
      }
    }
    if((d(P,Q) < d(P,P2(x1,y1)))||(d(P,Q) < d(Q,P2(x1,y1))))
    {
      return false;
    }
  return true;
}


boolean same_sign(float a, float b){

  return (( a * b) >= 0);
}


//Changes for 3D manipulation Start
pt bendProjectionPoint(pt P)
{
   pt O = P(0,0,0);
  pt globalProj = P(P); 
//   if(bend)
//   {
//     pt proj = bsl[3].findProjection(P,true);
     pt newProj = bsl[2].findProjection(P,false);
     globalProj = P(O,newProj.x,I,newProj.y,J,newProj.z,K);
//   }
   return globalProj;
}  

float extProd(vec U, vec V, vec W) {return (U.x*V.y*W.z + U.y*V.z*W.x + U.z*V.x*W.y - U.x*V.z*W.y - U.y*V.x*W.z - U.z*V.y*W.x); };
//Changes for 3D manipulation End  

 vec ToIK(vec V) {
 float x = detS(V,K) / detS(I,K);
 float z = detS(V,I) / detS(K,I);
 return V(x,0,z);
 }
 
vec ToJ(vec V) {
 float y = dot(V,J) / dot(J,J);
 return V(0,y,0);
 }

float detS(vec U, vec V) {return -U.z*V.x+U.x*V.z; }; 
