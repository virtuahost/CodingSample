//*****************************************************************************
// TITLE:         Curve registration
// DESCRIPTION:   Computes rigid motion that minimizes the sum of the square distances between corresponding vertices 
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  August 2009
// EDITS:
//*****************************************************************************
boolean showHelpText=false;       // toggled by keys to show/hide help text
boolean printIt=false;           // temporarily set when key '?' is pressed and used to print some debugging values
PImage me; // picture of my face
POLYGON P = new POLYGON(), Q=new POLYGON(), R=new POLYGON(), RP=new POLYGON(), RQ=new POLYGON();
void setup() { size(800, 800); smooth();   strokeJoin(ROUND); strokeCap(ROUND);  // set up window and drawing modes
  setColors();
  PFont font = loadFont("ArialMT-24.vlw"); textFont(font, 14);      // load font
  me = loadImage("data/me.jpg"); 

  P.loadPts("P");  Q.loadPts("Q"); //  P.resetPoints();  Q.copyFrom(P); R.copyFrom(P);
  } 

void draw() { background(121);  strokeWeight(1);                        // sets background
  if (showHelpText) showHelp(); else myActions(); 
  printIt=false;
  };  // end of draw

 
