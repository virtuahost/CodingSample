class Signature{
  public ArrayList<Genom> genom = new ArrayList<Genom>();
  public float maxDeviation = 0.0f;
  public vec2 normal;
  public vec2 tangent;
}
class Genom {
  public int cntVal = 0;
  public int firstIndex = -1;
  public Genom(){}
  public Genom(int c, int i)
  {
    cntVal = c;
    firstIndex = i;
  }
}
