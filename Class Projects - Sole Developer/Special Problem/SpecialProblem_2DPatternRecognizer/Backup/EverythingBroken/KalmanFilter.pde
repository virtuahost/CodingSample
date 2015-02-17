class KalmanFilter {
//  Matrix X = null;
//  Matrix A = null;
//  Matrix P = null;
//  Matrix H = null;
//  Matrix R = null;
//  Matrix Z = null;
//  Matrix U = null;
//  Matrix K = null;
//  Matrix I = null;
//    
//  public KalmanFilter()
//  {
//    double[][] arrX = {{1,1,1}};
//    X = new Matrix(arrX);
//    double[][] arrA = {{1,1,0},{0,1,1},{0,0,1}};
//    A = new Matrix(arrA);
//    double[][] arrP = {{1,0,0},{0,1,0},{0,0,1}};
//    P = new Matrix(arrP);
//    double[][] arrH = {{1,0,0},{0,1,0},{0,0,1}};
//    H = new Matrix(arrH);
//    double[][] arrR = {{1,0,0},{0,1,0},{0,0,1}};
//    R = new Matrix(arrR);
//    Z = new Matrix(3,1);
//    double[][] arrU = {{1,1,0}};
//    U = new Matrix(arrU);
//    double[][] arrI = {{1,0,0},{0,1,0},{0,0,1}};
//    I = new Matrix(arrI);
//  }
//  
//  void Update(pt2 inputP,double t)
//  {
//     t = t*0.00001;
//     Matrix tempX = null;    //Temp variable to store parts of the new X calculation
//     Matrix tempK = null;        //Temp variable to store parts of the Kalman Gain filter calculation 
//     double[][] arrZ = {{inputP.x,inputP.y,1}};
//     Z = new Matrix(arrZ);
//     double[][] arrA = {{1,0,t},{0,1,t},{0,0,1}};
//     A = new Matrix(arrA);  
//     X = X.multiply(A).plus(U);            //Predict Next State           
////     A.printMatrix();
////     P.printMatrix();
////     P = A.multiply(P);
////     P.printMatrix();
//     P = (A.multiply(P)).multiply(A.transpose());      //Predict next Prediction Error
////     P.printMatrix();
//     tempK = ((H.multiply(P)).multiply(H.transpose())).plus(R);   //Calculates the inverse part of the Gain equation
////     tempK.printMatrix();
//     K = (H.multiply(P)).multiply(tempK.inverse());      //Calculates new gain     
//     P = I.minus(K.multiply(H)).multiply(P);    // Calculating Predcition Error
//     tempX = Z.minus(X.multiply(H));
//     X = X.plus(tempX.multiply(K));
//  }
//  
//  pt2 predict(double t)
//  {
//     t = t*0.00001;
//     double[][] arrA = {{1,t,0},{0,1,t},{0,0,1}};
//     A = new Matrix(arrA);
//     Matrix X1 = X.multiply(A).plus(U);
//     println("t: " + t + "loc: " + X1._arrMatrix[0][0] + ", " + X1._arrMatrix[0][1]);
//     return P2(X1._arrMatrix[0][0],X1._arrMatrix[0][1]);
//  }  
  private Matrix A = new Matrix(2, 2);   //state transition matrix
  private Matrix B = new Matrix(2, 1);   //input control matrix
  private Matrix C = new Matrix(2, 2);   //measurement matrix
  private double accU = 1;              //Acceleration defaulted to 1
  private Matrix initState = new Matrix(2, 1); //Initialize initial position to 0,0
  private Matrix estimatedState = initState; //Make the estimate and measured state same
  private double minCovarX = 1;           //Min covariance to move X along.
  private double minCovarZ = 1;           //Min covariance to move Z along.
  private Matrix P;               //position variance
  double[][] arrI = {{1,0},{0,1}};
  Matrix I = new Matrix(arrI);
  
  public double getaccU()
  {
    return accU;
  }
  public void setaccU(double lat)
  {
    accU = lat;
  }
  
  public void Update(pt2 loc, double time)
  {
    if(loc != null)
    {
      time = time * 0.001;
      double[][] temp = new double[][] {{1,time},{0,1}};
      A = new Matrix(temp);
      temp = new double[][] {{time*time/2},{time}};
      B = new Matrix(temp);
      temp = new double[][] {{1,0},{0,1}};
      C = new Matrix(temp);
      temp = new double[][] {{time*time*time*time/4 + minCovarX*minCovarX,time*time*time/2 + minCovarX*minCovarX},{time*time*time/2 + minCovarX*minCovarX,time*time + minCovarX*minCovarX}};
      Matrix Ex = new Matrix(temp);      //position noise conversion to Covariance matrix
      temp = new double[][] {{1,0},{0,1}};
      Ex = new Matrix(temp);
      if(P == null)
      {
        P = Ex;
      }  
      temp = new double[][]{{minCovarZ*minCovarZ,0},{0,1}};
      Matrix Ez = new Matrix(temp);
      estimatedState = A.solve(estimatedState).plus(B);
      P = A.solve(P).solve(A.transpose()).plus(Ex);
      Matrix K = new Matrix(2,2);
      K = P.solve(C.transpose()).solve((C.solve(P).solve(C.transpose()).plus(Ez)).inverse());
      temp = new double[][] {{loc.x},{loc.y}};
      Matrix tempLoc = new Matrix(temp);
      estimatedState = estimatedState.plus(K.solve(tempLoc.minus(C.solve(estimatedState))));
      P = (I.minus(K.solve(C))).solve(P);
    }
  }
  
  public pt2 predict(double time)
  {
    time = time * 0.001;
    double[][] temp = new double[][] {{1,time},{0,1}};
    A = new Matrix(temp);
    temp = new double[][] {{time*time/2},{time}};
    B = new Matrix(temp);  
    Matrix predState = new Matrix(2, 1);
    predState = A.solve(estimatedState).plus(B);
    double x = predState.get(0,0);
    double y = predState.get(1,0);
    println("new loc: x: " + x + ", y: " + y);
    return P2((float)x,(float)y); 
  }
}
