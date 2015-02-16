//All necessary functions for matrix manipulation.
//Inverse function code uses excerpts from http://www.codeproject.com/Articles/405128/Matrix-operations-in-Java

class MatrixManipulator {
  public float[][] _arrMatrix;
  public int _row;
  public int _col;
  
  public MatrixManipulator(int rowProvd, int colProvd)
  {
    _row = rowProvd;
    _col = colProvd;
    _arrMatrix = new float[_row][_col];
    for(int i =0; i < _row; i ++)
    {
      for(int j =0; j < _col; j ++)
      {
        _arrMatrix[i][j] = 0;
      }
    }
  }
  public MatrixManipulator(float[][] arrInput)
  {
    _row = arrInput.length;
    _col = arrInput[0].length;
    _arrMatrix = new float[_row][_col];
    for(int i =0; i < _row; i ++)
    {
      for(int j =0; j < _col; j ++)
      {
        _arrMatrix[i][j] = arrInput[i][j];
      }
    }
  }
  public MatrixManipulator transpose()
  {
    float[][] transMatrix = new float[_col][_row];
    for(int i =0; i < _col; i ++)
    {
      for(int j =0; j < _row; j ++)
      {
        transMatrix[i][j] = _arrMatrix[j][i];
      }
    } 
     return new MatrixManipulator(transMatrix);
  }
  public MatrixManipulator multiply(MatrixManipulator arrSecondMatrix)
  {
    MatrixManipulator tempMatrix = null;
    float element = 0;
    if(arrSecondMatrix._row == _col)
    {
      tempMatrix = new MatrixManipulator(_row,arrSecondMatrix._col);
      for(int i =0; i < arrSecondMatrix._col; i ++)
      {
        for(int j =0; j < _row; j ++)
        {
          for(int k = 0; k < _col; k++)
          {
            element = element + _arrMatrix[j][k]*arrSecondMatrix._arrMatrix[k][i];
          }
          tempMatrix._arrMatrix[j][i] = element;
          element = 0;
        }
      }
    }
    return tempMatrix;
  }
  public MatrixManipulator multiply(float val)
  {
    float[][] tempMatrix = new float[_row][_col];
    for(int i =0; i < _row; i ++)
    {
      for(int j =0; j < _col; j ++)
      {
        tempMatrix[j][i] = val * _arrMatrix[j][i];
      }
    }
    return new MatrixManipulator(tempMatrix);
  }
  public MatrixManipulator add(MatrixManipulator arrSecondMatrix)
  {
    MatrixManipulator tempMatrix = null;
    if(arrSecondMatrix._row == _row && arrSecondMatrix._col == _col)
    {
      tempMatrix = new MatrixManipulator(_row,arrSecondMatrix._col);
      for(int i =0; i < _row; i ++)
      {
        for(int j =0; j < _col; j ++)
        {
          tempMatrix._arrMatrix[i][j] = _arrMatrix[i][j] + arrSecondMatrix._arrMatrix[i][j];
        }
      }
    }
    return tempMatrix;
  }
  public MatrixManipulator inverse()
  {
    return this.cofactor().transpose().multiply(1.0/this.determinant()); 
  }
  public MatrixManipulator cofactor()
  {
    MatrixManipulator tempMatrix = new MatrixManipulator(_row, _col);
    for(int i =0; i < _row; i ++)
      {
        for(int j =0; j < _col; j ++)
        {
            tempMatrix._arrMatrix[i][j] = pow(-1,(i+j+2)) * createSubMatrix(this, i, j).determinant();
        }
    }
    
    return tempMatrix;
  }
  public MatrixManipulator createSubMatrix(MatrixManipulator matrix, int excluding_row, int excluding_col) {
    MatrixManipulator tempMatrix = new MatrixManipulator(this._row-1, this._col-1);
    int r = -1;
    for (int i=0;i<tempMatrix._row;i++) {
        if (i==excluding_row)
            continue;
            r++;
            int c = -1;
        for (int j=0;j<tempMatrix._col;j++) {
            if (j==excluding_col)
                continue;
            tempMatrix._arrMatrix[r][++c] = matrix._arrMatrix[i][j];
        }
    }
    return tempMatrix;
  } 
  public MatrixManipulator minus(MatrixManipulator arrSecondMatrix)
  {
    MatrixManipulator tempMatrix = null;
    if(arrSecondMatrix._row == _row && arrSecondMatrix._col == _col)
    {
      tempMatrix = new MatrixManipulator(_row,arrSecondMatrix._col);
      for(int i =0; i < _row; i ++)
      {
        for(int j =0; j < _col; j ++)
        {
          tempMatrix._arrMatrix[i][j] = _arrMatrix[i][j] - arrSecondMatrix._arrMatrix[i][j];
        }
      }
    }
    return tempMatrix;
  }
  public float determinant()
  {
    float temp = 0.0f;
    if(_row == _col)
    {
      if(_row == 2)
      {
        temp = _arrMatrix[0][0] * _arrMatrix[1][1] - _arrMatrix[0][1] * _arrMatrix[1][0];
      }
      else if(_row == 1)
      {
        temp = _arrMatrix[0][0];
      }
      else
      {
        for(int k =0; k < _col; k ++)
        {
          float[][] recMatrix = new float[(_row-1)][(_col-1)];
          for(int i =0; i < _row; i ++)
          {
            for(int j =0; j < _col; j ++)
            {
              if(i!=0 && k!=j)
              {
                recMatrix[i][j] = _arrMatrix[i][j];
              }
            }
          } 
          MatrixManipulator recCall = new MatrixManipulator(recMatrix);
          temp = temp + ((k == 0 || k%2 == 0)?1:-1) * _arrMatrix[0][k] * recCall.determinant();
        }
      }
    }
    return temp;
  }
  public void printMatrix()
  {
    println("Matrix Start: ");
    for(int i =0; i < _col; i++)
    {
      for(int j =0; j < _row; j ++)
      {
        println("Row: " + j + " Col: " + i + " value: " +_arrMatrix[i][j]);
      }
    }
    println("Matrix End: ");
  }
}
