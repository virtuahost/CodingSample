// CS 6491: Assignment 03 //<>//
// Common class to draw a line based on different methods
// 1. Start coordinates and line angle supplied.
// 2. Start and end co ordinates.
// Allows modification of the line length by user of the class. Defaulted to 100.
// Calculates mid point of the line and stores them in the class attributes.
// Author: DEEP GHOSH AND DONOVAN HATCH, last edited on SEPTEMBER 10, 2014
/*****************Class to store Polygon Information **************************************************/
public class PolygonBuilder
{
  public ArrayList<pt> vertices;
  public ArrayList<EdgeBuilder> edges;
  public float area;
  private int iterator = 0;
  private float distAccuracy = 10F;
  public int edgeDrawColor = black;
  public int fillDrawColor;
  public Boolean changed = true;
  public Boolean fillPoly = true;
  public String polyName = "base";
  public int areaDiv = 1;
  private ArrayList<Integer> edgeColorList;
  public Boolean isPositiveArea = false;
  
  public PolygonBuilder()
  {
     init();
  }
  
  public PolygonBuilder(ArrayList<pt> points)
  {
    init();
    
    for(int i = 1; i < points.size(); i++)
    {
      AddPolygonBuildData(points.get(i-1), points.get(i)); 
    }
  }
  
  private void init()
  {
    this.vertices = new ArrayList<pt>();
    this.edges = new ArrayList<EdgeBuilder>(); 
    fillDrawColor = color(255,255,255,0);
    
    edgeColorList = new ArrayList<Integer>();
    edgeColorList.add(color(195, 205, 205));
    edgeColorList.add(color(150, 180, 205));
    edgeColorList.add(color(205, 160, 190));
    edgeColorList.add(color(205, 205, 205));
    edgeColorList.add(color(160, 160, 160));
    edgeColorList.add(color(195, 100, 100));
    edgeColorList.add(color(150, 150, 150));
    edgeColorList.add(color(150, 150, 150));
    edgeColorList.add(color(150, 150, 150));
    edgeColorList.add(color(150, 150, 150));
    edgeColorList.add(color(150, 150, 150));
    
    edgeDrawColor = edgeColorList.get(areaDiv);
  }
  
  public void setColorList(ArrayList<Integer> colorList) {
    edgeColorList = colorList;
    edgeDrawColor = edgeColorList.get(areaDiv);
  }
  
  public void AddPolygonBuildData(EdgeBuilder edge)
  {
    this.AddPolygonBuildData(P(edge.startVertex), P(edge.endVertex));
  }
  
  public void AddPolygonBuildData(pt edgeVertexStart, pt edgeVertexEnd)
  { 
    changed = true;
    pt startVertexFound = null, endVertexFound = null;
    
    for(int i = 0; i < this.vertices.size(); i++)
    {
      if(d(this.vertices.get(i), edgeVertexStart) < distAccuracy)
      {
        startVertexFound = this.vertices.get(i);
      }
      if(d(this.vertices.get(i), edgeVertexEnd) < distAccuracy)
      {
        endVertexFound = this.vertices.get(i);
      }
    }
    
    if(startVertexFound == null) 
    {
      startVertexFound = P(edgeVertexStart);
      this.vertices.add(startVertexFound);
    }
    if(endVertexFound == null) 
    {
      endVertexFound = P(edgeVertexEnd);
      this.vertices.add(endVertexFound);
    }
    
    Boolean edgeFound = false;
        
    if(edges != null)
    {
      int prevEdgeID = -1;
      int nextEdgeID = -1;
      
      for(int i = 0; i < this.edges.size(); i++)
      {        
        if(!this.edges.get(i).CheckUniqueEdge(startVertexFound, endVertexFound))
        {
          edgeFound = true;
        }
        else
        {
          if(d(this.edges.get(i).endVertex, edgeVertexStart) < distAccuracy)
          {
            prevEdgeID = i;
          }
          if(d(this.edges.get(i).startVertex, edgeVertexEnd) < distAccuracy)
          {
            nextEdgeID = i;
          }
        }
      }
      
      if(!edgeFound)
      {
        EdgeBuilder tempEdge = new EdgeBuilder(startVertexFound, endVertexFound); 
        //println("edge: " + this.edges.size() +" NextEdge" + nextEdgeID);
        //println("edge: " + this.edges.size() +" PrevEdge" + prevEdgeID);
        if(nextEdgeID > -1)
        {
          tempEdge.nextEdge = nextEdgeID;
        }       
        this.edges.add(tempEdge);
        if(prevEdgeID > -1)
        {
          this.edges.get(prevEdgeID).nextEdge = this.edges.size() - 1;
        }
      }
    }
    else
    {  
      EdgeBuilder tempEdge = new EdgeBuilder(startVertexFound, endVertexFound);
      this.edges.add(tempEdge);
    }
  }
  
  public void FixEdgePointers()
  {
    //println("fixEdges "+polyName);
    
    ArrayList<EdgeBuilder> edgeList = new ArrayList<EdgeBuilder>();
    if(isPositiveArea)
    {
      if(this.edges != null)
      {        
        for(int i = 0; i < this.edges.size(); i++)
        {
          if(i == 0)
          {
            this.edges.get(i).nextEdge = this.edges.size() - 1;
            pt tempVertice = this.edges.get(i).startVertex;
            this.edges.get(i).startVertex = this.edges.get(i).endVertex;
            this.edges.get(i).endVertex = tempVertice;
          }
          else
          {
            this.edges.get(i).nextEdge = i-1;
            pt tempVertice = this.edges.get(i).startVertex;
            this.edges.get(i).startVertex = this.edges.get(i).endVertex;
            this.edges.get(i).endVertex = tempVertice;
          }
        }
      }
    }
    
//    for(int i = 0; i < this.edges.size(); i++) {
//      println(i+"-"+this.edges.get(i).nextEdge);
//    }
    
//    Boolean asdf = true;
//    EdgeBuilder edge = this.edges.get(0);
//    println(0);
//    println(edge.startVertex.write() + "-" + edge.endVertex.write()); 
//    for(int i = 1; i < this.edges.size(); i++)
//    {
//      println(edge.nextEdge);
//      edge = this.edges.get(edge.nextEdge);
//      println(edge.startVertex.write() + "-" + edge.endVertex.write()); 
//    }
  }
  
  public void AddVertex()
  {
    if(this.edges == null)
      return;
      
    EdgeBuilder lastEdge = this.edges.get(this.edges.size() - 1);
    pt midPoint = lastEdge.GetMidpoint();
    
    this.vertices.add(midPoint);
    EdgeBuilder newEdge = new EdgeBuilder(midPoint, lastEdge.endVertex);
    newEdge.nextEdge = 0;
    this.edges.add(newEdge);
    
    lastEdge.endVertex = midPoint;
    lastEdge.nextEdge = this.edges.size() - 1;
  }
 
  public pt GetClosestVertex() 
  {
    pt closestVertex = null;
    float dist = -1;
    
    for(int i = 0; i < this.vertices.size(); i++)
    {
       float tmpDist = d(this.vertices.get(i), Mouse());
       if(closestVertex == null || tmpDist < dist)
       {
          closestVertex = this.vertices.get(i);
          dist = tmpDist;
       } 
    }
    
    return closestVertex;
  }
  
  public float CalculateArea()
  {
    if(!this.changed)
      return this.area;
    else
      changed = false;
      
    this.FixEdgePointers();
    this.area = 0;

    for(int i = 0; i < this.edges.size(); i++)
    {
      //int j = this.edges.get(i).nextEdge;
      //println(polyName+" edge " + i + " area: " + this.area);

      this.area += (this.edges.get(i).startVertex.x * this.edges.get(i).endVertex.y - this.edges.get(i).endVertex.x * this.edges.get(i).startVertex.y);
    }
    isPositiveArea = (this.area >= 0) ? true : false;
    this.area = abs(this.area / 2);
    //this.FixEdgePointers();
    return this.area;
  }
  
  public Boolean CreatePolygon(Boolean doCalc, Boolean drawPoly, Boolean fillPoly)  
  {
    this.iterator = 0;
    //FixEdgePointers();
    if(IsPolygonInComplete(-1)){println("Not a ploygon");return false;}
    if(doCalc)
    {
      this.CalculateArea();
      DrawVertLines();
    }
    if(drawPoly)
    {
      DrawEdgeLines(edgeDrawColor, cyan);
    }
    
    this.fillPoly = fillPoly;
   
    return true;
  }
  
  public void DrawEdgeLines(int edgeColor, int vertexColor)  
  {
    if(this.edges != null)
    {
      //Draw Edges
        beginShape();
        stroke(edgeColor);
        fill(edgeColor, 50);
        
        //Draw vertices
        for(int i = 0; i < this.vertices.size(); i++)
        {
          pt vert = this.vertices.get(i);
          vertex(vert.x,vert.y);
        }
  //      if(!this.vertices.isEmpty()) vertex(this.vertices.get(0).x, this.vertices.get(0).y);
        endShape(CLOSE);
      
      //Draw vertices
      for(int i = 0; i < this.vertices.size(); i++)
      { 
        pt vert = this.vertices.get(i);
        fill(white);showDisk(vert.x, vert.y, 10);
        fill(black);text(i, vert.x - 4 , vert.y + 4);
        //vert.label("(" + vert.x +", " + vert.y + ")", 15, 15); //  + " : " + vert
      }
    }
  }
  
  public void DrawVertLines()
  {
    //ArrayList<EdgeBuilder> vertEdges = new ArrayList<EdgeBuilder>();
    //Array<Float> lastCompareVals = 
    PolyCutData polyCuts = new PolyCutData();
    polyCuts.cutLen = MAX_INT;
    //println(polyName + " Number of edges: " + this.edges.size());
    if(areaDiv == 1) {
      DrawEdgeLines(edgeDrawColor, edgeDrawColor);
      fill(edgeDrawColor);stroke(edgeDrawColor);text(polyName + " area: " +this.area, 700, 20+20*areaDiv);
      return;
    }
    for(int i = 0; i < this.edges.size(); i++)
    {
     //int i=3;
      vec vec1 = (i == 0) ? this.edges.get(this.edges.size()-1).AsRevVec() : this.edges.get(i-1).AsRevVec();
      vec vec2 = this.edges.get(i).AsVec();
      int col = edgeDrawColor;
      float tempAngle = angle(vec1,vec2);
      vec vertLine = vec1.rotateBy(tempAngle/2);//W(vec1, vec2);
      //stroke(col, 50);vertLine.showAt(this.edges.get(i).startVertex);
               
      PolygonBuilder areaPoly = new PolygonBuilder();
      areaPoly.polyName = "areaPoly-"+areaDiv;
      
      PolygonBuilder oppPoly = new PolygonBuilder();
      
      float areaTemp = 0;
      
      float accuracy = 0.0000;//0.0005;
      float moveDist = 5;
      float localMoveDist = moveDist;
      float areaMatch = this.area/areaDiv;
      float areaAccuracy = this.area * accuracy;
      float detectOsc = 0;
      float detectOsc2 = 0;

      pt perpStartPt;
           
      vec vertLineTemp;
      Boolean isConcave = false;
      if(tempAngle < 0)
      {
        vertLineTemp = V(vertLine);
        vertLineTemp.reverse(); 
        isConcave = true;
        
        ///stroke(col, 255);vertLineTemp.showArrowAt(this.edges.get(i).startVertex);      
        //println(abs(tempAngle));
      }
      else 
        vertLineTemp = V(vertLine);
        //stroke(col, 255);vertLineTemp.showArrowAt(this.edges.get(i).startVertex); 
        //stroke(green);fill(green);showDisk(this.edges.get(i).startVertex.x + vertLineTemp.x, this.edges.get(i).startVertex.y + vertLineTemp.y, 5);
        float firstMove = sqrt(area/areaDiv)/sqrt(2*PI)*2;
      perpStartPt = P(P(this.edges.get(i).startVertex), U(vertLineTemp).scaleBy(firstMove));// println(firstMove);
      //stroke(blue);fill(green);showDisk(this.edges.get(i).startVertex.x + vertLineTemp.x, this.edges.get(i).startVertex.y + vertLineTemp.y, 5);
      //println(polyName+" new perpStart: "+i+ " "+ perpStartPt.write());
      EdgeBuilder finalCutLine = null;
      
      while(areaTemp >= areaMatch + areaAccuracy || areaTemp < areaMatch - areaAccuracy)
      {
//        println("area acceptable Range: " + (this.area/areaDiv + accuracy*this.area)/this.area*100 + "-" + (this.area/areaDiv - accuracy*this.area)/this.area*100);
      // println(polyName + " new calc area: " + areaTemp/this.area * 100 + " : " + areaTemp + " : " + area);
        //println("moveDist: " + moveDist); 
        //stroke(black);line(this.edges.get(i).startVertex.x, this.edges.get(i).startVertex.y,perpStartPt.x, perpStartPt.y);
        if(isConcave) 
        {
          if(areaTemp >= areaMatch + areaAccuracy)
          {
            perpStartPt = P(perpStartPt, U(vertLineTemp).scaleBy(moveDist));
            
          }
          else if(areaTemp < areaMatch - accuracy*this.area)
          {
            //println("woooo");
            perpStartPt = P(perpStartPt, U(vertLineTemp).reverse().scaleBy(moveDist * 1));
            if((moveDist = moveDist * .1) < .1) moveDist = .1;
          } 
        }
        else
        {
          if(areaTemp >= areaMatch + areaAccuracy)
          {
            perpStartPt = P(perpStartPt, U(vertLineTemp).reverse().scaleBy(moveDist));
            if((moveDist = moveDist * .1) < .1) moveDist = .1;
          }
          else if(areaTemp < areaMatch - accuracy*this.area)
          {
            //println("woooo");
            perpStartPt = P(perpStartPt, U(vertLineTemp).scaleBy(moveDist * 1));
            //if((moveDist = moveDist * .5) < 1) moveDist = 1;
          }
        }
        //if(detectPointOverflow(

        areaPoly = new PolygonBuilder();
        areaPoly.edgeDrawColor = col;
        areaPoly.polyName = "areaPoly-"+areaDiv;
  
        stroke(col);
        vec perpLine = R(vertLine);
        perpLine.scaleBy(20);
        
        vec perpLine2 = V(perpLine);
        perpLine2 = R(perpLine2, PI);
        
        pt perpEndPt = P(perpStartPt, perpLine);
        pt perpEndPt2 = P(perpStartPt, perpLine2);
        
        pt intersectPts = P(perpEndPt);
        float intersectPtDist = MAX_INT;
        EdgeBuilder intersectEdge1 = null;
        pt intersectPts2 = P(perpEndPt2);
        float intersectPtDist2 = MAX_INT;
        EdgeBuilder intersectEdge2 = null;
        pt intersectPts3 = P(perpStartPt);
        EdgeBuilder intersectEdge3 = null;
        Boolean bOverflow = false;
        
        //println(polyName + " perpStart-" + i + ": " + perpStartPt.write() + " : " + perpStartPt);
        //if(i==5) stroke(green);fill(green);showDisk(perpStartPt.x, perpStartPt.y, 5);
        //println("moveDist: " + moveDist);
        
        //stroke(black);line(perpStartPt.x, perpStartPt.y, perpEndPt.x, perpEndPt.y);
        //stroke(black);line(perpStartPt.x, perpStartPt.y, perpEndPt2.x, perpEndPt2.y);
        //stroke(black);line(this.edges.get(i).startVertex.x, this.edges.get(i).startVertex.y,perpStartPt.x, perpStartPt.y);
        for(int j = 0; j < this.edges.size(); j++)
        {
            EdgeBuilder otherEdge = this.edges.get(j);
            
            pt intersectPt = intersect(perpStartPt.x, perpStartPt.y, perpEndPt.x, perpEndPt.y, otherEdge.startVertex.x, otherEdge.startVertex.y, otherEdge.endVertex.x, otherEdge.endVertex.y);
            pt intersectPt2 = intersect(perpStartPt.x, perpStartPt.y, perpEndPt2.x, perpEndPt2.y, otherEdge.startVertex.x, otherEdge.startVertex.y, otherEdge.endVertex.x, otherEdge.endVertex.y);
            pt intersectPt3 = DONT_INTERSECT;
            if((this.edges.get(i).startVertex.x != this.edges.get(j).startVertex.x) && (this.edges.get(i).startVertex.y != this.edges.get(j).startVertex.y) 
            && (this.edges.get(i).startVertex.x != this.edges.get(j).endVertex.x) && (this.edges.get(i).startVertex.y != this.edges.get(j).endVertex.y))
            {
              intersectPt3 = intersect(this.edges.get(i).startVertex.x, this.edges.get(i).startVertex.y,perpStartPt.x, perpStartPt.y, otherEdge.startVertex.x, otherEdge.startVertex.y, otherEdge.endVertex.x, otherEdge.endVertex.y);
            }
            
            if(!isSame(intersectPt, DONT_INTERSECT) && d(intersectPt,perpStartPt) < intersectPtDist)
            {
              intersectPtDist = d(intersectPt,perpStartPt);
              //println("intersectPt: " + intersectPt.write() + ", distance: " + intersectPtDist);
              intersectPts = P(intersectPt);
              intersectEdge1 = this.edges.get(j);
              //stroke(blue);fill(blue);showDisk(intersectPt.x, intersectPt.y, 5);
            }
            if(!isSame(intersectPt2, DONT_INTERSECT) && d(intersectPt2,perpStartPt) < intersectPtDist2)
            {
              intersectPtDist2 = d(intersectPt2,perpStartPt);
              //println("intersectPt2: " + intersectPt2.write() + ", distance: " + intersectPtDist2);
              intersectPts2 = P(intersectPt2);
              intersectEdge2 = this.edges.get(j);
              //stroke(green);fill(green);showDisk(intersectPt2.x, intersectPt2.y, 5);
            }
            if(!isSame(intersectPt3, DONT_INTERSECT))
            {
              bOverflow = true;
              //println("intersectPt2: " + intersectPt2.write() + ", distance: " + intersectPtDist2);
              //intersectPts3 = P(intersectPt3);
              //intersectEdge3 = this.edges.get(j);
              //stroke(green);fill(green);showDisk(intersectPt2.x, intersectPt2.y, 5);
            }
        } 

        if(bOverflow)
        {
          break;
        }

        if(intersectEdge1 == null || intersectEdge2 == null) 
        {
         //fill(white);showDisk(perpStartPt.x, perpStartPt.y, 10);
          //fill(black);text("P-" +i, perpStartPt.x - 4 , perpStartPt.y + 4);
          //perpStartPt.label("(" + perpStartPt.x +", " + perpStartPt.y + ")"  + " : " + perpStartPt , 15, 15); 
          break;
        }
        pt nearestVertex = P(intersectEdge1.endVertex); 
        EdgeBuilder startEdge = new EdgeBuilder(intersectPts, nearestVertex);
        
        pt nearestVertex1 = P(intersectEdge2.endVertex);
        EdgeBuilder startEdge1 = new EdgeBuilder(intersectPts2, nearestVertex1);
        
        pt farVertex = intersectEdge1.startVertex;
        EdgeBuilder farEdge = new EdgeBuilder(farVertex, intersectPts);

        pt farVertex1 = P(intersectEdge2.startVertex);
        EdgeBuilder farEdge1 = new EdgeBuilder(farVertex1, intersectPts2);
        
        //////////////////////
        //Set up first polly
        //////////////////////
        areaPoly.AddPolygonBuildData(startEdge1);

        int j = intersectEdge2.nextEdge;
        int k = 0;
        while(!isSame(intersectEdge1.startVertex, this.edges.get(j).startVertex))
        {
          k++;

          areaPoly.AddPolygonBuildData(this.edges.get(j)); 
          j = this.edges.get(j).nextEdge;
        } 
        //println("Found k=" + k + " edges");
        areaPoly.AddPolygonBuildData(farEdge);
        finalCutLine = new EdgeBuilder(P(intersectPts),P(intersectPts2));
        areaPoly.AddPolygonBuildData(finalCutLine);
        
        //////////////////////
        //set up second polly
        ///////////////////////
        oppPoly = new PolygonBuilder();
        //oppPoly.edgeDrawColor = col;
        oppPoly.polyName = "oppPoly-"+(areaDiv-1);
        
        oppPoly.AddPolygonBuildData(startEdge);

        j = intersectEdge1.nextEdge;
        while(!isSame(intersectEdge2.startVertex, this.edges.get(j).startVertex))
        {
          oppPoly.AddPolygonBuildData(this.edges.get(j)); 
          j = this.edges.get(j).nextEdge;
        } 
        oppPoly.AddPolygonBuildData(farEdge1);
        finalCutLine = new EdgeBuilder(P(intersectPts2), P(intersectPts));
        oppPoly.AddPolygonBuildData(finalCutLine);

        //areaPoly.FixEdgePointers();
        areaTemp = areaPoly.CalculateArea();
        if( areaTemp == detectOsc2)
        
          break;
        else 
        {
           detectOsc2 = detectOsc;
           detectOsc = areaTemp;   
        }
//        for(int l = 0; l < this.vertices.size(); l++)
//        {
//          if(this.vertices.get(l) != this.edges.get(i).startVertex) {
//            if(d(perpStartPt, this.vertices.get(l)) < 20)
//             continue;  
//          }
//        }
     }
//     fill(white);showDisk(perpStartPt.x, perpStartPt.y, 10);
//        fill(black);text("P", perpStartPt.x - 4 , perpStartPt.y + 4);
//        perpStartPt.label("(" + perpStartPt.x +", " + perpStartPt.y + ")"  + " : " + perpStartPt, 15, 15);
     if(finalCutLine != null && d(finalCutLine.startVertex, finalCutLine.endVertex) < polyCuts.cutLen) {
       polyCuts.poly = areaPoly;
       polyCuts.setCutLine(finalCutLine); 
       polyCuts.oPoly = oppPoly;
       //polyCuts.oPoly.setColorList(edgeColorList);
     }
    } 
    //println("areaDiv == " + areaDiv);
    
    if(polyCuts.poly != null) {
      fill(edgeDrawColor);stroke(edgeDrawColor);text("areaPoly-"+areaDiv+" area: " +polyCuts.poly.area, 700, 20+20*areaDiv);
      polyCuts.poly.CreatePolygon(false, true, true);
      
      if(areaDiv > 1) {
        //println(areaDiv);
        polyCuts.oPoly.areaDiv = this.areaDiv - 1;
        //println(polyCuts.oPoly.polyName);
        polyCuts.oPoly.setColorList(edgeColorList);
        //println("eekkk " + polyCuts.oPoly.areaDiv);
        polyCuts.oPoly.CreatePolygon(true, false, false);
      }  
      
//      if(areaDiv == 1) {
//        println("ptatop");
//        polyCuts.oPoly.CreatePolygon(true, true, false);
//      }
    }
    else {
     println("poly nulL!"); 
    }
  }
  
  void delay(int del)
  {
    int time = millis();
    while(millis() - time <= del)
    {
      
    }
  }
  
  Boolean IsConvexAngle(EdgeBuilder near, EdgeBuilder far)
  {
      if(angle(near.startVertex, near.endVertex, far.endVertex)>PI) return true;
      
    return false;
  }
  
  public void DrawStats(Boolean calculateArea)
  {
    if(this.edges == null && this.vertices == null)
      return;
    fill(edgeDrawColor);
    //text("Number of Edges: " + this.edges.size(), 25, 50);
    //text("Number of Vertices: " + this.vertices.size(), 25, 70); 

    if(calculateArea) {CalculateArea();}
    text("Calculated Area: " + this.area, 25, 90);
  }
  
  private Boolean IsPolygonInComplete(int findVal)
  {
    if(this.edges.isEmpty())
      return true;
    if(this.edges.get(this.iterator).nextEdge == findVal)
    {
      return true;
    }
    this.iterator++;
    if(this.iterator == this.edges.size())
    {
      return false;
    }
    return IsPolygonInComplete(findVal);    
  }
}

/*****************Class to store Edge Information **************************************************/
public class EdgeBuilder 
{
  public pt startVertex;
  public pt endVertex;
  public int nextEdge;
  public int edgeColor;
  
  public EdgeBuilder(EdgeBuilder edge)
  {
     this.startVertex = edge.startVertex;
    this.endVertex = edge.endVertex;
    nextEdge = -1;
    //edgeColor = color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2);
  }
  
  public EdgeBuilder(pt startVertex, pt endVertex)
  {
    this.startVertex = startVertex;
    this.endVertex = endVertex;
    nextEdge = -1;
    //edgeColor = color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2);
  }
  
  public Boolean CheckUniqueEdge(pt startVertex, pt endVertex)
  {
    if(isSame(this.startVertex, startVertex) && isSame(this.endVertex, endVertex))
    {
      return false;
    }
    else if(isSame(this.startVertex, endVertex) && isSame(this.endVertex, startVertex))
    {
      return false;
    }
    return true;    
  }
  
  public void Draw() 
  {
    line(this.startVertex.x, this.startVertex.y, this.endVertex.x, this.endVertex.y);
  }
  
  public pt GetMidpoint() {
     return P(startVertex, endVertex);
  }
  
  public vec AsVec()
  {
    return V(startVertex, endVertex);  
  }
  
  public vec AsRevVec()
  {
     return V(endVertex, startVertex); 
  }
}

public class PolyCutData 
{
  public PolygonBuilder poly;
  public PolygonBuilder oPoly; //opposite Poly
  public float cutLen;
  public EdgeBuilder cutLine;
  
  public PolyCutData() {}
  
  public void setCutLine(EdgeBuilder cutLine)
  {
    this.cutLine = new EdgeBuilder(cutLine);
    this.cutLen = d(cutLine.startVertex, cutLine.endVertex);
  }
  
  public PolyCutData(PolygonBuilder poly, EdgeBuilder cutLine)
  {
    this.poly = poly;
    this.cutLine = new EdgeBuilder(cutLine);
    this.cutLen = d(cutLine.startVertex, cutLine.endVertex);
  }
}
