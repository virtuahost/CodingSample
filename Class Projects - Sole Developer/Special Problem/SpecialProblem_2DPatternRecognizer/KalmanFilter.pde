class KalmanFilter {
  MatrixManipulator X = null;
  MatrixManipulator F = null;
  MatrixManipulator P = null;
  MatrixManipulator H = null;
  MatrixManipulator R = null;
  MatrixManipulator Z = null;
  MatrixManipulator U = null;
  MatrixManipulator K = null;
  
  //Equations Used:
  //State:
  //x(t)=Ax'(t-1)+Bu(t)
  //A=[{1,t},{0,1}] 
  //B=[t^2/2,t]
  //C=[{1,0},{0,1}]      Made changes to fix issues in initial equation
  //Error Covariance
  //P(t)=AP(t-1)A^T+E(x)
  //Kalman Gain:
  //K(t)=P(t)C^T(CP(t)C^T+E(z))^-1
  //Measurement:
  //x'(t)=x(t)+k(t)(z'(t)-Cx(t))
  //P'(t)=(I-K(t)C)P(t)
  //I=Identity Matrix
  
  public KalmanFilter()
  {
    float[][] arrX = {{0,0.001}};
    X = new MatrixManipulator(arrX);
    float[][] arrF = {{1,0},{0,1}};
    F = new MatrixManipulator(arrF);
    float[][] arrP = {{1,0},{0,1}};
    P = new MatrixManipulator(arrP);
    float[][] arrH = {{1,0},{0,1}};
    H = new MatrixManipulator(arrH);
    float[][] arrR = {{1,0},{0,1}};
    R = new MatrixManipulator(arrR);
    Z = new MatrixManipulator(1,2);
    float[][] arrU = {{0.01,0.01}};
    U = new MatrixManipulator(arrU);
    K = new MatrixManipulator(2,2);
  }
  
  void Update(float x,float t)
  {
     MatrixManipulator Y = new MatrixManipulator(1,2);
     MatrixManipulator S = null;
     float[][] arrZ = {{x,1}};
     Z = new MatrixManipulator(arrZ);
     float[][] arrF = {{1,t},{0,1}};
     F = new MatrixManipulator(arrF);        
     X = X.multiply(F).add(U);
     P = (F.multiply(P)).multiply(F.transpose());
     S = ((H.multiply(P)).multiply(H.transpose())).add(R);
     K = (H.multiply(P)).multiply(S.inverse());
     Y = Z.minus(X.multiply(H));
     X = X.add(Y.multiply(K));
     P = P.minus(P.multiply(H.transpose()).multiply(S.inverse()).multiply(H).multiply(H));
  }
  
  float predict(float t)
  {
     float[][] arrF = {{1,t},{0,1}};
     F = new MatrixManipulator(arrF);
     MatrixManipulator X1 = X.multiply(F).add(U);
     println("t: " + t + "loc: " + X1._arrMatrix[0][0]);
     return X1._arrMatrix[0][0];
  }  
}
