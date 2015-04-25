public class cellDBMInfo{
  public int posI;
  public int posJ;
  public Boolean noWalk = false;
  public float elecStatVal = 0.0f;
  public float phi_i_eta = 0.0f;
  public float phi_i = 0.0f;
  public float partial_sum_i = 0.0f;
  public cellDBMInfo(int x,int y)
  {
    posI = x;
    posJ = y;
  }
  public cellDBMInfo(int x,int y,Boolean calcInit)
  {
    posI = x;
    posJ = y;
    this.updateElecVal(calcInit);
  }
  public void addCandidates(boolean init)
  {
    int shiftValNeg1 = (posI-1+numCells)%numCells;
    int shiftValNeg2 = (posJ-1+numCells)%numCells;
    
    int shiftValPos1 = (posI+1)%numCells;
    int shiftValPos2 = (posJ+1)%numCells;
    if(init)
    {
      cellDBMInfo newCell = new cellDBMInfo(shiftValNeg1, posJ,true);
      lstDBMCandidateInfo.add(newCell);
      arrDisplay[shiftValNeg1][posJ] = 2;
      maxElecStat = lstDBMCandidateInfo.get(0).elecStatVal;
      minElecStat = lstDBMCandidateInfo.get(0).elecStatVal;
      
      newCell = new cellDBMInfo(shiftValNeg1, shiftValNeg2,true);
      lstDBMCandidateInfo.add(newCell);
      arrDisplay[shiftValNeg1][shiftValNeg2] = 2;
      
      newCell = new cellDBMInfo(shiftValNeg1, shiftValPos2,true);
      lstDBMCandidateInfo.add(newCell);
      arrDisplay[shiftValNeg1][shiftValPos2] = 2;
      
      newCell = new cellDBMInfo(shiftValPos1, posJ,true);
      lstDBMCandidateInfo.add(newCell);
      arrDisplay[shiftValPos1][posJ] = 2;
      
      newCell = new cellDBMInfo(shiftValPos1, shiftValNeg2,true);
      lstDBMCandidateInfo.add(newCell);
      arrDisplay[shiftValPos1][shiftValNeg2] = 2;
      
      newCell = new cellDBMInfo(shiftValPos1, shiftValPos2,true);
      lstDBMCandidateInfo.add(newCell);
      arrDisplay[shiftValPos1][shiftValPos2] = 2;
      
      newCell = new cellDBMInfo(posI, shiftValNeg2,true);
      lstDBMCandidateInfo.add(newCell);
      arrDisplay[posI][shiftValNeg2] = 2;
      
      newCell = new cellDBMInfo(posI, shiftValPos2,true);
      lstDBMCandidateInfo.add(newCell);
      arrDisplay[posI][shiftValPos2] = 2;
    }
    else
    {
      if(arrDisplay[shiftValNeg1][posJ] == 0)
      {
        cellDBMInfo newCell = new cellDBMInfo(shiftValNeg1, posJ,true);
        lstDBMCandidateInfo.add(newCell);
        arrDisplay[shiftValNeg1][posJ] = 2;
      }
      
      if(arrDisplay[shiftValNeg1][shiftValNeg2] == 0)
      {
        cellDBMInfo newCell = new cellDBMInfo(shiftValNeg1, shiftValNeg2,true);
        lstDBMCandidateInfo.add(newCell);
        arrDisplay[shiftValNeg1][shiftValNeg2] = 2;
      }
      
      if(arrDisplay[shiftValNeg1][shiftValPos2] == 0)
      {
        cellDBMInfo newCell = new cellDBMInfo(shiftValNeg1, shiftValPos2,true);
        lstDBMCandidateInfo.add(newCell);
        arrDisplay[shiftValNeg1][shiftValPos2] = 2;
      }
      
      if(arrDisplay[shiftValPos1][posJ] == 0)
      {
        cellDBMInfo newCell = new cellDBMInfo(shiftValPos1, posJ,true);
        lstDBMCandidateInfo.add(newCell);
        arrDisplay[shiftValPos1][posJ] = 2;
      }
      
      if(arrDisplay[shiftValPos1][shiftValNeg2] == 0)
      {
        cellDBMInfo newCell = new cellDBMInfo(shiftValPos1, shiftValNeg2,true);
        lstDBMCandidateInfo.add(newCell);
        arrDisplay[shiftValPos1][shiftValNeg2] = 2;
      }
      
      if(arrDisplay[shiftValPos1][shiftValPos2] == 0)
      {
        cellDBMInfo newCell = new cellDBMInfo(shiftValPos1, shiftValPos2,true);
        lstDBMCandidateInfo.add(newCell);
        arrDisplay[shiftValPos1][shiftValPos2] = 2;
      }
      
      if(arrDisplay[posI][shiftValNeg2] == 0)
      {
        cellDBMInfo newCell = new cellDBMInfo(posI, shiftValNeg2,true);
        lstDBMCandidateInfo.add(newCell);
        arrDisplay[posI][shiftValNeg2] = 2;
      }
      
      if(arrDisplay[posI][shiftValPos2] == 0)
      {
        cellDBMInfo newCell = new cellDBMInfo(posI, shiftValPos2,true);
        lstDBMCandidateInfo.add(newCell);
        arrDisplay[posI][shiftValPos2] = 2;
      }
    }
  }
  public void updateElecVal(boolean init)
  {
    if(init)
    {
      float pot = 0;
      for(int i = 0; i < lstDBMGrowInfo.size();i++)
      {
        pot = pot + ( 1 - (R1/dstanceBetCells(lstDBMGrowInfo.get(i))));
      }  
      this.elecStatVal = pot; 
      if(this.elecStatVal > maxElecStat)
      {
        maxElecStat = this.elecStatVal;
      }
      if(this.elecStatVal < minElecStat)
      {
        minElecStat = this.elecStatVal;
      }
    }
    else
    {
      maxElecStat = lstDBMCandidateInfo.get(0).elecStatVal;
      minElecStat = lstDBMCandidateInfo.get(0).elecStatVal;
      for(int i = 0; i < lstDBMCandidateInfo.size();i++)
      {
        lstDBMCandidateInfo.get(i).elecStatVal = lstDBMCandidateInfo.get(i).elecStatVal + (1 - (R1/lstDBMCandidateInfo.get(i).dstanceBetCells(this)));
        if(lstDBMCandidateInfo.get(i).elecStatVal > maxElecStat)
        {
          maxElecStat = lstDBMCandidateInfo.get(i).elecStatVal;
        }
        if(lstDBMCandidateInfo.get(i).elecStatVal < minElecStat)
        {
          minElecStat = lstDBMCandidateInfo.get(i).elecStatVal;
        }
      }
    }
  }
  public void calcPhiEta()
  {
    float diffRange = maxElecStat - minElecStat;
    float diffElecStat = this.elecStatVal - minElecStat;
    float totVal = diffElecStat/diffRange;
    this.phi_i_eta = pow(totVal,eta);
  }
  public float dstanceBetCells(cellDBMInfo Q)
  {
    return sqrt(sq(Q.posI*cellHt-this.posI*cellHt)+sq(Q.posJ*cellWdth-this.posJ*cellWdth));
  }
}  
