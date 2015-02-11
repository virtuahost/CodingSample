import java.util.Iterator;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Stack;
import java.util.EmptyStackException;

class PlanarGraph {

 //structure to handle vertices
 int pv =0, iv=0, nv = 0;                  // picked vertex index, insertion vertex index, number of vertices, deleted verticies
 int maxnv = 1024;                         //  max number of vertices

 int closeRange = 15;                      //range within which mouse clicked is considered to be on the vertex, also vertex radius
 int swRange = closeRange+5;
 pt2[] G = new pt2 [maxnv];  
 boolean[] DG = new boolean[maxnv]; //to track deleted vertices
 boolean[] EG = new boolean[maxnv]; //to track explored vertices
   
 //structure to handle corners
 int pc = -1, ic=0, nc=0;  //picked corner index, insertion corner index, number of corners, deleted corners
 int maxnc = 6*maxnv;        //max number of corners
 float dist = r, lineDist = 12 + closeRange;
 
 //Fill Color
 color fillC; int extraV = 5;
 
 int[] V = new int[maxnc]; 
 int[] N = new int[maxnc];
 int[] S = new int[maxnc];
 boolean[] D = new boolean[maxnc]; //to track deleted corners
 boolean[] E = new boolean[maxnc]; //to track explored corners
 
 PlanarGraph(pt2 p1, pt2 p2, pt2 p3){ //Nick
   nv = 3;
   G[0] = P2(p1); G[1] = P2(p2); G[2] = P2(p3);
   
   nc = 6; 
   V[0] = 0; V[1] = 0; V[2] = 1; V[3] = 1; V[4] = 2; V[5] = 2;
   N[0] = 2; N[1] = 5; N[2] = 4; N[3] = 1; N[4] = 0; N[5] = 3;
   S[0] = 1; S[1] = 0; S[2] = 3; S[3] = 2; S[4] = 5; S[5] = 4;
   D[0] = false; D[1] = false;D[2] = false; D[3] = false;D[4] = false; D[5] = false;
 } 
 
 
 PlanarGraph(pt2 p1, pt2 p2){ //Nick
   nv = 2;
   G[0] = P2(p1); G[1] = P2(p2);
   
   nc = 2; V[0] = 0; V[1] = 1;
   N[0] = 1; N[1] = 0;
   S[0] = 0; S[1] = 1;
   D[0] = false; D[1] = false; 
 } 
 PlanarGraph(pt2 p1, pt2 p2, pt2 p3, pt2 p4){ //Nick
 
   int v1 = createVertex(p1);
   int v2 = createVertex(p2);
   int v3 = createVertex(p3);
   int v4 = createVertex(p4);

   int c11 = createCorner(v1);
   int c12 = createCorner(v2);
   int c13 = createCorner(v3);
   int c14 = createCorner(v4);
   
   
   int c21 = createCorner(v1);
   int c22 = createCorner(v2);
   int c23 = createCorner(v3);
   
   
   int c33 = createCorner(v3);
   int c34 = createCorner(v4);
   int c31 = createCorner(v1);
   
   N[c11] = c14;
   N[c12] = c11;
   N[c13] = c12;
   N[c14] = c13;
   
   N[c21] = c22;
   N[c22] = c23;
   N[c23] = c21;
   
   N[c33] = c34;
   N[c34] = c31;
   N[c31] = c33;
   
   S[c11] = c21;
   S[c21] = c31;
   S[c31] = c11;
   
   S[c12] = c22;
   S[c22] = c12;
   
   S[c13] = c33;
   S[c23] = c13;
   S[c33] = c23;
   
   S[c14] = c34;
   S[c34] = c14;
   
 } 
 
 void fillColor(color clr){
  fillC = clr;
 }
 
 int createVertex(pt2 pos){
   if(nv >= maxnv) return -1;
   int idx = nv;
   nv++;
   G[idx] = P2(pos);
   DG[idx] = false;
   return idx;
 }
 
 void deleteVertex(int vert){
   if(vert >= nv || vert < 0) return;
   DG[vert] = true; 
 }

 int createCorner(int vert){
   if(nc >= maxnc) return -1;
   int idx = nc;
   nc++;
   D[idx] = false;
   V[idx] = vert;
   N[idx] = -1;
   S[idx] = -1;
   return idx;
 }

 int createCorner(){
   return createCorner(-1);
 }

 void deleteCorner(int corner){
   if(corner >= nc || corner < 0) return;
   D[corner] = true; 
 }
 
 //Support v, n, s, p, u, z operations
 int v(int c) {return V[c];}
 int n(int c) {return N[c];}
 int s(int c) {return S[c];}
 int z(int c) {return S[N[c]];}
 int p(int c) {return S[N[S[c]]];}
 int u(int c) {return N[S[N[c]]];}
 
 pt2 g(int c) {return G[v(c)];}
 
 void moveVertex(int vertex, vec2 drag){
   if(vertex < 0 || vertex >= nv) return;
   G[vertex].add(drag);
 }
 void moveFace(int c, vec2 drag) {
   if(c < 0 || c >= nc || D[c]) return;
   for(int i = 0; i < nv; i++) EG[i] = false;
   int i = c;
   do {
     if(!EG[v(i)]) G[v(i)].add(drag);
     EG[v(i)] = true;
     i = n(i);
   } while(i!=c);
 }
 
 void setCorner(int c) { pc = c; }
 int selectedCorner() { return pc; }

 //returns the index of Vertex. If the point click is too far away, returns -1
 boolean closeToVertex(pt2 click) {
  return closeToVertex(pickVertex(click, -1),click); 
 }

 boolean closeToVertex(int vertex, pt2 click) {
   if (d(click,G[vertex]) <= closeRange ) {
    return true;
    } else {
      return false;
    }
 }
 
 //returns the index of Vertex
 int pickVertex(pt2 click, float range){ 
    int result = 0;
    for (int i = 0; i<nv; i++) {
      if(DG[i])continue;
     if (d(click,G[result]) > d(click,G[i])) { 
       result = i; 
       pv = i;
       }
    }
    
  //check if the picked vertex is within close range
  if (d(click,G[result]) <= closeRange || range <= 0) {
    return result;
    } else {
      return -1;
    }
 }
 
 //Sumit
 int pickCorner(pt2 click) {return pickCorner(pickVertex(click, -1), click);}//return the closest corner based on mouse click
 
 //pickCorner: gives the corner based on selected vertex and point of mouse click
 //Calculate angle ( 0 to 2PI) for each corner. Calculate delta angle between corner and clicked point. The corner with the largest delta angle wins
 int pickCorner(int vertex, pt2 click) { 
   //println("pickCorner("+vertex+", pt2: "+click.x+","+click.y+")");
   int i;
   for (i=0; i<nc; i++) {
    if (!D[i] && v(i) == vertex) break;
   } 
   
   //println("St Corner: "+i);
   //i is now the index of one of the corners
   
   //Step1: Calculate angle of the clicked point wrt vertex
   float clickedAngle = positive(atan2(click.y - G[vertex].y,click.x - G[vertex].x));
   //println("Clicked Angle: "+degrees(clickedAngle));
   //Check if there's only one corner (Dangling Vertex). If so, return the corner
   //if (i == s(i)) { pc = i; return i;}
   
   //Step2: Compare swept angle from one corner to another with swept angle from one corner to clicked point.
   //The chosen corner will always have swept angle to the next corner greater than swept angle to the clicked point
   int stCorner = i;
   vec2 clickVec = V2(G[vertex],click);
   while (true) {
     float angleToNextCorner = cAngle(i,s(i));
     float angleToClickPt = positive(angle(cVec(i),clickVec));
     //println("i: "+i+" AngCorner: "+degrees(angleToNextCorner)+" AngClick: "+degrees(angleToClickPt));
     if (angleToNextCorner > angleToClickPt) break;
     i = s(i);
     if (i == stCorner) break;
   }
      
   pc = i;
   return i; 
 }
 
 //returns the vector associated with half-edge / corner
 vec2 cVec(int c) {
   return V2(G[v(c)],G[v(n(c))]);
 }
 
 //returns the positive angle associated with half-edge / corner
 float cAngle(int c) {
  return positive(angle(cVec(c)));
 }
 
 //returns the swept angle between two corners
 float cAngle(int c, int d) {
  return positive(angle(cVec(c), cVec(d)));
 }
 
 //return the corner position
 pt2 cPos(int c) {
   //Calculate angle between corner and swing corner
   float ang = cAngle(c,s(c));
   //println(" cs ang: "+degrees(ang));
   
   //Edge Case: Dangling vertex
   if ((ang%(TWO_PI)) == 0) return P2(G[v(c)], S(lineDist ,R2(U(cVec(c)), PI)) ) ;
   if ((ang%(PI)) == 0) return P2(G[v(c)], S(lineDist ,R2(U(cVec(c)))) ) ;
   
   //Cases except Edge case
   float sVal = dist/(det(U(cVec(c)), U(cVec(s(c)))));
   //println("S Value: "+sVal);
   return P2(G[v(c)], S(sVal, W(U(cVec(c)),U(cVec(s(c))))));
   //return P2(0,0);
 }
 
 //print corner positions for debugging purpose
 void printCorners() {
    for (int i=0; i<nc; i++) {
    println("C:"+i+" "+cPos(i).x+","+cPos(i).y); 
    }
 }
 
 //show the corner in red, next in blue, swing(clockwise) in green.
 void displayCorner(int c, color clr) {
    stroke(clr); fill(clr);
    //text(Integer.toString(c),cPos(c).x,cPos(c).y);
    pt2 p = cPos(c);
    //println(p);
    ellipse(p.x,p.y,5,5); 
 }  
   
 void addEdge(pt2 start, pt2 end) {
    //println("addEdge("+start.x+","+start.y+" -> "+end.x+","+end.y+")");
    
    boolean closeVertexSt = closeToVertex(start);  boolean closeVertexEnd = closeToVertex(end);
    int stVertex = pickVertex(start, -1), endVertex = pickVertex(end, -1);
   
   //Case1: starting point is an existing vertex, and ending point is a new point
   if (closeVertexSt && !closeVertexEnd) {addDangleCorners(stVertex, end);}
   
   //Case2: starting point is an existing vertex, and ending point is an existing vertex
   if (closeVertexSt && closeVertexEnd && (stVertex != endVertex)) {addFaceCorners(stVertex,endVertex);}
   
   //Case3: starting point is projection on existing edge, and no ending point
    if (!closeVertexSt) {addSplitCorners(start);}
   
 }
 
 void addDangleCorners(int stVertex, pt2 end) {
  //print("Add Edge with Dangle Corners. St Vertex: "+stVertex+" End Pt: "+end.x+","+end.y); 
  
  //Find corner associated with this vertex, and endPoint
  int stCorner = pickCorner(stVertex,end);
  //Step1: add new vertex for end point
    int newV = createVertex(end);
  //Step2: Save p, s for the starting corner in temporary location
    int oldS = s(stCorner), oldP = p(stCorner);
    
  //Step3: Create two new corners
  int fc = createCorner(v(stCorner));
  int sc = createCorner(newV);
  
  //Link next and swing fields for the two corners
  N[fc] = sc; N[sc] = stCorner;
  S[fc] = oldS; S[sc] = sc;
  
  //Update fields of affected old corners
  S[stCorner] = fc;
  N[oldP] = fc;
 }

 void addFaceCorners(int vertexSt, int vertexEnd) {
  //println("Add Edge with Face Corners. St V: "+vertexSt+" End V: "+vertexEnd); 
  
  //Step1: Find corners associated with these two vertices
  int stCorner = pickCorner(vertexSt,G[vertexEnd]);
  int endCorner = pickCorner(vertexEnd,G[vertexSt]);

  //New Face will be created. Four Cases:
  //Case1: Both corners are dangling
  //Case2: Starting corner is dangling
  //Case3: End corner is dangling
  //Case4: Neither corner is dangling
  
  //Case1:  Both corners are dangling
  if ( (stCorner == s(stCorner)) && (endCorner == s(endCorner))) {
    //println("........Adding edge with two dangling corners: "+stCorner+", "+endCorner);
    //Save old p and n values of st and end corners
    int stOldP = p(stCorner); int endOldP = p(endCorner);
    
   //create two new corners
   int fc = createCorner(vertexSt);
   int sc = createCorner(vertexEnd);
  
   //Link next and swing field of new corners 
   N[fc] = endCorner; N[sc] = stCorner;
   S[fc] = stCorner; S[sc] = endCorner;
   
   //Update affected corners
    S[stCorner] = fc; S[endCorner] = sc;
    N[endOldP] = sc; N[stOldP] = fc;
  }
  
  //Case2: Starting corner is dangling. End Corner is not
  else if ( (stCorner == s(stCorner)) && (endCorner != s(endCorner))) {
    //println("........Adding edge with dangling starting corner: "+stCorner+" -> "+endCorner);
     addFaceOneDanglingCorner(stCorner,endCorner);
  }
  
  //Case3: End corner is dangling. Starting Corner is not
  else if ((stCorner != s(stCorner)) && (endCorner == s(endCorner))) {
   //println("........Adding edge with dangling end corner: "+stCorner+" -> "+endCorner);
     addFaceOneDanglingCorner(endCorner,stCorner);
  }
  
  
  //Case4: Neither corner is dangling
  //if ((stCorner != s(stCorner)) && (endCorner != s(endCorner))) {
  else {
  //println("........Adding edge with non-dangling corners: "+stCorner+" -> "+endCorner);
  //Step1: Save next and swing fields of these corners
    int stOldS = s(stCorner), endOldS = s(endCorner);
    int stOldP = p(stCorner), endOldP = p(endCorner);
  
  //Step2: Create two new corners;
    int fc = createCorner(vertexSt);
    int sc = createCorner(vertexEnd);
  
  //Step3: Link next and swing fields for the two corners
    N[fc] = endCorner; N[sc] = stCorner;
    S[fc] = stOldS; S[sc] = endOldS;
  
  //Step4: Update fields of affected old corners
    S[stCorner] = fc; S[endCorner] = sc;
    N[endOldP] = sc; N[stOldP] = fc;
  }
  
 }
 
 //add Edge/Face involving one dangling corner (dc), and another non-dangling corner(ndc)
 void addFaceOneDanglingCorner(int dc, int ndc) {
    //Save old p and n values of st and end corners
    int stOldN = n(dc); int endOldN = n(ndc);
    int endOldU = u(ndc);
    
   //create two new corners
   int fc = createCorner(v(dc));
   int sc = createCorner(v(ndc));
  
   //Link next and swing field of new corners 
   N[fc] = stOldN;   N[sc] = endOldN;
   S[fc] = dc; S[sc] = ndc;
   
   //Update affected corners
    S[endOldU] = sc; S[dc] = fc;
    N[dc] = sc; N[ndc] = fc; 
 }
 
 void addSplitCorners(pt2 st) {
   //println("Add Edge with Split Corners. St Point: "+st.x+","+st.y);
   
   pt2 p = closestProjection(st);
   if(d(p,st)>swRange) return;
   if (pc == -1) {println("Projection on any corner not possible...");}
   else {
     
     //println("The projected point is: ("+p.x+","+p.y+")");
     int stCorner = pc;
   
    //Step1: add new vertex for end point
    int newV = createVertex(p);
    
    //Step2: Save p, s for the starting corner in temporary location
    int oldP = p(stCorner), oldZ = z(stCorner), oldN = n(stCorner), oldU = u(stCorner);
    
    //Step3: Create two new corners
    int fc = createCorner(newV);
    int sc = createCorner(newV);
  
    //Step4: Link next and swing fields for the two corners
    N[fc] = oldN; N[sc] = oldU;
    S[fc] = sc; S[sc] = fc;
  
    //Step5: Update fields of affected old corners
    N[stCorner] = fc;
    N[oldZ] = sc; 
   }
  
 }

 pt2 closestProjection(pt2 click) { 
   //This function provides the closest projected point from clicked point
   // It also updates corner(pc) that has the projected point
   
   pc = -1;
 
   //For each corner, find out starting point, and ending point. Evaluate if clicked point lies in the interior of SE.
   //If it does, find the projected distance. Pick the corner based on shortest projected distance
   
   float minDist = 9999;
   pt2 projection = P2(0,0);
   for (int i=0; i<nc; i++) {
     if (D[i]) continue;  
     //Starting point is G[v(i)], and ending point is G[v(n(i))]
     if (projectsBetween(click, G[v(i)], G[v(n(i))])) {
        float d = disToLine(click, G[v(i)], G[v(n(i))]);
        if (d < minDist) {
            minDist = d;
            pc = i;
            projection = projectionOnLine(click, G[v(i)], G[v(n(i))]);
        }
     }
   }
   
   //println("The projected point is: ("+projection.x+","+projection.y+")");
   return projection;
 }



 void removeEdge(pt2 click) {
   int v = pickVertex(click, closeRange);
   int c = -1;
   pt2 proj = null;
   if(v == -1){
     proj = closestProjection(click);
     if(proj == null || d(proj,click) > closeRange) return;
     c = pc;
     v = pickVertex(proj, closeRange);
     
   } 
   if(v != -1){
     c = pickCorner(v, click);
   }
   
  if(v != -1){ //clicked on a vertex
    if(s(c)==c){
      if(s(n(c))==n(c)) return; // two dangling verts
      //Case1: Dangle vertex  
      //removes vertex and an edge
      removeDanglingEdge(c);
    }else if(s(s(c))==c){
      //Case2: Vertex with two edges
      //remove vertex and one of the two edge. Update the corners accordingly
      
      if(n(n(c))==p(c)){//inside triangle that is about to collapse to a line
        removeFullEdge(n(c));
      }
      if(n(n(s(c)))==p(s(c))){//outside collapsing triangle
        removeFullEdge(n(s(c)));
      }
      
      int p = p(c), n = n(c), s = s(c);
      int sp = p(s), sn = n(s);
      
      
      N[p] = n;
      N[sp] = sn;
      
      deleteVertex(v);
      deleteCorner(c);
      deleteCorner(s);
    }
    //Case3: Vertex with 3+ edges
    //Ignore
  } else { // clicked on an edge
    int z = z(c);
    //Case4: Remove edge with one dangle vertex
    //Detect that the vertex is dangling, and remove both edge, as well as vertex
    if(s(c)==c){
      if(s(z)==z) return; // two dangling verts
      //c is dangling vert
      removeDanglingEdge(c);
    } else if(s(z)==z) {
      //z is dangling vert
      removeDanglingEdge(z);
    } else {
      //Case5: Remove edge with both existing vertices
      //Check whether graph still stays connected
      
      int u = u(c);
      int i = n(u);
      while(true){
        if(i == c) return; //would be disconnected
        if(i == z) break; // found alternate path its safe
        if(i == u) {
          print("Did not find z or c before finding full loop, this should never happen");
          exit(); //something terrible happened
        }
        i = n(i);
      }
      
      removeFullEdge(c);
    }
  }
 }
 
 void removeFullEdge(int c){
  int z = z(c);
  int s = s(c), zs = s(z);
  int u = u(c), zu = u(z);
  int p = p(c), zp = p(z);
  
  S[u] = s;
  S[zu] = zs;
  N[p] = u;
  N[zp] = zu;
  
  deleteCorner(c);
  deleteCorner(z);
 }
 
 void removeDanglingEdge(int c){
    //removes vertex and an edge
    int p = p(c), n = n(c);
    int pp = p(p), ps = s(p);
    int v = v(c);
    
    N[pp] = n;
    S[n] = ps;
    
    deleteVertex(v);
    deleteCorner(p);
    deleteCorner(c);
 }
 
 float area(int c) { return abs(sArea(c)); }
 float sArea(int c) {
   float sum = 0;
   int i = c;
   do {
     sum += det(V2(G[v(i)]),V2(G[v(n(i))])); 
     i = n(i);
   } while(i!=c);
   return sum/2;
 }
 
 
 int getInfiniteFace(){
   for(int i = 0; i < nc; i++) E[i] = false;
   for(int i = 0; i < nc; i++) {
     if(E[i] || D[i]) continue;
     clearFace(i);
     if(sArea(i) <= 0) return i; //Infinite face should be the only one labeled counter clockwise (negative signed area
   }
   return 0;
 }
 void clearFace(int c){
   int i = c;
   do {
     E[i] = true;
     //print(i);
     i = n(i);
   } while(i!=c);
 }
 int pickFace(pt2 click){ // return a corner from the face containing the click
   int inf = getInfiniteFace();
   for(int i = 0; i < nc; i++) E[i] = false;
   //println("Clearing "+inf);
   clearFace(inf);
   for(int i = 0; i < nc; i++) {
     if(E[i] || D[i]) continue;
     if(inFace(click,i)) return i;
   }
   return inf;
 }
 boolean inFace(pt2 click, int corner){ // check if the click is in the face this corner is connected to
   // E must be false for the entire face and will be true for the entire face after calling
   E[corner] = true;//no triangle since it has a shared end point for these two
   E[p(corner)] = true;
   ///print("Face "+corner);
   int base = n(corner);
   int total = 0;
   while(!E[base]){
     if(inTriangle(click, corner, base)) total++;
     E[base] = true;
     //print(base);
     base = n(base);
   }
   //println(total);
   return total%2 != 0;
 } 
 boolean inTriangle(pt2 p, int t, int l) {
   pt2 a = G[v(t)];
   pt2 b = G[v(l)];
   pt2 c = G[v(n(l))];
   
   //Barycentric coordinate method from: http://www.blackpawn.com/texts/pointinpoly/
   
    // Compute vectors        
    vec2 v0 = V2(a,c);
    vec2 v1 = V2(a,b);
    vec2 v2 = V2(a,p);
    
    // Compute dot products
    float dot00 = dot(v0, v0);
    float dot01 = dot(v0, v1);
    float dot02 = dot(v0, v2);
    float dot11 = dot(v1, v1);
    float dot12 = dot(v1, v2);
    
    // Compute barycentric coordinates
    float invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    float v = (dot00 * dot12 - dot01 * dot02) * invDenom;
    
    //print(" ("+u+","+v+") ");
    
    // Check if point is in triangle
    return (u >= 0) && (v >= 0) && (u + v < 1);
 }
 
 
  boolean checkSidewalk(int c){
    int i = c;
    do {
      if(d(swExit(i),G[v(i)]) >= d(swEntry(n(i)),G[v(i)])) return false;
      i = n(i);
    } while(i != c);
    return true;
  }
  
  void fillCurve(int c, color r){
    if(!checkSidewalk(c)) return; //sidewalk cant be drawn
    int i = c;
    stroke(fillC); strokeWeight(1); fill(fillC);
    beginShape();
    
    while(true) {
      (swEntry(c)).v2();  
      
      if (!(cAngle(c, s(c)) < PI && cAngle(c, s(c)) != 0)) { //extra arc points needed
    
         int extraVertices = extraV;
         float deltaAng = cAngle(c,p(c))/(extraVertices+1); //println("delta ang: "+degrees(deltaAng));
         pt2 curPt = swEntry(c);

         for (int k=1; k<extraVertices+1;k++){
     
            pt2 nextPt = P2(G[v(c)], R2(V2(G[v(c)],swExit(c)),cAngle(c,p(c)) - deltaAng*k));
            //curPt.v2(); 
            (nextPt).v2();
            //edge(curPt,nextPt);
            curPt = nextPt;
            //curPt.show();
          }
        //edge(curPt,swEntry(c)); 
       
       } // end of create arc point
 
      (swExit(c)).v2();
      c = n(c);
      if (c == i) break;      
    
  }
    endShape();
  }
  
  void drawSidewalk(int c, color r){
    if(!checkSidewalk(c)) return; //sidewalk cant be drawn
    int i = c;
    stroke(r); strokeWeight(0.5);
    noFill();
    do {
      edge(swExit(i),swEntry(n(i)));
      swDraw(i);
      i = n(i);
    } while(i != c);
  }
  
  pt2 swInner(int c){
    pt2 v = G[v(c)];
    vec2 a = U(cVec(c));
    vec2 b = U(cVec(s(c)));
    return P2(v, S(swRange/det(a,b), W(a,b)));
  }
  
  pt2 swMid(int c){
    vec2 x = U(R2(cVec(c)));
    vec2 n = U(R2(cVec(p(c))));
    vec2 m = U(W(x,n));
    if(n2(m) == 0) m = U(M(cVec(c)));
    return P2(G[v(c)], S(swRange, m));
  }
  
  pt2 swEntry(int c){ //starting point of the arc on that corner
    if(cAngle(c, s(c)) < PI && cAngle(c, s(c)) != 0) return swInner(c);
    vec2 v = U(R2(cVec(p(c))));
    return P2(G[v(c)], S(swRange, v));
  }
  
  pt2 swExit(int c){ //ending point of the arc on that corner
    if(cAngle(c, s(c)) < PI && cAngle(c, s(c)) != 0) return swInner(c);
    vec2 v = U(R2(cVec(c)));
    return P2(G[v(c)], S(swRange, v));
  }
  
  void swDraw(int c){//draw an arc at c if needed
    if(cAngle(c, s(c)) < PI && cAngle(c, s(c)) != 0) return; // no arc needed
    
    int extraVertices = extraV;
    float deltaAng = cAngle(c,p(c))/(extraVertices+1);
    pt2 curPt = swExit(c);

    for (int i=1; i<extraVertices+1;i++){
     
      pt2 nextPt = P2(G[v(c)], R2(V2(G[v(c)],swExit(c)),deltaAng*i));
      
      edge(curPt,nextPt);
      curPt = nextPt;
      //curPt.show();
    }
      edge(curPt,swEntry(c));  
  }
  
  int faceCount(){
   int count = 0;
   for(int i = 0; i < nc; i++) E[i] = false;
   for(int i = 0; i < nc; i++) {
     if(E[i] || D[i]) continue;
       int j = i;
       count++;
       do {
         E[j] = true;
         j = n(j);
       } while (i != j);
   }
   return count;
  }
  
  color makeColor(float idx, float total){
    float zi=(idx)/(total); 
    return color(zi*256 ,(1.-zi)*256, sq(sq(1.-abs(0.5-zi)))*200 ); 
  }
 
 void showDebugCorner(int c) {
   swEntry(c).tag("O"+c, 0);
   swExit(c).tag("X"+c, 0);
   swMid(c).tag(Integer.toString(c), 0);
 }
 
 void getLoopCorners(Stack<pt2> cl, int loop) {
     int c = loop;
     boolean hasArc = false; pt2 loopArcSt = swEntry(c);
     while (true) {
        if (!E[c]) { // Check corner not already explored. End of loop check
          if(!checkSidewalk(c)) return; //sidewalk cant be drawn
            
          //Start with arc. Determine if you need an arc, and if yes - add additional vertices
          if( !(cAngle(c, s(c)) < PI && cAngle(c, s(c)) != 0) ) {  //check arc needed
            hasArc = true;
            //println("Arc needed at C: "+c);
            
            pt2 curSWEntry = new pt2(); curSWEntry.setTo(swEntry(c));
            cl.push(curSWEntry);
            //println("Entry Pt For C: "+c+" Pt: "+curSWEntry.x+","+curSWEntry.y);

            int extraVertices = extraV;
            float deltaAng = cAngle(c,p(c))/(extraVertices+1);

            pt2 curPt = swExit(c);

            for (int i=1; i<extraVertices+1;i++){ // add extra vertices
              pt2 nextPt = P2(G[v(c)], R2(V2(G[v(c)],swExit(c)),cAngle(c,p(c)) - deltaAng*i));
              pt2 newArcPt = new pt2(); newArcPt.setTo(nextPt);
              cl.push(newArcPt);
              //println("..Extra C: "+i+" Pt: "+newArcPt.x+","+newArcPt.y);
            } //end of extra vertices
          } // end check arc needed

          pt2 curSWExit = new pt2(); curSWExit.setTo(swExit(c));
          cl.push(curSWExit);          
          E[c] = true;
          
          //println(".......C: "+c+" Pt: "+curSWExit.x+","+curSWExit.y);
          
        } // end corner already explored
        
        c = n(c);
        if (c == loop) break;       
     }
     
     
     //Add the starting point again, to indicate loop is fully traversed
     pt2 loopOrigin = new pt2(); 
     if (hasArc) { loopOrigin.setTo(swEntry(loop));
     } else {loopOrigin.setTo(swExit(loop));}
     cl.push(loopOrigin);          
     
 }
 
 //Generate list of corner positions based on sidewalks
 ArrayList<pt2> cornerList(){
  
   ArrayList<pt2> al = new ArrayList<pt2>();
   
   Stack<pt2> cl = new Stack<pt2>(); 
   //Get infinite face
   int of = getInfiniteFace();
   for(int i = 0; i < nc; i++) E[i] = false; //set the explored corner list to all false
   
   //Get points from infinite face
   getLoopCorners(cl,of);
   stackToList(cl,al);
   
   
   //Traverse the remaining loops
   for(int i = 0; i < nc; i++) {  
     if(E[i] || D[i]) continue; //if corner has been explored or deleted, then ignore it
     getLoopCorners(cl,i);
     stackToList(cl,al);
   }
   
   /*
   //check ArrayList is as expected
   for (int j=0; j<al.size();j++) {
    println("AL: "+j+" : "+al.get(j).x+","+al.get(j).y); 
   } 
   */
   
   return al;
 }  
 
 void stackToList(Stack<pt2> cl, ArrayList<pt2> al) {
  try{  
    while (!cl.empty()) {
      al.add(cl.pop());
    } 
  } catch (EmptyStackException e) {
    }
 }
 
void getReverseCorners(Stack<pt2> cl, int loop) {
     int c = loop;
     boolean hasArc = false; pt2 loopArcSt = swExit(c);
     while (true) {
        if (!E[c]) { // Check corner not already explored. End of loop check
          if(!checkSidewalk(c)) return; //sidewalk cant be drawn
            
          //Start with arc. Determine if you need an arc, and if yes - add additional vertices
          if( !(cAngle(c, s(c)) < PI && cAngle(c, s(c)) != 0) ) {  //check arc needed
            hasArc = true;
            //println("Arc needed at C: "+c);
            
            pt2 curSWEntry = new pt2(); curSWEntry.setTo(swExit(c));
            cl.push(curSWEntry);
            //println("Entry Pt For C: "+c+" Pt: "+curSWEntry.x+","+curSWEntry.y);

            int extraVertices = extraV;
            float deltaAng = cAngle(c,p(c))/(extraVertices+1);

            pt2 curPt = swExit(c);

            for (int i=1; i<extraVertices+1;i++){ // add extra vertices
              pt2 nextPt = P2(G[v(c)], R2(V2(G[v(c)],swExit(c)),deltaAng*i));
              pt2 newArcPt = new pt2(); newArcPt.setTo(nextPt);
              cl.push(newArcPt);
              //println("..Extra C: "+i+" Pt: "+newArcPt.x+","+newArcPt.y);
            } //end of extra vertices
          } // end check arc needed

          pt2 curSWExit = new pt2(); curSWExit.setTo(swEntry(c));
          cl.push(curSWExit);          
          E[c] = true;
          
          //println(".......C: "+c+" Pt: "+curSWExit.x+","+curSWExit.y);
          
        } // end corner already explored
        
        c = p(c);
        if (c == loop) break;       
     }
     
     
     //Add the starting point again, to indicate loop is fully traversed
     pt2 loopOrigin = new pt2(); 
     if (hasArc) { loopOrigin.setTo(swExit(loop));
     } else {loopOrigin.setTo(swEntry(loop));}
     cl.push(loopOrigin);          
     
 }
 
 //Generate list of corner positions based on sidewalks
 ArrayList<pt2> reverseCList(){
  
   ArrayList<pt2> al = new ArrayList<pt2>();
   
   Stack<pt2> cl = new Stack<pt2>(); 
   //Get infinite face
   int of = getInfiniteFace(); //println("reverse face: "+of);
   for(int i = 0; i < nc; i++) E[i] = false; //set the explored corner list to all false
   
   //Get points from infinite face
   getReverseCorners(cl,of);
   stackToList(cl,al);
   
   //Traverse the remaining loops
   for(int i = 0; i < nc; i++) {  
     if(E[i] || D[i]) continue; //if corner has been explored or deleted, then ignore it
     getReverseCorners(cl,i);
     stackToList(cl,al);
   }
   
   /*
   //check ArrayList is as expected
   for (int j=0; j<al.size();j++) {
    println("AL: "+j+" : "+al.get(j).x+","+al.get(j).y); 
   } 
   */
   
   return al;
 }  
 
 
 //Generate list of bridge points
 ArrayList<pt2> bridgeList(){
   ArrayList<pt2> bl = new ArrayList<pt2>(); 
   ArrayList<Integer> tl = new ArrayList<Integer>();
   
   //Get infinite face
   int of = getInfiniteFace();
   for(int i = 0; i < nc; i++) E[i] = false; //set the explored corner list to all false
   
   //Create a queue to store corners
   Queue<Integer> q = new LinkedList<Integer>();
   
   //Traverse all loops starting from the infinite face
   int c = of; int bPt = -1;
   while(true) { //take element out of the queue, and traverse the loop
     //println("Begining C: "+c);
     if (!E[c]) {
       while(true) { //traverse one loop. Comes out at the original point
         q.add(c); E[c] = true;
         //println("T: "+c+" Pt: "+cPos(c).x+","+cPos(c).y);
         c = n(c);
         if (E[c]) break;
       } //end: traverse one loop
     } 
     
     if (E[c]) {
      //loop is over. Find out the bridge point
       while(true) {
         //println("loop is over");
         if (q.isEmpty()) break;
         c = q.poll(); //println(".....removing.."+c);
         bPt = s(c);
        //println("Swing to: "+bPt+" Pt: "+cPos(bPt).x+","+cPos(bPt).y);
        //if (!E[bPt]) {println("....found bridge..C: "+bPt);}
        if (!E[bPt]) break;
       } 
        //println("...moving ahead with: "+bPt+" Pt: "+cPos(bPt).x+","+cPos(bPt).y);
     }
     

     if (!E[bPt]) {
       //println("...adding bridge to list :"+bPt);
       //tl.add(c); tl.add(bPt);
       bl.add(swExit(c)); bl.add(swExit(bPt));
       c = bPt;
     }

     //println("......C at end: "+c);
     if (q.isEmpty()) break;
   }
   /*
   //Checking bridge corners
   for (int i=0; i<tl.size(); i++) {
    println("B "+i+" : "+tl.get(i)+" Pt: "+cPos(tl.get(i)).x+","+cPos(tl.get(i)).y); 
   }
   */
   
   /*
   for (int i=0; i<bl.size(); i++) {
    println("B "+i+" Pt: "+bl.get(i).x+","+bl.get(i).y); 
   }
   */
   
   return bl;
 }  
 
 
    
 //Display the graph
 void display(){
   int faces = faceCount();
   int face = 0;
   //fillCurve(1, red);
   for(int i = 0; i < nc; i++) E[i] = false;
   for(int i = 0; i < nc; i++) {
     // each edge will be drawn twice, 
     if(E[i] || D[i]) continue;
     face++;
     //drawSidewalk(i, makeColor(face, faces));
     
     fillCurve(i, makeColor(face, faces));
     // when implementing colored faces we can call a function to draw a single face here with a color.
      
     strokeWeight(1); 
     stroke(black); noFill();
     int curC = i;
     while (true) {
        int nextC = n(curC); 
        E[curC] = true;
        edge(G[v(curC)],G[v(nextC)]);
        if (nextC == i) break;
        curC = nextC;
     }
     
 
   }
   
   
   //show the vertices here;
   //stroke(black); fill(white);
   for(int i = 0; i < nv; i++) if(!DG[i]) G[i].tag(Integer.toString(i), closeRange);
   
   //show all corners here
   //for(int i = 0; i < nc; i++) {displayCorner(i,blue);}
   
   //show picked corner in red, next in blue, swing in green
   if (pc >= 0 && !D[pc]) { 
       displayCorner(pc,red);
       displayCorner(n(pc),blue);
       if (s(pc) != pc) {displayCorner(s(pc),green);}  
   }
   
 }  
      
   String toString(){
    String pre = "\t", post = "\n";
    StringBuilder res = new StringBuilder("PlanarGraph {\n");
    res.append(pre).append("| Vertex || x      | y      |").append(post);
    for(int i = 0; i < nv; i++){
      if(DG[i]) continue;
      res.append(pre).append(String.format("| %6d || %6.0f | %6.0f |", i, G[i].x, G[i].y)).append(post);
    }
    res.append(post).append(pre).append("| Corner ||  V |  N |  S |  v |  n |  s |  p |  u |  z |").append(post);
    for(int i = 0; i < nc; i++){
      if(D[i]) continue;
      res.append(pre).append(String.format("| %6d || %2d | %2d | %2d | %2d | %2d | %2d | %2d | %2d | %2d |", i, V[i], N[i], S[i], v(i), n(i), s(i), p(i), u(i), z(i))).append(post);
    }
    
    res.append("}");
    return res.toString();
   }
 
}
