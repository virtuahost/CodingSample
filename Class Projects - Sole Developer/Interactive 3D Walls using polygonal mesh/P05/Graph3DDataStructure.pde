//////////// 3D Array 
ArrayList<pt> G3D = new ArrayList<pt>();        //Vertices
ArrayList<Integer> V3D = new ArrayList<Integer>();      //Half Edges
ArrayList<Integer> NC3D = new ArrayList<Integer>();      //Next Half Edges
ArrayList<Integer> S3D = new ArrayList<Integer>();    //Swing Corners
ArrayList<Integer> arrTV3D = new ArrayList<Integer>();      //Visited Vertices
Boolean draw3DArray = false;
int loopStart = -1;
int zOffset = 20;
int toVisitCount3D;
float angle3D = 0;
int loopStartVertex = 0;
Boolean useOffSet = false;
int loopCount = -1;
int secondCornerID = -1;
vec angleVector = null;

public void recurse3DArray(int i)
{
  if ((arrTV3D.get(i) != -1))
  {
    arrTV3D.set(i, -1);
    toVisitCount3D--;
  } else if (toVisitCount3D != 0)
  {     
    int temp = i;
    if (smallestCornerID > -1)
    {
      if (!outSideLoop)
      {             
        outSideLoop = true;
      }
    }
    smallestCornerID = -1;
    arrCalArea.clear();
    for (int j =0; j < arrTV3D.size (); j++)
    {
      if ((arrTV3D.get(j) != -1)&&!D.get(j))
      {        
        i = j;
        arrTV3D.set(i, -1);
        toVisitCount3D--; 
        break;
      }
    }
    if (temp == i)
    {
      toVisitCount3D=0;
      return;
    }
    loopCount++;
  } else
  {
    float area = CalculateArea();   
    if (!outSideLoop)
    { 
      outSideLoop = true;
    }
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
    float angleForUse = BCBA;
    vec reqdVec = angleVector;
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
            outSideLoop=false;
            break;
          }
        }
      }
    }
    if (outSideLoop && (angleForUse > PI || angleForUse == -1))
    { 
      int r =5;
      Boolean newStartLoop = (arrCalArea.size()==0);
      vec bc;
      vec ba;
      if (i == S.get(i) && angleForUse == -1)
      {
        pt temp=R(G.get(V.get(i)),-PI/16,cp);
        addTo3DStructure(temp, newStartLoop);     
        
        addTo3DStructure(cp, false);
 
        temp=R(G.get(V.get(i)),PI/16,cp);
        addTo3DStructure(temp, false);
      }
      else
      {
        bc = V(G.get(V.get(i)), G.get(V.get(NC.get(i))));
        ba = V(G.get(V.get(i)), G.get(V.get(prevCorner(i))));
        vec temp=R(reqdVec,-PI/8,bc.normalize(),ba.normalize());
        addTo3DStructure(P(G.get(V.get(i)), temp), newStartLoop);//(arrCalArea.size()==0));        
        
        addTo3DStructure(cp, false);

        temp=R(reqdVec,PI/8,bc.normalize(),ba.normalize());
        addTo3DStructure(P(G.get(V.get(i)), temp), false);
      }
    } else
    {
      addTo3DStructure(cp, (arrCalArea.size()==0));
    }
    arrCalArea.add(cp);
    arrCalArea.add(ncp);
  } else
  {
    newToVisit = i;
  }
  if (newToVisit > -1)  
  {
    recurse3DArray(newToVisit);
  } else        //Nothing left to visit
  return;
}


public Boolean create3DArray()
{
  toVisitCount3D = V.size();
  arrTV3D.clear();
  int startPt = -1;
  for (int i = 0; i < V.size (); i++)
  {
    if(S.get(i)!=i && startPt == -1){startPt = i;}
    arrTV3D.add(1);
  }
  loopCount=1;
  recurse3DArray(startPt);
  loopStartVertex = 0;
  if (toVisitCount3D == 0) 
    return true;

  return false;
}

public Boolean draw3DArray()
{
  int startCorner = -1;
  arrTV3D.clear();
  for (int i = 0; i < V3D.size (); i++)
  {
    arrTV3D.add(1);
  }
  //  println("Color");
  for (int i =0; i<V3D.size (); i++)
  {
    if (arrTV3D.get(i) == 0)continue;    
    fill(color(255- i, 255- i-20, 255- i-30));
    beginShape();
    if (drawSkeleton)
    {
      stub(G3D.get(V3D.get(i)), V(G3D.get(V3D.get(i)), G3D.get(V3D.get(NC3D.get(i)))), 1, 1);
    } else
    {
      vertex(G3D.get(V3D.get(i)));
    }
    arrTV3D.set(i, 0);    
    startCorner = NC3D.get(i);
    while (i!=startCorner)
    {
      if (drawSkeleton)
      {
        stub(G3D.get(V3D.get(startCorner)), V(G3D.get(V3D.get(startCorner)), G3D.get(V3D.get(NC3D.get(startCorner)))), 1, 1);
      } else
      {
        vertex(G3D.get(V3D.get(startCorner)));
      }
      arrTV3D.set(startCorner, 0);
      startCorner = NC3D.get(startCorner);
    }
    endShape(CLOSE);
    noFill();
  }
  return true;
}

public pt cornerPosition3D(int i) 
{
  if (i == S3D.get(i))
  {
    vec bf = V(G3D.get(V3D.get(i)), G3D.get(V3D.get(NC3D.get(i))));
    bf.normalize().mul(2).rev();
    //return P(G.get(V.get(i)));
    return P(G3D.get(V3D.get(i)), bf);
  }

  vec bc = V(G3D.get(V3D.get(NC3D.get(i))), G3D.get(V3D.get(i)));
  vec ba = V(G3D.get(V3D.get(prev3DCorner(i))), G3D.get(V3D.get(i)));
  angle3D = positive(angle(bc, ba, true));

//  float s = 10/det2(ba.normalize(), bc.normalize())*0.001;
//  vec f = A(ba, bc);
//  if (Float.isInfinite(s))
//  {
//    s=10;
//    f=R(bc.normalize()).rev();
//  }
//  f.mul(s).rev();
//
//  return P(G3D.get(V3D.get(i)), f);
  //float s = 10/det2(ba.normalize(), bc.normalize())*0.001;
  vec f = A(ba.normalize(), bc.normalize());  
  if (Float.isInfinite(s))
  {
    s=10;
    f=R(bc.normalize()).rev();
  }
  f.mul(4).rev();
  if(angle3D > PI)
  {
    f.rev();
  }
  return P(G3D.get(V3D.get(i)), f);
}

public void addTo3DStructure(pt P, Boolean newLoop)
{
  int lastLoopStart = -1;
  if (newLoop)
  {
    if (loopStart > -1)
    {
      lastLoopStart = loopStart;
      NC3D.set(V3D.size()-6, loopStart);//C1
//      println("NC: " + (V3D.size()-6) + " value: " + NC3D.get(V3D.size()-6));
      NC3D.set(loopStart+1, V3D.size()-4);//C2
//      println("NC: " + (loopStart+1) + " value: " + NC3D.get(loopStart+1));
      NC3D.set(loopStart+3, V3D.size()-3);//C4
//      println("NC: " + (loopStart+3) + " value: " + NC3D.get(loopStart+3));
      NC3D.set(V3D.size()-2, loopStart+5);//C5
//      println("NC: " + (V3D.size()-2) + " value: " + NC3D.get(V3D.size()-2));
      loopStart = V3D.size();
    } else
    {      
      loopStart = 0;
    }
  }
  G3D.add(P);  
//  println("G: " + (G3D.size()-1) + " value: " + P.x + ", " + P.y + ", " + P.z); 
  V3D.add(G3D.size()-1);  
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  V3D.add(G3D.size()-1);
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  V3D.add(G3D.size()-1);
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  S3D.add(V3D.size()-2);  
//  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));
  S3D.add(V3D.size()-1);
//  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));
  S3D.add(V3D.size()-3);
//  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));
  pt Pz = P(P.x, P.y, zOffset);
  G3D.add(Pz);
//  println("G: " + (G3D.size()-1) + " value: " + Pz.x + ", " + Pz.y + ", " + Pz.z);
  V3D.add(G3D.size()-1);
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  V3D.add(G3D.size()-1);
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  V3D.add(G3D.size()-1);
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  S3D.add(V3D.size()-2);
//  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));
  S3D.add(V3D.size()-1);
//  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));
  S3D.add(V3D.size()-3);
//  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));  
  NC3D.add(-1);
  NC3D.add(-1);
  NC3D.add(-1);
  NC3D.add(-1);
  NC3D.add(-1);
  NC3D.add(-1);
  NC3D.set(NC3D.size()-6, V3D.size());//To be updated again on newLoop start for the previous iteration to close loop.C1  
//  println("NC: " + (NC3D.size() - 6) + " value: " + NC3D.get(NC3D.size()-6));
  if (!newLoop)
  {
    NC3D.set(NC3D.size()-5, V3D.size()-10);//To be updated again on newLoop start for the previous iteration to close loop.C2
//    println("NC: " + (NC3D.size() - 5) + " value: " + NC3D.get(NC3D.size()-5));
  }
  NC3D.set(NC3D.size()-4, V3D.size()-2);//C3
//  println("NC: " + (NC3D.size() - 4) + " value: " + NC3D.get(NC3D.size()-4));
  if (!newLoop)
  {
    NC3D.set(NC3D.size()-3, V3D.size()-9);//To be updated again on newLoop start for the previous iteration to close loop.C4
//    println("NC: " + (NC3D.size() - 3) + " value: " + NC3D.get(NC3D.size()-3));
  }
  NC3D.set(NC3D.size()-2, V3D.size()+5);//To be updated again on newLoop start for the previous iteration to close loop.C5
//  println("NC: " + (NC3D.size() - 2) + " value: " + NC3D.get(NC3D.size()-2));
  NC3D.set(NC3D.size()-1, V3D.size()-5);//C6
//  println("NC: " + (NC3D.size() - 1) + " value: " + NC3D.get(NC3D.size()-1));
}
public void generate3DDataStructure()
{
  G3D.clear();
  V3D.clear();      //Half Edges
  NC3D.clear();      //Next Half Edges
  S3D.clear();    //Swing Corners
  create3DArray();
  if (loopStart > -1)
  {
    NC3D.set(V3D.size()-6, loopStart);//C1
//    println("NC: " + (V3D.size()-6) + " value: " + NC3D.get(V3D.size()-6));
    NC3D.set(loopStart+1, V3D.size()-4);//C2
//    println("NC: " + (loopStart+1) + " value: " + NC3D.get(loopStart+1));
    NC3D.set(loopStart+3, V3D.size()-3);//C4
//    println("NC: " + (loopStart+3) + " value: " + NC3D.get(loopStart+3));
    NC3D.set(V3D.size()-2, loopStart+5);//C5
//    println("NC: " + (V3D.size()-2) + " value: " + NC3D.get(V3D.size()-2));
  }
  loopStart = -1;
  createBridgeLines();
//  for(int i =0 ;i<V3D.size();i++)
//  {
//    println("Start: " + i + " End: " + NC3D.get(i));
//  }
}
public void createBridgeLines()
{
  int orgLoopCount = loopCount;
  arrTV3D.clear();
  int startPt = 0;
  int orgCount = NC3D.size();
  for (int i = 0; i < V.size (); i++)
  {
    if(!D.get(i))
    {    
      arrTV3D.add(1);
    }
    else
    {
      arrTV3D.add(0);
    }
  }
  int i =0;
  int loopStart = -1;
  while(loopCount -1 > 0)
  {
    if(loopStart == i)
    {
      i++;
      if(i == V.size())
      {
        i = 0;
      }
      continue;
    }
    if(D.get(i))
    {
      i++;
      if(i == V.size())
      {
        i = 0;
      }
      continue;
    }
    if(arrTV3D.get(i) == 0 && arrTV3D.get(S.get(i)) != 0)
    {
//      println("Swing : " + findStartCorner(cornerPosition(i)) + ", " + findStartCorner(cornerPosition(S.get(i))));
      setBridgeLines(findStartCorner(cornerPosition(i)),findStartCorner(cornerPosition(S.get(i))),orgCount);
      markAllVisited(S.get(i));
      loopCount--;  
      loopStart= S.get(i);
      i = NC.get(S.get(i));
      continue;
    }
    if(arrTV3D.get(i) != 0 && arrTV3D.get(S.get(i)) == 0)
    {
//      println("Swing : " + findStartCorner(cornerPosition(i)) + ", " + findStartCorner(cornerPosition(S.get(i))));
      setBridgeLines(findStartCorner(cornerPosition(S.get(i))),findStartCorner(cornerPosition(i)),orgCount);
      markAllVisited(i);
      loopCount--;
      i = NC.get(i);
      continue;
    }
    if(arrTV3D.get(i) == 0)
    {
      i++;
      if(i == V.size())
      {
        i = 0;
      }
      continue;
    }        
    if(i==S.get(i))
    {
      i=NC.get(i);
      continue;
    }
    if(checkIfswingInSameLoop(i,S.get(i)))
    {
      i=NC.get(i);
      continue;
    }
    if(loopStart == -1)
    {
      loopCount--;    
      println("Non Swing : " + findStartCorner(cornerPosition(i)) + ", " + findStartCorner(cornerPosition(S.get(i))));
      setBridgeLines(findStartCorner(cornerPosition(i)),findStartCorner(cornerPosition(S.get(i))),orgCount);
      Boolean needPath = markAllVisited(i);    
      Boolean needPath2 = markAllVisited(S.get(i));
      loopStart = i;
    }
//    i=S.get(i);
    i=NC.get(i);
  }
}

public int checkAllVisited()
{
  for(int i =0; i < arrTV3D.size();i++)
  {
    if(arrTV3D.get(i) == 1)
    {
      return i;
    }
  }
  return -1;
}

public Boolean checkIfswingInSameLoop(int i, int j)
{
  int startPt = i;
  do
  {
    if(startPt == j)
    {
      return true;
    }
    startPt = NC.get(startPt);
  }
  while(startPt != i);
  return false;
}

public Boolean markAllVisited(int startPt)
{
  Boolean outputResult = false;
  int endCond = startPt;
  do
  { 
    if(arrTV3D.get(endCond) == 0)
    {
      outputResult = true;
    }   
    arrTV3D.set(endCond,0);
    endCond = NC.get(endCond);
  }
  while(startPt!= endCond);
  return outputResult;
}

public void setBridgeLines(int i, int j,int orgCount)
{
  int prevStartCorner = prev3DCorner(i+3);
  int prevEndCorner = prev3DCorner(j+3);
  //Start corner C7 and C8
  V3D.add(V3D.get(i));
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  V3D.add(V3D.get(i+3));
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  
  //End Corner C7 and C8
  V3D.add(V3D.get(j));
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  V3D.add(V3D.get(j+3));
//  println("V: " + (V3D.size()-1) + " value: " + V3D.get(V3D.size()-1));
  
  //Swing fix for start
  S3D.add(i);  //C7 swing fix
  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));
  S3D.set(i+2,V3D.size()-4); //C3 swing fix
  println("S: " + (i+2) + " value: " + S3D.get(i+2));
  S3D.add(i+4);  //C8 swing fix
  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));
  S3D.set(i+3,V3D.size()-3);  //C6 swing fix
  println("S: " + (i+5) + " value: " + S3D.get(i+5));
  
  //Swing fix for End
  S3D.add(j);  //C7 swing fix
  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));
  S3D.set(j+2,V3D.size()-2); //C3 swing fix
  println("S: " + (j+2) + " value: " + S3D.get(j+2));
  S3D.add(j+4);  //C8 swing fix
  println("S: " + (S3D.size()-1) + " value: " + S3D.get(S3D.size()-1));
  S3D.set(j+3,V3D.size()-1);  //C6 swing fix
  println("S: " + (j+3) + " value: " + S3D.get(j+3));
    
  NC3D.add(-1);
  NC3D.add(-1);
  NC3D.add(-1);
  NC3D.add(-1);
  
  //Next Corner Fix for bottom  
  int temp = NC3D.get(i);
  NC3D.set(NC3D.size()-4, temp);//C7 start
  println("NC: " + (NC3D.size()-4) + " value: " + NC3D.get(NC3D.size()-4));
  NC3D.set(i,NC3D.size()-2);//C1 start
  println("NC: " + (i) + " value: " + NC3D.get(i));
  temp = NC3D.get(j);
  NC3D.set(NC3D.size()-2, temp);//C7 end
  println("NC: " + (NC3D.size()-2) + " value: " + NC3D.get(NC3D.size()-2));
  NC3D.set(j, V3D.size()-4);//C1 end
  println("NC: " + (j) + " value: " + NC3D.get(j));
  
  //Next Corner Fix for top
  NC3D.set(NC3D.size()-3, j+3);//C8 start
  println("NC: " + (NC3D.size()-3) + " value: " + NC3D.get(NC3D.size()-3));
  NC3D.set(prevStartCorner,NC3D.size()-3);//C12 start
  println("NC: " + (prevStartCorner) + " value: " + NC3D.get(prevStartCorner));
  NC3D.set(NC3D.size()-1, i+3);//C8 end
  println("NC: " + (NC3D.size()-1) + " value: " + NC3D.get(NC3D.size()-1));
  NC3D.set(prevEndCorner, NC3D.size()-1);//C12 end
  println("NC: " + (prevEndCorner) + " value: " + NC3D.get(prevEndCorner));
}


public int findStartCorner(pt P)
{
  for(int i =0; i < V3D.size();i++)
  {
    if(isSame(P,G3D.get(V3D.get(i))))
    {
      return i;
    }
    else if(d(P,G3D.get(V3D.get(i))) < 5)
    {
      return i;
    }
  }
  return -1;
}
public void draw3DNextCorner(int i)
{
  draw3DCorner(NC3D.get(i), blue, false);
}

public int prev3DCorner(int i)
{
  //println("i: " + i);
  //println(" swing: " + S.get(i));
  println("ID: " + i + "Swing: " + S3D.get(i) + "Next: " + NC3D.get(S3D.get(i)) + "Prev: " + S3D.get(NC3D.get(S3D.get(i))));
  return S3D.get(NC3D.get(S3D.get(i)));
}

public void draw3DPrevCorner(int i)
{
  draw3DCorner(prev3DCorner(i), magenta, false);
}

public void draw3DSwingCorner(int i)
{
  if (i == S3D.get(i))
    return;
  draw3DCorner(S3D.get(i), green, true);
}

public int unswing3DCorner(int i)
{
  return NC3D.get(z3DCorner(i));
}

public void draw3DUnswingCorner(int i)
{
  draw3DCorner(unswing3DCorner(i), yellow, true);
}

public int z3DCorner(int i)
{
  return S3D.get(NC3D.get(i));
}

public void draw3DZCorner(int i)
{
  draw3DCorner(z3DCorner(i), cyan, true);
}

public void draw3DCorner(int i, int col, boolean ext)
{
  //  pt p = G3D.get(V3D.get(i));
  pt p = cornerPosition3D(i);
  stroke(col);
  fill(col);
  show(p, 2);
  if(showLoops)
  {
    if(!ext)
    {
      int curCorner = i;
      fill(yellow);
      stroke(yellow);
      do
      {
        stub(G3D.get(V3D.get(curCorner)), V(G3D.get(V3D.get(curCorner)), G3D.get(V3D.get(NC3D.get(curCorner)))), 4, 1);
        curCorner = NC3D.get(curCorner);
      }
      while(i!=curCorner);
    }
  }
  //  show(xyz,2);
}
//pt xyz;
//public void selectCorner3D(int x, int y)
public void selectCorner3D(pt P)
{
  float dist = 0;
  for (int i = 0; i<V3D.size (); i++)
  {
    pt Q = cornerPosition3D(i);
    float temp = d(P, Q);
    if (temp<5 && (dist >temp || dist == 0))
    {
      showSelCorner = true;
      selCorner = i;
      dist = temp;
    }
  }
}

public void move3DNext()
{
  println("Curr Corner: " + selCorner);
  selCorner = NC3D.get(selCorner);
  println("Next Corner: " + selCorner);
}
public void move3DPrev()
{
  selCorner = prev3DCorner(selCorner);
}
public void move3DSwing()
{
  selCorner = S3D.get(selCorner);
}
public void move3DUnswing()
{
  selCorner = unswing3DCorner(selCorner);
}
public void move3DZ()
{
  selCorner = z3DCorner(selCorner);
}

