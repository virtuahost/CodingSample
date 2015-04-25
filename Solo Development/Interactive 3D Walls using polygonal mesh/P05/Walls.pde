void showWalls(pts P, pts Q){
  int n=min(P.nv,Q.nv);
  for (int i=n-1, j=0; j<n; i=j++) {
    beginShape(); v(P.G[i]); v(P.G[j]); v(Q.G[j]); v(Q.G[i]); endShape(CLOSE);
    }
  }
