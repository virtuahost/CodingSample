ArrayList<pt> G = new ArrayList<pt>();        //Vertices
ArrayList<Integer> V = new ArrayList<Integer>();      //Half Edges
ArrayList<Integer> NC = new ArrayList<Integer>();      //Next Half Edges
ArrayList<Integer> S = new ArrayList<Integer>();

ArrayList<Boolean> D = new ArrayList<Boolean>();
ArrayList<Boolean> DG = new ArrayList<Boolean>();

int toVisitCount;
ArrayList<Integer> arrTV = new ArrayList<Integer>();      //Visited Vertices

//////////// Drawing Variables
float vertexSize = 2;
float cornerSize = 3;
int vertexColor;
int soonToAddColor;
int graphColor;
int deleteColor;
ArrayList<Integer> randomLoopColor = new ArrayList<Integer>();
int colorIndex = 0;

int vertexSnapSize = 10;
int cornerSelectDist = 100;

pt soonStartPt;
pt soonEndPt;
Boolean showSoon = false;
Boolean stopColorGeneration = false;

pt delStartPt;
pt delEndPt;
Boolean delIsEdge = false;
Boolean showDel = false;
Boolean delPossible = false;
Boolean outSideLoop = true;
int smallestCornerID = -1;

/////////////Interaction
int selCorner = -1;
Boolean selCornerIsLoop = false;
Boolean showSelCorner = false;
Boolean showFaceLoops = false;
ArrayList<pt> arrCalArea = new ArrayList<pt>();
float BCBA = 0f;

pt debugStart;
pt debugEnd;
pt debugStart2;
pt debugEnd2;

public void initGDS()
{
  vertexColor = black;
  soonToAddColor = green;
  graphColor = black;  
  deleteColor = red;
  generateRandomColor(true);

  //Initialize start shape (Triangle)
  initTriangle();

  for (int i = 0; i < 100; i++) 
  {
    D.add(false); 
    DG.add(false);
  }
}

public void reset()
{
  V.clear();
  G.clear();
  NC.clear();
  S.clear();
  D.clear();
  DG.clear();
  for (int i = 0; i < 100; i++) 
  {
    D.add(false); 
    DG.add(false);
  }
}

public void initTriangle()
{
  //  G.add(P(-100, 100,0));
  //  G.add(P(100, -100,0));
  //  G.add(P(0, 100,0));c
  //  G.add(P(100, 200,0));
  //  G.add(P(50, 250,0));
  //  G.add(P(250, 50,0));
  //  G.add(P(150, 250,0));
  //  G.add(P(250, 350,0));
  G.add(P(100, 300, 0));
  G.add(P(300, 100, 0));
  G.add(P(200, 300, 0));
  G.add(P(300, 400, 0));

  V.add(0);
  NC.add(2);
  S.add(4);//0
  V.add(1);
  NC.add(4);
  S.add(2);//1
  V.add(1);
  NC.add(5);
  S.add(1);//2
  V.add(2);
  NC.add(1);
  S.add(6);//3
  V.add(0);
  NC.add(6);
  S.add(0);//4
  V.add(2);
  NC.add(0);
  S.add(3);//5
  V.add(2);
  NC.add(7);
  S.add(5); //6
  V.add(3);
  NC.add(3);
  S.add(7); //7
}

public int addVertice(pt P)
{
  G.add(P);
  return G.size()-1;
}

public void addEdge(pt P, pt Q, Boolean isDrag)
{
  selCorner = -1;
  Boolean verticeAdded = false;
  int i = checkNearestVertices(P);
  if (isDrag)
  {
    if (V.size() == 0)
    {
      addVertice(P);
      addVertice(Q);
      V.add(0);
      NC.add(1);
      S.add(0);
      V.add(1);
      NC.add(0);
      S.add(1);
      return;
    }

    int j = checkNearestVertices(Q);

    //if(checkforEdgeIntersection(P(P),P(Q))){return;}

    if (i== -1 && j==-1)  
    {
      println("testing");
      return;//return if neither vertex is on graph
    } else if (i!= -1 && j == -1)
    {
      println("add from start!");
      //Start point is connected to the graph
      //      verticeAdded = addSingleClickVertice(Q);
      //      if(!verticeAdded){addVertice(Q);}
      int c = checkNearestCornerForAdd(i, Q);
      println("corner c: " + c);
      addVertice(Q);
      V.add(i);
      V.add(G.size()-1);

      int cn = V.size()-2;
      int cn2 = V.size()-1;

      NC.set(prevCorner(c), cn);

      NC.add(cn2);
      NC.add(c);

      S.add(S.get(c));
      S.add(cn2);
      S.set(c, cn);
      //println("Corners Added: " + c + " " + cn2 + " " + cn);
    } else if (j!=-1 && i == -1)
    { 
      addEdge(Q, P, true);
    } else
    {
      //Both points are connected  to the graph

      int c1 = checkNearestCornerForAdd(i, Q);
      int c2 = checkNearestCornerForAdd(j, P);

      println("adding edges : " + c1 + " and " + c2);

      V.add(i);
      V.add(j);  

      int cn = V.size()-2;
      int cn2 = V.size()-1;

      NC.add(c2);
      NC.add(c1);

      NC.set(prevCorner(c2), cn2);
      NC.set(prevCorner(c1), cn);

      S.add(S.get(c1));
      S.set(c1, cn);

      S.add(S.get(c2));
      S.set(c2, cn2);
    }
  } else
  {
    println("hello");
    if (i==-1)
    {
      addSingleClickVertice(P);
    }
  }
}

public int checkNearestCornerForAdd(int sV, pt end)
{
  //float angle = 0;
  //int c = -1;
  float tempAngle = 0;
  float newAngle = 0;
  float highestAngle = -1;
  int cornerIndex = -1;
  pt nextCorner = P(-1, -1);
  ArrayList<Integer> startEdges = new ArrayList<Integer>();
  for (int k = 0; k < V.size (); k++)
  {
    if ((sV == V.get(k))&&!D.get(k))
    {
      startEdges.add(k);
    }
  }
  for (int j=0; j < startEdges.size (); j++)
  {
    int currC = startEdges.get(j);
    if (cornerIndex == -1)
    {
      nextCorner = G.get(V.get(NC.get(currC)));
      vec startV = V(G.get(sV), nextCorner);
      println("Corners:" + nextCorner.write() + ", " + G.get(sV).write());
      vec endV = V(G.get(sV), end);
      println("Corners:" + G.get(sV).write() + ", " + end.write());
      newAngle = toDeg(positive(angle(startV, endV, true)));
      //newAngle = toDeg(angle(startV,endV));
      println("Initial Angle: " + newAngle);
      cornerIndex = currC;
      println("Initial Corner: " + cornerIndex);
      continue;
    } else
    {
      vec startV = V(G.get(sV), nextCorner);
      vec endV = V(G.get(sV), G.get(V.get(NC.get(currC))));
      tempAngle = toDeg(positive(angle(startV, endV, true)));
      //tempAngle = toDeg(angle(startV,endV));
    }
    println("Angles:" + newAngle + ", " + tempAngle);     
    println("Corner in question: " +currC);
    if ((highestAngle < tempAngle)&&(tempAngle<newAngle))
    {
      highestAngle = tempAngle;
      cornerIndex = currC;
    }     
    println("Corner set: " +cornerIndex);
  }
  println("Corner Data: " + G.get(V.get(cornerIndex)).write());
  return cornerIndex;
}


Boolean addSingleClickVertice(pt P)
{
  pt start = P(0, 0);
  pt end = P(0, 0);
  for (int i =0; i < V.size (); i++)
  {
    if (D.get(i))
    {
      continue;
    }

    if (detectClickOnEdge(P.x, P.y, P(G.get(V.get(i))), P(G.get(V.get(NC.get(i))))) && !D.get(i))
    {
      start = P(G.get(V.get(i)));
      end = P(G.get(V.get(NC.get(i))));
      break;
    }
  }
  if (isSame(start, P(0, 0)) || isSame(end, P(0, 0)))
  {
    return false;
  }
  println("Found line match: " + start.write() + ":" + end.write());

  deleteEdge(start, end, false);  

  if (checkNearestVertices(start) != -1)
  {
    addEdge(P(start), P(P), true); 
    addEdge(P(P), P(end), true);
  } else
  {
    addEdge(P(P), P(end), true);
    addEdge(P(start), P(P), true);
  }



  return true;
}

public void soonDeleteAt(pt p)
{
  int i = checkNearestVertices(p);
  if (i != -1) 
  {
    delStartPt = G.get(i);
    delIsEdge = false;
    showDel = true;
  } else
  {
    //check if clicking on edge
    for (int k =0; k < V.size (); k++)
    {
      if (detectClickOnEdge(p.x, p.y, P(G.get(V.get(k))), P(G.get(V.get(NC.get(k))))) && !D.get(k))
      {
        delStartPt = P(G.get(V.get(k)));
        delEndPt = P(G.get(V.get(NC.get(k))));
        delIsEdge = true;
        showDel = true;
        break;
      }
    }
  }
}

public void deleteAt(pt p)
{
  println("In deleteAt: " + p.write());
  int i = checkNearestVertices(p);
  if (i != -1) 
  {
    p = G.get(i);
    deletePoint(i);
  } else
  {
    //check if clicking on edge
    pt start;
    pt end;
    for (int k =0; k < V.size (); k++)
    {
      if (detectClickOnEdge(p.x, p.y, P(G.get(V.get(k))), P(G.get(V.get(NC.get(k))))) && !D.get(k))
      {
        start = P(G.get(V.get(k)));
        end = P(G.get(V.get(NC.get(k))));
        deleteEdge(start, end, true);
        break;
      }
    }
  }
  if (checkEmptyGraph())
  {
    reset();
  }
}

public void deletePoint(int i)
{
  selCorner = -1;
  ArrayList<Integer> startHalfEdge = new ArrayList<Integer>();
  //Find all half edges from vertex
  for (int j= 0; j < V.size (); j++)
  {
    if (V.get(j) == i && !D.get(j))
    {
      startHalfEdge.add(j);
    }
  }

  //println("found # half Edges for corner " + i +": " + startHalfEdge.size());
  int k = startHalfEdge.get(0);
  if (startHalfEdge.size() == 2)
  {
    //    println("deleting vertex with 2 edges");
    //    NC.set(S.get(NC.get(k)), NC.get(S.get(k)));
    //    NC.set(prevCorner(k), NC.get(k));
    //    
    //    println("deleting corners: " + k + " and " + S.get(k));
    //
    //    D.set(k, true);
    //    D.set(S.get(k), true);
    //    DG.set(i, true);

    deleteEdge(G.get(V.get(k)), G.get(V.get(NC.get(k))), false);
    deleteEdge(G.get(V.get(k)), G.get(V.get(prevCorner(k))), false);
    DG.set(i, true);
  } else if (startHalfEdge.size() == 1)
  {
    println("Deleting hanging vertex with corner: " + k);
    //println("prevCorners: " + prevCorner(i) + "-" + prevCorner(prevCorner(k)));
    NC.set(prevCorner(prevCorner(k)), NC.get(k));

    D.set(k, true);
    D.set(prevCorner(k), true);
    DG.set(i, true);

    S.set(NC.get(k), S.get(prevCorner(k)));
  }
}

public void deleteEdge(pt start, pt end, Boolean doCheck)
{
  selCorner = -1;

  int cn = -1;
  int cn2 = -1;

  for (int k =0; k < V.size (); k++)
  {
    if (isSame(G.get(V.get(k)), start) && isSame(G.get(V.get(NC.get(k))), end) && !D.get(k))  //if same edge
    {
      cn = k;
      cn2 = zCorner(k);
      println("weeee: " + cn);
      println("weeee2222: " + cn2);
      break;
    }
  }

  //If the edge isn't connected to the other side of the graph
  if (cn == S.get(cn))
  {
    //println("cn == sw(cn)");
    deletePoint(V.get(cn));
    return;
  } else if (cn2 == S.get(cn2))
  {
    //println("cn2 == sw(cn2): " + G.get(V.get(cn2)).write());
    deletePoint(V.get(cn2));
    return;
  }

  //else edge is connected on both sides  
  println("deleting edge with corners: " + cn + " and " + cn2);
  NC.set(prevCorner(cn), NC.get(cn2));
  NC.set(prevCorner(cn2), NC.get(cn));

  S.set(NC.get(cn2), S.get(cn));
  S.set(NC.get(cn), S.get(cn2));

  D.set(cn, true);
  D.set(cn2, true);

  //println("checking graph recursion: " + checkConnectedGraph());
  if (doCheck && !checkConnectedGraph())
  {
    addEdge(start, end, true);
  }
}

public Boolean checkConnectedGraph()
{
  arrTV.clear();
  toVisitCount = 0;
  int startRecurse = 0;
  for (int i = 0; i < V.size (); i++)
  {
    if (D.get(i))
    {
      arrTV.add(-1);
    } else
    {
      arrTV.add(1);
      startRecurse = i;
      toVisitCount++;
    }
  }
  recurseCheckConnectedGraph(startRecurse);

  if (toVisitCount == 0) 
    return true;
  //println("toVisitCount = " + toVisitCount);
  return false;
}

public void recurseCheckConnectedGraph(int i)
{
  //println("recusing on index " + i);
  if (arrTV.get(i) == -1)
    return;
  arrTV.set(i, -1);
  toVisitCount--; 


  ArrayList<Integer> startHalfEdge = new ArrayList<Integer>();
  ArrayList<Integer> newToVisit = new ArrayList<Integer>();

  for (int j= 0; j < V.size (); j++)
  {
    if (V.get(j) == V.get(i))
    {
      if (i == j && arrTV.get(NC.get(j)) != -1)
      {
        //println("found matching corner on vertice");
        startHalfEdge.add(NC.get(j));
      } else
      {
        if (arrTV.get(j) != -1)
        {

          startHalfEdge.add(j);
          if (arrTV.get(NC.get(j)) != -1)
          {
            //println("corner " + j + ": adding start for corner: " + NC.get(j));
            startHalfEdge.add(NC.get(j));
          }
        }
      }
    }
  }
  for (int s = 0; s < startHalfEdge.size (); s++)
  {      
    newToVisit.add(startHalfEdge.get(s));
  }

  if (newToVisit.size() >= 1)  
  {
    for (int k = 0; k < newToVisit.size (); k++)
    {
      recurseCheckConnectedGraph(newToVisit.get(k));
    }
  } else        //Nothing left to visit
  return;
}

public void removeVertice(pt P)
{
  int i = checkNearestVertices(P);
  if (i!=-1) {
    G.remove(i);
  }
}

public int checkNearestVertices(pt P)
{
  for (int i = 0; i < G.size (); i++)
  {
    if (d(P, G.get(i)) < vertexSnapSize && !DG.get(i))
    {
      return i;
    }
  }
  return -1;
}

public int checkNearestCorner(pt p)
{
  float sDist = 30;
  int c = -1;

  for (int k = 0; k < V.size (); k++)
  {
    float lDist = d(cornerPosition(k), p);
    if (lDist < cornerSelectDist && lDist < sDist && !D.get(k))
    {
      sDist = lDist;
      c = k;
    }
  }

  return c;
}

public void selectCorner(pt p, Boolean show)
{
  if (!show)
  {
    showSelCorner = false;
    return;
  }

  int i = checkNearestCorner(p);

  if (i != -1)
  {
    selCorner = i;
    showSelCorner = true; 
    selCornerIsLoop = false;
  } else
  {
    int closestCorner = -1;
    float distance = MAX_INT;
    for (int k = 0; k < V.size (); k++)
    {
      float d = d(p, cornerPosition(k)); 

      if (d < distance && !D.get(k))
      {
        println("looking at corner: " + k);
        //println("closest current corner is: " + k);
        Boolean doesIntersect = false;
        int currCorner = k;
        Boolean blah = false;
        int smallestCornerIndex = selCorner;
        Boolean isIntersect = false;
        while (k != currCorner || !blah)
        {
          println("looking at line starting at corner " + currCorner + " " + G.get(V.get(k)).write() +" and going to corner " + NC.get(currCorner) + " " + G.get(V.get(NC.get(k))).write());
          if (!isSame(intersect(p.x, p.y, cornerPosition(k).x, cornerPosition(k).y, G.get(V.get(currCorner)).x, G.get(V.get(currCorner)).y, G.get(V.get(NC.get(currCorner))).x, G.get(V.get(NC.get(currCorner))).y), DONT_INTERSECT))
          {
            println("found intersect");
            isIntersect = true;
            break;
          }
          blah = true;
          currCorner = NC.get(currCorner);
        }
        if (!isIntersect)
        {
          println("closest current corner is: " + k + " with distance " + d);
          closestCorner = k;
          distance = d;
        }
      }
    } 
    //println("selected loop corner is: " + closestCorner);
    showSelCorner = true;
    selCorner = closestCorner;
    selCornerIsLoop = true;
  }
}

public pt cornerPosition(int i) //asdf
{
  if (i == S.get(i))
  {
    //println("hellow " + P(G.get(V.get(i))).write());
    vec bf = V(G.get(V.get(i)), G.get(V.get(NC.get(i))));
    bf.normalize().mul(20).rev();
    BCBA = -1;
    //return P(G.get(V.get(i)));
    return P(G.get(V.get(i)), bf);
  }
  //  println("Vector :" + i + "pointss :" + G.get(V.get(i)).write() + ", " + G.get(V.get(NC.get(i))).write());
  //  println("Vector :" + i + "points :" + G.get(V.get(i)).write() + ", " + G.get(V.get(prevCorner(i))).write());

  vec bc = V(G.get(V.get(i)), G.get(V.get(NC.get(i))));
  vec ba = V(G.get(V.get(i)), G.get(V.get(prevCorner(i))));
  //  println("Vector :" + i + "plain vector :" + bc.x + ", " + bc.y);
  //  println("Vector :" + i + "plain vectors :" + ba.x + ", " + ba.y);
  BCBA = positive(angle(bc, ba, true));
  if (toDeg(positive(angle(bc, ba, true))) == 180)
    //if(toDeg(angle(bc, ba)) == 180)
  {
    //return P(G.get(V.get(i)));
  }

  float s = 10/det2(ba.normalize(), bc.normalize());
  vec f = A(ba, bc);
  //  println("Vector :" + i + "before stuff f:" + f.x + ", " + f.y);
  //  println("Vector :" + i + "before stuff :" + P(G.get(V.get(i)), f).write());
  if (Float.isInfinite(s))
  {
    s=10;
    f=R(bc.normalize()).rev();
  }
  f.mul(s).rev();
  //  println("Vector :" + i + "after stuff f:" + f.x + ", " + f.y);
  //  println("Vector :" + i + "after stuff :" + P(G.get(V.get(i)), f).write());
  angleVector = f;
  return P(G.get(V.get(i)), f);
}

public void drawCorner(int i, int col, boolean ext)
{
  pt p = cornerPosition(i);
  stroke(col);
  fill(col);
  show(p, 2);
}

public void drawNextCorner(int i)
{
  drawCorner(NC.get(i), blue, false);
}

public int prevCorner(int i)
{
  //println("i: " + i);
  //println(" swing: " + S.get(i));
  return S.get(NC.get(S.get(i)));
}

public void drawPrevCorner(int i)
{
  drawCorner(prevCorner(i), magenta, false);
}

public void drawSwingCorner(int i)
{
  if (i == S.get(i))
    return;
  drawCorner(S.get(i), green, true);
}

public int unswingCorner(int i)
{
  return NC.get(zCorner(i));
}

public void drawUnswingCorner(int i)
{
  drawCorner(unswingCorner(i), yellow, true);
}

public int zCorner(int i)
{
  return S.get(NC.get(i));
}

public void drawZCorner(int i)
{
  drawCorner(zCorner(i), cyan, true);
}

public void DrawSoonToAdd(pt P, pt Q, Boolean isDrag, Boolean keepDrawing)
{
  int i = checkNearestVertices(P); 
  int j = checkNearestVertices(Q);
  if (i != -1) P = G.get(i);
  if (j != -1) Q = G.get(j);

  soonStartPt = P(P);
  soonEndPt   = P(Q);
  showSoon = keepDrawing;
}

public void drawGraph()
{
  if (!threeDMode)
  {
    for (int i=0; i < V.size (); i++)
    {
      if (D.get(i))
        continue;
      stroke(graphColor);
      line(G.get(V.get(i)).x, G.get(V.get(i)).y, G.get(V.get(NC.get(i))).x, G.get(V.get(NC.get(i))).y);
      fill(white);
      show(G.get(V.get(i)), vertexSize);
      if (!D.get(NC.get(i))) show(G.get(V.get(NC.get(i))), vertexSize);
      fill(black);
      if (!threeDMode) {
//        text(G.get(V.get(i)).write(), G.get(V.get(i)).x + 15, G.get(V.get(i)).y + 15);
      }
      noFill();
      if (!threeDMode)
      {
//        text(V.get(i), G.get(V.get(i)).x - 4, G.get(V.get(i)).y + 4);
//        text(V.get(NC.get(i)), G.get(V.get(NC.get(i))).x - 4, G.get(V.get(NC.get(i))).y + 4);
//        text("V(" + i + "): " + G.get(V.get(i)).write() + ":" +  G.get(V.get(NC.get(i))).write(), 900, 200+i*20);
      }
    }

    if(showSoon)
    {
      fill(white);
      stroke(soonToAddColor);
      line(soonStartPt.x, soonStartPt.y, soonEndPt.x, soonEndPt.y);
      show(soonStartPt, vertexSize);
      show(soonEndPt, vertexSize);
      noFill();
    }

    if(showDel)
    {
      if(delIsEdge)
      {
        fill(white);
        stroke(deleteColor);
        line(delStartPt.x, delStartPt.y, delEndPt.x, delEndPt.y);
        show(delStartPt, vertexSize);
        show(delEndPt, vertexSize);
        noFill();
      }
      else
      {
        fill(white);
        stroke(deleteColor);
        show(delStartPt, vertexSize);
        noFill();
      }
      showDel = false;
    }

    if (debugStart != null)
    {
      stroke(red);
      fill(red);
      line(debugStart.x, debugStart.y, debugEnd.x, debugEnd.y); 
      stroke(magenta);
      fill(magenta);
      line(debugStart2.x, debugStart2.y, debugEnd2.x, debugEnd2.y);
    }
  }

  if (showFaceLoops)
  {
    if (drawFaceLoops())
    {
      stopColorGeneration = true;
    }
  }
  if (threeDMode)
  {
    if (draw3DArray())
    {
      //stopColorGeneration = true;
    }
  }

  if (!threeDMode && showSelCorner && selCorner != -1)
  {   
    if (!selCornerIsLoop)
    {
      fill(black);
      if (!threeDMode)
      {
        text("selCorner: " + selCorner, 100, 500);
        text("prevCorner: " + prevCorner(selCorner), 100, 520);
        text("nextCorner: " + NC.get(selCorner), 100, 540);
        text("swingCorner: " + S.get(selCorner), 100, 560);
      }

      drawNextCorner(selCorner);
      drawPrevCorner(selCorner);
      drawSwingCorner(selCorner);
      //drawUnswingCorner(selCorner);
      //drawZCorner(selCorner);
      drawCorner(selCorner, red, false);

      fill(black);
      text("Corner Colors:", 800, 200);
      fill(red);
      text("Selected", 800, 220);
      fill(blue);
      text("Next", 800, 240);
      fill(green);
      text("Swing", 800, 260);
      fill(magenta);
      text("Previous", 800, 280);
      fill(cyan);
      text("Z", 800, 300);
    } else
    {
      stroke(blue);
      noFill();
      beginShape();
      vertex(cornerPosition(selCorner).x, cornerPosition(selCorner).y);
      int currCorner = NC.get(selCorner);
      arrCalArea.clear();
      arrCalArea.add(cornerPosition(selCorner));
      arrCalArea.add(cornerPosition(NC.get(selCorner)));
      int smallestCornerIndex = selCorner;
      while (selCorner != currCorner)
      {
        vertex(cornerPosition(currCorner).x, cornerPosition(currCorner).y);
        arrCalArea.add(cornerPosition(currCorner));
        arrCalArea.add(cornerPosition(NC.get(currCorner)));
        if (currCorner < selCorner)
          smallestCornerIndex = selCorner;
        currCorner = NC.get(currCorner);
      }
      endShape(CLOSE);
      //arrCalArea.add(cornerPosition(selCorner));
      stroke(black);
      fill(black);
      text("Selected Face " + smallestCornerIndex + " has an area of " + CalculateArea(), 100, 120);
    }
  }  
  if(threeDMode && showSelCorner && selCorner != -1)
  {
      fill(black);

      draw3DNextCorner(selCorner);
      draw3DPrevCorner(selCorner);
      draw3DSwingCorner(selCorner);
      //drawUnswingCorner(selCorner);
      //drawZCorner(selCorner);
      draw3DCorner(selCorner, red, false);
  }
}

Boolean checkforEdgeIntersection(pt P, pt Q)
{
  for (int i =0; i < V.size (); i++)
  {
    if (!(d(P(P), P(G.get(V.get(i))))<vertexSnapSize && d(P(Q), P(G.get(V.get(NC.get(i)))))<vertexSnapSize))
    {
      pt temp = intersect(P.x, P.y, Q.x, Q.y, P(G.get(V.get(i))).x, P(G.get(V.get(i))).y, P(G.get(V.get(NC.get(i)))).x, P(G.get(V.get(NC.get(i)))).y);      
      if (!(d(P(temp), P(P))<vertexSnapSize) && !(d(P(temp), P(Q))<vertexSnapSize) && !isSame(P(temp), DONT_INTERSECT))
      {
        //        println(temp.write());
        return true;
      }
    }
  }
  return false;
}

public void moveNext()
{
  selCorner = NC.get(selCorner);
}
public void movePrev()
{
  selCorner = prevCorner(selCorner);
}
public void moveSwing()
{
  selCorner = S.get(selCorner);
}
public void moveUnswing()
{
  selCorner = unswingCorner(selCorner);
}
public void moveZ()
{
  selCorner = zCorner(selCorner);
}
public void generateRandomColor(Boolean reset)
{ 
  if (!stopColorGeneration)
  {
    if (reset) {
      randomLoopColor.clear();
      randomLoopColor.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    } else
    {
      randomLoopColor.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    }
  }
  //randomLoopColor = color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2);
}
public Boolean drawFaceLoops()
{
  toVisitCount = V.size();
  arrTV.clear();
  for (int i = 0; i < V.size (); i++)
  {
    arrTV.add(1);
  }
  colorIndex = 0;
  arrCalArea.clear();
  if (threeDMode)
  {
    fill(green);
  }
  smallestCornerID = -1;
  recurseDrawFace(0);
  //  println("Start");
  if (toVisitCount == 0) 
    return true;

  return false;
}

public void recurseDrawFace(int i)
{
  //    println("Corner: " + i);
  if ((arrTV.get(i) != -1))
  {
    arrTV.set(i, -1);
    toVisitCount--;    
    //      if(D.get((i)))
    //      { 
    //         recurseDrawFace(i);
    //      }
  } else if (toVisitCount != 0)
  {
    float area = CalculateArea();   
    int temp = i;
    if (smallestCornerID > -1)
    {
      //        println("New Loop");
//      if (!threeDMode)
//      {
        if (outSideLoop)
        { 
          fill(randomLoopColor.get(colorIndex));
          text("Face " + smallestCornerID + " Area: Infinity", 50, 350+colorIndex*20);
          noFill();
        } else
        { 
          fill(randomLoopColor.get(colorIndex));
          text("Face " + smallestCornerID + " Area: " + area, 50, 350+colorIndex*20);
          noFill();
          outSideLoop = true;
        }
//      }
    }
    smallestCornerID = -1;
    arrCalArea.clear();
    for (int j =0; j < arrTV.size (); j++)
    {
      if ((arrTV.get(j) != -1)&&!D.get(j))
      {
        i = j;
        arrTV.set(i, -1);
        toVisitCount--; 
        generateRandomColor(false);
        colorIndex++;
        break;
      }
    }
    if (temp == i)
    {
      toVisitCount=0;
      return;
    }
  } else
  {
    float area = CalculateArea();   
//    if (!threeDMode)
//    {
      if (outSideLoop)
      { 
        fill(randomLoopColor.get(colorIndex));
        text("Face " + smallestCornerID + " Area: Infinity", 50, 350+colorIndex*20);
        noFill();
      } else
      { 
        fill(randomLoopColor.get(colorIndex));
        text("Face " + smallestCornerID + " Area: " + area, 50, 350+colorIndex*20);
        noFill();
        outSideLoop = true;
      }
//    }
    smallestCornerID = -1;
    arrCalArea.clear();
    return;
  }

  int newToVisit = -1;
  if (!D.get((i)))
  {
    if (i < smallestCornerID || smallestCornerID == -1)
    {
      smallestCornerID = i;
    }
    newToVisit = NC.get(i);
    pt cp = cornerPosition(i);
    pt ncp = cornerPosition(NC.get(i));      
    if (arrCalArea.size() == 0)
    {
      vec bf = V(G.get(V.get(i)), cp);
      bf.normalize().mul(500);
      pt P = P(G.get(V.get(i)), bf);
      for (int k=0; k<V.size (); k++)
      {
        if (!isSame(G.get(V.get(i)), G.get(V.get(k))) && !isSame(G.get(V.get(i)), G.get(V.get(NC.get(k)))))
        {
          if (!isSame(intersect(G.get(V.get(i)).x, G.get(V.get(i)).y, P.x, P.y, G.get(V.get(k)).x, G.get(V.get(k)).y, G.get(V.get(NC.get(k))).x, G.get(V.get(NC.get(k))).y), DONT_INTERSECT))
          { 
            //              println(i + k+ NC.get(k));
            //              stroke(red);line(G.get(V.get(i)).x,G.get(V.get(i)).y,P.x,P.y);
            //              stroke(green);line(G.get(V.get(k)).x,G.get(V.get(k)).y,G.get(V.get(NC.get(k))).x,G.get(V.get(NC.get(k))).y);
            outSideLoop=false;
            break;
          }
        }
      }
    }
    //      if(draw3DArray)
    //      {
    //        addTo3DStructure(cp,(arrCalArea.size()==0));
    //      }
    //      else
    //      {
//          if(outSideLoop)
//          {
//            beginShape(LINES);
//            stroke(randomLoopColor.get(colorIndex));
//            int r =50;
//            int k = ceil((BCBA-PI)/(PI/5));
//            float e = (BCBA-PI)/k;
//            for(float a=PI/2;a<BCBA-PI/2+0.01;a+=e)
//            {
//              pt temp=R(P(cp,r,U(cp,ncp)),-a,cp);
//              v(temp);
//              show(temp,2);
//            }
//            endShape();
//          }
    if (threeDMode)
    {
      //          beginShape();
      //          fill(green);
      stroke(red);
      show(cp, 8);
      stroke(randomLoopColor.get(colorIndex));
      //          v(cp);v(ncp);
      stub(cp, V(cp, ncp), 4, 2);
      //          endShape(CLOSE);
    } else
    {
//      if(outSideLoop)
//      {
//        beginShape(LINES);
//        stroke(randomLoopColor.get(colorIndex));
//        int r =50;
//        int k = ceil((BCBA-PI)/(PI/5));
//        float e = (BCBA-PI)/k;        
//        for(float a=PI/2;a<BCBA-PI/2+0.01;a+=e)
//        {
//          pt temp=R(P(cp),-a,G.get(V.get(i)));
//          v(temp);
//          show(temp,2);
//        }
//        endShape();
//      }
//      else
//      {
        stroke(randomLoopColor.get(colorIndex));
        line(cp.x, cp.y, ncp.x, ncp.y);
//      }
    }
    //     }
    //      }
    //      fill(randomLoopColor.get(colorIndex));show(cp, vertexSize);
    //      show(G.get(V.get(NC.get(i))), cornerSize);
    //      text("E(" + i + "): " + G.get(V.get(i)).write() + ":" +  G.get(V.get(NC.get(i))).write(), 900, 400+i*20);
    //      fill(black);text(cp.write(), cp.x + 15, cp.y + 15);noFill();
    arrCalArea.add(cp);
    arrCalArea.add(ncp);
  } else
  {
    newToVisit = i;
  }
  if (newToVisit > -1)  
  {
    recurseDrawFace(newToVisit);
  } else        //Nothing left to visit
  return;
}

public float CalculateArea()
{
  float area = 0;
  for (int i = 0; i < arrCalArea.size (); i++)
  {

    area += (arrCalArea.get(i).x * arrCalArea.get(i+1).y - arrCalArea.get(i+1).x * arrCalArea.get(i).y);
    i = i+1;
  }
  return area = abs(area / 2);
}

public Boolean checkEmptyGraph()
{
  for (int i =0; i < V.size (); i++)
  {
    if (!D.get(i))
      return false;
  }  
  return true;
}

