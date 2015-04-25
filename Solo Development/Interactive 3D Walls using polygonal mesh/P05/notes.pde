/*

6491 Project:
Compute a GVNS representation of a polygonal approximation of the Minkowski sum 
of a planar edge graph with a vertical cylinder. 
Support visualization and corner operations on the resulting mesh.

Start with the 3D visualization and polyloop editor code provided. 
It supports editing vertices in 2D and drawing a polyloop.
 
Combine that code with your edge-graph editor from the previous project 
and with your GVNS representation of vertices and corners 
and with your code for tracing offset sidewalk loops.

AN easier alternative may be to use a key to toggle the 2D and 3D modes.
In the 2D mode, you use your code from the previous project. 
When the user toggles inot the 3D mode, you compute the 3D mesh of the extrusion and let the user 
manipulate its view and use corner operators.

Then, provide an extrusion operation that extrudes each sidewalk into a vertical quad, 
constructs floor and ceiling faces, and produces a GVNS representation of the result.
Provide key-based support to demonstrate that your c.v, c.n, c.s corner operators 
still work (see result of c.s below).
Beware that the Minkowski sum may produce floor and ceiling faces that are multiply connected. 
You may choose to introduce bridge edges (as shown below).
   



Functionality of the code provided:
We show two polyloops, P and Q
User operates on P
‘e’ swaps them, ‘q’ changes Q to be a copy of P, ‘p’ does the reverse
Pressing ‘x’, ‘z’, ‘d’ selects the vertex of P that has the closest screen projection to the mouse
Pressing ‘d’ deletes the selected vertex
Dragging the mouse while ‘x’ is pressed moves the selected vertex of P in X and Y
Dragging the mouse while ‘z’ is pressed moves the selected vertex of P in Z
Using ‘X’ or ‘Z’ instead, translates all vertices of P similarly
‘0’ snaps all vertices of P to the floor (z=0)
Dragging the mouse moves the black insert point in X and Y
Its closest projection on P is shown as a translucent sphere
Dragging the mouse while holding SHIFT moves the black insert point on in Z
Pressing ‘i’ inserts a new vertex in P at the closest projection of the black point
Holding SPACE down and moving the mouse (not pressed) rotates the view
Holding ‘f’ down and dragging the mouse (pressed) translates the scene in X and Y
Holding ‘F’ down and dragging the mouse (pressed) translates the scene in Z
Pressing ‘_’ toggles the display of the greound (yellow square) and the global frame
Pressing ‘]’ toggles the display of the thick green rods along  P and red rods along Q
Pressing ‘w’ saves P to file. Pressing ‘W’ saves both P and Q
Pressing ‘l’ (or ‘L’) loads the saved files into P (or into P and Q)

Implementation:
Geometry3D:
Setup loads P and Q from files.
Draw controls the viewing transformation (angle and focus point F).
If showFloor, it shows the ground and the shadows of P 
It shows the black insert point
It computes the screen projections I, J, K of the basis vectors (see PICK section at end of pv3D)
  These are used to interpret mouse movements in the model frame
It always compute pp as the ID in P of the vertex closest to the mouse

If showControlPolygon, it shows the cones and balls along the polyloops of P and Q

Then, it shows the vertical walls as cyan quads (see code in Walls) 
and the floor and ceiling in yellow and orange (see drawClosedCurve method in pts)

You should replace the above display by the display of your polygonal mesh. 
You may use the ‘Z’ GUI to control the extrusion amount.

Implement ‘N’ and ‘S’ operators to perform the corresponding corner operators 
and show the current corner c as a red ball, c.n as a green ball, and c.s as a blue ball. 
Place these ball at a constant distance offset. 
So, pressing ‘N’ should move the red ball to the location of the green one…

I suggest that you start with the pts class, 
add the VNS arrays and operators that you wrote for the previous project, 
and then write an extrude(pts P, float r, float h) method that empties the current model 
and builds a new one that is the extrusion (approximation of the Minkowski sum of P a cylinder(r,h)). 
To use it, declare a new object E, and call E.extrude(P,r,h). Then, show E.
You will also need to write a show method that shows all the faces. 
Because the extrusion may create faces with several bounding loops, 
you need to decide whether you want to use the Processing support for such polygons or 
write your own code to split these faces.


*/
