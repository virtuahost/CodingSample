// CS 6491: Assignment 02
// Functions and variables to implement functions for Area Splitter Controller.
// Author: DEEP GHOSH AND DONOVAN HATCH, last edited on SEPTEMBER 10, 2014
Boolean drawModeOn = false;
PolygonBuilder objPolygon;
pt objDragVertex;
Boolean drawStartPoly = true;
color baseColor;
Boolean drawPoly = true;
Boolean canDrag = false;

pt lastDrawPt = P(200,200);

//***********Initializes all initial values***********************//
void initializeStartElements()
{
  baseColor = color(0,102,204);
  lastDrawPt = P(200, 200);
  
    ArrayList<Integer> edgeColorList = new ArrayList<Integer>();
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
    edgeColorList.add(color((random(255)+255)/2, (random(255)+255)/2, (random(255)+255)/2));
  
  if(drawStartPoly) {
    ArrayList<pt> startPolygon = new ArrayList<pt>();
    startPolygon.add(P(200,100));
    startPolygon.add(P(200,300));
    startPolygon.add(P(250,400));
    startPolygon.add(P(500,450));
    startPolygon.add(P(550,100));
    startPolygon.add(P(200,100));
    
    objPolygon = new PolygonBuilder(startPolygon);
    
  }
  else
    objPolygon = new PolygonBuilder();
    
  objPolygon.setColorList(edgeColorList);
  objPolygon.edgeDrawColor = baseColor;
  
}

//***********Controls the drawing mechanism for the polygon***********************//
void drawKeyFrame()
{
  stroke(black);fill(black);rect(680, 10, 200, 200);
  if(!drawModeOn)
  {
    if(!objPolygon.CreatePolygon(true, drawPoly, false))
    {
      fill(0);text("Not a valid Polygon",mouseX-2,mouseY);
    }
  }
  else
  {
    stroke(red);fill(red);text("Draw only counter-clockwise. Concave implementation broke clockwise.", 400,400);
    objPolygon.DrawEdgeLines(red, green);
    if(mousePressed){stroke(100);line(lastDrawPt.x, lastDrawPt.y, mouseX, mouseY);}
  } 
  
  objPolygon.DrawStats(!drawModeOn);
}

/****************************Starts the capture of edges*****************************************************/
void calculateOnMousePressChanges()
{ 
  if(drawModeOn)
  {
    //objStartVertex = Mouse();
  }
  else 
  {
    objDragVertex = objPolygon.GetClosestVertex();
  }
}

void calculateOnMouseDraggedChanges()
{ 
  if(!drawModeOn && objDragVertex != null && canDrag) 
  {
    objDragVertex.moveWithMouse();
    objPolygon.changed = true;
  }
}

/****************************Ends the capture of edges*****************************************************/
void calculateOnMouseReleaseChanges()
{    
  if(drawModeOn)
  {
    objPolygon.AddPolygonBuildData(lastDrawPt, Mouse());
    lastDrawPt = Mouse();
  }
}

/****************************Toggle modes to enable drawing of polygons*****************************************************/
void toggleMode()
{
  if(key=='d') { drawModeOn=!drawModeOn; if(drawModeOn){drawStartPoly=false;initializeStartElements();} else objPolygon.FixEdgePointers();} 
}

void addVertex()
{
  if(!drawModeOn)
   if(key=='v') objPolygon.AddVertex();
}

void toggleDrawPoly()
{
  if(key=='p') drawPoly=!drawPoly;
}

void toggleChangeSplit()
{
  if(key=='1') objPolygon.areaDiv = 1;
  if(key=='2') objPolygon.areaDiv = 2;
  if(key=='3') objPolygon.areaDiv = 3;
  if(key=='4') objPolygon.areaDiv = 4;
  if(key=='5') objPolygon.areaDiv = 5;
  if(key=='6') objPolygon.areaDiv = 6;
  if(key=='7') objPolygon.areaDiv = 7;
  if(key=='8') objPolygon.areaDiv = 8;
  if(key=='9') objPolygon.areaDiv = 9;
  //if(key=='9') objPolygon.areaDiv = 10;
}

void toggleDragging()
{
  if(key=='o') canDrag = !canDrag;
}
