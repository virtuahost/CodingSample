//CS 7492 HW3
//Author: Deep Ghosh
//Last Date Update: 03/02/2015

int cellHt = 2;
int cellWdth = 2;
int numCells = 500;
int spdUp = 1000;
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB;
int[][] arrDisplay = new int[numCells][numCells];
ArrayList<cellDLAInfo> lstCellInfo = new ArrayList<cellDLAInfo>();
ArrayList<cellDBMInfo> lstDBMGrowInfo = new ArrayList<cellDBMInfo>();
ArrayList<cellDBMInfo> lstDBMCandidateInfo = new ArrayList<cellDBMInfo>();
String printText = "";
Boolean growthOngoing = true, DLA = true, DBM = false;
float stickyFactor = 1;
float eta = 0;
float R1 = cellHt/2;
int particleCount = 5000;
float minElecStat = 0;
float maxElecStat = 0;

void setup()
{
  size(cellHt*numCells, cellWdth*numCells);
  initialState();
}

void draw()
{  
  background(black);
  for (int i = 0; i < numCells; i++)
  {
    for (int j = 0; j < numCells; j++)
    {
      if (arrDisplay[i][j] == 1)colorPixel(i, j);
    }
  } 
  if (growthOngoing)
  {
    for(int k=0; k<spdUp;k++)
    {
      setCellStates();
    }
  }
  fill(red);
  text(printText, 800, 100);
  text("Use c to clear, = to speed up \n and - to slow down simulation", 800, 50);
  noFill();
}

void keyPressed()
{
  if (keyPressed)
  {
    if (key==' ') {
      growthOngoing = !growthOngoing;
    }
    if (key=='s') {
      growthOngoing = false;
      for(int k=0; k<spdUp;k++)
      {
        setCellStates();
      }
    }
    if (key=='c') {
      initialState();
    }
    if (key=='1') {
      DBM = false;
      DLA = true;
      stickyFactor = 1;
      initialState();
    }
    if (key=='2') {
      DBM = false;
      DLA = true;
      stickyFactor = 0.1;
      initialState();
    }
    if (key=='3') {
      DBM = false;
      DLA = true;
      stickyFactor = 0.01;
      initialState();
    }
    if (key=='0') {
      DBM = false;
      DLA = true;
      stickyFactor = 0.5;
      multSeedState();
    }
    if (key=='=') {
      spdUp = spdUp + 500;
      if(spdUp > 5000)
      {
        spdUp = 5000;
      }  
    }
    if (key=='-') {
      spdUp = spdUp - 500;
      if(spdUp < 500 && DLA)
      {
        spdUp = 500;
      }
      if(spdUp < 1 && DBM)
      {
        spdUp = 1;
      } 
    }
    if (key=='4') {
      DBM = true;
      DLA = false;
      eta = 0;
      initialState();
    }
    if (key=='5') {
      DBM = true;
      DLA = false;
      eta = 3;
      initialState();
    }
    if (key=='6') {
      DBM = true;
      DLA = false;
      eta = 6;
      initialState();
    }
  }
}

void mousePressed()
{
  int i = mouseX/cellHt;
  int j = mouseY/cellWdth;
  if (i >= numCells || j >= numCells)return;
  printText = " i: " + i + "\n j: " + j;
}

void colorPixel(int i, int j)
{
  fill(white);
  stroke(white);
  rect(i*cellHt, j*cellWdth, cellHt, cellWdth);
  noFill();
}
void initialState()
{
  particleCount = 5000;
  lstCellInfo.clear();
  lstDBMGrowInfo.clear();
  lstDBMCandidateInfo.clear();
  for (int i = 0; i < numCells; i++)
  {
    for (int j = 0; j < numCells; j++)
    {
      arrDisplay[i][j]=0;
    }
  }
  if(DLA)
  {
    spdUp = 1000;
    for(int i = 0; i < particleCount; i++)
    {    
      cellDLAInfo newCell = new cellDLAInfo(round(random(width)), round(random(height)));
      lstCellInfo.add(newCell);
    }
  }
  if(DBM)
  {
    spdUp = 1;
    cellDBMInfo newCell = new cellDBMInfo(numCells/2, numCells/2);
    lstDBMGrowInfo.add(newCell);
    newCell.addCandidates(true);
    updateCandPhiEta();
  }
  arrDisplay[numCells/2][numCells/2] = 1;
}

void updateCandPhiEta()
{
  for(int i = 0; i < lstDBMCandidateInfo.size();i++)
  {
    lstDBMCandidateInfo.get(i).calcPhiEta();
  }
}

void multSeedState()
{
  particleCount = 5000*5;
  lstCellInfo.clear();
  for (int i = 0; i < numCells; i++)
  {
    for (int j = 0; j < numCells; j++)
    {
      arrDisplay[i][j]=0;
    }
  }
  if(DLA)
  {
    for(int i = 0; i < particleCount; i++)
    {    
      cellDLAInfo newCell = new cellDLAInfo(round(random(width)), round(random(height)));
      lstCellInfo.add(newCell);
    }
  }
  arrDisplay[numCells/4][numCells/3] = 1;
  arrDisplay[3*numCells/4][numCells/2] = 1;
  arrDisplay[numCells/2][numCells/2] = 1;
  arrDisplay[numCells/2][3*numCells/4] = 1;
  arrDisplay[numCells/3][numCells/4] = 1;
}

void setCellStates()
{
  if (DLA)
  {
    changeDLAState();
  }
  if(DBM)
  {
    changeDBMState();
  }
}
void changeDLAState()
{
  for (int i = 0; i < particleCount; i++)
  { 
    if (!lstCellInfo.get(i).noWalk)
    {
      int x = lstCellInfo.get(i).posI + randomWalk();
      int y = lstCellInfo.get(i).posJ + randomWalk();
      if(x<0)x = x+ numCells;
      if(y<0)y = y + numCells;
      int shiftValNeg1 = (x)%numCells;
      int shiftValNeg2 = (y)%numCells;
      lstCellInfo.get(i).posI = shiftValNeg1;
      lstCellInfo.get(i).posJ = shiftValNeg2;
      if (!lstCellInfo.get(i).hasNoNeighbours())
      {
        arrDisplay[lstCellInfo.get(i).posI][lstCellInfo.get(i).posJ] = 1;
        lstCellInfo.get(i).noWalk = true;
      }
    }
  }
}

void changeDBMState()
{
  int i = selectCell();
  cellDBMInfo newCell = new cellDBMInfo(lstDBMCandidateInfo.get(i).posI, lstDBMCandidateInfo.get(i).posJ);
  lstDBMCandidateInfo.remove(i);
  newCell.updateElecVal(false);
  lstDBMGrowInfo.add(newCell);
  arrDisplay[newCell.posI][newCell.posJ] = 1;
  newCell.addCandidates(false);
}

int selectCell()
{
  float totPhiVal = 0;
  updateCandPhiEta();
  for(int i = 0; i < lstDBMCandidateInfo.size();i++)
  {
    totPhiVal = totPhiVal + lstDBMCandidateInfo.get(i).phi_i_eta;
  }
  float partSum =0;
  for(int i = 0; i < lstDBMCandidateInfo.size();i++)
  {
    if(totPhiVal != 0)
    {
      lstDBMCandidateInfo.get(i).phi_i  = lstDBMCandidateInfo.get(i).phi_i_eta/totPhiVal;
    }
    partSum = partSum + lstDBMCandidateInfo.get(i).phi_i;
    lstDBMCandidateInfo.get(i).partial_sum_i = partSum;
  }
  float R = random(0,partSum);
  for(int i = 0; i < lstDBMCandidateInfo.size();i++)
  {
    if(R <lstDBMCandidateInfo.get(i).partial_sum_i)
    {
      return i;
    }
  }
  return 0;
}

int randomWalk()
{
  int resultVal = 0;
  resultVal = round(random(-1, 1));  
  return resultVal;
}

