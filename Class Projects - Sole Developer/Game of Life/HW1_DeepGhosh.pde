//CS 7492 HW1
//Author: Deep Ghosh
//Last Date Update: 01/07/2015

int cellHt = 6;
int cellWdth = 6;
int numCells = 100;
Boolean[][] lfSim = new Boolean[100][100]; //{{false,true,false},{false,true,false},{false,true,false}};      //Test Case remove later
Boolean[][] lsSimRuleSet = {{false,false},{false,false},{false,true},{true,true},{false,false},{false,false},{false,false},{false,false},{false,false}};        //Rule set to define cell status over time
Boolean[][] prevlfSim = new Boolean[100][100]; //{{false,true,false},{false,true,false},{false,true,false}};      //Test Case remove later
Boolean bContinous = false; 
Boolean singleModeOn = true;
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
   red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB;

void setup()
{
  size(cellHt*numCells,cellWdth*numCells);
  resetLifeSim(false,-1);
}

void draw()
{  
  background(black);
  for(int i =0;i<lfSim.length;i++)
  {
    for(int j =0;j<lfSim.length;j++)
    {
      if(lfSim[i][j])
      {
        fill(white);
        rect(i*cellHt,j*cellWdth,cellHt,cellWdth);
        noFill();
      }
      else
      {
        fill(black);
        rect(i*cellHt,j*cellWdth,cellHt,cellWdth);
        noFill();
      }
    }
  }
  if(bContinous)
  {
    updateState();
    if(singleModeOn)
    {
      bContinous = false;
    }
  }
}

//Common function to change state for each delta time.
void updateState()
{
  for(int i =0;i<lfSim.length;i++)
  {
    for(int j =0;j<lfSim.length;j++)
    {
      prevlfSim[i][j] = lfSim[i][j];
    }
  }
  for(int i =0;i<lfSim.length;i++)
  {
    for(int j =0;j<lfSim.length;j++)
    {
      int countCell = 0;
      Boolean bChkVal = false;
      
      int chkVal1 = i;
      int chkVal2 = j;
      
      int shiftValNeg1 = (i-1+numCells)%numCells;
      int shiftValNeg2 = (j-1+numCells)%numCells;
      
      int shiftValPos1 = (i+1)%numCells;
      int shiftValPos2 = (j+1)%numCells;
      
      bChkVal = prevlfSim[shiftValNeg1][shiftValNeg2];
      if(bChkVal)countCell++;
      bChkVal = prevlfSim[shiftValNeg1][chkVal2];
      if(bChkVal)countCell++;
      bChkVal = prevlfSim[shiftValNeg1][shiftValPos2];
      if(bChkVal)countCell++;
      
      bChkVal = prevlfSim[chkVal1][shiftValNeg2];
      if(bChkVal)countCell++;
      bChkVal = prevlfSim[chkVal1][shiftValPos2];
      if(bChkVal)countCell++;
      
      bChkVal = prevlfSim[shiftValPos1][shiftValNeg2];
      if(bChkVal)countCell++;
      bChkVal = prevlfSim[shiftValPos1][chkVal2];
      if(bChkVal)countCell++;
      bChkVal = prevlfSim[shiftValPos1][shiftValPos2];
      if(bChkVal)countCell++;
      
//      println("I: " + i + " J: " + j + " CountCell: " + countCell);
      Boolean chngToAlive = lsSimRuleSet[countCell][0];
      Boolean keepState = lsSimRuleSet[countCell][1];
      
      if(chngToAlive && keepState)
      {
        lfSim[i][j] = true;
      }
      else if(!keepState)
      {
        lfSim[i][j] = false;
      }
    }
  }
}

void keyPressed()
{
  if(keyPressed)
  {
    if(key==' ' && singleModeOn)
    {
      bContinous = true;
    }
    if(key=='g')
    {
      singleModeOn = !singleModeOn;
      bContinous = !singleModeOn;
    }
    if(key=='c')
    {
      resetLifeSim(false,-1);
    }
    if(key=='r')
    {
      resetLifeSim(true,-1);
    }
    if(key=='1')
    {
      resetLifeSim(true,1);
    }
    if(key=='2')
    {
      resetLifeSim(true,2);
    }
    if(key=='3')
    {
      resetLifeSim(true,3);
    }
    if(key=='4')
    {
      resetLifeSim(true,4);
    }
    if(key=='5')
    {
      resetLifeSim(true,5);
    }
  }
}

void mousePressed()
{
  int i = mouseX/cellHt;
  int j = mouseY/cellWdth;
  lfSim[i][j] = !lfSim[i][j];
}

//Common function to set cells in different configurations. First input to function specifies if any pattern needs to be generated or if all cells need to reset to black. Second input cycles between different patterns.
void resetLifeSim(Boolean randData, int mode)                
{  
  for(int i =0;i<lfSim.length;i++)
  {
    for(int j =0;j<lfSim.length;j++)
    {
      if(randData)
      {
        switch(mode)
        {
          case 1:                    //Simple bar pattern
            if(i==50&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==51&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==52&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else
            {
              lfSim[i][j] = false;
              prevlfSim[i][j] = false;
            }
          break;
          case 2:                //Glider
            if(i==50&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==51&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==52&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==50&&j==51)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==51&&j==52)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else
            {
              lfSim[i][j] = false;
              prevlfSim[i][j] = false;
            }
          break;
          case 3:                  //Pantanimo
            if(i==50&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==50&&j==51)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==50&&j==52)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==51&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==49&&j==51)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else
            {
              lfSim[i][j] = false;
              prevlfSim[i][j] = false;
            }
          break;
          case 4:                      //Double bar pattern
            if(i==50&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==51&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==52&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==51&&j==52)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==50&&j==54)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==51&&j==54)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==52&&j==54)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else
            {
              lfSim[i][j] = false;
              prevlfSim[i][j] = false;
            }
          break;
          case 5:                      //Spaceship
            if(i==50&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==51&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==52&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==53&&j==50)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==54&&j==51)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==50&&j==51)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==50&&j==52)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else if(i==51&&j==53)
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            else
            {
              lfSim[i][j] = false;
              prevlfSim[i][j] = false;
            }
          break;
          default:
            float randVal = random(-50, 50);
            if(randVal > 0)
            {
              lfSim[i][j] = false;
              prevlfSim[i][j] = false;
            }
            else
            {
              lfSim[i][j] = true;
              prevlfSim[i][j] = true;
            }
            break;
        }
      }
      else
      {
        lfSim[i][j] = false;
        prevlfSim[i][j] = false;
      }
    }
  }
}

