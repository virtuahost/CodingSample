 float t=0.5; // parameter for displaying a point (red dot) on the curve
 float dt=0.01;
 float dd=0;
 boolean showVertexIds=true, showVertices=true;
 boolean mid=true;
 boolean morph=true;
 float tt=0;
 int edited=2;
 void myActions() { // actions to be executed at each frame
     float a;
   if (mousePressed&&keyPressed) {if(edited==1) Q.dragPolygon(); else P.dragPolygon();}
   noFill(); stroke(orange,100); strokeWeight(5); arrow(P.centerV(),V(P.centerV(),Q.centerV()));
        a=P.distances(Q); fill(dred); text("distances = "+str(a),10,12); noFill(); R.copyFrom(P); R.registerTo(Q,a); strokeWeight(2); stroke(dred); R.drawEdges(); R.drawPoints(2); 
        a=P.moments(Q); fill(dgreen); text("moments = "+str(a),10,32); noFill(); R.copyFrom(P); R.registerTo(Q,a); strokeWeight(1); stroke(dgreen); R.drawEdges(); R.drawPoints(2);
        a=P.angles(Q); fill(blue); text("angles = "+str(a),10,52); noFill(); R.copyFrom(P); R.registerTo(Q,a); stroke(blue); R.drawEdges(); R.drawEdges(); R.drawPoints(2);
    strokeWeight(4); stroke(red); fill(red);       Q.drawPoints(4);  noFill(); Q.drawEdges();
    strokeWeight(4); stroke(green); fill(green);   P.drawPoints(4);  noFill(); P.drawEdges();
    fill(dgreen); P.writePointIDs(); fill(dred); Q.writePointIDs();    
    if(draw){fill(magenta);P.drawVec(Q);noFill();}
//    text("dd="+str(dd),width-100,12);
    };


