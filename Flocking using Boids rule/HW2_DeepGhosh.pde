//CS 7492 HW1
//Author: Deep Ghosh
//Last Date Update: 02/03/2015

int cellHt = 10;
int cellWdth = 8;
int numCells = 100;
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB;
ArrayList<creature_list> allCreatures = new ArrayList<creature_list>();
Boolean wanderForceToggle = true, veloMatchingForceToggle = true, collAvoidForceToggle = true, centreFlockForceToggle = true, display = true,attract = false,repel = false, setPathing = false;

void setup()
{
  size(cellHt*numCells, cellWdth*numCells);  
  creature_list lstCreatureOne = new creature_list();
  for (int i =0; i <20; i++)
  {
    PVector position = new PVector(width/2,height/2);
    creature objCreature = new creature(position.x,position.y, i); 
    lstCreatureOne.lstCreature.add(objCreature);
  }
  allCreatures.add(lstCreatureOne);
}

void draw()
{  
  if(!setPathing)background(black);  
  fill(white);
  allCreatures.get(0).flockStep();
  text("Centering: " + (centreFlockForceToggle?"on":"off") + " Collisions: " + (!collAvoidForceToggle?"on":"off") + " Velocity matching: " + (veloMatchingForceToggle?"on":"off") + " Wandering: " + (wanderForceToggle?"on":"off"),100,100);
  text("Number of Creatures: " + allCreatures.get(0).count(), 700,100);
  noFill();
}

void keyPressed()
{
  if(keyPressed && key == '1')
  {
    centreFlockForceToggle = !centreFlockForceToggle;
  }
  if(keyPressed && key == '2')
  {
    collAvoidForceToggle = !collAvoidForceToggle;
  }
  if(keyPressed && key == '3')
  {
    veloMatchingForceToggle = !veloMatchingForceToggle;
  }
  if(keyPressed && key == '4')
  {
    wanderForceToggle = !wanderForceToggle;
  }
  if(keyPressed && key == '=')
  {
    allCreatures.get(0).addCreature();
  }
  if(keyPressed && key == '-')
  {
    allCreatures.get(0).removeCreature();
  }
  if(keyPressed && key == 's')
  {
    allCreatures.get(0).scatter();
  }
  if(keyPressed && key == 'c')
  {
    allCreatures.get(0).clearScreen();
  }
  if(keyPressed && key == 'p')
  {
    setPathing = !setPathing;
  }
  if(keyPressed && key == ' ')
  {
    display = !display;
  }
}

void mousePressed()
{
  if(mousePressed && keyPressed && key == 'a')
  {
    attract = true;
  }
  if(mousePressed && keyPressed && key == 'r')
  {
    repel = true;
  }
}

void mouseReleased()
{
  attract = false;
  repel = false;
}

