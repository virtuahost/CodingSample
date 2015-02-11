pt cam = P(100, -1000, 100);
pt focus = P();  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
vec down = U(0, 0, -1);
vec forw;
vec left;
boolean donut = false, wireframe=false, textured = false;
boolean animation = false;
boolean autoAnim = false;
boolean showThings = false;
float duration = 5; // in seconds
float alpha = PI;
float animFrame = 0, animStep = 1.0/(duration*frameRate);
float aStep = PI/180;
int subs = 1; // intraface subdivisions
int spq = 5; // steps per quarter of a revolution

ArrayList<pt2> p, q;


void startTube() {
  donut = true;
  p = PS.getCurve();
  q = QS.getCurve();
  //  pList = pgl[0].cornerList(); 
  //  pList.remove(pList.size()-1);
  //  qList = pgl[1].reverseCList();
  //  qList.remove(qList.size()-1);

  //    pList = new ArrayList<pt2>();
  //    qList = new ArrayList<pt2>();
  //  
  //    pList.add(P2(0, 50));
  //    pList.add(P2(0, 100));
  //    pList.add(P2(-100, 100));
  //    pList.add(P2(-100, 50));
  //  
  //    qList.add(P2(0, 50));
  //    qList.add(P2(0, 100));
  //    qList.add(P2(-100, 100));
  //    qList.add(P2(-100, 50));

  ArrayList<pt2> joined = new ArrayList<pt2>(p);
  joined.addAll(q);
  float y = avg(joined).y;
  bsl[2].avgY = y;
  bsl[3].avgY = y;
  p = recenterShape(p, mirrorLine, y);
  q = recenterShape(q, mirrorLine, y);
  mirrorLine = 0;
  p = mirrorShape(p, false, true);
  q = mirrorShape(q, false, true);
  p = joinRads(p, PS.getRadius());
  q = joinRads(q, QS.getRadius());
}

ArrayList<pt2> joinRads(ArrayList<pt2> p, ArrayList<Float> r) {
  ArrayList<pt2> res = new ArrayList<pt2>();
  for (int i = 0; i < min (p.size (), r.size()); i++) {
    res.add(new pt2(p.get(i), r.get(i)));
  }
  return res;
}
ArrayList<Float> splitRads(ArrayList<pt2> pr) {
  ArrayList<Float> res = new ArrayList<Float>();
  for (pt2 p : pr) {
    res.add(p.r);
  }
  return res;
}

void onMouseMovedTube() {
  if (keyPressed && (key==' ')) {
    vec t = MouseDrag();
    vec I, J, K;
    I = down;
    J = forw;
    K = left;
    cam = R(cam, t.x/width*PI, K, J, focus);
    cam = R(cam, t.y/height*PI, J, I, focus);
  }
  if (keyPressed && (key=='c'||key=='C')) {
    vec t = MouseDrag();
    vec I, J, K;
    I = down;
    J = forw;
    K = left;
    focus = R(focus, t.x/width*PI, K, J, cam);
    focus = R(focus, t.y/height*PI, J, I, cam);
  }
  if (keyPressed && (key=='x'||key=='X')) {
    pt2 p = Pmouse2();
    pt2 n = Mouse2();
    pt2 c = ScreenCenter2D();
    float a = angle(V2(c, p), V2(c, n));
    vec I, J, K;
    I = down;
    J = forw;
    K = left;
    down = R(down, a, K, I);
  }
  if (keyPressed && (key=='z'||key=='Z')) {
    cam = P(cam, mouseY-pmouseY, forw);
  }
}
void onKeyPressedTube() {
  if (key=='w'||key=='W')wireframe = !wireframe;
  if (key=='t'||key=='T')textured = !textured;
  if (key=='.')alpha = fix(alpha+aStep, TWO_PI);
  if (key==',')alpha = fix(alpha-aStep, TWO_PI);
  if (key=='}')subs += 1;
  if (key=='{')subs = max(1, subs-1);
  if (key==']')spq += 1;
  if (key=='[')spq = max(1, spq-1);
  if (key=='3') {
    donut = false;
    mirrorLine = width/2;
  }
  if (key=='v'||key=='V') showVolume();
  if (key=='>') {
    animFrame = min(animFrame+animStep, 1); 
    animation = true;
    autoAnim = false;
  }
  if (key=='<') {
    animFrame = max(animFrame-animStep, 0); 
    animation = true;
    autoAnim = false;
  }
  if (key=='a'||key=='A') {
    autoAnim = true;
    animation = !animation;
    animFrame = 0;
    animStep = 1.0/(duration*frameRate);
  }
  if (key == ';') {
    //    ArrayList<Float> pr = new ArrayList<Float>();
    //    ArrayList<pt2> pp = new ArrayList<pt2>();
    //    doMorph(p, q, splitRads(p), splitRads(q), 0.5, pp, pr);
    //    BSpline b = new BSpline();
    //    ArrayList<pt2> loop = b.makeCurve(pp, pr, m);
  }
}
void camera(pt c, pt f, vec u) {
  camera(c.x, c.y, c.z, f.x, f.y, f.z, u.x, u.y, u.z);
}
void onDrawTube() {
  forw = U(cam, focus);
  left = U(N(down, forw));
  down = U(N(forw, left));
  background(white);
  lights();
  pushMatrix();  
  camera(cam, focus, down);
  fill(lgrey);
  noStroke();
  show(cam, 20);

  //draw axis and line to origin
  stroke(blue);
  bsl[2].showPts3D(cyan);
  bsl[2].showCurve3D(blue,cyan,false);
  bsl[2].showTangentsandNormals();
  if(controlPolyLine)
  {
    stroke(grey); 
    bsl[3].showPts3D(green);
    bsl[3].showCurve3D(grey,green,true);
  }
  stroke(black);
  show(focus, V(focus, P()));

  if (animation) {
    if (wireframe) {
      noStroke();
      fill(lgrey);
      drawLineCap(p, q, -alpha*animFrame, subs);
    } else {
      textureWrap(REPEAT);
      textureMode(IMAGE);
      noStroke();
      fill(lgrey);
      drawCap(p, q, -alpha*animFrame, textured, subs);
    }
    if (autoAnim) animFrame+=animStep;
    if (animFrame > 1) animation = false;
  } else {
    donut(p, q, -alpha, max(1, ceil(spq*alpha/HALF_PI)), wireframe, textured, subs);
  }

  popMatrix();
}
public void donut(ArrayList<pt2> shape1, ArrayList<pt2> shape2, float a, int steps, boolean wireFrame, boolean textured, int subs) {
  if (wireFrame) {
    noStroke();
    fill(lgrey);
    drawLineShape(shape1, shape2, a, steps, subs); // bg
    fill(red, 0);
    drawShape(shape1, shape2, a, steps, false, subs); // cover
    drawCap(shape1, shape2, 0, false, subs);
    drawCap(shape1, shape2, a, false, subs);
    fill(black);
    drawLineShape(shape1, shape2, a, steps, subs); // fg
  } else {
    textureWrap(REPEAT);
    textureMode(IMAGE);
    noStroke();
    fill(lgrey);
    drawShape(shape1, shape2, a, steps, textured, subs);
    drawCap(shape1, shape2, 0, textured, subs);
    drawCap(shape1, shape2, a, textured, subs);
  }
  //blendMode(BLEND);
}

void drawCap(ArrayList<pt2> s1, ArrayList<pt2> s2, float a, boolean textured, int subs) {
  PImage tex = null;
  ArrayList<pt>  s = getCrossSection(s1, s2, a);
  if (textured) {
    tex = loadImage("data/tex.bmp");
  }
  beginShape();
  if (textured) texture(tex);
  for (int vert = 0; vert < s.size (); vert++) {
    pt c = getPoint(vert, s, false);
    pt n = getPoint(vert+1, s, false);
    for ( int sub = 0; sub < subs; sub++) {
      pt p_ = subPoint(c, n, float(sub)/subs);
      pt p = bendProjectionPoint(p_);
      if (textured) v(p, toScreen(p_));
      else v(p);
    }
  }
  endShape();
}
public void showVolume() {
  float v = donutVolume(p, q, alpha, max(1, ceil(spq*alpha/HALF_PI)), subs);
  float f = v*TWO_PI/alpha;
  print("Volume for section: "+v);
  println(" For full circle (assuming uniform shape): "+f);
}
public float donutVolume(ArrayList<pt2> shape1, ArrayList<pt2> shape2, float a, int steps, int subs) {
  float total = 0;
  //end caps
  float f = faceVolume(shape1, shape2, 0, subs);
  total += f;
  f = faceVolume(shape1, shape2, a, subs);
  total -= f;

  ArrayList<pt> c, n = getCrossSection(shape1, shape2, 0);
  for (int step = 0; step < steps; step++) {
    c = n;
    float a_ = (step+1)*a/steps;
    n = getCrossSection(shape1, shape2, a_);
    total += bandVolume(c, n, subs);
  }

  return abs(total);
}

float bandVolume(ArrayList<pt> l, ArrayList<pt> r, int subs) {
  float total = 0;
  for (int vert = 0; vert < r.size (); vert++) {
    pt lb = getPoint(vert, l, false);
    pt lt = getPoint(vert+1, l, false);
    pt rt = getPoint(vert+1, r, false);
    pt rb = getPoint(vert, r, false);
    for (int u = 0; u < subs; u++) {
      for (int v = 0; v < subs; v++) {
        float ld = float(u)/subs;
        float rd = float(u+1)/subs;
        float bd = float(v)/subs;
        float td = float(v+1)/subs;
        pt a = subPlane(lt, lb, rt, rb, ld, bd);
        pt b = subPlane(lt, lb, rt, rb, ld, td);
        pt c = subPlane(lt, lb, rt, rb, rd, td);
        pt d = subPlane(lt, lb, rt, rb, rd, bd);
        a = bendProjectionPoint(a);
        b = bendProjectionPoint(b);
        c = bendProjectionPoint(c);
        d = bendProjectionPoint(d);
        total += volume(P(), a, b, c); //topleft  trianglr
        total += volume(P(), a, c, d); // bottom right triangle
      }
    }
  }
  return total;
}

float faceVolume(ArrayList<pt2> s1, ArrayList<pt2> s2, float a, int subs) {
  float total = 0;
  ArrayList<pt>  s = getCrossSection(s1, s2, a);
  pt c = getPoint(0, s, false);
  pt n = getPoint(1, s, false);
  pt p_ = subPoint(c, n, float(0)/subs);
  pt p = bendProjectionPoint(p_);
  pt p2;
  pt x = p;
  for (int vert = 0; vert < s.size (); vert++) {
    c = getPoint(vert, s, false);
    n = getPoint(vert+1, s, false);
    for ( int sub = vert==0?1:0; sub < subs; sub++) {
      p_ = subPoint(c, n, float(sub)/subs);
      p = bendProjectionPoint(p_);
      p_ = subPoint(c, n, float(sub+1)/subs);
      p2 = bendProjectionPoint(p_);
      total += volume(P(), x, p2, p);
    }
  }
  return total;
}



void drawLineShape(ArrayList<pt2> s1, ArrayList<pt2> s2, float a, int steps, int subs) {
  ArrayList<pt> p, c = getCrossSection(s1, s2, -a/steps), n = getCrossSection(s1, s2, 0), nn = getCrossSection(s1, s2, a/steps);
  for (int step = 0; step < steps; step++) {
    p=c;
    c=n;
    n=nn;
    float a_ = (step+2)*a/steps;
    nn = getCrossSection(s1, s2, a_);
    for (int vert = 0; vert < c.size (); vert++) {
      drawLineQuad(vert, p, c, n, nn, subs);
    }
  }
  drawLineCap(s1, s2, 0, subs);
  drawLineCap(s1, s2, a, subs);
}
void drawLineCap(ArrayList<pt2> s1, ArrayList<pt2> s2, float a, int subs) {
  ArrayList<pt>  s = getCrossSection(s1, s2, a);
  for (int vert = 0; vert < s.size (); vert++) {
    pt c = getPoint(vert, s, false);
    pt n = getPoint(vert+1, s, false);
    boxLine(c, n, subs);
  }
}
void boxLine(pt a, pt b, int subs, float size1, float size2) {
  pt pc, pn = bendProjectionPoint(subPoint(a, b, 0));
  for ( int sub = 0; sub < subs; sub++) {
    pc = pn;
    pt p = subPoint(a, b, float(sub+1)/subs);
    pn = bendProjectionPoint(p);
    stub(pc, V(pc, pn), size1, size2);
  }
}
void boxLine(pt a, pt b, int subs) {
  boxLine(a, b, subs, 2, 2);
}
void drawLineQuad(int vert, ArrayList<pt> p, ArrayList<pt> c, ArrayList<pt> n, ArrayList<pt> nn, int subs) {
  drawLineQuad(vert, p, c, n, nn, subs, false);
}

void drawLineQuad(int vert, ArrayList<pt> p, ArrayList<pt> c, ArrayList<pt> n, ArrayList<pt> nn, int subs, boolean all) {
  pt p1=getPoint(vert, c, false), p2=getPoint(vert, n, false), p3=getPoint(vert+1, n, false), p4=getPoint(vert+1, c, false);
  if (all||shouldShowV(vert, c, n)) boxLine(p1, p2, subs);
  if (all||shouldShowH(vert, c, n, nn)) boxLine(p2, p3, subs);
  if (all||shouldShowV(vert+1, c, n)) boxLine(p3, p4, subs);
  if (all||shouldShowH(vert, p, c, n)) boxLine(p4, p1, subs);
}
//compare v to v+1
boolean shouldShowV(int v, ArrayList<pt> c, ArrayList<pt> n) {
  pt vp = getPoint(v, c);
  pt np = getPoint(v, n);
  pt lp = getPoint(v+1, c);
  pt rp = getPoint(v-1, c);
  return isSharp(vp, np, lp, rp) || isSilhouette(vp, np, lp, rp);
}
boolean shouldShowH(int v, ArrayList<pt> p, ArrayList<pt> c, ArrayList<pt> n) {
  pt vp = getPoint(v, c);
  pt np = getPoint(v+1, c);
  pt lp = getPoint(v, p);
  pt rp = getPoint(v, n);
  return isSharp(vp, np, lp, rp) || isSilhouette(vp, np, lp, rp);
}
boolean isSharp(pt v, pt n, pt l, pt r) { 
  float th = QUARTER_PI;
  return angle(N(v, n, l), N(v, r, n))>th;
}
boolean isSilhouette(pt v, pt n, pt l, pt r) {
  vec n1 = N(v, n, l);
  vec n2 = N(v, r, n);
  vec c = V(v, cam);
  return dot(c, n1) * dot(c, n2) < 0;
}


void drawShape(ArrayList<pt2> s1, ArrayList<pt2> s2, float a, int steps, boolean textured, int subs) {
  ArrayList<pt> p, c = getCrossSection(s1, s2, -a/steps), n = getCrossSection(s1, s2, 0), nn = getCrossSection(s1, s2, a/steps);
  for (int step = 0; step < steps; step++) {
    p = c;
    c = n;
    n = nn; // assumption that the shape continues as the interpolation says past end of rendering
    float a_ = (step+2)*a/steps;
    nn = getCrossSection(s1, s2, a_);
    for (int vert = 0; vert < c.size (); vert++) {
      for (int u = 0; u < subs; u++) {
        for (int v = 0; v < subs; v++) {
          float ul = float(u)/subs;
          float ur = float(u+1)/subs;
          float vt = float(v)/subs;
          float vb = float(v+1)/subs;
          vec norm = V();
          pt point;
          beginShape();
          point = getPoint(ul, vt, vert, p, c, n, nn, norm);
          if (textured)normal(norm);
          vertex(point);
          point = getPoint(ur, vt, vert, p, c, n, nn, norm);
          if (textured)normal(norm);
          vertex(point);
          point = getPoint(ur, vb, vert, p, c, n, nn, norm);
          if (textured)normal(norm);
          vertex(point);
          point = getPoint(ul, vb, vert, p, c, n, nn, norm);
          if (textured)normal(norm);
          vertex(point);
          endShape(CLOSE);
        }
      }
    }
  }
}
pt2 toScreen(pt p) {
  return P2(p.u, p.v);
}

pt getPoint(int vert, ArrayList<pt> prev, ArrayList<pt> cur, ArrayList<pt> next, vec n) {
  pt p = getPoint(vert, cur);
  if (n!=null) {
    pt cn = getPoint(vert+1, cur);
    pt cp = getPoint(vert-1, cur);
    pt tn = getPoint(vert, next);
    pt tp = getPoint(vert, prev);
    n.set(U(makeNormal(p, cn, cp, tn, tp)));
  }
  return p;
}

vec makeNormal(pt p, pt cn, pt cp, pt tn, pt tp) {
  vec r=V(), l=V();
  if (tn!=null) {
    vec tr = N(p, cn, tn);
    vec br = N(p, tn, cp);
    r = A(tr, br);
  }
  if (tp!=null) {
    vec bl = N(p, cp, tp);
    vec tl = N(p, tp, cn);
    l = A(bl, tl);
  }
  return A(l, r);
}
pt getPoint(float u, float v, int vert, ArrayList<pt> p, ArrayList<pt> c, ArrayList<pt> n, ArrayList<pt> nn, vec norm) {
  pt[][] vs = new pt[4][4];
  for (int y = 0; y < 4; y++)
  {
    vs[0][y] = getPoint(vert+y-1, p, false);
    vs[1][y] = getPoint(vert+y-1, c, false);
    vs[2][y] = getPoint(vert+y-1, n, false);
    vs[3][y] = getPoint(vert+y-1, nn, false);
  }
  vec[][] ns = {
    {
      makeNormal(vs[1][1], vs[1][0], vs[1][2], vs[2][1], vs[0][1]), makeNormal(vs[1][2], vs[1][1], vs[1][3], vs[2][2], vs[0][2])
      }
    , {
      makeNormal(vs[2][1], vs[2][0], vs[2][2], vs[3][1], vs[1][1]), makeNormal(vs[2][2], vs[2][1], vs[2][3], vs[3][2], vs[1][2])
      }
    };
    pt tl = PN(vs[1][1], ns[0][0]);
  pt tr = PN(vs[2][1], ns[1][0]);
  pt bl = PN(vs[1][2], ns[0][1]);
  pt br = PN(vs[2][2], ns[1][1]);

  pt res = subPlane(tl, tr, bl, br, u, v);
  norm.set(res.u, res.v, res.w);
  return bendProjectionPoint(res);
}
pt getPoint(int vert, ArrayList<pt> l, boolean bend) {
  if (l==null)return null;
  int s = l.size();
  pt a = l.get(fix(vert, s));
  pt p;
  if (bend) {
    p = bendProjectionPoint(a);
  } else {
    p = P(a);
  }
  p.u = a.u;
  p.v = a.v;
  return p;
}
pt getPoint(int vert, ArrayList<pt> l) {
  return getPoint(vert, l, true);
}

/** returns the same shape in 3D **/
public ArrayList<pt> make3D(ArrayList<pt2> shape) {
  ArrayList<pt> r = new ArrayList<pt>();
  for (pt2 p : shape) {
    r.add(new pt(p.x, 0, p.y, p.x, p.y));
  }
  return r;
}

ArrayList<pt2> mirrorShape(ArrayList<pt2> s, boolean x, boolean y) {
  ArrayList<pt2> r = new ArrayList<pt2>();
  for (pt2 p : s) {
    r.add(P2(x?-p.x:p.x, y?-p.y:p.y)); //center to 0, mirror on 0, recenter to line
  }
  return r;
}

ArrayList<pt2> recenterShape(ArrayList<pt2> s, float x, float y) {
  ArrayList<pt2> r = new ArrayList<pt2>();
  for (pt2 p : s) {
    r.add(P2(p.x-x, p.y-y)); //center to 0, mirror on 0, recenter to line
  }
  return r;
}

pt2 avg(ArrayList<pt2> s) {
  float x = 0, y = 0;
  for (pt2 p : s) {
    x += p.x;
    y += p.y;
  }
  int c = s.size();
  return P2(x/c, y/c);
}
pt avg(ArrayList<pt> s) {
  float x = 0, y = 0, z=0, u= 0, v=0, w=0;
  for (pt p : s) {
    x += p.x;
    y += p.y;
    z += p.z;
    u += p.u;
    v += p.v;
    w += p.w;
  }
  int c = s.size();
  return new pt(x/c, y/c, z/c, u/c, v/c, w/c);
}

pt rot(pt a, float angle) { 
  pt p = R(a, angle, V(1, 0, 0), V(0, 1, 0), P());
  p.u = a.u;
  p.v = a.v;
  return p;
}

ArrayList<pt> getCrossSection(ArrayList<pt2> a, ArrayList<pt2> b, float angle) {
  angle = fix(angle, TWO_PI);
  float reflectAngle = angle>PI?TWO_PI-angle:angle;
  ArrayList<pt> res = new ArrayList<pt>();
  for (pt p : make3D (getStep (a, b, reflectAngle/PI))) {
    res.add(rot(p, angle));
  }
  return res;
}

ArrayList<pt2> getStep(ArrayList<pt2> a, ArrayList<pt2> b, float t) {
  ArrayList<pt2> rp = new ArrayList<pt2>();
  ArrayList<Float> rr = new ArrayList<Float>();
  doMorph(a, b, splitRads(a), splitRads(b), t, rp, rr);
  return new BSpline().doMakeCurve(rp, rr, m);
}

pt subPlane(pt tl, pt tr, pt bl, pt br, float u, float v) {
  return subPoint(subPoint(tl, tr, u), subPoint(bl, br, u), v);
}

pt subPoint(pt a, pt b, float bt) {
  float at = 1-bt;
  float x, y, z, u, v, w;
  x = at*a.x+bt*b.x;
  y = at*a.y+bt*b.y;
  z = at*a.z+bt*b.z;
  u = at*a.u+bt*b.u;
  v = at*a.v+bt*b.v;
  w = at*a.w+bt*b.w;
  return new pt(x, y, z, u, v, w);
}

pt PN(pt p, vec n) {
  return new pt(p.x, p.y, p.z, n.x, n.y, n.z);
}

float fix(float x, float l) {
  return (x%l+l)%l;
}
int fix(int x, int l) {
  return (x%l+l)%l;
}

