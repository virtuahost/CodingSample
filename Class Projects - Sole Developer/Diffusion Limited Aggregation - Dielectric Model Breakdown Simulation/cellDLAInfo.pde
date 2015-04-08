public class cellDLAInfo{
  public int posI;
  public int posJ;
  public Boolean noWalk = false;
  public cellDLAInfo(int x,int y)
  {
    posI = x;
    posJ = y;
  }
  public Boolean hasNoNeighbours()
  {
    int shiftValNeg1 = (posI-1+numCells)%numCells;
    int shiftValNeg2 = (posJ-1+numCells)%numCells;
    
    int shiftValPos1 = (posI+1)%numCells;
    int shiftValPos2 = (posJ+1)%numCells;
    if(arrDisplay[shiftValPos1][posJ] == 1
    || arrDisplay[posI][shiftValPos2] == 1
    || arrDisplay[shiftValNeg1][posJ] == 1
    || arrDisplay[posI][shiftValNeg2] == 1
    || arrDisplay[shiftValPos1][shiftValNeg2] == 1
    || arrDisplay[shiftValPos1][shiftValPos2] == 1
    || arrDisplay[shiftValNeg1][shiftValPos2] == 1
    || arrDisplay[shiftValNeg1][shiftValNeg2] == 1)
    {
      float ranStck = random(0,1);
      if(ranStck <= stickyFactor)
      {        
        return false;
      }
    }
    return true;
  }
}
