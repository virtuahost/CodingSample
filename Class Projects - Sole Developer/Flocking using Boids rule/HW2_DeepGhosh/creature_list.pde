class creature_list{
  public ArrayList<creature> lstCreature = new ArrayList<creature>();
  
  public void flockStep()
  {
    for(creature objTemp: lstCreature)
    {
      if(display)objTemp.move(lstCreature);
      objTemp.drawShape();
    }
  }
  
  public void addCreature()
  {
    PVector position = new PVector(width/2,height/2);
    creature objTemp = new creature(position.x,position.y, lstCreature.size());
    lstCreature.add(objTemp);
  }
  
  public void removeCreature()
  {
    if(lstCreature.size()>0)lstCreature.remove(0);
  }
  
  public void scatter()
  {
    for(creature objTemp: lstCreature)
    {
      float x = random(0,cellWdth*numCells);
      float y = random(0,cellHt*numCells);
      objTemp.position.x = x;
      objTemp.position.y = y;
    }
  }
  
  public void clearScreen()
  {
    int size = lstCreature.size();
    for(int i =0 ; i < size;i++)
    {
      lstCreature.remove(0);
    }
  }
  
  public float count()
  {
    return lstCreature.size();
  }
}
