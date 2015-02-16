class KalmanFilter {
  MatrixManipulator X = null;
  MatrixManipulator A = null;
  MatrixManipulator P = null;
  MatrixManipulator H = null;
  MatrixManipulator R = null;
  MatrixManipulator Z = null;
  MatrixManipulator U = null;
  MatrixManipulator K = null;
  MatrixManipulator I = null;
    
  public KalmanFilter()
  {
    float[][] arrX = {{1,1,1}};
    X = new MatrixManipulator(arrX);
    float[][] arrA = {{1,1,0},{0,1,1},{0,0,1}};
    A = new MatrixManipulator(arrA);
    float[][] arrP = {{1,0,0},{0,1,0},{0,0,1}};
    P = new MatrixManipulator(arrP);
    float[][] arrH = {{1,0,0},{0,1,0},{0,0,1}};
    H = new MatrixManipulator(arrH);
    float[][] arrR = {{0.0000064,0,0},{0,0.000064,0},{0,0,0.000064}};
    R = new MatrixManipulator(arrR);
    Z = new MatrixManipulator(3,1);
    float[][] arrU = {{1,1,0}};
    U = new MatrixManipulator(arrU);
    float[][] arrI = {{1,0,0},{0,1,0},{0,0,1}};
    I = new MatrixManipulator(arrI);
  }
  
  void Update(pt2 inputP,float t)
  {
     t = t*0.00001;
     MatrixManipulator tempX = null;    //Temp variable to store parts of the new X calculation
     MatrixManipulator tempK = null;        //Temp variable to store parts of the Kalman Gain filter calculation 
     float[][] arrZ = {{inputP.x,inputP.y,1}};
     Z = new MatrixManipulator(arrZ);
     float[][] arrA = {{1,0,t},{0,1,t},{0,0,1}};
     A = new MatrixManipulator(arrA);  
     X = X.multiply(A).add(U);            //Predict Next State           
//     A.printMatrix();
//     P.printMatrix();
//     P = A.multiply(P);
//     P.printMatrix();
     P = (A.multiply(P)).multiply(A.transpose());      //Predict next Prediction Error
//     P.printMatrix();
     tempK = ((H.multiply(P)).multiply(H.transpose())).add(R);   //Calculates the inverse part of the Gain equation
//     tempK.printMatrix();
     K = (H.multiply(P)).multiply(tempK.inverse());      //Calculates new gain     
     P = I.minus(K.multiply(H)).multiply(P);    // Calculating Predcition Error
     tempX = Z.minus(X.multiply(H));
     X = X.add(tempX.multiply(K));
  }
  
  pt2 predict(float t)
  {
     t = t*0.00001;
     float[][] arrA = {{1,t,0},{0,1,t},{0,0,1}};
     A = new MatrixManipulator(arrA);
     MatrixManipulator X1 = X.multiply(A).add(U);
     println("t: " + t + "loc: " + X1._arrMatrix[0][0] + ", " + X1._arrMatrix[0][1]);
     return P2(X1._arrMatrix[0][0],X1._arrMatrix[0][1]);
  }  
}
