class Signature{
  public ArrayList<Genom> genom = new ArrayList<Genom>();
  public float maxDeviation = 0.0f;
  public vec2 normal;
  public vec2 tangent;
}
class Genom {
  public int cntVal = 0;
  public ArrayList<Integer> allIndex = new ArrayList<Integer>();
  public Genom(){}
  public Genom(int c, int i)
  {
    cntVal = c;
    allIndex.add(i);
  }
  public Genom(int c, ArrayList<Integer> val)
  {
    cntVal = c;
    for(int i = 0; i < val.size();i++)
    {
      allIndex.add(val.get(i));
    }
  }
}
