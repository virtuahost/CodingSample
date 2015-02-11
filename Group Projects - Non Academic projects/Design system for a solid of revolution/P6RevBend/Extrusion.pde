class Extrusion {

 int of = -1;
 boolean[] E; // to track which corners have been explored 
 pt G3[]; int V3[], N3[], S3[];
 int pc = -1; // pc: picked corner, 
 int nc3D = 0; int nv3D = 0; int numWC = 0;
 vec topNormal; float ht = 0;

 Extrusion(ArrayList<pt2> cl, ArrayList<pt2> bl, float h){


  int maxnv3D = 2*cl.size(); int maxnc3D = 8*cl.size(); // 6 3D corners for each 2D corner. Factor of 8 to cover for bridge edge corners
  ht = h;
  
  G3 = new pt [maxnv3D];
  V3 = new int [maxnc3D]; N3 = new int [maxnc3D]; S3 = new int [maxnc3D];
  E = new boolean[maxnc3D]; // to track which corners have been explored
  
  //Setup3D Graph
  setup3DGraph(cl, bl, ht);
  
  //showFloor();   
 }  
 
 void setup3DGraph(ArrayList<pt2> cl, ArrayList<pt2> bl, float h) {
 
   HashMap<String,Integer> vMap = new HashMap<String,Integer>();
   
   int face = 0; int loopOrigin = nv3D;
   boolean isLoop = true; int i=0; //index to track corner element
   int numElements = 0, stVID = 0, stCID = 0;
     
    /*
   //Print 2D Corner List   
   println();
   for (int j=0; j<cl.size();j++) {
    println("C: "+j+" : "+cl.get(j).x+","+cl.get(j).y); 
   }
   */
   
   //traverse the 2D cornerList
   while(true) {
     //println("Corner: "+cl.get(i).x+","+cl.get(i).y);
     //vMap.put(cl.get(i).x+","+cl.get(i).y, nv3D++);
     //println("Map Entry: "+i+vMap.containsKey(cl.get(i).x+","));
          
     if (!vMap.containsKey(cl.get(i).x+","+cl.get(i).y)) { //create new vertices if vMap doesn't already contain this vertex
     
       //print("i: "+i); println(" Created two corners at: "+nv3D+" , "+(nv3D+1));
       stVID = nv3D;
       //1. Create two vertices for each 2D corner
       pt v1 = new pt(cl.get(i).x, cl.get(i).y,h); G3[nv3D] = v1; vMap.put(cl.get(i).x+","+cl.get(i).y,nv3D); nv3D++;
       pt v2 = new pt(cl.get(i).x, cl.get(i).y,0); G3[nv3D] = v2; nv3D++;
       
       i++; numElements++;
       stCID = nc3D;
       
     } else 
     {
      //Vertex is already in map, so end of loop
       //println("End of loop. Face: "+face+" has "+numElements+" elements.");
       //println("loopOrigin: "+loopOrigin+" i :"+i);
       //println("stVID: "+stVID+" stCID: "+stCID);
      //2. Create six corners for each 2D vertex
          
      for (int v = 0; v < numElements; v++) {
      
        //Vertices 
        V3[nc3D] = nc3D/3; V3[nc3D + 1] = nc3D/3; V3[nc3D + 2] = nc3D/3; 
        V3[nc3D + 3] = nc3D/3 + 1; V3[nc3D + 4] = nc3D/3 + 1; V3[nc3D + 5] = nc3D/3 + 1; 
               
        //Swing
        S3[nc3D] = nc3D + 1; S3[nc3D+1] = nc3D+2; S3[nc3D+2] = nc3D; 
        S3[nc3D+3] = nc3D + 4; S3[nc3D+4] = nc3D + 5; S3[nc3D+5] = nc3D + 3; 
        
        //Next 
        //N3[nc3D+1] = stCID +(6*v +1 + 4)%(6*numElements);
        N3[nc3D] = stCID + (6 + 6*v)%(6*numElements); N3[nc3D+1] = stCID +(6*(numElements - 1) + 6*v + 2)%(6*numElements); N3[nc3D+2] = stCID +(6*v +2 + 2)%(6*numElements); 
        N3[nc3D+3] = stCID +(6*(numElements - 1) + 6*v + 3)%(6*numElements); N3[nc3D+4] = stCID +(6*v + 4 +7)%(6*numElements); N3[nc3D+5] = stCID +(6*v + 5 -4)%(6*numElements);  
   
        //Increment number of corners
        nc3D = nc3D + 6;     
      }
  
       loopOrigin = i; 
       i++; face++; numElements = 0;
     }
   
     if (i >= cl.size()) break;
   }
   
   
   /*
   //Check bridge list contents
   println("vMap Size:"+vMap.size());
   Iterator itr = vMap.keySet().iterator();
    while(itr.hasNext()){
      String key   = (String) itr.next();
      int value = vMap.get(key);
      println(key+" : "+value);
    }
   */
   
   numWC = nc3D;
   
   for (int j=0; j<bl.size(); j=j+2) {
    //println("B "+j+" Pt: "+bl.get(j).x+","+bl.get(j).y+" In Map: "+vMap.containsKey(bl.get(j).x+","+bl.get(j).y));
    //println("B "+j+" Pt: "+bl.get(j).x+","+bl.get(j).y+" In Map: "+vMap.get(bl.get(j).x+","+bl.get(j).y)); 

    //Find vertex ids for making bridge edge
     int v1 = vMap.get(bl.get(j).x+","+bl.get(j).y);
     int v2 = vMap.get(bl.get(j+1).x+","+bl.get(j+1).y);
     
     
    //Find corner ids
     int c1 = v1*3; int c2 = v2*3; //ceiling
     int c3 = v1*3 + 3; int c4 = v2*3 + 3; //floor
     
    
    //Create two new corners to create a new bridge edge 
    //println("V: "+v1+","+v2+" C:"+c1+","+c2);
          
      addBridgeEdge(c1,c2, v1, v2);
      addBridgeEdge(c3,c4,v1+1, v2+1);
   }
   
   //Find out normal to the top face
   int stTopC = 0;
   topNormal = U(N(c3Vec(stTopC),M(c3Vec(p3(stTopC)))));
   
   int curC = 0;
   float tVol = 0;
    while(true) {
      float incVol = m(c3Vec(curC),M(c3Vec(p3(curC))),topNormal);
      tVol += incVol;
      //println("C: "+curC+" Vol: "+incVol);
      curC = n3(curC);
      if (curC == stTopC) break;
    }
   
   //println(tVol);
   //topNormal = (tVol > 0)? topNormal : M(topNormal);
   
 }
 
 void addBridgeEdge(int stCorner, int endCorner, int stV, int endV) {
   //println("........Adding edge with non-dangling corners: "+stCorner+" -> "+endCorner);
   
    //Step1: Save next and swing fields of these corners
    int stOldS = s3(stCorner), endOldS = s3(endCorner);
    int stOldP = p3(stCorner), endOldP = p3(endCorner);
  
    //Step2: Create two new corners;
    int fc = nc3D++ ; int sc = nc3D++;
    V3[fc] =  stV; V3[sc] = endV;
   
    //Step3: Link next and swing fields for the two corners
    N3[fc] = endCorner; N3[sc] = stCorner;
    S3[fc] = stOldS; S3[sc] = endOldS;
  
    //Step4: Update fields of affected old corners
    S3[stCorner] = fc; S3[endCorner] = sc;
    N3[endOldP] = sc; N3[stOldP] = fc;
 }
 
  //Support v, n, s, p, u, z operations
 int v3(int c) {return V3[c];}
 int n3(int c) {return N3[c];}
 int s3(int c) {return S3[c];}
 int z3(int c) {return S3[N3[c]];}
 int p3(int c) {return S3[N3[S3[c]]];}
 int u3(int c) {return N3[S3[N3[c]]];}
 pt g3(int c) {return G3[v3(c)];}


void updateHeight(float h) {
 //Go through all the vertices, and update height of alternate ones 
  for (int i=0; i<nv3D; i=i+2) {
    G3[i].z = h;
  }
  
}


//returns the vector associated with half-edge / corner
 vec c3Vec(int c) {
   return V(g3(c),g3(n3(c)));
 }
 
 
 //returns the positive swept angle between two corners
 float c3Angle(int c, int d) {
  return angle(c3Vec(c), c3Vec(d));
 }


 
 pt c3Pos(int c) {
   //Vertex position for easier troubleshooting
   //return G3[V3[c]]; 
   
   //Use normal to the face to check whether edge is convex or concave
   float isConvex = m(c3Vec(c),M(c3Vec(p3(c))),topNormal);
   float ang = angle(c3Vec(c),M(c3Vec(p3(c))))/2;
   vec offsetV = U(A(U(c3Vec(c)), U(M(c3Vec(p3(c))))));
   
   //Identify if a corner is on the bottom including the bridge edge corners
   if ((c%6 == 3) || ( (c - numWC)/2 >= 0 && (((c - numWC)/2)%2 == 1)   ) ) {
     pt newC = (isConvex < 0 )? P(g3(c),10,offsetV): P(g3(c),10,M(offsetV)); 
     return newC;
   }
   
   //Base Case: other than bottom corners
   pt newC = (isConvex >= 0 )? P(g3(c),10,offsetV): P(g3(c),10,M(offsetV));
   return newC;
 }
 
 int pickVertex(pt click){
   int selV = -1;
   float minD = 999999;
   
  for (int i=0; i<nv3D; i++){
   //println("V "+i+" : "+modelX(G3[i].x,G3[i].y,G3[i].z)+","+modelY(G3[i].x,G3[i].y,G3[i].z)+","+modelZ(G3[i].x,G3[i].y,G3[i].z));
   float x = modelX(G3[i].x, G3[i].y, G3[i].z);
   float y = modelY(G3[i].x, G3[i].y, G3[i].z);
   float z = modelZ(G3[i].x, G3[i].y, G3[i].z);
   
   float curDist = sqrt(sq(click.x - x) + sq(click.y - y) + sq(click.z - z));
   if (curDist < minD) {
      minD = curDist;
      selV = i; 
   } // end of min check
   
  } // end of for loop 
   //println("Selected V: "+selV);
   return selV;
 }
 
 int pickCorner(int v, pt click){
   
   //1: Find the corner whose vertex matches v
   int c = 0;
   for (c = 0; c<nc3D; c++) {
    if (v3(c) == v) break; 
   }
   //println("Matching Corner: "+c);
   
   //2. Swing around the corner to select best fit (min projected distance)
   int stC = c; float minDist = 999999; int selC = c; 
   while (true) {
     //Find location of current corner
       float cx = modelX(g3(c).x, g3(c).y, g3(c).z);
       float cy = modelY(g3(c).x, g3(c).y, g3(c).z);
       float cz = modelZ(g3(c).x, g3(c).y, g3(c).z);
       pt cpt = P(cx,cy,cz);
  
     //Find location of next corner
       float nx = modelX(g3(n3(c)).x, g3(n3(c)).y, g3(n3(c)).z);
       float ny = modelY(g3(n3(c)).x, g3(n3(c)).y, g3(n3(c)).z);
       float nz = modelZ(g3(n3(c)).x, g3(n3(c)).y, g3(n3(c)).z);
       pt npt = P(nx,ny,nz);
    
     //Find location of previous corner
       float px = modelX(g3(p3(c)).x, g3(p3(c)).y, g3(p3(c)).z);
       float py = modelY(g3(p3(c)).x, g3(p3(c)).y, g3(p3(c)).z);
       float pz = modelZ(g3(p3(c)).x, g3(p3(c)).y, g3(p3(c)).z);
       pt ppt = P(px,py,pz);
       
      //Find forward vector, previous vector, clicked vector
     vec fVec = U(V(cpt,npt)); vec pVec = U(V(cpt,ppt)); vec clickVec = V(cpt,click);
     
     //Find projected distance to the clicked point
     float projD = abs(m(clickVec,fVec,pVec));
     
     if (projD < minDist) {
      minDist = projD; selC = c; 
     }
     
     c = s3(c);
     if (c == stC) break;
     
   }
      
   return selC;
 }
 
 
 void setCorner(int c) { pc = c; }
 int selectedCorner() { return pc; }
 
 void showCorner(int c, color clr) {
    
    fill(clr);
    //text(Integer.toString(c),cPos(c).x,cPos(c).y);
    pt P = c3Pos(c);
    show(P,2);
    
 }  
 
 void showCeiling() {
   
   beginShape(); fill(yellow);
   int stCorner = 0;
   int c = 0;
   while (true) {
     v(g3(c));
     c = n3(c);
     if (c == stCorner) break;
   }
   
   endShape();
   
 }
 
void showTopV() {
   
   for (int i=0; i<nv3D; i = i+2) {
     show(G3[i],Integer.toString(i)); 
    //println("V #"+i+" "+G3[i].x+","+G3[i].y+","+G3[i].z);
   }   
 }
 
 void showTopC() {
   
   for (int i=0; i<numWC; i = i+6) {
     showCorner(i,red);
    //show(c3Pos(i),Integer.toString(i)); 
    //println("V #"+i+" "+G3[i].x+","+G3[i].y+","+G3[i].z);
   }   
 }
 
 void showSpecial(int v) {
      pt vpt = G3[v];
      show(vpt,2);    
 }
 
  void showAllCorners() {
   
     showCorner(25,red);
     pt cLoc = c3Pos(25);
     //println(cLoc.x+","+cLoc.y+","+cLoc.z+" X: "+modelX(cLoc.x,cLoc.y,cLoc.z)+"Y: "+modelY(cLoc.x,cLoc.y,cLoc.z)+"Z: "+modelZ(cLoc.x,cLoc.y,cLoc.z));    
 }
 
 void showFloor() {
   
   beginShape(); fill(lgrey);
   int stCorner = 3;
   int c = 3;
   while (true) {
     v(g3(c));
     c = n3(c);
     if (c == stCorner) break;
   }
   
   endShape();
   
 }
 
 void showWalls() {
   
   stroke(grey);
     //Initialize all corners to not explored
    for (int i=0; i<nc3D; i++) {
     E[i] = false; 
    }
    
    //Start with corner # 1, and complete the wall loop
    
    for (int i=1; i<numWC ; i=i+6) {
      int curCorner = i;
      fill(green);
      beginShape(); 
      while (true) {
        v(g3(curCorner));
        E[curCorner] = true;
        curCorner = n3(curCorner);
        if (curCorner == i) break;
      }
        v(g3(i));
        endShape();  
    }
     
 }
  
 void display(){
   
   if (pc >= 0) { 
       showCorner(pc,red);
       showCorner(n3(pc),blue);
       showCorner(s3(pc),orange);
       //if (s(pc) != pc) {displayCorner(s(pc),green);}  
   }
 }
 
 String toString(){
    String pre = "\t", post = "\n";
    StringBuilder res = new StringBuilder("X Graph {\n");
    res.append(pre).append("| Vertex || x      | y      | z      |").append(post);
    for(int i = 0; i < nv3D; i++){
      res.append(pre).append(String.format("| %6d || %6.0f | %6.0f | %6.0f |", i, G3[i].x, G3[i].y, G3[i].z)).append(post);
    }
    
    
    res.append(post).append(pre).append("| Corner ||  V |  N |  S |").append(post);
    
    for(int i = 0; i < nc3D; i++){
      res.append(pre).append(String.format("| %6d || %2d | %2d | %2d |", i, V3[i], N3[i], S3[i])).append(post);
    }
    
    res.append("}");
    return res.toString();
   }
 
}
