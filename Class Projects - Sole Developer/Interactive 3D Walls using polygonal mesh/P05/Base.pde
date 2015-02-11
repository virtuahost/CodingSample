// CS 6491: Assignment 02
// Functions and variables to implement functions for Area Splitter Controller.
// Author: DEEP GHOSH AND DONOVAN HATCH, last edited on SEPTEMBER 10, 2014
pt dragStartVertex;
boolean deleteMode = false;
Boolean selectMode = false;
Boolean threeDMode = false;
Boolean drawSkeleton = false;
Boolean showLoops = false;

void initBase()
{
  initGDS();  
}

//***********Controls the drawing mechanism for the polygon***********************//
void drawKeyFrame()
{
  drawGraph();
  if(deleteMode)
    soonDeleteAt(Mouse());
//
//  if(deleteMode) {fill(red);text("DeleteMode",-300,-300); }
//  else if(selectMode) { fill(magenta);text("SelectMode",-300,-300); }
//  else { fill(green);text("AddMode",-300,-300); }
}

/****************************Starts the capture of edges*****************************************************/
void calculateOnMousePressChanges()
{ 
//  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
//    translate(width/2,height/2,dz); // puts origin of model at screen center and moves forward/away by dz
//    rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
//    rotateX(PI/2); //
  if(!threeDMode)
  {
    dragStartVertex = P(mouseX, mouseY);
  }
//  popMatrix();
  
  if(selectMode)
  {
    if(!threeDMode)
    {
      selectCorner(Mouse(), true);
    }
    else
    {
      pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
    camera();       // sets a standard perspective
    translate(width/3,height/6,dz); // puts origin of model at screen center and moves forward/away by dz
    lights();  // turns on view-dependent lighting
    rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
    rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
      pt P = pick(mouseX,mouseY);
      selectCorner3D(P);
      popMatrix();
//      println("In 3D mode");
//      selectCorner3D(mouseX,mouseY);
    }
  }
}

void calculateOnMouseDraggedChanges()
{ 
  if(!deleteMode && !selectMode)
    DrawSoonToAdd(P(dragStartVertex), P(mouseX, mouseY), isDrag(), true);
}

/****************************Ends the capture of edges*****************************************************/
void calculateOnMouseReleaseChanges()
{    
//  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
//    translate(width/2,height/2,dz); // puts origin of model at screen center and moves forward/away by dz
//    rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
//    rotateX(PI/2); //
  pt dragEnd = P(mouseX, mouseY);
//  popMatrix();
  DrawSoonToAdd(P(dragStartVertex), P(dragEnd), isDrag(), false);
  if(deleteMode)
  {
    deleteAt(dragEnd);
  }
  else if(selectMode) {
    //showCornerInfo(); 
  }
  else
  {
     addEdge(dragStartVertex, dragEnd, isDrag()); 
  } 
  stopColorGeneration = false;generateRandomColor(true);
}

boolean isDrag()
{
  return (d(dragStartVertex, P(mouseX, mouseY)) > 10) ? true : false;
}

/****************************Toggle modes to enable drawing of polygons*****************************************************/
void toggleMode()
{
  if(key=='d') { deleteMode = !deleteMode; selectMode = false;selectCorner(Mouse(), false); threeDMode = false;showFaceLoops=false;} 
  if(key=='c') { selectMode = !selectMode; deleteMode=false; if(!selectMode) selectCorner(Mouse(), false); showFaceLoops=false;}
  if(key=='a') { selectMode = false;selectCorner(Mouse(), false);deleteMode = false; threeDMode = false;showFaceLoops=false;}
  if(key=='x') { threeDMode = true;showFaceLoops=false;selectMode = false;selectCorner(Mouse(), false); deleteMode=false;drawSkeleton=false;generate3DDataStructure();}
  if(key=='1') { if(threeDMode){drawSkeleton = !drawSkeleton;}showFaceLoops=false;selectMode = false;selectCorner(Mouse(), false); deleteMode=false;}
  if(key=='2'){showLoops=!showLoops;}
  
  if(key=='n' && showSelCorner) { if(threeDMode){move3DNext();}else{moveNext();} }
  if(key=='p' && showSelCorner) { if(threeDMode){move3DPrev();}else{movePrev();}}
  if(key=='s' && showSelCorner) { if(threeDMode){move3DSwing();}else{moveSwing();} }
  if(key=='u' && showSelCorner) { if(threeDMode){move3DUnswing();}else{moveUnswing();}}
  //if(key=='z' && showSelCorner) { if(threeDMode){move3DZ();}else{moveZ();}}
  if(key=='f') {showFaceLoops = !showFaceLoops;if(!showFaceLoops){stopColorGeneration=false;generateRandomColor(true);}else{threeDMode = false;}}
}


