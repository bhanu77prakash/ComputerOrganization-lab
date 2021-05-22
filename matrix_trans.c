#include <stdio.h>

int main(){
	int n,m,s,sum,i,j;
	scanf("%d%d%d", &m,&n, &s);
	sum = s;
	int A[m][n], B[n][m];
	for(i=0;i<m;i++){
		for(j =0; j<n;j++){
			sum = (330*sum+100)%481;
			A[i][j] = sum;
		}
	}
	matPrint(n,m,A);
	printf("\n");
	matTranspose(n,m,A,B);
	matPrint(m,n,B);
}

void matPrint(int n, int m, int A[][n]){
	int i,j;
	for(i=0;i<m;i++){
		for(j=0;j<n;j++){
			printf("%d ", A[i][j]);
		}
		printf("\n");
	}
}

void matTranspose(int n, int m, int A[][n], int B[][m]){
	int i,j;
	for (i = 0; i < m; ++i)
	{
		for (j = 0; j < n; ++j)
		{
			B[j][i] = A[i][j];
		}
	}
}
