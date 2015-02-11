float dz=-100; // distance to camera. Manipulated with wheel or when 
float rx=-0.10*TWO_PI, ry=-0.10*TWO_PI;    // view angles manipulated when space pressed but not mouse
Boolean twistFree=false, animating=false, center=true, showControlPolygon=true, showFloor=false;
float t=0, s=0;
pt F = P(0, 0, 0);  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
pt O=P(100, 100, 0); // red point controlled by the user via mouseDrag : used for inserting vertices ...

void setup() {
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  size(1200, 700, P3D); // p3D means that we will do 3D graphics
  initBase();
  noSmooth();
}

void draw() {
  background(255);
  if (threeDMode)
  {
    pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
    camera();       // sets a standard perspective
    translate(width/3, height/6, dz); // puts origin of model at screen center and moves forward/away by dz
    lights();  // turns on view-dependent lighting
    rotateX(rx); 
    rotateY(ry); // rotates the model around the new origin (center of screen)
    rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
  }
  if (center) translate(-F.x, -F.y, -F.z);
  noStroke(); // if you use stroke, the weight (width) of it will be scaled with you scaleing factor
  if (showFloor) {
    showFrame(50); // X-red, Y-green, Z-blue arrows
    fill(yellow); 
    pushMatrix(); 
    translate(0, 0, -1.5); 
    box(400, 400, 1); 
    popMatrix(); // draws floor as thin plate
    fill(magenta); 
    show(F, 4); // magenta focus point (stays at center of screen)
    fill(magenta, 100); 
    showShadow(F, 5); // magenta translucent shadow of focus point (after moving it up with 'F'
    if (showControlPolygon) {
      pushMatrix();
      drawKeyFrame(); 
      popMatrix();
    } // show floor shadow of polyloop
  }


  if (showControlPolygon) {
    drawKeyFrame();
  }

  // replace the following 2 lines by display of the extrucded polygonal model
  fill(cyan); 
  stroke(blue); //showWalls(P,Q);  
  noStroke(); 
  drawKeyFrame();//fill(yellow); P.drawClosedLoop(); fill(orange); Q.drawClosedLoop();
  if (threeDMode)
  {
    popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
  }

  if (keyPressed) {
    stroke(red); 
    fill(white); 
    ellipse(mouseX, mouseY, 26, 26); 
    fill(red); 
    text(key, mouseX-5, mouseY+4);
  }
  // for demos: shows the mouse and the key pressed (but it may be hidden by the 3D model)
  if (scribeText) {
    fill(black); 
    displayHeader();
  } // dispalys header on canvas, including my face
  if (scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if (animating) { 
    t+=PI/180*2; 
    if (t>=TWO_PI) t=0; 
    s=(cos(t)+1.)/2;
  } // periodic change of time 
  if (filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++, 4)+".tif");  // save next frame to make a movie  

  if (deleteMode) {
    fill(red);
    text("DeleteMode", 100, 100);
  } else if (selectMode) { 
    fill(magenta);
    text("SelectMode", 100, 100);
  } else if (threeDMode) {
    fill(cyan);
    text("3D Drawing", 100, 100);
  } else { 
    fill(green);
    text("AddMode", 100, 100);
  }
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
}

void keyPressed() {
  toggleMode();
  if (key=='j') {
    dz -= 2; 
    change=true;
  }
  change=true;
}

void mouseWheel(MouseEvent event) {
  dz -= event.getAmount(); 
  change=true;
}

void mousePressed()
{
  calculateOnMousePressChanges();
}

void mouseReleased()
{
  if (!threeDMode)
  {
    calculateOnMouseReleaseChanges();
  }
}

void mouseMoved() {
  if (keyPressed && key==' ') {
    rx-=PI*(mouseY-pmouseY)/height; 
    ry+=PI*(mouseX-pmouseX)/width;
  };
  if (keyPressed && key=='j') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
}

void mouseDragged() {
  if (!threeDMode)
  {
    calculateOnMouseDraggedChanges();
  }
}  

// **** Header, footer, help text on canvas
void displayHeader() { // Displays title and authors face on screen
  scribeHeader(title, 0); 
  scribeHeaderRight(name); 
  fill(white); 
  image(myFace, width-myFace.width/2, 25, myFace.width/2, myFace.height/2);
}
void displayFooter() { // Displays help text at the bottom
  scribeFooter(guide, 1); 
  scribeFooter(menu, 0);
}

String title ="CS6491, Fall 2014, Assignment 5: '3D Walls'", name ="Deep Ghosh", // enter project number and your name
menu="?:(show/hide) help, !:snap picture, ~:(start/stop) recording frames for movie, Q:quit, F: show faces, A: add mode, D: delete mode, C: view/traverse mode, X: 3D Diagram, 1: Show 3D lines,  2: Show Loops in 3D ", 
guide="J: Mouse scroll: Zoom out. Space: Free View. In Add mode, click edge or drag to add. In delete mode, click edge or vertex. In view mode, click to select. n=next,p=prev,s=swing,u=unswing, z=z."; // help info

