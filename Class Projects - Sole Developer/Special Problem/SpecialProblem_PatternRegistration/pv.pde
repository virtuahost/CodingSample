//*****************************************************************************
// TITLE:         GEOMETRY UTILITIES IN 2D  
// DESCRIPTION:   Classes and functions for manipulating points, vectors, edges, triangles, quads, frames, and circular arcs  
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  September 2009
// EDITS:         Revised July 2011
//*****************************************************************************
//************************************************************************
//**** POINT CLASS
//************************************************************************
class pt2 { float x=0,y=0; float r=0;
  // CREATE
  pt2 () {}
  pt2 (float px, float py) {x = px; y = py;};

  pt2 (float px, float py, float pr) {x = px; y = py;r = pr;};
  pt2 (pt2 pp, float pr) {x = pp.x; y = pp.y;r = pr;};

  // MODIFY
  pt2 setTo(float px, float py) {x = px; y = py; return this;};  
  pt2 setTo(pt2 P) {x = P.x; y = P.y; return this;}; 
  pt2 setToMouse() { x = mouseX; y = mouseY;  return this;}; 
  pt2 add(float u, float v) {x += u; y += v; return this;}                       // P.add(u,v): P+=<u,v>
  pt2 add(pt2 P) {x += P.x; y += P.y; return this;};                              // incorrect notation, but useful for computing weighted averages
  pt2 add(float s, pt2 P)   {x += s*P.x; y += s*P.y; return this;};               // adds s*P
  pt2 add(vec2 V) {x += V.x; y += V.y; return this;}                              // P.add(V): P+=V
  pt2 add(float s, vec2 V) {x += s*V.x; y += s*V.y; return this;}                 // P.add(s,V): P+=sV
  pt2 translateTowards(float s, pt2 P) {x+=s*(P.x-x);  y+=s*(P.y-y);  return this;};  // transalte by ratio s towards P
  pt2 scale(float u, float v) {x*=u; y*=v; return this;};
  pt2 scale(float s) {x*=s; y*=s; return this;}                                  // P.scale(s): P*=s
  pt2 scale(float s, pt2 C) {x*=C.x+s*(x-C.x); y*=C.y+s*(y-C.y); return this;}    // P.scale(s,C): scales wrt C: P=L(C,P,s);
  pt2 rotate(float a) {float dx=x, dy=y, c=cos(a), s=sin(a); x=c*dx+s*dy; y=-s*dx+c*dy; return this;};     // P.rotate(a): rotate P around origin by angle a in radians
  pt2 rotate(float a, pt2 G) {float dx=x-G.x, dy=y-G.y, c=cos(a), s=sin(a); x=G.x+c*dx+s*dy; y=G.y-s*dx+c*dy; return this;};   // P.rotate(a,G): rotate P around G by angle a in radians
  pt2 rotate(float s, float t, pt2 G) {float dx=x-G.x, dy=y-G.y; dx-=dy*t; dy+=dx*s; dx-=dy*t; x=G.x+dx; y=G.y+dy;  return this;};   // fast rotate s=sin(a); t=tan(a/2); 
  pt2 moveWithMouse() { x += mouseX-pmouseX; y += mouseY-pmouseY;  return this;}; 
     
  // DRAW , WRITE
  pt2 write() {print("("+x+","+y+")"); return this;};  // writes point coordinates in text window
  pt2 v2() {vertex(x,y); return this;};  // used for drawing polygons between beginShape(); and endShape();
  pt2 show(float r) {ellipse(x, y, 2*r, 2*r); return this;}; // shows point as disk of radius r
  pt2 show() {show(3); return this;}; // shows point as small dot
  pt2 label(String s, float u, float v) {fill(black); text(s, x+u, y+v); noFill(); return this; };
  pt2 label(String s, vec2 V) {fill(black); text(s, x+V.x, y+V.y); noFill(); return this; };
  pt2 label(String s) {label(s,5,4); return this; };
  pt2 tag(String s) {return tag(s,13);} 
  pt2 tag(String s, float r) {fill(white); show(r); fill(black); textAlign(CENTER, CENTER); text(s, x, y); textAlign(LEFT); return this;} 
    
  String toString() { return "("+x+","+y+")";}
    
  } // end of pt2 class

//************************************************************************
//**** VECTORS
//************************************************************************
class vec2 { float x=0,y=0; 
 // CREATE
  vec2 () {};
  vec2 (float px, float py) {x = px; y = py;};
 
 // MODIFY
  vec2 setTo(float px, float py) {x = px; y = py; return this;}; 
  vec2 setTo(vec2 V) {x = V.x; y = V.y; return this;}; 
  vec2 zero() {x=0; y=0; return this;}
  vec2 scaleBy(float u, float v) {x*=u; y*=v; return this;};
  vec2 scaleBy(float f) {x*=f; y*=f; return this;};
  vec2 reverse() {x=-x; y=-y; return this;};
  vec2 divideBy(float f) {x/=f; y/=f; return this;};
  vec2 normalize() {float n=sqrt(sq(x)+sq(y)); if (n>0.000001) {x/=n; y/=n;}; return this;};
  vec2 add(float u, float v) {x += u; y += v; return this;};
  vec2 add(vec2 V) {x += V.x; y += V.y; return this;};   
  vec2 add(float s, vec2 V) {x += s*V.x; y += s*V.y; return this;};   
  vec2 rotateBy(float a) {float xx=x, yy=y; x=xx*cos(a)-yy*sin(a); y=xx*sin(a)+yy*cos(a); return this;};
  vec2 left() {float m=x; x=-y; y=m; return this;};
 
  // OUTPUT VEC
  vec2 clone() {return(new vec2(x,y));}; 

  // OUTPUT TEST MEASURE
  float norm() {return(sqrt(sq(x)+sq(y)));}
  boolean isNull() {return((abs(x)+abs(y)<0.000001));}
  float angle() {return(atan2(y,x)); }

  // DRAW, PRINT
  void write() {println("<"+x+","+y+">");};
  void showAt (pt2 P) {line(P.x,P.y,P.x+x,P.y+y); }; 
  void showArrowAt (pt2 P) {line(P.x,P.y,P.x+x,P.y+y); 
      float n=min(this.norm()/10.,height/50.); 
      pt2 Q=P2(P,this); 
      vec2 U = S(-n,U(this));
      vec2 W = S(.3,R2(U)); 
      beginShape(); Q.add(U).add(W).v2(); Q.v2(); Q.add(U).add(M(W)).v2(); endShape(CLOSE); }; 
  void label(String s, pt2 P) {P2(P).add(0.5,this).add(3,R2(U(this))).label(s); };
  } // end vec2 class

//************************************************************************
//**** POINTS
//************************************************************************
// create 
pt2 P2() {return P2(0,0); };                                                                            // make point (0,0)
pt2 P2(float x, float y) {return new pt2(x,y); };                                                       // make point (x,y)
pt2 P2(pt2 P2) {return P2(P2.x,P2.y); };                                                                    // make copy of point A
pt2 Mouse2() {return P2(mouseX,mouseY);};                                                                 // returns point at current mouse location
pt2 Pmouse2() {return P2(pmouseX,pmouseY);};                                                              // returns point at previous mouse location
pt2 ScreenCenter2D() {return P2(width/2,height/2);}                                                        //  point in center of  canvas

// display 
void show(pt2 P, float r) {ellipse(P.x, P.y, 2*r, 2*r);};                                             // draws circle of center r around P
void show(pt2 P) {ellipse(P.x, P.y, 6,6);};                                                           // draws small circle around point
void edge(pt2 P, pt2 Q) {line(P.x,P.y,Q.x,Q.y); };                                                      // draws edge (P,Q)
void arrow(pt2 P, pt2 Q) {arrow(P,V2(P,Q)); }                                                            // draws arrow from P to Q
void label(pt2 P, String S) {text(S, P.x-4,P.y+6.5); }                                                 // writes string S next to P on the screen ( for example label(P[i],str(i));)
void label(pt2 P, vec2 V, String S) {text(S, P.x-3.5+V.x,P.y+7+V.y); }                                  // writes string S at P+V
void v2(pt2 P) {vertex(P.x,P.y);};                                                                      // vertex for drawing polygons between beginShape() and endShape()
void show(pt2 P, pt2 Q, pt2 R) {beginShape(); v2(P); v2(Q); v2(R); endShape(CLOSE); };                      // draws triangle 

// transform 
pt2 R2(pt2 Q, float a) {float dx=Q.x, dy=Q.y, c=cos(a), s=sin(a); return new pt2(c*dx+s*dy,-s*dx+c*dy); };  // Q rotated by angle a around the origin
pt2 R2(pt2 Q, float a, pt2 C) {float dx=Q.x-C.x, dy=Q.y-C.y, c=cos(a), s=sin(a); return P2(C.x+c*dx-s*dy, C.y+s*dx+c*dy); };  // Q rotated by angle a around point P2
pt2 P2(pt2 P, vec2 V) {return P2(P.x + V.x, P.y + V.y); }                                                 //  P+V (P transalted by vector V)
pt2 MoveByDistanceTowards(pt2 P, float d, pt2 Q) { return P2(P,d,U(V2(P,Q))); };                          //  P+dU(PQ) (transLAted P by *distance* s towards Q)!!!

// average 
pt2 P2(pt2 A, pt2 B) {return P2((A.x+B.x)/2.0,(A.y+B.y)/2.0); };                                          // (A+B)/2 (average)
pt2 P2(pt2 A, pt2 B, pt2 C) {return P2((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0); };                            // (A+B+C)/3 (average)
pt2 P2(pt2 A, pt2 B, pt2 C, pt2 D) {return P2(P2(A,B),P2(C,D)); };                                            // (A+B+C+D)/4 (average)

// weighted average 
pt2 P2(float a, pt2 A) {return P2(a*A.x,a*A.y);}                                                      // aA  
pt2 P2(float a, pt2 A, float b, pt2 B) {return P2(a*A.x+b*B.x,a*A.y+b*B.y);}                              // aA+bB, (a+b=1) 
pt2 P2(float a, pt2 A, float b, pt2 B, float c, pt2 C) {return P2(a*A.x+b*B.x+c*C.x,a*A.y+b*B.y+c*C.y);}   // aA+bB+cC 
pt2 P2(float a, pt2 A, float b, pt2 B, float c, pt2 C, float d, pt2 D){return P2(a*A.x+b*B.x+c*C.x+d*D.x,a*A.y+b*B.y+c*C.y+d*D.y);} // aA+bB+cC+dD 
//pt2 P2(pt2... ps) {return P2(ps);};
//pt2 P2(pt2[] ps) {pt2 p = P2(); for(pt2 x:ps)p.add(x); if(ps.length>0)p.scale(1.0/ps.length); return p;};

// frame maps
pt2 P2(pt2 O, float x, vec2 I) {return P2(O.x+x*I.x,O.y+x*I.y);}                              // O+xI
pt2 P2(pt2 O, float x, vec2 I, float y, vec2 J) {return P2(O.x+x*I.x+y*J.x,O.y+x*I.y+y*J.y);}   // O+xI+yJ
float x(pt2 P, pt2 O, vec2 I, vec2 J) {return det(V2(O,P),J)/det(I,J);}
float y(pt2 P, pt2 O, vec2 I, vec2 J) {return det(V2(O,P),I)/det(J,I);}

// barycentric coordinates and transformations
float m(pt2 A, pt2 B, pt2 C) {return (B.x-A.x)*(C.y-A.y) - (B.y-A.y)*(C.x-A.x); }
float a(pt2 P, pt2 A, pt2 B, pt2 C) {return m(P,B,C)/m(A,B,C); }
float b(pt2 P, pt2 A, pt2 B, pt2 C) {return m(A,P,C)/m(A,B,C); }
float c(pt2 P, pt2 A, pt2 B, pt2 C) {return m(A,B,P)/m(A,B,C); }

float x(vec2 V, vec2 I, vec2 J) {return det(V,J)/det(I,J);}
float y(vec2 V, vec2 I, vec2 J) {return det(V,I)/det(J,I);}

float x(pt2 P, pt2 A, pt2 B) {return dot(V2(A,B),V2(A,P))/d2(A,B);}
float y(pt2 P, pt2 A, pt2 B) {return det(V2(A,B),V2(A,P))/d2(A,B);}
     
// measure 
boolean isSame(pt2 A, pt2 B) {return (A.x==B.x)&&(A.y==B.y) ;}                                         // A==B
boolean isSame(pt2 A, pt2 B, float e) {return ((abs(A.x-B.x)<e)&&(abs(A.y-B.y)<e));}                   // ||A-B||<e
float d(pt2 P, pt2 Q) {return sqrt(d2(P,Q));  };                                                       // ||AB|| (Distance)
float d2(pt2 P, pt2 Q) {return sq(Q.x-P.x)+sq(Q.y-P.y); };                                             // AB*AB (Distance squared)

boolean projectsBetween(pt2 P, pt2 A, pt2 B) {return dot(V2(A,P),V2(A,B))>0 && dot(V2(B,P),V2(B,A))>0 ; };
float disToLine(pt2 P, pt2 A, pt2 B) {return abs(det(U(A,B),V2(A,P))); };
pt2 projectionOnLine(pt2 P, pt2 A, pt2 B) {return P2(A,dot(V2(A,B),V2(A,P))/dot(V2(A,B),V2(A,B)),V2(A,B));}


//************************************************************************
//**** VECTORS
//************************************************************************
// create 
vec2 V2(vec2 V) {return new vec2(V.x,V.y); };                                                             // make copy of vector V
vec2 V2(pt2 P) {return new vec2(P.x,P.y); };                                                              // make vector from origin to P
vec2 V2(float x, float y) {return new vec2(x,y); };                                                      // make vector (x,y)
vec2 V2(pt2 P, pt2 Q) {return new vec2(Q.x-P.x,Q.y-P.y);};                                                 // PQ (make vector Q-P from P to Q
vec2 U(vec2 V) {float n = n(V); if (n==0) return new vec2(0,0); else return new vec2(V.x/n,V.y/n);};      // V/||V|| (Unit vector : normalized version of V)
vec2 U(pt2 P, pt2 Q) {return U(V2(P,Q));};                                                                // PQ/||PQ| (Unit vector : from P towards Q)
vec2 MouseDrag2D() {return new vec2(mouseX-pmouseX,mouseY-pmouseY);};                                      // vector representing recent mouse displacement

// display 
void show(pt2 P, vec2 V) {line(P.x,P.y,P.x+V.x,P.y+V.y); }                                              // show V as line-segment from P 
void show(pt2 P, float s, vec2 V) {show(P,S(s,V));}                                                     // show sV as line-segment from P 
void arrow(pt2 P, float s, vec2 V) {arrow(P,S(s,V));}                                                   // show sV as arrow from P 
void arrow(pt2 P, vec2 V, String S) {arrow(P,V); P2(P2(P,0.70,V),15,R2(U(V))).label(S,V2(-5,4));}       // show V as arrow from P and print string S on its side
void arrow(pt2 P, vec2 V) {show(P,V);  float n=n(V); if(n<0.01) return; float s=max(min(0.2,20./n),6./n);       // show V as arrow from P 
     pt2 Q=P2(P,V); vec2 U = S(-s,V); vec2 W = R2(S(.3,U)); beginShape(); v2(P2(P2(Q,U),W)); v2(Q); v2(P2(P2(Q,U),-1,W)); endShape(CLOSE);}; 

// weighted sum 
vec2 W(float s,vec2 V) {return V2(s*V.x,s*V.y);}                                                      // sV
vec2 W(vec2 U, vec2 V) {return V2(U.x+V.x,U.y+V.y);}                                                   // U+V 
vec2 W(vec2 U,float s,vec2 V) {return W(U,S(s,V));}                                                   // U+sV
vec2 W(float u, vec2 U, float v, vec2 V) {return W(S(u,U),S(v,V));}                                   // uU+vV ( Linear combination)

// transformed 
vec2 R2(vec2 V) {return new vec2(-V.y,V.x);};                                                             // V turned right 90 degrees (as seen on screen)
vec2 R2(vec2 V, float a) {float c=cos(a), s=sin(a); return(new vec2(V.x*c-V.y*s,V.x*s+V.y*c)); };                                     // V rotated by a radians
vec2 S(float s,vec2 V) {return new vec2(s*V.x,s*V.y);};                                                  // sV
pt2 S(float s, pt2 A) {return new pt2(s*A.x,s*A.y); };                                                  // Weighted point: sA
vec2 Reflection(vec2 V, vec2 N) { return W(V,-2.*dot(V,N),N);};                                          // reflection
vec2 M(vec2 V) { return V2(-V.x,-V.y); }                                                                  // -V


// measure 
float dot(vec2 U, vec2 V) {return U.x*V.x+U.y*V.y; }                                                     // dot(U,V): U*V (dot product U*V)
float det(vec2 U, vec2 V) {return dot(R2(U),V); }                                                         // det | U V | = scalar cross UxV 
float n(vec2 V) {return sqrt(dot(V,V));};                                                               // n(V): ||V|| (norm: length of V)
float n2(vec2 V) {return sq(V.x)+sq(V.y);};                                                             // n2(V): V*V (norm squared)
boolean parallel (vec2 U, vec2 V) {return dot(U,R2(V))==0; }; 

float angle (vec2 U, vec2 V) {return atan2(det(U,V),dot(U,V)); };                                   // angle <U,V> (between -PI and PI)
float angle(vec2 V) {return(atan2(V.y,V.x)); };                                                       // angle between <1,0> and V (between -PI and PI)
float angle(pt2 A, pt2 B, pt2 C) {return  angle(V2(B,A),V2(B,C)); }                                       // angle <BA,BC>
float turnAngle(pt2 A, pt2 B, pt2 C) {return  angle(V2(A,B),V2(B,C)); }                                   // angle <AB,BC> (positive when right turn as seen on screen)
int toDeg(float a) {return int(a*180/PI);}                                                           // convert radians to degrees
float toRad(float a) {return(a*PI/180);}                                                             // convert degrees to radians 
float positive(float a) { if(a<0) return a+TWO_PI; else return a;}                                   // adds 2PI to make angle positive

//************************************************************************
//**** INTERPOLATION
//************************************************************************

//**** CIRCLES
pt2 CircumCenter (pt2 A, pt2 B, pt2 C) {vec2 AB = V2(A,B); vec2 AC = R2(V2(A,C)); 
   return P2(A,1./2/dot(AB,AC),W(-n2(AC),R2(AB),n2(AB),AC)); }; // CircumCenter(A,B,C): center of circumscribing circle, where medians meet)
float circumRadius (pt2 A, pt2 B, pt2 C) {float a=d(B,C), b=d(C,A), c=d(A,B), s=(a+b+c)/2, d=sqrt(s*(s-a)*(s-b)*(s-c)); return a*b*c/4/d;} // radiusCircum(A,B,C): radius of circumcenter

// display 
void drawCircle(int n) {  
  float x=1, y=0; float a=TWO_PI/n, t=tan(a/2), s=sin(a); 
  beginShape(); for (int i=0; i<n; i++) {x-=y*t; y+=x*s; x-=y*t; vertex(x,y);} endShape(CLOSE);}


void showArcThrough (pt2 A, pt2 B, pt2 C) {
  if (abs(dot(V2(A,B),R2(V2(A,C))))<0.01*d2(A,C)) {edge(A,C); return;}
   pt2 O = CircumCenter ( A,  B,  C); 
   float r=d(O,A);
   vec2 OA=V2(O,A), OB=V2(O,B), OC=V2(O,C);
   float b = angle(OA,OB), c = angle(OA,OC); 
   if(0<c && c<b || b<0 && 0<c)  c-=TWO_PI; 
   else if(b<c && c<0 || c<0 && 0<b)  c+=TWO_PI; 
   beginShape(); v2(A); for (float t=0; t<1; t+=0.01) v2(R2(A,t*c,O)); v2(C); endShape();
   }

pt2 pointOnArcThrough (pt2 A, pt2 B, pt2 C, float t) { // July 2011
  if (abs(dot(V2(A,B),R2(V2(A,C))))<0.001*d2(A,C)) {edge(A,C); return L(A,C,t);}
   pt2 O = CircumCenter ( A,  B,  C); 
   float r=(d(O,A) + d(O,B)+ d(O,C))/3;
   vec2 OA=V2(O,A), OB=V2(O,B), OC=V2(O,C);
   float b = angle(OA,OB), c = angle(OA,OC); 
   if(0<b && b<c) {}
   else if(0<c && c<b) {b=b-TWO_PI; c=c-TWO_PI;}
   else if(b<0 && 0<c) {c=c-TWO_PI;}
   else if(b<c && c<0) {b=TWO_PI+b; c=TWO_PI+c;}
   else if(c<0 && 0<b) {c=TWO_PI+c;}
   else if(c<b && b<0) {}
   return R2(A,t*c,O);
   }

// Interpolation of points LERP
pt2 L(pt2 A, pt2 B, float t) {return P2(A.x+t*(B.x-A.x),A.y+t*(B.y-A.y));}
float L(float A, float B, float t) {return A+t*(B-A);}  //lerp float

// Interpolation of vectors 
vec2 L(vec2 U, vec2 V, float s) {return new vec2(U.x+s*(V.x-U.x),U.y+s*(V.y-U.y));};                      // (1-s)U+sV (Linear interpolation between vectors)
vec2 S(vec2 U, vec2 V, float s) {float a = angle(U,V); vec2 W = R2(U,s*a); float u = n(U); float v=n(V); W(pow(v/u,s),W); return W; } // steady interpolation from U to V
vec2 slerp(vec2 U, float t, vec2 V) {float a = angle(U,V); float b=sin((1.-t)*a),c=sin(t*a),d=sin(a); return W(b/d,U,c/d,V); }

void spiral(pt2 A0, pt2 B0, pt2 A1, pt2 B1, float t, pt2 At, pt2 Bt) {
  float a =spiralAngle(A0,B0,A1,B1); 
  float s =spiralScale(A0,B0,A1,B1);
  pt2 F = spiralCenter(a, s, A0, A1); if(!animating) {show(F,13); label(F,"F"); }
  At.setTo(L(F,R2(A0,t*a,F),pow(s,t))); 
  Bt.setTo(L(F,R2(B0,t*a,F),pow(s,t)));
  }
float spiralAngle(pt2 A, pt2 B, pt2 C, pt2 D) {return angle(V2(A,B),V2(C,D));}
float spiralScale(pt2 A, pt2 B, pt2 C, pt2 D) {return d(C,D)/d(A,B);}
pt2 spiralCenter(float a, float z, pt2 A, pt2 C) {
  float c=cos(a), s=sin(a);
  float D = sq(c*z-1)+sq(s*z);
  float ex = c*z*A.x - C.x - s*z*A.y;
  float ey = c*z*A.y - C.y + s*z*A.x;
  float x=(ex*(c*z-1) + ey*s*z) / D;
  float y=(ey*(c*z-1) - ex*s*z) / D;
  return P2(x,y);
  }

//Morphs two triangles using spiral for one edge and Local LERP for the thrid vertex
void morph(pt2 A0, pt2 B0, pt2 C0, pt2 A1, pt2 B1, pt2 C1, float t, pt2 At, pt2 Bt, pt2 Ct) {
  spiral(A0,B0,A1,B1,t,At,Bt);
  float x0=x(C0,A0,B0), y0=y(C0,A0,B0);
  float x1=x(C1,A1,B1), y1=y(C1,A1,B1);
  float xt=x0+t*(x1-x0), yt=y0+t*(y1-y0);
  Ct.setTo(P2(At,xt,V2(At,Bt),yt,R2(V2(At,Bt))));
  }

