class creature{
  public int idCreature = -1;
  public PVector position;
  public PVector velocity;
  private float maxVelocity = 5;
  private float maxEffectingVelocity = 0.3;
  private float maxAttrctVelocity = 7;
  private float nanOffset = 0.000001;
  private float flockCentreDist = 50;
  private float avoidDist = 25;
  
  public creature()
  {}
  
  public creature(float xPostn, float yPostn, int id)
  {
    position = new PVector(xPostn,yPostn);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    idCreature = id;
  }
  
  public void move(ArrayList<creature> arrTotal)
  {
    PVector flockCentering = centerFlock(arrTotal);
    PVector collAvoidance = collAvoid(arrTotal);
    PVector veloMatching = veloMatch(arrTotal);
    PVector wanderForce = wanderFrc();
    PVector attractForce = new PVector(0,0);
    
    PVector totalChange = new PVector(0,0);
    if(centreFlockForceToggle)totalChange.add(flockCentering);
    if(collAvoidForceToggle)totalChange.add(collAvoidance);
    if(veloMatchingForceToggle)totalChange.add(veloMatching);
    if(wanderForceToggle)totalChange.add(wanderForce);
    if(attract || repel)
    {
      PVector mousePostn = new PVector(mouseX,mouseY);
      if(attract)
      {
        attractForce = PVector.sub(mousePostn,position);
      }
      else if(repel)
      {
        attractForce = PVector.sub(position,mousePostn);
      }
      attractForce.normalize();
      attractForce.limit(maxAttrctVelocity);
      totalChange.add(attractForce);
    }
    velocity.add(totalChange);
    velocity.limit(maxVelocity);
    position.add(velocity);
    if(position.x < 0)
    {
      position.x = width;
    }
    if(position.x > width)
    {
      position.x = 0;
    }
    if(position.y < 0)
    {
      position.y = height;
    }
    if(position.y > height)
    {
      position.y = 0;
    }
  }
  
  private PVector centerFlock(ArrayList<creature> arrTotal)
  {
    PVector temp = new PVector(0,0);
    float totWght = 0 + nanOffset;
    for(creature objTemp: arrTotal)
    {
      float dist = PVector.dist(position, objTemp.position);
      if(dist >0 && dist < flockCentreDist)
      {
        float tempWght = weight(position,objTemp.position);
        PVector calcVector = PVector.sub(objTemp.position,position);
        calcVector.mult(tempWght);
        totWght = totWght + tempWght;
        temp.add(calcVector);
//        if(idCreature == 19)
//        {          
//          println(objTemp.idCreature + ", " + temp.mag());
//        }
      }
    }
    temp.div(totWght);    
    temp.normalize();
    temp.mult(maxVelocity);
    temp.limit(maxEffectingVelocity);
    temp.mult(1.0);
    return temp;
  }
    
  private PVector collAvoid(ArrayList<creature> arrTotal)
  {
    PVector temp = new PVector(0,0);
    for(creature objTemp: arrTotal)
    {       
      float dist = PVector.dist(position, objTemp.position);
      if(dist >0 && dist < avoidDist)
      { 
        float tempWght = weight(position,objTemp.position);
        PVector calcVector = PVector.sub(position,objTemp.position);
        calcVector.normalize();
        calcVector.mult(tempWght);
        temp.add(calcVector);        
//        if(idCreature == 19)
//        {          
//          println(objTemp.idCreature + ", " + temp.mag());
//        }
      }
    }
    if(temp.mag() > 0)
    {
      temp.normalize();
      temp.mult(maxVelocity);
      temp.sub(velocity);
      temp.limit(maxEffectingVelocity);
    }
    temp.mult(1.5);
    return temp;
  }
   
  private PVector veloMatch(ArrayList<creature> arrTotal)
  {
    PVector temp = new PVector(0,0);
    for(creature objTemp: arrTotal)
    {
      float dist = PVector.dist(position, objTemp.position);
      if(dist >0 && dist < flockCentreDist)
      {
        float tempWght = weight(position,objTemp.position);
        PVector calcVector = PVector.sub(objTemp.velocity,velocity);
        calcVector.mult(tempWght);
        temp.add(calcVector); 
//        if(idCreature == 19)
//        {          
//          println(objTemp.idCreature + ", " + temp.mag());
//        }
      }
    }
    if(temp.mag() > 0)
    {
      temp.normalize();
      temp.mult(maxVelocity);
      temp.limit(maxEffectingVelocity);
    }
    temp.mult(1.0);
    return temp;
  }
    
  private PVector wanderFrc()
  {
    float x = random(-0.5,0.5);
    float y = random(-0.5,0.5); 
    return new PVector(x,y);
  }
  
  private float weight(PVector start, PVector end)
  {
    float dist = sq(start.x-end.x)+sq(start.y-end.y);
    return (1/(dist + nanOffset)>=0?1/(dist + nanOffset):0);
  }
  
  public void drawShape()
  {
    float angleStart = 0;
    float angleEnd = 0;
    angleStart = velocity.heading()-PI/2;
    angleEnd = angleStart + PI;
    arc(position.x, position.y, cellHt, cellWdth,angleStart,angleEnd,OPEN);
  }
}
