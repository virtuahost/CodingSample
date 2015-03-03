Boolean draw = false;
  
void keyPressed() {  
  if (key==' ') showHelpText=!showHelpText ; 
  if (key=='m') {}  // used to set mode when mouse pressed
  if (key=='i') {}  // used to set mode when mouse pressed
  if (key=='d') {}  // used to set mode when mouse pressed
  if (key=='r') {}  // used to set mode when mouse pressed
  if (key=='s') {}  // used to set mode when mouse pressed
  if (key=='t') {}  // used to set mode when mouse pressed
  if (key=='e') {mid=!mid;}  // used to set mode when mouse pressed
  if (key=='c') {Q.copyFrom(P);}  // used to set mode when mouse pressed
  if (key=='C') {P.copyFrom(Q);}  // used to set mode when mouse pressed
  if (key=='f') {P.flip();}  // mirror
  if (key=='g') {P.recenter(Q);}  // mirror
//  if (key=='O') loopIsClosed=!loopIsClosed;
//  if (key=='#') showVertexIds=!showVertexIds ;
//  if (key=='V') showVertices=!showVertices; 
//  if (key=='S') {refine(0.5); coarsen();};
//  if (key=='R') refine(0.5);
//  if (key=='C') coarsen();
  if (key=='W') {P.savePts("P"); Q.savePts("Q");}
  if (key=='G') {P.loadPts("P");  Q.loadPts("Q");}
  if (key=='X') {String S="images/P####.tif"; saveFrame(S);};   ;
  if (key=='?') printIt=true;  // toggle debug mode
  if (key==',') dd=max(0,dd-1); 
  if (key=='.') dd=min(2,dd+1);
  if (key=='1') {edited=1;}  // used to set mode when mouse pressed
  if (key=='2') {edited=2;}  // used to set mode when mouse pressed
  if(key=='8'){draw=!draw;}
  };     

void showHelp() {
     image(me, width-me.width, 0); 
     fill(dblue); pushMatrix(); translate(20,20);
     text("Rigid body registration of curves",0,0); translate(0,20);
     text("Jarek Rossignac",0,0); translate(0,20);
     text("August 23, 2009",0,0); translate(0,20);
     text("  ",0,0); translate(0,20);
     text("First click in the window to activate it ",0,0); translate(0,20);
     text("Press SPACE to show/hide this help text",0,0); translate(0,20);
     text("  ",0,0); translate(0,20);
     text("Click&drag while pressing 't' to translate, 's' to scale, 'r' to rotate green curve",0,0); translate(0,20);
     text("Click&drag while pressing 'm'to move individual green vertices",0,0); translate(0,20);
     text("    ",0,0); translate(0,20);
     text("A rigid motion is computed  which registers the green curve to the red curve.",0,0); translate(0,20);
     text("The registered image of the green curve is shown in blue.",0,0); translate(0,20);
     text("  ",0,0); translate(0,20);
     text("Press'G' to get (i.e., read) vertex positions from file ",0,0); translate(0,20);
     text("  ",0,0); translate(0,20);
     text("Press 'c' or 'C' to copy the green to red or vice versa",0,0); translate(0,20);
     text("  ",0,0); translate(0,20);
     text("'W' write the green curve to file ",0,0); translate(0,20);
     text("Press 'X' to snap a picture (when running Processing, not in browser)",0,0); translate(0,20);
     text("  ",0,0); translate(0,20);
        text("  ",0,0); translate(0,20);
     popMatrix(); noFill();
   }
  
void mousePressed() {
 
  if (Mouse().isInWindow()) if (keyPressed) if(edited==1) Q.clickPolygon(); else P.clickPolygon(); 
  } 


 

   
