//*************************************************************
//**** 2D GEOMETRY CLASSES AND UTILITIES, Jarek Rossignac *****
//****         LAST EDITED ON:  March 06 2008               *****
//*************************************************************
//************************************************************************
//**** POINTS
//************************************************************************
// create
pt P(float x, float y) {return new pt(x,y); };                                                       // make point (x,y)
pt P() {return P(0,0); };                                                                            // make point (0,0)
pt P(pt P) {return P(P.x,P.y); };                                                                    // make copy of point P
// combine
pt S(pt A, pt B) {return new pt(A.x+B.x,A.y+B.y); };                                                 // Weighted sum: A+B
pt S(pt A, pt B, pt C) {return S(A,S(B,C)); };                                                       // Weighted sum: A+B+C
pt S(pt A, pt B, pt C, pt D) {return S(S(A,B),S(C,D)); };                                            // Weighted sum: A+B+C+D
pt S(float s, pt A) {return new pt(s*A.x,s*A.y); };                                                  // Weighted point: sA
pt S(pt A, float s, pt B) {return S(A,S(s,B)); };                                                    // Weighted sum: A+sB
pt L(pt A, float s, pt B) {return P(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y)); };                             // Linear interpolation: A+sAB
pt S(float a, pt A, float b, pt B) {return S(S(a,A),S(b,B));}                                        // Weighted sum: aA+bB 
pt S(float a, pt A, float b, pt B, float c, pt C) {return S(S(a,A),S(b,B),S(c,C));}                  // Weighted sum: aA+bB+cC 
pt S(float a, pt A, float b, pt B, float c, pt C, float d, pt D){return A(S(a,A,b,B),S(c,C,d,D));}   // Weighted sum: aA+bB+cC+dD
pt A(pt A, pt B) {return P((A.x+B.x)/2.0,(A.y+B.y)/2.0); };                                          // Average: (A+B)/2
pt A(pt A, pt B, pt C) {return P((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0); };                            // Average: (A+B+C)/3
// transform
pt R(pt Q, float a) {float dx=Q.x, dy=Q.y, c=cos(a), s=sin(a); return new pt(c*dx+s*dy, -s*dx+c*dy); };                 // Rotated Q by a around origin
pt R(pt Q, float a, pt P) {float dx=Q.x-P.x, dy=Q.y-P.y, c=cos(a), s=sin(a); return P(P.x+c*dx-s*dy, P.y+s*dx+c*dy); }; // Rotated Q by a around P
pt T(pt P, vec V) {return P(P.x + V.x, P.y + V.y); }                                                 // Translate: P+V
pt T(pt P, float s, vec V) {return T(P,S(s,V)); }                                                    // Translate: P+sV
pt T(pt A, float s, pt B) { return T(A,s,U(V(A,B))); };                                              // Translate: P by s towards Q: P+sU(PQ)
// measure
boolean isSame(pt A, pt B) {return (A.x==B.x)&&(A.y==B.y) ;}                                         // Equality: A==B
boolean isSame(pt A, pt B, float e) {return ((abs(A.x-B.x)<e)&&(abs(A.y-B.y)<e));}                   // Equality: ||A-B||<e
float d(pt P, pt Q) {return sqrt(d2(P,Q));  };                                                       // Distance: ||AB||
float d2(pt P, pt Q) {return sq(Q.x-P.x)+sq(Q.y-P.y); };                                             // Distance squared: AB*AB
boolean leftTurn(pt A, pt B, pt C) {return (A.y-C.y)*(B.x-A.x)>(A.x-C.x)*(B.y-A.y);}
// render
void v(pt P) {vertex(P.x,P.y);};                                                                      // next point when drawing polygons between beginShape(); and endShape();
void cross(pt P, float r) {line(P.x-r,P.y,P.x+r,P.y); line(P.x,P.y-r,P.x,P.y+r);};                    // shows P as cross of length r
void cross(pt P) {cross(P,2);};                                                                       // shows P as small cross
void show(pt P, float r) {ellipse(P.x, P.y, 2*r, 2*r);};                                              // draws circle of center r around point
void show(pt P) {ellipse(P.x, P.y, 4,4);};                                                            // draws small circle around point
void show(pt P, pt Q) {line(P.x,P.y,Q.x,Q.y); };                                                      // draws edge (P,Q)
void arrow(pt P, pt Q) {arrow(P,V(P,Q)); }                                                            // draws arrow from P to Q
void label(pt P, String S) {text(S, P.x+5,P.y+4); }                                                  // writes S next to P
// mouse & screen
pt Mouse() {return P(mouseX,mouseY);};                                                                 // current mouse location
pt Pmouse() {return P(pmouseX,pmouseY);};                                                              // previous mouse location
vec mouseDrag() {return V(mouseX-pmouseX,mouseY-pmouseY);};                                            // vector of mouse-drag
pt mouseInWindow() {float x=mouseX, y=mouseY; x=max(x,0); y=max(y,0); x=min(x,height); y=min(y,height);  return P(x,y);}; // clips mouse to square window
pt screenCenter() {return P(height/2,height/2);}                                                       // point in center of screen
boolean mouseIsInWindow() {return(((mouseX>0)&&(mouseX<height)&&(mouseY>0)&&(mouseY<height)));};       // if mouse is in square window

//************************************************************************
//**** VECTORS
//************************************************************************
// create
vec V(vec V) {return new vec(V.x,V.y); };                                                             // make copy of vector V
vec V(float x, float y) {return new vec(x,y); };                                                      // make vector (x,y)
vec V(pt P, pt Q) {return new vec(Q.x-P.x,Q.y-P.y);};                                                 // PQ
vec MouseDrag() {return new vec(mouseX-pmouseX,mouseY-pmouseY);};                                     // vector representing recent mouse displacement
// combine
vec S(vec U, vec V) {return new vec(U.x+V.x,U.y+V.y);}                                                // Weighted sum: U+V 
vec S(float s,vec V) {return new vec(s*V.x,s*V.y);};                                                  // Weighted sum: sV
vec S(float a, vec U, float b, vec V) {return S(S(a,U),S(b,V));}                                      // Weighted sum: aU+bV 
vec S(vec U,float s,vec V) {return new vec(U.x+s*V.x,U.y+s*V.y);};                                    // Weighted sum: U+sV
vec A(vec U, vec V) {return new vec((U.x+V.x)/2.0,(U.y+V.y)/2.0); };                                  // Average: (U+V)/2
vec L(vec U,float s,vec V) {return new vec(U.x+s*(V.x-U.x),U.y+s*(V.y-U.y));};                        // Linear interpolation: (1-s)U+sV
// transform
vec U(vec V) {float n = n(V); if (n==0) return new vec(0,0); else return new vec(V.x/n,V.y/n);};      // Unit vector: V/||V||
vec R(vec V) {return new vec(-V.y,V.x);};                                                             // Rotate: V turned right 90 degrees (as seen on screen)
vec R(vec U, float a) {vec W = U.makeRotatedBy(a);  return W ; };                                     // Rotate: U rotated by a
vec R(vec U, float s, vec V) {float a = angle(U,V); vec W = U.makeRotatedBy(s*a);                     // Rotate: interpolation (angle and length) between U and V
    float u = n(U); float v=n(V); S((u+s*(v-u))/u,W); return W ; };
// measure
float dot(vec U, vec V) {return U.x*V.x+U.y*V.y; };                                                    // dot product: U*V
float n(vec V) {return sqrt(dot(V,V));};                                                               // ||V||
float n2(vec V) {return sq(V.x)+sq(V.y);};                                                             // V*V
boolean parallel (vec U, vec V) {return dot(U,R(V))==0; }; 
// render
void show(pt P, vec V) {line(P.x,P.y,P.x+V.x,P.y+V.y); }                                              // show line from P along V
void show(pt P, float s, vec V) {show(P,S(s,V));}                                                     // show line from P along sV
void arrow(pt P, vec V) {show(P,V);  float n=n(V); if(n<0.01) return; float s=max(min(0.2,20./n),6./n);                  // show arrow from P along V
     pt Q=T(P,V); vec U = S(-s,V); vec W = R(S(.3,U)); beginShape(); v(T(T(Q,U),W)); v(Q); v(T(T(Q,U),-1,W)); endShape(CLOSE);}; 
void arrow(pt P, float s, vec V) {arrow(P,S(s,V));}                                                   // show arrow from P along sV
void arrow(pt P, vec V, String S) {arrow(P,V); T(T(P,0.70,V),15,R(U(V))).showLabel(S,V(-5,4));}      // show arrow from P along V with Label
//************************************************************************
//**** ANGLES
//************************************************************************
float angle (vec U, vec V) {return atan2(dot(R(U),V),dot(U,V)); };                                   // angle <U,V> between -PI and PI
float angle(vec V) {return(atan2(V.y,V.x)); };                                                       // angle <<1,0>,V> between -PI and PI
float angle(pt A, pt B, pt C) {return  angle(V(B,A),V(B,C)); }                                       // angle <BA,BC>
float turnAngle(pt A, pt B, pt C) {return  angle(V(A,B),V(B,C)); }                                   // angle <AB,BC> (positive when right turn as seen on screen)
int toDeg(float a) {return int(a*180/PI);}
float toRad(float a) {return(a*PI/180);}
float positive(float a) { if(a<0) return a+TWO_PI; else return a;}

//************************************************************************
//**** EDGES
//************************************************************************
//************************************************************************
//**** RAYS
//************************************************************************
boolean isRightOf(pt A, pt Q, vec T) {return dot(R(T),V(Q,A)) > 0 ; };                               // A is on right of ray(Q,T) (as seen on screen)

//************************************************************************
//**** TRIANGLES
//************************************************************************
// centers
pt CenterMass (pt A, pt B, pt C)  {return A(A,B,C);}
pt CenterCircum (pt A, pt B, pt C) { vec AB = V(A,B); vec AC = R(V(A,C)); return T(A,1./2/dot(AB,AC),S(-n2(AC),R(AB),n2(AB),AC)); }; // circumcenter of tri(A,B,C)
pt CenterIn (pt A, pt B, pt C)  {  float Z=area(A,B,C), a=B.disTo(C), b=C.disTo(A), c=A.disTo(B), s=a+b+c, r=2*Z/s, R=a*b*c/(2*r*s);
     return S(a/s,A,b/s,B,c/s,C);  }
pt CenterD (pt A, pt B, pt C)  {  float Z=area(A,B,C), a=B.disTo(C), b=C.disTo(A), c=A.disTo(B), ss=a*a+b*b+c*c;
     return S(a*a/ss,A,b*b/ss,B,c*c/ss,C);  }
pt CenterN (pt A, pt B, pt C)  {  float Z=area(A,B,C), a=B.disTo(C), b=C.disTo(A), c=A.disTo(B), s=a+b+c;
     return S((s-a)/2/s,A,(s-b)/2/s,B,(s-c)/2/s,C);  }
// measures
float radiusCircum (pt A, pt B, pt C) {
    float a=B.disTo(C);     float b=C.disTo(A);     float c=A.disTo(B);
    float s=(a+b+c)/2;     float d=sqrt(s*(s-a)*(s-b)*(s-c));   float r=a*b*c/4/d;
    return (r);
   };
float radiusMonotonic (pt A, pt B, pt C) {                                                  // size of bubble pushed through (A,C) and touching B, >0 when ABC ic clockwise
    float a=d(B,C), b=d(C,A), c=d(A,B);
    float s=(a+b+c)/2; float d=sqrt(s*(s-a)*(s-b)*(s-c)); float r=a*b*c/4/d;
    if (abs(angle(A,B,C))>PI/2) r=sq(d(A,C)/2)/r;
    if (abs(angle(C,A,B))>PI/2) r=sq(d(C,B)/2)/r;
    if (abs(angle(B,C,A))>PI/2) r=sq(d(B,A)/2)/r;
    if (!isRightTurn(A,B,C)) r=-r;
    return r;
   };
float radiusN (pt A, pt B, pt C)  {  float Z=area(A,B,C), a=B.disTo(C), b=C.disTo(A), c=A.disTo(B), s=a+b+c;  return 2*Z/s;  }
float area(pt A, pt B, pt C) {return 0.5*dot(V(A,C),R(V(A,B))); }                                    // signed area of triangle
float thickness(pt A, pt B, pt C) {float a = abs(dot(V(B,A),U(R(V(B,C))))), b = abs(dot(V(C,B),U(R(V(C,A))))), c = abs(dot(V(A,C),U(R(V(A,B))))); return min (a,b,c); } 
boolean ccw(pt A, pt B, pt C) {return C.isLeftOf(A,B) ;}
// render
void show(pt A, pt B, pt C)  {beginShape();  A.v(); B.v(); C.v(); endShape(CLOSE);}
void show(pt A, pt B, pt C, float r) {if (thickness(A,B,C)<2*r) return;
    float s=r; if (!ccw(A,B,C)) s=-s; pt AA = A.makeOffset(B,C,s); pt BB = B.makeOffset(C,A,s); pt CC = C.makeOffset(A,B,s); 
    beginShape();  AA.v(); BB.v(); CC.v(); endShape(CLOSE);
    }
// constructions    
pt makeProjectionOnLine(pt P, pt B, pt Q) {float a=dot(V(P,B),V(P,Q)), b=d2(P,Q); return T(P,a/b,Q); };
pt makeOffset(pt A, pt B, pt C, float r) {
    float a = angle(V(B,A),V(B,C))/2;
    float d = r/sin(a); 
    vec N = U(A(U(V(B,A)),U(V(B,C)))); 
    return T(B,d,N); };
    boolean isRightTurn(pt A, pt B, pt C) {return dot( R(V(A,B)),V(B,C)) > 0 ; };                        // A-B-C makes right turn (as seen on screen)


//************************************************************************
//**** CIRCLES
//************************************************************************
// ?????????????
pt circumCenterOLD (pt A, pt B, pt C) {    // computes the center of a circumscirbing circle to triangle (A,B,C)
  vec AB =  A.makeVecTo(B);  float ab2 = dot(AB,AB);
  vec AC =  A.makeVecTo(C); AC.turnLeft();  float ac2 = dot(AC,AC);
  float d = 2*dot(AB,AC);
  AB.turnLeft();
  AB.scaleBy(-ac2); 
  AC.scaleBy(ab2);
  AB.add(AC);
  AB.scaleBy(1./d);
  pt X =  A.makeClone();
  X.translateBy(AB);
  return(X);
  };

//************************************************************************
//**** ARCS
//************************************************************************


  
//************************************************************************
//**** CURVES
//************************************************************************
  void retrofitBezier(pt[] PP, pt[] QQ) {                            // sets control polygon QQ so that tits Bezier curve interpolates PP
  QQ[0]=P(PP[0]);
  QQ[1]=S(-15./18.,PP[0],54./18.,PP[1],-27./18.,PP[2],6./18.,PP[3]);
  QQ[2]=S(-15./18.,PP[3],54./18.,PP[2],-27./18.,PP[1],6./18.,PP[0]);
  QQ[3]=P(PP[3]);
  }
  
//************************************************************************
//**** POINTS
//************************************************************************
class pt { float x=0,y=0; 
  // CREATE
  pt () {}
  pt (float px, float py) {x = px; y = py;};
  pt (pt P) {x = P.x; y = P.y;};
  pt (pt P, vec V) {x = P.x+V.x; y = P.y+V.y;};
  pt (pt P, float s, vec V) {x = P.x+s*V.x; y = P.y+s*V.y;};
  pt (pt A, float s, pt B) {x = A.x+s*(B.x-A.x); y = A.y+s*(B.y-A.y);};

  // MODIFY
  void setTo(float px, float py) {x = px; y = py;};  
  void setTo(pt P) {x = P.x; y = P.y;}; 
  void setToMouse() { x = mouseX; y = mouseY; }; 
  void moveWithMouse() { x += mouseX-pmouseX; y += mouseY-pmouseY; }; 
  void translateToTrack(float s, pt P) {setTo(T(P,s,V(P,this)));};
  void track(float s, pt P) {setTo(T(P,s,V(P,this)));};
  void scaleBy(float f) {x*=f; y*=f;};
  void scaleBy(float u, float v) {x*=u; y*=v;};
  void translateBy(vec V) {x += V.x; y += V.y;};   
  void addVec(vec V) {x += V.x; y += V.y;};   
  void translateBy(float s, vec V) {x += s*V.x; y += s*V.y;};  
  void addScaled(float s, vec V) {x += s*V.x; y += s*V.y;};  
  void addScaled(float s, pt P)   {x += s*P.x; y += s*P.y;};   
  void addScaledPt(float s, pt P) {x += s*P.x; y += s*P.y;};        // incorrect notation, but useful for computing weighted averages
  void translateBy(float u, float v) {x += u; y += v;};
  void translateTowards(float s, pt P) {x+=s*(P.x-x);  y+=s*(P.y-y); };
  void translateTowardsBy(float s, pt P) {vec V = this.makeVecTo(P); V.normalize(); this.translateBy(s,V); };
  void addPt(pt P) {x += P.x; y += P.y;};        // incorrect notation, but useful for computing weighted averages
  void rotateBy(float a) {float dx=x, dy=y, c=cos(a), s=sin(a); x=c*dx+s*dy; y=-s*dx+c*dy; };     // around origin
  void rotateBy(float a, pt P) {float dx=x-P.x, dy=y-P.y, c=cos(a), s=sin(a); x=P.x+c*dx+s*dy; y=P.y-s*dx+c*dy; };   // around point P
  void rotateBy(float s, float t, pt P) {float dx=x-P.x, dy=y-P.y; dx-=dy*t; dy+=dx*s; dx-=dy*t; x=P.x+dx; y=P.y+dy; };   // s=sin(a); t=tan(a/2);
  void clipToWindow() {x=max(x,0); y=max(y,0); x=min(x,height); y=min(y,height); }
  
  // OUTPUT POINT
  pt clone() {return new pt(x,y); };
  pt make() {return new pt(x,y); };
  pt makeClone() {return new pt(x,y); };
  pt makeTranslatedBy(vec V) {return(new pt(x + V.x, y + V.y));};
  pt makeTranslatedBy(float s, vec V) {return(new pt(x + s*V.x, y + s*V.y));};
  pt makeTransaltedTowards(float s, pt P) {return(new pt(x + s*(P.x-x), y + s*(P.y-y)));};
  pt makeTranslatedBy(float u, float v) {return(new pt(x + u, y + v));};
  pt makeRotatedBy(float a, pt P) {float dx=x-P.x, dy=y-P.y, c=cos(a), s=sin(a); return(new pt(P.x+c*dx+s*dy, P.y-s*dx+c*dy)); };
  pt makeRotatedBy(float a) {float dx=x, dy=y, c=cos(a), s=sin(a); return(new pt(c*dx+s*dy, -s*dx+c*dy)); };
  pt makeProjectionOnLine(pt P, pt Q) {float a=dot(P.makeVecTo(this),P.makeVecTo(Q)), b=dot(P.makeVecTo(Q),P.makeVecTo(Q)); return(P.makeTransaltedTowards(a/b,Q)); };
  pt makeOffset(pt P, pt Q, float r) {
    float a = angle(vecTo(P),vecTo(Q))/2;
    float h = r/tan(a); 
    vec T = vecTo(P); T.normalize(); vec N = T.left();
    pt R = new pt(x,y); R.translateBy(h,T); R.translateBy(r,N);
    return R; };

   // OUTPUT VEC
  vec vecTo(pt P) {return(new vec(P.x-x,P.y-y)); };
  vec makeVecTo(pt P) {return(new vec(P.x-x,P.y-y)); };
  vec makeVecToCenter () {return(new vec(x-height/2.,y-height/2.)); };
  vec makeVecToAverage (pt P, pt Q) {return(new vec((P.x+Q.x)/2.0-x,(P.y+Q.y)/2.0-y)); };
  vec makeVecToAverage (pt P, pt Q, pt R) {return(new vec((P.x+Q.x+R.x)/3.0-x,(P.y+Q.y+R.x)/3.0-y)); };
  vec makeVecToMouse () {return(new vec(mouseX-x,mouseY-y)); };
  vec makeVecToBisectProjection (pt P, pt Q) {float a=this.disTo(P), b=this.disTo(Q);  return(this.makeVecTo(L(P,a/(a+b),Q))); };
  vec makeVecToNormalProjection (pt P, pt Q) {float a=dot(P.makeVecTo(this),P.makeVecTo(Q)), b=dot(P.makeVecTo(Q),P.makeVecTo(Q)); return(this.makeVecTo(L(P,a/b,Q))); };
  vec makeVecTowards(pt P, float d) {vec V = makeVecTo(P); float n = V.norm(); V.normalize(); V.scaleBy(d-n); return V; };
 
  // OUTPUT TEST OR MEASURE
  float disTo(pt P) {return(sqrt(sq(P.x-x)+sq(P.y-y))); };
  float disToMouse() {return(sqrt(sq(x-mouseX)+sq(y-mouseY))); };
  boolean isInWindow() {return(((x>0)&&(x<height)&&(y>0)&&(y<height)));};
  boolean projectsBetween(pt P, pt Q) {float a=dot(P.makeVecTo(this),P.makeVecTo(Q)), b=dot(P.makeVecTo(Q),P.makeVecTo(Q)); return((0<a)&&(a<b)); };
  float ratioOfProjectionBetween(pt P, pt Q) {float a=dot(P.makeVecTo(this),P.makeVecTo(Q)), b=dot(P.makeVecTo(Q),P.makeVecTo(Q)); return(a/b); };
  float disToLine(pt P, pt Q) {float a=dot(P.makeVecTo(this),P.makeVecTo(Q).makeUnit().makeTurnedLeft()); return(abs(a)); };
  boolean isLeftOf(pt P, pt Q) {boolean l=dot(P.makeVecTo(this),P.makeVecTo(Q).makeTurnedLeft())>0; return(l);  };
  boolean isLeftOf(pt P, pt Q, float e) {boolean l=dot(P.makeVecTo(this),P.makeVecTo(Q).makeTurnedLeft())>e; return(l);  };  boolean isInTriangle(pt A, pt B, pt C) { boolean a = this.isLeftOf(B,C); boolean b = this.isLeftOf(C,A); boolean c = this.isLeftOf(A,B); return((a&&b&&c)||(!a&&!b&&!c));};
  boolean isInCircle(pt C, float r) {return d(this,C)<r; }  // returns true if point is in circle C,r
  
  // DRAW , PRINT
  void show() {ellipse(x, y, height/200, height/200); }; // shows point as small dot
  void show(float r) {ellipse(x, y, 2*r, 2*r); }; // shows point as disk of radius r
  void showCross(float r) {line(x-r,y,x+r,y); line(x,y-r,x,y+r);}; 
  void v() {vertex(x,y);};  // used for drawing polygons between beginShape(); and endShape();
  void write() {print("("+x+","+y+")");};  // writes point coordinates in text window
  void showLabel(String s, vec D) {text(s, x+D.x-5,y+D.y+4);  };  // show string displaced by vector D from point
  void showLabel(String s) {text(s, x+5,y+4);  };
  void showLabel(int i) {text(str(i), x+5,y+4);  };  // shows integer number next to point
  void showLabel(String s, float u, float v) {text(s, x+u, y+v);  };
  void showSegmentTo (pt P) {line(x,y,P.x,P.y); }; // draws edge to another point
  void to (pt P) {line(x,y,P.x,P.y); }; // draws edge to another point

  } // end of pt class

//************************************************************************
//**** VECTORS
//************************************************************************
class vec { float x=0,y=0; 
 // CREATE
  vec () {};
  vec (vec V) {x = V.x; y = V.y;};
  vec (float s, vec V) {x = s*V.x; y = s*V.y;};
  vec (float px, float py) {x = px; y = py;};
  vec (pt P, pt Q) {x = Q.x-P.x; y = Q.y-P.y;};
 
 // MODIFY
  void setTo(float px, float py) {x = px; y = py;}; 
  void setTo(pt P, pt Q) {x = Q.x-P.x; y = Q.y-P.y;}; 
  void setTo(vec V) {x = V.x; y = V.y;}; 
  void scaleBy(float f) {x*=f; y*=f;};
  void back() {x=-x; y=-y;};
  void mul(float f) {x*=f; y*=f;};
  void div(float f) {x/=f; y/=f;};
  void scaleBy(float u, float v) {x*=u; y*=v;};
  void normalize() {float n=sqrt(sq(x)+sq(y)); if (n>0.000001) {x/=n; y/=n;};};
  void add(vec V) {x += V.x; y += V.y;};   
  void add(float s, vec V) {x += s*V.x; y += s*V.y;};   
  void addScaled(float s, vec V) {x += s*V.x; y += s*V.y;};  
  void add(float u, float v) {x += u; y += v;};
  void turnLeft() {float w=x; x=-y; y=w;};
  void rotateBy (float a) {float xx=x, yy=y; x=xx*cos(a)-yy*sin(a); y=xx*sin(a)+yy*cos(a); };
  
  // OUTPUT VEC
  vec make() {return(new vec(x,y));}; 
  vec clone() {return(new vec(x,y));}; 
  vec makeClone() {return(new vec(x,y));}; 
  vec makeUnit() {float n=sqrt(sq(x)+sq(y)); if (n<0.000001) n=1; return(new vec(x/n,y/n));}; 
  vec unit() {float n=sqrt(sq(x)+sq(y)); if (n<0.000001) n=1; return(new vec(x/n,y/n));}; 
  vec makeScaledBy(float s) {return(new vec(x*s, y*s));};
  vec makeTurnedLeft() {return(new vec(-y,x));};
  vec left() {return(new vec(-y,x));};
  vec makeOffsetVec(vec V) {return(new vec(x + V.x, y + V.y));};
  vec makeOffsetVec(float s, vec V) {return(new vec(x + s*V.x, y + s*V.y));};
  vec makeOffsetVec(float u, float v) {return(new vec(x + u, y + v));};
  vec makeRotatedBy(float a) {float c=cos(a), s=sin(a); return(new vec(x*c-y*s,x*s+y*c)); };
  vec makeReflectedVec(vec N) { return makeOffsetVec(-2.*dot(this,N),N);};

  // OUTPUT TEST MEASURE
  float norm() {return(sqrt(sq(x)+sq(y)));}
  boolean isNull() {return((abs(x)+abs(y)<0.000001));}
  float angle() {return(atan2(y,x)); }

  // DRAW, PRINT
  void write() {println("("+x+","+y+")");};
  void show (pt P) {line(P.x,P.y,P.x+x,P.y+y); }; 
  void showAt (pt P) {line(P.x,P.y,P.x+x,P.y+y); }; 
  void showArrowAt (pt P) {line(P.x,P.y,P.x+x,P.y+y); 
      float n=min(this.norm()/10.,height/50.); 
      pt Q=P.makeTranslatedBy(this); 
      vec U = this.makeUnit().makeScaledBy(-n);
      vec W = U.makeTurnedLeft().makeScaledBy(0.3);
      beginShape(); Q.makeTranslatedBy(U).makeTranslatedBy(W).v(); Q.v(); 
                    W.scaleBy(-1); Q.makeTranslatedBy(U).makeTranslatedBy(W).v(); endShape(CLOSE); }; 
  void showLabel(String s, pt P) {pt Q = P.makeTranslatedBy(0.5,this); 
           vec N = makeUnit().makeTurnedLeft(); Q.makeTranslatedBy(3,N).showLabel(s); };
  } // end vec class
 

 //************************************************************************
//**** FRAMES
//************************************************************************
class frame {       // frame [O I J]
  pt O = new pt();
  vec I = new vec(1,0);
  vec J = new vec(0,1);
  frame() {}
  frame(pt pO, vec pI, vec pJ) {O.setTo(pO); I.setTo(pI); J.setTo(pJ);  }
  frame(pt A, pt B, pt C) {O.setTo(B); I=A.makeVecTo(C); I.normalize(); J=I.makeTurnedLeft();}
  frame(pt A, pt B) {O.setTo(A); I=A.makeVecTo(B).makeUnit(); J=I.makeTurnedLeft();}
  frame(pt A, vec V) {O.setTo(A); I=V.makeUnit(); J=I.makeTurnedLeft();}
  frame(float x, float y) {O.setTo(x,y);}
  frame(float x, float y, float a) {O.setTo(x,y); this.rotateBy(a);}
  frame(float a) {this.rotateBy(a);}
  frame makeClone() {return(new frame(O,I,J));}
  void reset() {O.setTo(0,0); I.setTo(1,0); J.setTo(0,1); }
  void setTo(frame F) {O.setTo(F.O); I.setTo(F.I); J.setTo(F.J); }
  void setTo(pt pO, vec pI, vec pJ) {O.setTo(pO); I.setTo(pI); J.setTo(pJ); }
  void show() {float d=height/20; O.show(); I.makeScaledBy(d).showArrowAt(O); J.makeScaledBy(d).showArrowAt(O); }
  void showLabels() {float d=height/20; 
               O.makeTranslatedBy(A(I,J).makeScaledBy(-d/4)).showLabel("O",-3,5); 
               O.makeTranslatedBy(d,I).makeTranslatedBy(-d/5.,J).showLabel("I",-3,5); 
               O.makeTranslatedBy(d,J).makeTranslatedBy(-d/5.,I).showLabel("J",-3,5); 
             }
  void translateBy(vec V) {O.translateBy(V);}
  void translateBy(float x, float y) {O.translateBy(x,y);}
  void rotateBy(float a) {I.rotateBy(a); J.rotateBy(a); }
  frame makeTranslatedBy(vec V) {frame F = this.makeClone(); F.translateBy(V); return(F);}
  frame makeTranslatedBy(float x, float y) {frame F = this.makeClone(); F.translateBy(x,y); return(F); }
  frame makeRotatedBy(float a) {frame F = this.makeClone(); F.rotateBy(a); return(F); }
   
  float angle() {return(I.angle());}
  void apply() {translate(O.x,O.y); rotate(angle());}  // rigid body tansform, use between pushMatrix(); and popMatrix();
  void moveTowards(frame B, float s) {O.translateTowards(s,B.O); rotateBy(s*(B.angle()-angle()));}  // for chasing or interpolating frames
  } // end frame class
 
frame makeMidEdgeFrame(pt A, pt B) {return(new frame(A(A,B),A.makeVecTo(B)));}  // creates frame for edge

frame interpolate(frame A, float s, frame B) {   // creates a frame that is a linear interpolation between two other frames
    frame F = A.makeClone(); F.O.translateTowards(s,B.O); F.rotateBy(s*(B.angle()-A.angle()));
    return(F);
    }

frame twist(frame A, float s, frame B) {   // a circular interpolation
  float d=A.O.disTo(B.O);
  float b=angle(A.I,B.I);
  frame F = A.makeClone(); F.rotateBy(s*b);
  pt M = A(A.O,B.O);   
  if ((abs(b)<0.000001) || (abs(b-PI)<0.000001)) F.O.translateTowards(s,B.O); 
  else {
  float h=d/2/tan(b/2); //else print("/b");
     vec W = A.O.makeVecTo(B.O); W.normalize();
     vec L = W.makeTurnedLeft();   L.scaleBy(h);
     M.translateBy(L);  // fill(0); M.show(6);
     L.scaleBy(-1);  L.normalize(); 
     if (abs(h)>=0.000001) L.scaleBy(abs(h+sq(d)/4/h)); //else print("/h");
     pt N = M.makeClone(); N.translateBy(L);  
     F.O.rotateBy(-s*b,M);
     };   
  return(F);
  }
  
 //************************************************************************
//**** EDGES
//************************************************************************
boolean edgesIntersect(pt A, pt B, pt C, pt D) {boolean hit=true; 
    if (leftTurn(A,B,C)==leftTurn(A,B,D)) hit=false; 
    if (leftTurn(C,D,A)==leftTurn(C,D,B)) hit=false; 
     return hit; }
boolean edgesIntersect(pt A, pt B, pt C, pt D,float e) {
  return ((A.isLeftOf(C,D,e) && B.isLeftOf(D,C,e))||(B.isLeftOf(C,D,e) && A.isLeftOf(D,C,e)))&&
         ((C.isLeftOf(A,B,e) && D.isLeftOf(B,A,e))||(D.isLeftOf(A,B,e) && C.isLeftOf(B,A,e))) ;   }
pt linesIntersection(pt A, pt B, pt C, pt D) {vec AB = A.makeVecTo(B);  vec CD = C.makeVecTo(D);  vec N=CD.makeTurnedLeft();  vec AC = A.makeVecTo(C);
   float s = dot(AC,N)/dot(AB,N); return A.makeTranslatedBy(s,AB); }

 //************************************************************************
//**** SPIRALS
//************************************************************************
 
pt spiralPt(pt A, pt G, float s, float a) {return L(G,s,R(A,a,G));}  
pt spiralPt(pt A, pt G, float s, float a, float t) {return L(G,pow(s,t),R(A,t*a,G));} 
pt spiralCenter(pt A, pt B, pt C, pt D) { // computes center of spiral that takes A to C and B to D
  float a = spiralAngle(A,B,C,D); 
  float z = spiralScale(A,B,C,D);
  return spiralCenter(a,z,A,C);
  }
float spiralAngle(pt A, pt B, pt C, pt D) {return angle(V(A,B),V(C,D));}
float spiralScale(pt A, pt B, pt C, pt D) {return d(C,D)/d(A,B);}
pt spiralCenter(float a, float z, pt A, pt C) {
  float c=cos(a), s=sin(a);
  float D = sq(c*z-1)+sq(s*z);
  float ex = c*z*A.x - C.x - s*z*A.y;
  float ey = c*z*A.y - C.y + s*z*A.x;
  float x=(ex*(c*z-1) + ey*s*z) / D;
  float y=(ey*(c*z-1) - ex*s*z) / D;
  return P(x,y);
  }

//************************************************************************
//****  RAYS 
//************************************************************************ 
RAY ray(pt A, pt B) {return new RAY(A,B); }
RAY ray(pt Q, vec T) {return new RAY(Q,T); }
RAY ray(pt Q, vec T, float d) {return new RAY(Q,T,d); }
RAY ray(RAY R) {return new RAY(R.Q,R.T,R.r); }
RAY leftTangentToCircle(pt P, pt C, float r) {return tangentToCircle(P,C,r,-1); }
RAY rightTangentToCircle(pt P, pt C, float r) {return tangentToCircle(P,C,r,1); }
RAY tangentToCircle(pt P, pt C, float r, float s) {
  float n=d(P,C); float w=sqrt(sq(n)-sq(r)); float h=r*w/n; float d=h*w/r; vec T = S(d,U(V(P,C)),s*h,R(U(V(P,C)))); return ray(P,T,w);}

class RAY {
    pt Q = new pt(300,300);  // start
    vec T = new vec(1,0);    // direction
    float r = 50;           // length for display arrow and dragging
    float d = 300;            // distance to hit
  RAY () {};
  RAY (pt pQ, vec pT) {Q.setTo(pQ);T.setTo(U(pT)); };
  RAY (pt pQ, vec pT, float pd) {Q.setTo(pQ);T.setTo(U(pT)); d=max(0,pd);};
  RAY(pt A, pt B) {Q.setTo(A); T.setTo(U(V(A,B))); d=d(A,B);}
  RAY(RAY B) {Q.setTo(B.Q); T.setTo(B.T); d=B.d; T.normalize();}
  void drag() {pt P=T(Q,r,T); if(P.disToMouse()<Q.disToMouse()) {float dd=d(Q,Mouse()); pt O=T(Q,dd,T); O.moveWithMouse(); Q.track(dd,O); T.setTo(U(V(Q,O)));} else Q.moveWithMouse();}
  void setTo(pt P, vec V) {Q.setTo(P); T.setTo(U(V)); }
  void setTo(RAY B) {Q.setTo(B.Q); T.setTo(B.T); d=B.d; T.normalize();}
  void showArrow() {arrow(Q,r,T); }
  void showLine() {show(Q,d,T);}
  pt at(float s) {return new pt(Q,s,T);}         pt at() {return new pt(Q,d,T);}
  void turn(float a) {T.rotateBy(a);}            void turn() {T.rotateBy(PI/180.);}

  float disToLine(pt A, vec N) {float n=dot(N,T); float t=0; if(abs(n)>0.000001) t = -dot(N,V(A,Q))/n; return t;}

  boolean hitsEdge(pt A, pt B) {boolean hit=isRightOf(A,Q,T)!=isRightOf(B,Q,T); if (isRightTurn(A,B,Q)==(dot(T,R(V(A,B)))>0)) hit=false; return hit;} // if hits
  float disToEdge(pt A, pt B) {vec N = U(R(V(A,B))); float t=0; float n=dot(N,T); if(abs(n)>0.000001) t=-dot(N,V(A,Q))/n; return t;} // distance to edge along ray if hits
  pt intersectionWithEdge(pt A, pt B) {return at(disToEdge(A,B));}                                                                   // hit point if hits
  RAY reflectedOfEdge(pt A, pt B) {pt X=intersectionWithEdge(A,B); vec V =T.makeReflectedVec(R(U(V(A,B)))); float rd=d-disToEdge(A,B); return ray (X,V,rd); } // bounced ray
  RAY surfelOfEdge(pt A, pt B) {pt X=intersectionWithEdge(A,B); vec V = R(U(V(A,B))); float rd=d-disToEdge(A,B); return ray (X,V,rd); } // bounced ray

  float disToCircle(pt C, float r) { return rayCircleIntesectionParameter(Q,T,C,r);}  // distance to circle along ray
  pt intersectionWithCircle(pt C, float r) {return at(disToCircle(C,r));}            // intersection point if hits
  boolean hitsCircle(pt C, float r) {return disToCircle(C,r)!=-1;}                   // hit test
  RAY reflectedOfCircle(pt C, float r) {pt X=intersectionWithCircle(C,r); vec V =T.makeReflectedVec(U(V(C,X))); float rd=d-disToCircle(C,r); return ray (X,V,rd); }
  }
     
//************************************************************************
//**** TRIANGLES
//************************************************************************


//************************************************************************
//**** INTEGRAL PRPERTIES, AREA, CENTER
//************************************************************************
float trapezeArea(pt A, pt B) {return((B.x-A.x)*(B.y+A.y)/2.);}
pt trapezeCenter(pt A, pt B) { return(new pt(A.x+(B.x-A.x)*(A.y+2*B.y)/(A.y+B.y)/3., (A.y*A.y+A.y*B.y+B.y*B.y)/(A.y+B.y)/3.) ); }

//************************************************************************
//**** CIRCLES
//************************************************************************


void showArcThrough (pt A, pt B, pt C) {
   pt O = CenterCircum ( A,  B,  C); //O.show(3);
   float r=2.*(O.disTo(A) + O.disTo(B)+ O.disTo(C))/3.;
   float a = V(O,A).angle(); //average(O,A).showLabel(str(toDeg(a)));
   float c = V(O,C).angle(); //average(O,C).showLabel(str(toDeg(c)));
   if(!isRightTurn(A,B,C)) arc(O.x,O.y,r,r,a,c); else arc(O.x,O.y,r,r,c,a);
    }

void showArcThroughXXX (pt A, pt B, pt C) {
   pt O = CenterCircum ( A,  B,  C);
   float r=2.*(O.disTo(A) + O.disTo(B)+ O.disTo(C))/3.;
   float a = O.vecTo(A).angle(); //average(O,A).showLabel(str(toDeg(a)));
   float c = O.vecTo(C).angle(); //average(O,C).showLabel(str(toDeg(c)));
   float w = angle(O.vecTo(C),O.vecTo(A)); 
   if(!isRightTurn(A,B,C)) w=TWO_PI-w; if (w>TWO_PI) w-=TWO_PI; if (w<0) w+=TWO_PI;  //println(w*180/PI);
   float d=w/2.;
   if(!isRightTurn(A,B,C)) arc(O.x,O.y,r,r,a-d,c+d); else arc(O.x,O.y,r,r,c-d,a+d);   
   }

float interpolateAngles(float a, float t, float b) {if(b<a) b+=TWO_PI; float m=(t-a)/(b-a); if (m>PI) m-=TWO_PI; return m;}

pt pointOnArcThrough (pt A, float t, pt B, pt C) {
  pt X=new pt();
   pt O = CenterCircum ( A,  B,  C);
   float r=(O.disTo(A) + O.disTo(B)+ O.disTo(C))/3.;
   float a = V(O,A).angle(); 
   float ab = positive(angle(V(O,A),V(O,B)));  if(isRightTurn(A,B,C)) ab-=TWO_PI;
   return ptOnCircle(a+t*ab,O,r);
   }
pt pointOnArcThrough (pt A, pt B, float t, pt C) {
  pt X=new pt();
   pt O = CenterCircum ( A,  B,  C);
   float r=(O.disTo(A) + O.disTo(B)+ O.disTo(C))/3.;
   float b = V(O,B).angle(); 
   float bc = positive(angle(V(O,B),V(O,C)));  if(isRightTurn(A,B,C)) bc-=TWO_PI;
   return ptOnCircle(b+t*bc,O,r);
   }
   
pt ptOnCircle(float a, pt O, float r) {return P(r*cos(a)+O.x,r*sin(a)+O.y);}   

  
float edgeCircleIntesectionParameter (pt A, pt B, pt C, float r) {  // computes parameter t such that A+tAB is on circle(C,r)
  vec T = V(A,B); float n = n(T); T.normalize();
  float t=rayCircleIntesectionParameter(A,T,C,r);
  return t*n;
}

float rayCircleIntesectionParameter (pt A, vec T, pt C, float r) {  // computes parameter t such that A+tT is on circle(C,r) or -1
  vec AC = V(A,C);
  float d=dot(AC,T); 
  float h = dot(AC,R(T)); 
  float t=-1;
  if (abs(h)<r) {
    float w = sqrt(sq(r)-sq(h));
    float t1=(d-w);
    float t2=(d+w);
     if ((0<=t1)&&(t1<=t2)) t = t1; else if (0<=t2) t = t2; 
   }
  return t;
}

pt circleInversion(pt A, pt C, float r) {vec V=V(C,A); return S(C,sq(r/n(V)),A); }

pt interArc(pt A, pt B, pt C, pt D) {
  pt M = A(B,C);
   float ab=d(A,B); float bc=d(B,C); float cd=d(C,D); float t=(ab/(ab+bc)+(1.-cd/(bc+cd)))/2; 
   M= A(pointOnArcThrough(A,B,t,C),pointOnArcThrough(B,t,C,D));
    return M;}
   
pt circleCenterForAngle(pt A, pt B, float a) {                   // computes center of the circle of points C such that angle(A,C,B)=a
   pt M = A(A,B); float d=d(A,B)/2; float h=d*tan(PI/2.-a); vec V=R(S(h,U(V(A,B))));  return T(M,V); }

pt CCl(pt C1, float r1, pt C2, float r2) { // computes  the intersection of two circles that is on the left of (C1,C2)
   float d=d(C1,C2);
   float d1=(sq(r1)-sq(r2)+sq(d))/(d*2);
   float h=sqrt(sq(r1)-sq(d1));
   return T(T(C1,d1,C2),-h,R(V(C1,C2)));}
   
pt CCr(pt C1, float r1, pt C2, float r2) { // computes  the intersection of two circles that is on the right of (C1,C2)
   float d=d(C1,C2);
   float d1=(sq(r1)-sq(r2)+sq(d))/(d*2);
   float h=sqrt(sq(r1)-sq(d1));
   return T(T(C1,d1,C2),h,R(V(C1,C2)));}
   
//************************************************************************
//**** CURVES
//************************************************************************
pt s(pt A, float s, pt B) {return(new pt(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y))); };
pt b(pt A, pt B, pt C, float s) {return( s(s(B,s/4.,A),0.5,s(B,s/4.,C))); };                          // returns a tucked B towards its neighbors
pt f(pt A, pt B, pt C, pt D, float s) {return( s(s(A,1.+(1.-s)/8.,B) ,0.5, s(D,1.+(1.-s)/8.,C))); };    // returns a bulged mid-edge point 
pt B(pt A, pt B, pt C, float s) {return( s(s(B,s/4.,A),0.5,s(B,s/4.,C))); };                          // returns a tucked B towards its neighbors
pt F(pt A, pt B, pt C, pt D, float s) {return( s(s(A,1.+(1.-s)/8.,B) ,0.5, s(D,1.+(1.-s)/8.,C))); };    // returns a bulged mid-edge point 
pt limit(pt A, pt B, pt C, pt D, pt E, float s, int r) {
  if (r==0) return C.clone();
  else return limit(b(A,B,C,s),f(A,B,C,D,s),b(B,C,D,s),f(B,C,D,E,s),b(C,D,E,s),s,r-1);
  }

pt cubicBezier(pt A, pt B, pt C, pt D, float t) {return( s( s( s(A,t,B) ,t, s(B,t,C) ) ,t, s( s(B,t,C) ,t, s(C,t,D) ) ) ); }
void splitBezier(pt A, pt B, pt C, pt D, int rec) {
  if (rec==0) {B.v(); C.v(); D.v(); return;};
  pt E=A(A,B);   pt F=A(B,C);   pt G=A(C,D);  
           pt H=A(E,F);   pt I=A(F,G);  
                    pt J=A(H,I); J.show(3);   
  splitBezier(A,E,H,J,rec-1);   splitBezier(J,I,G,D,rec-1); 
 }
 
void drawSplitBezier(pt A, pt B, pt C, pt D, float t) {
  pt E=s(A,t,B); E.show(2);  pt F=s(B,t,C); F.show(2);  pt G=s(C,t,D); G.show(2);  E.to(F); F.to(G);
           pt H=s(E,t,F); H.show(2);   pt I=s(F,t,G);  I.show(2); H.to(I);
                    pt J=s(H,t,I); J.show(4);   
 }

void drawCubicBezier(pt A, pt B, pt C, pt D) { beginShape();  for (float t=0; t<=1; t+=0.02) {cubicBezier(A,B,C,D,t).v(); };  endShape(); }
void drawEdges(pt A, pt B, pt C, pt D) { A.to(B); B.to(C); C.to(D); }
float cubicBezierAngle (pt A, pt B, pt C, pt D, float t) {pt P = s(s(A,t,B),t,s(B,t,C)); pt Q = s(s(B,t,C),t,s(C,t,D)); vec V=P.makeVecTo(Q); float a=atan2(V.y,V.x); return(a);}  
vec cubicBezierTangent (pt A, pt B, pt C, pt D, float t) {pt P = s(s(A,t,B),t,s(B,t,C)); pt Q = s(s(B,t,C),t,s(C,t,D)); vec V=P.makeVecTo(Q); V.makeUnit(); return(V);}  

void drawParabolaInHat(pt A, pt B, pt C, int rec) {
   if (rec==0) { B.showSegmentTo(A); B.showSegmentTo(C); } 
   else { 
     float w = (A.makeVecTo(B).norm()+C.makeVecTo(B).norm())/2;
     float l = A.makeVecTo(C).norm()/2;
     float t = l/(w+l);
     pt L = new pt(A); 
     L.translateBy(t,A.makeVecTo(B)); 
     pt R = new pt(C); R.translateBy(t,C.makeVecTo(B)); 
     pt M = A(L,R);
     drawParabolaInHat(A,L, M,rec-1); drawParabolaInHat(M,R, C,rec-1); 
     };
   };

vec vecToCubic (pt A, pt B, pt C, pt D, pt E) {return(new vec( (-A.x+4*B.x-6*C.x+4*D.x-E.x)/6, (-A.y+4*B.y-6*C.y+4*D.y-E.y)/6  ));}
pt cubic(pt A, pt B, pt D, pt E, float s, float t, float u) {
   float ct1, ct2, ct3;
    vec AB, AD, AE;
    ct1 = (s*u + s - u - s*s) * s;     ct2 = (u*u + s - s*u - u) * u;     ct3 = s*u + 1 - s - u;
    AB = A.vecTo(B); AB.div(ct1);      AD = A.vecTo(D); AD.div(ct2);       AE = A.vecTo(E); AE.div(ct3);
    vec a = AB.make(); a.mul(-1.0); a.add(AD); a.add(AE);   
    vec b = AB.make(); b.mul(u+1); b.addScaled(-(s+1),AD); b.addScaled(-(u+s),AE);
   vec c = AB.make(); c.mul(-u);  c.addScaled(s,AD); c.addScaled(u*s,AE); 
    
   vec V = a.make(); V.mul(t*t*t); V.addScaled(t*t,b); V.addScaled(t,c);
   pt R = A.make();  R.addVec(V);
   return (R);
   };
  
vec bulgeVec(pt A, pt B, pt C, pt D) {return A(B.makeVecTo(A),C.makeVecTo(D)).makeScaledBy(-3./8.); }
pt prop(pt A, pt B, pt D, pt E) {float a=d(A,B), b=d(B,D), c=d(D,E), t=a+b+c, d=b/(1+pow(c/a,1./3) ); return cubic(A,B,D,E,a/t,(a+d)/t,(a+b)/t); }

//---- biLaplace fit
vec fitVec (pt B, pt C, pt D) { return A(V(C,B),V(C,D)); }
pt fitPt (pt B, pt C, pt D) {return A(B,D);};  
pt fitPt (pt B, pt C, pt D, float s) {return T(C,s,fitVec(B,C,D));};  
pt fitPt(pt A, pt B, pt C, pt D, pt E, float s) {pt PB = fitPt(A,B,C,s); pt PC = fitPt(B,C,D,s);  pt PD = fitPt(C,D,E,s); return fitPt(PB,PC,PD,-s);}
pt fitPt(pt A, pt B, pt C, pt D, pt E) {float s=sqrt(2.0/3.0); pt PB = fitPt(A,B,C,s); pt PC = fitPt(B,C,D,s);  pt PD = fitPt(C,D,E,s); return fitPt(PB,PC,PD,-s);}
//---- proportional biLaplace fit
vec proVec (pt B, pt C, pt D) { return S(V(C,B), d(C,B)/(d(C,B)+d(C,D)),V(C,D)); }
pt proPt (pt B, pt C, pt D) {return T(B,d(C,B)/(d(C,B)+d(C,D)),V(B,D));};  
pt proPt (pt B, pt C, pt D, float s) {return T(C,s,proVec(B,C,D));};  
pt proPt(pt A, pt B, pt C, pt D, pt E, float s) {pt PB = proPt(A,B,C,s); pt PC = proPt(B,C,D,s);  pt PD = proPt(C,D,E,s); return proPt(PB,PC,PD,-s);}
pt proPt(pt A, pt B, pt C, pt D, pt E) {float s=sqrt(2.0/3.0); pt PB = proPt(A,B,C,s); pt PC = proPt(B,C,D,s);  pt PD = proPt(C,D,E,s); return proPt(PB,PC,PD,-s);}

