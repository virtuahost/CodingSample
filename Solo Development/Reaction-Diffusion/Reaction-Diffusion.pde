//CS 7492 HW3
//Author: Deep Ghosh
//Last Date Update: 03/02/2015

int cellHt = 4;
int cellWdth = 4;
int numCells = 200;
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB;
float ru = 0.082, rv = 0.041;
float k = 0.055, f = 0.062;
Boolean display = true, varPara = false, showDiffusion = false, printU = true, printV = false;
float[][] arrU = new float[numCells][numCells];
float[][] arrV = new float[numCells][numCells];
float plainBlack = 255;
float dt = 1.0;
float maxU = 1.0;
float minU = 0.0;
float maxV = 1.0;
float minV = 0.0;
String printText = "";
float renderSpeed = 10.0;

void setup()
{
  size(cellHt*numCells+numCells, cellWdth*numCells);
  initialState();
}

void draw()
{  
  background(white);
  for (int i = 0; i < numCells; i++)
  {
    for (int j = 0; j < numCells; j++)
    {
      colorGradient(arrU[i][j], arrV[i][j], i, j);
    }
  }  
  if (display)
  {
    for(int m=0;m<renderSpeed;m++)
    {
      calcDiffusion();
    }
  }  
  fill(cyan);
  rect(cellHt*numCells, 0, numCells, cellWdth*numCells);
  if (printText != "")
  {
    fill(red);
    text(printText, cellHt*numCells + 2, 20);
  }
  fill(red);
  text("Rendering speed: " + renderSpeed, cellHt*numCells + 2, 100);
  text("Use = to increase speed \n and - to decrease speed.", cellHt*numCells + 2, 120);
  text("Time step values are \n clamped between 1 and 20", cellHt*numCells + 2, 160);
  noFill();
}

void keyPressed()
{
  if (keyPressed && key == '1')
  {
    k = 0.0625;
    f = 0.035;
    initialState();
  }
  if (keyPressed && key == '2')
  {
    k = 0.06;
    f = 0.035;
    initialState();
  }
  if (keyPressed && key == '3')
  {
    k = 0.0475;
    f = 0.0118;
    initialState();
  }
  if (keyPressed && key == '4')
  {
    k = 0.0545;
    f = 0.0222;
    initialState();
  }
  if (keyPressed && key == 'i')
  {
    initialState();
  }
  if (keyPressed && key == 'u')
  {
    printU = true;
    printV = false;
  }
  if (keyPressed && key == 'v')
  {
     printV = true;
     printU = false;
  }
  if (keyPressed && key == 'd')
  {
    showDiffusion = !showDiffusion;
  }
  if (keyPressed && key == 'p')
  {
    varPara = !varPara;
  }
  if (keyPressed && key == ' ')
  {
    display = !display;
  }
  if (keyPressed && key == '=')
  {
    renderSpeed = renderSpeed + 1;
    if(renderSpeed > 20)
    {
      renderSpeed = 20;
    }
  }
  if (keyPressed && key == '-')
  {
    renderSpeed = renderSpeed - 1;
    if(renderSpeed <= 1)
    {
      renderSpeed = 1;
    }
  }
}

void mousePressed()
{
  int i = mouseX/cellHt;
  int j = mouseY/cellWdth;
  if (i >= numCells || j >= numCells)return;
  printText = " i: " + i + "\n j: " + j + "\n U: " + arrU[i][j] + "\n V: " +  arrV[i][j];
  if (varPara)
  {
    float varF = (numCells-j) * 0.08/numCells;
    float varK = 0.03 + i * (0.04)/numCells;
    printText = printText + "\n K: " + varK + "\n F: " +  varF;
  }
}

void colorGradient(float u, float v, int i, int j)
{
  if(printU)
  {
    fill(plainBlack * (u)/(maxU - minU));
    stroke(plainBlack * (u)/(maxU - minU));
  }
  if(printV)
  {
    fill(plainBlack * (1-(v)/(maxV - minV)));
    stroke(plainBlack * (1-(v)/(maxV - minV)));
  }
  rect(i*cellHt, j*cellWdth, cellHt, cellWdth);
  fill(green);
  noFill();
}
void calcDiffusion()
{
  float Lu = 0, Lv = 0, uvv = 0;
  float varF = f, varK = k;
  for (int i = 0; i < numCells; i++)
  {
    for (int j = 0; j < numCells; j++)
    {
      int shiftValNeg1 = (i-1+numCells)%numCells;
      int shiftValNeg2 = (j-1+numCells)%numCells;

      int shiftValPos1 = (i+1)%numCells;
      int shiftValPos2 = (j+1)%numCells;
      if (varPara)
      {
        varF = (numCells-j) * 0.08/numCells;
        varK = 0.03 + i * (0.04)/numCells;
      }
      Lu = arrU[shiftValPos1][j] + arrU[shiftValNeg1][j] + arrU[i][shiftValPos2] + arrU[i][shiftValNeg2] - 4*arrU[i][j];
      Lv = arrV[shiftValPos1][j] + arrV[shiftValNeg1][j] + arrV[i][shiftValPos2] + arrV[i][shiftValNeg2] - 4*arrV[i][j];
      uvv = arrU[i][j]*arrV[i][j]*arrV[i][j];
      if (!showDiffusion)
      {
        arrU[i][j] = arrU[i][j] + dt*((varF*(1-arrU[i][j])) - uvv + ru*Lu);
        arrV[i][j] = arrV[i][j] + dt*(-(varF + varK)*arrV[i][j] + uvv + rv*Lv);
      } else
      {
        arrU[i][j] = arrU[i][j] + dt*ru*Lu;
        arrV[i][j] = arrV[i][j] + dt*rv*Lv;
      }
      if (arrU[i][j] < minU)
      {
        minU = arrU[i][j];
      }
      if (arrU[i][j] > maxU)
      {
        maxU = arrU[i][j];
      }
      if (arrV[i][j] < minV)
      {
        minV = arrV[i][j];
      }
      if (arrV[i][j] > maxV)
      {
        maxV = arrV[i][j];
      }
    }
  }
}
void initialState()
{
  for (int i = 0; i < numCells; i++)
  {
    for (int j = 0; j < numCells; j++)
    {
      arrU[i][j] = 1;
      arrV[i][j] = 0;
    }
  }
  for (int i = 10; i < 20; i ++)
  {
    for (int j = 10; j < 20; j++)
    {
      arrU[i][j] = 0.5;
      arrV[i][j] = 0.25;
    }
  }
  dt = 1;
}

