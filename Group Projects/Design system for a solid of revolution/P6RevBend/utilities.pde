// LecturesInGraphics: utilities
// Author: Jarek ROSSIGNAC, last edited on August 1, 2013

// ************************************************************************ COLORS 
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
   red=#FF0000, grey=#818181, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB,
   orange=#FFA600, brown=#B46005, metal=#B5CCDE, dgreen=#157901, lgrey = #D3D3D3;

// ************************************************************************ GRAPHICS 
void pen(color c, float w) {stroke(c); strokeWeight(w);}
void showDisk(float x, float y, float r) {ellipse(x,y,r*2,r*2);}

// ************************************************************************ IMAGES & VIDEO 
int pictureCounter=0;
PImage myFace; // picture of author's face, should be: data/pic.jpg in sketch folder
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); }


// ************************************************************************ TEXT 
Boolean scribeText=true; // toggle for displaying of help text
void scribe(String S, float x, float y) {fill(0); text(S,x,y); noFill();} // writes on screen at (x,y) with current fill color
void scribeHeader(String S, int i) {fill(0); text(S,10,20+i*20); noFill();} // writes black at line i
void scribeHeaderRight(String S) {fill(0); text(S,width-7.5*S.length(),20); noFill();} // writes black on screen top, right-aligned
void scribeFooter(String S, int i) {fill(0); text(S,10,height-10-i*20); noFill();} // writes black on screen at line i from bottom
void scribeAtMouse(String S) {fill(0); text(S,mouseX,mouseY); noFill();} // writes on screen near mouse
void scribeMouseCoordinates() {fill(black); text("("+mouseX+","+mouseY+")",mouseX+7,mouseY+25); noFill();}
void displayHeader() { // Displays title and authors face on screen
    fill(0); 
    text(title, 10, 20); 
    //text(name_nick, width - 17.0* name_nick.length(), 140);
    text(name_sumit, width - 6.0* name_sumit.length()/3, 140);
    
    image(DeepDonovanFace, width - DeepDonovanFace.width/2 - 172, 10, DeepDonovanFace.width/2, DeepDonovanFace.height/2);  
    image(NicksFace, width - NicksFace.width/2 - 92, 10, NicksFace.width/2, NicksFace.height/2);  
    image(SumitsFace, width - SumitsFace.width/2 - 15, 10, SumitsFace.width/2, SumitsFace.height/2);  
    }
    
void displayArea() { // Displays help text at the bottom
    fill(blue); 
    textSize(16);
    text("Area: ", width - 17.0*name_nick.length(), 200); 
    fill(black);
    textSize(12);
    
    if (face < 0) {
      text("Face not selected",width - 140, 200);
      text("Press 'f' and select a face",width - 17.0*name_nick.length(), 220);
      } else {
      text(Float.toString(PG.area(face)),width - 140, 200);
    }
}

void displayCurveSelection(int c, int m) { // Shows which curve (Red / Green) is selected

    stroke(black); 
    String msg = "Selected Curve (Press '0', '1', '2'): ";
    String leftCurve = "Left Curve";
    String rightCurve = "Right Curve";
    String midSpine = "Middle Axis";
    fill(black);
    text(msg,10, 50 + textAscent()+textDescent());
    stroke(red); fill(red);
    if (c == 2) { text(midSpine,210, 50 + textAscent()+textDescent()); }
    if (c == 0) { text(leftCurve,210, 50 + textAscent()+textDescent()); }
    if (c == 1) { text(rightCurve,210, 50 + textAscent()+textDescent()); }
    
    String modeMsg = "Selected mode ('m' to toggle): ";
    String normMsg = "Normal";
    String radialMsg = "Radial";
    String ballMsg = "Ball";
    String allMsg = "Normal, Radial, Ball";
    
    fill(black);
    text(modeMsg,10, 70 + textAscent()+textDescent());
    stroke(red); 
    if (m == 3) { fill(red); text(normMsg,210, 70 + textAscent()+textDescent()); fill(dgreen); text(radialMsg,260, 70 + textAscent()+textDescent()); fill(blue); text(ballMsg,302, 70 + textAscent()+textDescent()); }
    if (m == 2) { fill(blue); text(ballMsg,210, 70 + textAscent()+textDescent()); }
    if (m == 0) { fill(red); text(normMsg,210, 70 + textAscent()+textDescent()); }
    if (m == 1) { fill(dgreen); text(radialMsg,210, 70 + textAscent()+textDescent()); }
    
    
    
    
}
    
void displayFooter() { // Displays help text at the bottom
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }

// ************************************************************************ GENERIC TEXT FOR TITLE 
String subtitle = "for Jarek Rossignac's CS3451 class in the Fall 2013";
//************************ capturing frames for a movie ************************
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)
boolean change=false;   // true when the user has presed a key or moved the mouse
boolean animating=false; // must be set by application during animations to force frame capture

// ************************************************************************ IO FILES
String fileName="data/points";

void fileSelected(File selection) {
  if (selection == null) println("Window was closed or the user hit cancel.");
  else {
    fileName = selection.getAbsolutePath();
    println("User selected " + fileName);
    }
  }
  


