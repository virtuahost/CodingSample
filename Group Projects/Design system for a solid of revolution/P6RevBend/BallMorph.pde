Boolean doBallMorph = true;
float t=0;
int tp =0;
float animateSpeed = .01;
boolean showArcs = false;
boolean showArcAnimation = false;
boolean showMoveAnimation = false;

void animateMorph(ArrayList<pt2> pList, ArrayList<pt2> qList, ArrayList<Float> pRadList, ArrayList<Float> qRadList) {
  noFill();
  pen(black, 3);
  if (t>1 || t <0) {
    //t=1;
    //showArcAnimation = false;
    //showMoveAnimation = false;
    //return;
  }
  //showArcAnimation = true;
  text("Translation: " + ((doBallMorph) ? "Ball Morph" : "Lerp"), 100,100);
  if(t !=1)
    if(t + animateSpeed > 1)
      t = 1;
    else
      t+=animateSpeed;
      
     // t=0;
      
  stroke(black);
  drawLine(PS.getCurve(), black);
  
  drawLine(createC1Prime(qList), black);
  
  ArrayList<pt2> curve = new ArrayList<pt2>();
  ArrayList<Float> rad = new ArrayList<Float>();
  
  BSpline res = new BSpline();

  doMorph(pList, qList, pRadList, qRadList, t, curve, rad);
  
//  print("a: ");
//  println(pRadList);
//  print("b: ");
//  println(rad);
  //drawLine(curve, orange);
  //res.setCurvedLoop(curve,rad, m);

  
  ArrayList<pt2> loop = res.doMakeCurve(curve,rad, m);
  

  beginShape();
  for(int i = 0; i < curve.size(); i++) {
    curve.get(i).v2();  
  }
  endShape();
  
//  println(loop.size());
    stroke(orange, 150);
    fill(orange, 150);
  beginShape();
  for(int i = 0; i < loop.size(); i++) {
//    loop.get(i+1).v2();
    loop.get(i).v2();
    //edge(loop.get(i), loop.get(i+1));
  }
  endShape(CLOSE);
  stroke(orange);
  fill(orange);
  //beginShape();
  curve = res.getCurve();
  for(int i = 0; i < curve.size()-1; i++) {
    edge(curve.get(i), curve.get(i+1));//curve.get(i).v2();  
  }
  
//  stroke(magenta);
//  fill(magenta);
//  for(int i = 0; i < loop.size(); i++) {
//
//    loop.get(i).show(3);
//    //edge(loop.get(i), loop.get(i+1));
//  }
}

void doMorph(ArrayList<pt2> pl, ArrayList<pt2> ql, ArrayList<Float> prl, ArrayList<Float> qrl, float time, ArrayList<pt2> outResult, ArrayList<Float> outRadius) { 
  outResult.clear();outRadius.clear();
  if(doBallMorph)
    ballMorph(pl, ql, prl, qrl, time, outResult, outRadius);
  else
    lerp(pl, ql, prl, qrl, time, outResult, outRadius);
}

void ballMorph(ArrayList<pt2> pl, ArrayList<pt2> ql, ArrayList<Float> pr, ArrayList<Float> qr, float time, ArrayList<pt2> outResult, ArrayList<Float> outRad) { 

  
  ArrayList<pt2> qp = createC1Prime(ql);  //q-prime

  ArrayList<pt2> corrP = new ArrayList<pt2>();
  ArrayList<pt2> corrQ = new ArrayList<pt2>();
  ArrayList<vec2> corrRP = new ArrayList<vec2>();
  ArrayList<vec2> corrRQ = new ArrayList<vec2>();

  findCorrespondence(pl, qp, corrP, corrQ, corrRP, corrRQ);
  //findCorrespondence(new ArrayList<pt2>(corrQ), new ArrayList<pt2>(corrP), corrP, corrQ, corrR);

  if(showArcAnimation)  {
    drawCorr(corrP, corrQ, corrRQ);
    //drawBallAtP(corrQ, corrRQ, (int)tp, cyan);
  } 

  findArcLerp(corrP, corrQ, corrRP, corrRQ, time, outResult);
  //println("num: " + arced.size());
  //drawLine(outResult, orange);
  findRadLerp(pl, qp, corrP, corrQ, pr, qr, time, outRad);
}

void findCorrespondence(ArrayList<pt2> pl, ArrayList<pt2> ql, ArrayList<pt2> corrP, ArrayList<pt2> corrQ, ArrayList<vec2> corrRP, ArrayList<vec2> corrRQ) {
  int lastStored = -1;
  for (int i = 0; i < pl.size(); i++)
  {
    pt2 clPt = null;
    float smRad = 1.0/0;
    vec2 nr = null;
    vec2 pn = null;
    for (int j = 0; j < ql.size()-1; j+=1)
    {
      vec2 qp = V2(ql.get(j), pl.get(i));
      //println("qp: " + qp.toString());
      float qpSq = dot(qp, qp);

      pt2 p = pl.get(i);
      pt2 q = ql.get(j);

      vec2 l = (i != pl.size()-1) ? V2(p, pl.get(i+1)) : V2(p, pl.get(i-1));
      vec2 l2 = V2(q, ql.get(j+1));

      vec2 edgeNorm = orientNormal(l2, U(R2(l2)), qp);
      vec2 pNormal = orientNormal(l, U(R2(l)), V2(p, q));
//      stroke(red);
//      show(p, W(100, pNormal));
      //stroke(green);
      //show(q, W(100, edgeNorm));

      float r2 = dot(qp, edgeNorm)/(1 - dot(pNormal, edgeNorm));
      pt2 a = P2(p, V2(pNormal).scaleBy(r2).add(V2(edgeNorm).scaleBy(r2).reverse()));
      int cs = corrP.size()-1;

      if (r2 < smRad && detectClickOnEdge(a.x, a.y, q, ql.get(j+1)) && 
          ((cs==-1) ? true : isSame(DONT_INTERSECT, intersect(p.x, p.y, a.x, a.y, corrP.get(cs).x, corrP.get(cs).y, corrQ.get(cs).x, corrQ.get(cs).y))) && 
          checkNotInCirc(ql, j, P2(a, V2(edgeNorm).scaleBy(r2)), r2) &&
          checkNotInCirc(pl, i, P2(p, V2(pNormal).scaleBy(r2)), r2)) { // && closerThanNeighbors(pl, i, ql, j)
        smRad = r2;
        clPt = a;
        pn = V2(pNormal).scaleBy(r2);
        nr = V2(edgeNorm).scaleBy(r2);
        lastStored = j;
      }

//      vec2 nn = edgeNorm; //orientNormal(l2, getNormal(ql, j, p), U(p,q)); //
//      float r =  qpSq/(dot(V2(qp).scaleBy(2), nn));

      //check to see if it's closer thanboth of its neighbors???????
//      if (r < smRad && closerThanNeighbors(pl, i, ql, j) ) { //&& !corrQ.contains(q) //(i==0 ||  i==pl.size()-1) //                         
//        //println("r: " + r);
//        pn = V2(pNormal).scaleBy(r2);
//        smRad = r;
//        clPt = q;
//        nr = V2(nn).scaleBy(r);
//      }
    }  
    if (clPt != null)
    {
      corrP.add(pl.get(i));
      corrQ.add(clPt);
      corrRP.add(pn);
      corrRQ.add(nr);
//      stroke(green);
//      //show(clPt, 5);
//      show(clPt, nr);
//      stroke(red);
//      //show(pl.get(i), 5);
//      show(pl.get(i), W(100, pn));
    }
  }
}

//ball morph arc "lerp" for moving between lines. corrP, corrQ, corrR
void findArcLerp(ArrayList<pt2> cp, ArrayList<pt2> cq, ArrayList<vec2> crp, ArrayList<vec2> crq, float time, ArrayList<pt2> outResult) {
  for (int i = 0; i < cp.size(); i++)
  { 
    pt2 p = cp.get(i);
    pt2 q = cq.get(i);

    vec2 l = (i != cp.size()-1) ? V2(p, cp.get(i+1)) : V2(p, cp.get(i-1)).reverse();
    vec2 l2 = (i != cp.size()-1) ? V2(q, cq.get(i+1)) : V2(q, cq.get(i-1)).reverse();

    vec2 pn = crp.get(i);//orientNormal(l, R2(l), V2(p, q));  //normals
    vec2 qn = crq.get(i);//orientNormal(l2, R2(l2), V2(q, p));

    vec2 pt = R2(pn).scaleBy(MAX_INT); //Tangents
    vec2 qt = R2(qn).scaleBy(MAX_INT).reverse();

    pt2 ptEnd = P2(p, pt);  //End Points for tangents
    pt2 qtEnd = P2(q, qt);

    pt2 center = intersect(p.x, p.y, ptEnd.x, ptEnd.y, q.x, q.y, qtEnd.x, qtEnd.y);

    if (isSame(center, DONT_INTERSECT))
    {
      pt.reverse();
      qt.reverse();
      ptEnd = P2(p, pt);  //End Points for tangents
      qtEnd = P2(q, qt);
      center = intersect(p.x, p.y, ptEnd.x, ptEnd.y, q.x, q.y, qtEnd.x, qtEnd.y);
    }    
 
    if(showArcs) {
      ArrayList<pt2> test = new ArrayList<pt2>();
      for(float j = 0; j <= 1; j+=.01)
        test.add(R2(p, angle(p,center,q)*j, center));
      drawLine(test, cyan);
      stroke(green);
      //show(clPt, 5);
      show(q, W(.25, qn));
      stroke(red);
      //show(pl.get(i), 5);
      show(p, W(.25, pn));
      //show(q, cr.get(i).scaleBy(2));
      
    }
      outResult.add(R2(p, angle(p,center,q)*time, center));

  }
}

//lerp for moving curve radius
void findRadLerp(ArrayList<pt2> pl, ArrayList<pt2> ql, ArrayList<pt2> cp, ArrayList<pt2> cq, ArrayList<Float> pr, ArrayList<Float> qr, float time, ArrayList<Float> outRad) {
  for(int i = 0; i < cp.size(); i++) {
    float pRad = 0;
    float qRad = 0;
    for(int j = 0; j < pl.size(); j++) {  //find p radius
      if(isSame(cp.get(i), pl.get(j))) {  
        pRad = pr.get(j);
        break;
      }
    }

    for(int j = 0; j < ql.size()-1; j++) {  //find q radius
      if(isSame(cq.get(i), ql.get(j)) || detectClickOnEdge(cq.get(i).x, cq.get(i).y, ql.get(j), ql.get(j+1))) {  //find p radius spot
        qRad = (qr.get(j) + qr.get(j+1))/2;
        break;
      }
    }
    
    outRad.add(L(pRad, qRad, time)); //
  }
}

void lerp(ArrayList<pt2> pl, ArrayList<pt2> ql, ArrayList<Float> prl, ArrayList<Float> qrl, float time, ArrayList<pt2> outResult, ArrayList<Float> outRad) {
  ArrayList<pt2> ret = new ArrayList<pt2>();
  ArrayList<pt2> cp = createC1Prime(ql);
  
  for(int i = 0; i < pl.size(); i++) {
    outResult.add(L(pl.get(i), cp.get(i), time));
    outRad.add(L(prl.get(i), qrl.get(i), time));
  }
  
  if(showArcAnimation) {
    drawLine(pl, red);
    drawLine(cp, green);
  }
}

void drawCorr(ArrayList<pt2> corrP, ArrayList<pt2> corrQ, ArrayList<vec2> corrR) {
//  for(int i = 0; i < corrQ.size(); i++)
//  {
//    drawBallAtP(corrQ, corrR, i, cyan);
//  }
  drawLine(corrP, red);
  drawLine(corrQ, green);
}

void drawBallAtP(ArrayList<pt2> corrQ, ArrayList<vec2> corrR, int p, int col)
{
  if(p <0 || p > corrQ.size()-1) return;
  stroke(col);
  show(P2(corrQ.get(p),corrR.get(p)), n(corrR.get(p)));
}

void drawLine(ArrayList<pt2> l, int col) {
  stroke(col);
  beginShape();//POINTS
  for(pt2 p : l) {
    p.v2();  
  }
  endShape();  
}

ArrayList<pt2> createC1Prime(ArrayList<pt2> c1) {
  ArrayList<pt2> c1p = new ArrayList<pt2>();
  for (pt2 p : c1) {
    //println("original x: " + p.x + ", new x: " + (width/2 -p.x));
    c1p.add(P2(mirrorLine - (p.x-mirrorLine), p.y));
  } 
  return c1p;
}

vec2 getNormal(ArrayList<pt2> l, int i, pt2 p) {
  vec2 v1;
  vec2 v2;
  vec2 r;

  if (i==0) {  //first index on line
    v2 = V2(l.get(i), l.get(i+1));
    r = R2(v2);
  } else if (i == l.size() -1) {  //last index on line
    v1 = V2(l.get(i), l.get(i-1));
    r = R2(v1);
  } else
  {
    v1 = R2(V2(l.get(i), l.get(i-1)));
    v2 = R2(V2(l.get(i), l.get(i+1)).reverse());
    r= W(U(v1), U(v2));
  }

  //println(det(V2(l.get(i), l.get(i+1)), U(r)) * det(V2(l.get(i), l.get(i+1)), V2(l.get(i), p)));

  return U(r);
}

vec2 orientNormal(vec2 l, vec2 n, vec2 pq) {
  if (det(l, n) * det(l, pq) < 0)
  {
    n = V2(n).reverse();
  }
  return U(n);
}

boolean closerThanNeighbors(ArrayList<pt2> l, int i, ArrayList<pt2> ql, int j) {
  float cDist;
  pt2 p = l.get(i);
  pt2 q = ql.get(j);
  cDist = d(p, q);

  if (i==0) {
    if (j == 0) {
      //println("woo: i="+i+", j=" +j+ ", p="+p+", q="+q + ", qp="+ql.get(j+2) +", dist=" + cDist + ", qpDist="+d(p, ql.get(j+2)));

      if (cDist < d(p, ql.get(j+2))) {
        //println("ret true");
        return true;
      }
    } else if (j == ql.size()-1) {
      //print("ahh" + cDist);
      if (cDist < d(p, ql.get(j-1))) 
        return true;
    } else {//if(j !=0 && j != ql.size()-1){
      if (cDist < d(p, ql.get(j+1)) && cDist < d(p, ql.get(j-1)))
        return true;
    }
  } else if (i==l.size()-1) {
    if (j == ql.size()-2) {

      if (cDist < d(p, ql.get(j-2))) {
        //println("ret true");
        return true;
      }
    }
  } else
  {
    cDist = d(p, q);
    //println("woo: i="+i+", j=" +j+ ", p="+p+", q="+q + ", qp="+l.get(i+1) +", dist=" + cDist + ", qpDist="+d(l.get(i+1), q));
    if (cDist < d(l.get(i+1), q) && cDist < d(l.get(i-1), q))
      return true;
  }
  return false;
}

boolean checkNotInCirc(ArrayList<pt2> l, int j, pt2 cp, float r) {
  for(int i = 0; i < l.size(); i++) {
    if(i==j) continue;
    //if point is in circle
    if(i==0) {
//      stroke(magenta);
//      show(cp, r);
//        
    }
    pt2 p = l.get(i);
    if(Math.pow((p.x - cp.x),2) + Math.pow((p.y - cp.y),2) < Math.pow(r, 2)) {
//      println("found in circle");
      return false;
    }
  }
  
  return true;
}


