import java.nio.*;
pt DONT_INTERSECT = P(-1,-1);
pt COLLINEAR = P(-2,-2);
pt DONT_INTERSECT2 = P(-3,-3);

pt intersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4){

  float a1, a2, b1, b2, c1, c2;
  float r1, r2 , r3, r4;
  float denom, offset, num;
  float x,y;

  // Compute a1, b1, c1, where line joining points 1 and 2
  // is "a1 x + b1 y + c1 = 0".
  a1 = y2 - y1;
  b1 = x1 - x2;
  c1 = (x2 * y1) - (x1 * y2);

  // Compute r3 and r4.
  r3 = ((a1 * x3) + (b1 * y3) + c1);
  r4 = ((a1 * x4) + (b1 * y4) + c1);

  // Check signs of r3 and r4. If both point 3 and point 4 lie on
  // same side of line 1, the line segments do not intersect.
  if ((r3 != 0) && (r4 != 0) && same_sign(r3, r4)){
    //println("don't intersect1!");
    return DONT_INTERSECT;
  }

  // Compute a2, b2, c2
  a2 = y4 - y3;
  b2 = x3 - x4;
  c2 = (x4 * y3) - (x3 * y4);

  // Compute r1 and r2
  r1 = (a2 * x1) + (b2 * y1) + c2;
  r2 = (a2 * x2) + (b2 * y2) + c2;

  // Check signs of r1 and r2. If both point 1 and point 2 lie
  // on same side of second line segment, the line segments do
  // not intersect.
  if ((r1 != 0) && (r2 != 0) && (same_sign(r1, r2))){
    //println("don't interesect2!");
    return DONT_INTERSECT;
  }

  //Line segments intersect: compute intersection point.
  denom = (a1 * b2) - (a2 * b1);

  if (denom == 0) {
    //println("colinear!");
    return DONT_INTERSECT;
  }

  if (denom < 0){ 
    offset = -denom / 2; 
  } 
  else {
    offset = denom / 2 ;
  }

  // The denom/2 is to get rounding instead of truncating. It
  // is added or subtracted to the numerator, depending upon the
  // sign of the numerator.
  num = (b1 * c2) - (b2 * c1);
  if (num < 0){
    x = (num - offset) / denom;
  } 
  else {
    x = (num + offset) / denom;
  }

  num = (a2 * c1) - (a1 * c2);
  if (num < 0){
    y = ( num - offset) / denom;
  } 
  else {
    y = (num + offset) / denom;
  }

  // lines_intersect
  return P(x,y);
}

Boolean detectClickOnEdge(float x1, float y1, pt P, pt Q){

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
    if((d(P,Q) < d(P,P(x1,y1)))||(d(P,Q) < d(Q,P(x1,y1))))
    {
      return false;
    }
  return true;
}


boolean same_sign(float a, float b){

  return (( a * b) >= 0);
}

float positive(float a) { if(a<0) return a+TWO_PI; else return a;}                                   // adds 2PI to make angle positive
int toDeg(float a) {return int(a*180/PI);}                                                           // convert radians to degrees
boolean isSame(pt A, pt B) {return (A.x==B.x)&&(A.y==B.y)&&(A.z==B.z) ;}                                         // A==B

public pt pick(int mX, int mY)
{
  PGL pgl = beginPGL();
  FloatBuffer depthBuffer = ByteBuffer.allocateDirect(1 << 2).order(ByteOrder.
nativeOrder()).asFloatBuffer();
  pgl.readPixels(mX, height - mY - 1, 1, 1, PGL.DEPTH_COMPONENT, PGL.FLOAT, depthBuffer);
  float depthValue = depthBuffer.get(0);
  depthBuffer.clear();
  endPGL();

  //get 3d matrices
  PGraphics3D p3d = (PGraphics3D)g;
  PMatrix3D proj = p3d.projection.get();
  PMatrix3D modelView = p3d.modelview.get();
  PMatrix3D modelViewProjInv = proj; modelViewProjInv.apply( modelView ); modelViewProjInv.invert();
  
  float[] viewport = {0, 0, p3d.width, p3d.height};
  
  float[] normalized = new float[4];
  normalized[0] = ((mX - viewport[0]) / viewport[2]) * 2.0f - 1.0f;
  normalized[1] = ((height - mY - viewport[1]) / viewport[3]) * 2.0f - 1.0f;
  normalized[2] = depthValue * 2.0f - 1.0f;
  normalized[3] = 1.0f;
  
  float[] unprojected = new float[4];
  
  modelViewProjInv.mult( normalized, unprojected );
  return P( unprojected[0]/unprojected[3], unprojected[1]/unprojected[3], unprojected[2]/unprojected[3] );
}
