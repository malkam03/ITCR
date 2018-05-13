/* 
 * File:   saxpy.c
 * Author: Malcolm Davis
 * Course: Computer Architecture II
 * Created on Feb 24, 2018
 * Simple matrix multiplication with OpenMP
 *
 * Ussage: 
 * ./argv[0] for default parameters and random vectors or;
 * ./argv[0] <m matrix 1 size> <n matrix 1 size> <m matrix 2 size> <n matrix 2 size> 
 */

#include <stdio.h> 
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <omp.h>

#define FLOAT_RAND_MAX 10000
#define MATRIX_SIZE_M 1000
#define MATRIX_SIZE_N 1000
#define MATRIX_SIZE_P 1000
#define MATRIX_SIZE_Q 1000

typedef struct doubleMatrix{
	double * data;
	long nrows;
	long ncols;
} double_matrix;

void generateMatrix(struct doubleMatrix* mat);
void printMatrix(struct doubleMatrix* mat);
void matMult(struct doubleMatrix* A, struct doubleMatrix* B, struct doubleMatrix* C);



/*
 * Main method, retrive command line options, create the threads
 */
int main(int argc, char const *argv[])
{
	const int printMatrixB = getenv("PRINT_MATRIX") ? 1 : 0;
	double start_time, run_time;
	srand(time(NULL));
	// If the vector size is inserted then use it if not then use the default 
	long m = argc > 1 && atol(argv[1]) > 0 ? atol(argv[1]) : MATRIX_SIZE_M;
	long n = argc > 2 && atol(argv[2]) > 0 ? atol(argv[2]) : MATRIX_SIZE_N;
	long p = argc > 3 && atol(argv[3]) > 0 ? atol(argv[3]) : MATRIX_SIZE_P;
	long q = argc > 4 && atol(argv[4]) > 0 ? atol(argv[4]) : MATRIX_SIZE_Q;
	if(n!=q){
		printf("Incompatible matrix sizes %ldx%ld and %ldx%ld", m,n,p,q);
		return -1;
	} 
	// Allocate memmory for the Matrix
	struct doubleMatrix A;
	struct doubleMatrix B;
	struct doubleMatrix C;
	A.data = (double*)malloc(sizeof(double)*m*n);
	A.nrows = m;
	A.ncols = n;
	B.data = (double*)malloc(sizeof(double)*p*q);
	B.nrows = p;
	B.ncols = q;
	C.data = (double*)calloc(m*q,sizeof(double));
	C.nrows = m;
	C.ncols = q;
	// Generate random Matrix
	generateMatrix(&A);
	generateMatrix(&B);
	// Print the Matrix
	if(printMatrixB){
		printf("----C=A*B----\n");
		printf("A: ");
		printMatrix(&A);
		printf("B: ");
		printMatrix(&B);
	}
	//Do the actual matMult and take the time
	start_time = omp_get_wtime();
	matMult(&A, &B, &C);
	run_time = omp_get_wtime() - start_time;
	//Print the result
	if(printMatrixB){
		printf("C: ");
		printMatrix(&C);
	}
	printf("Size(NXM) %ld Seconds(s) %f \n", q*n, run_time);
	// Free the allocated memmory
	free(A.data);
	free(B.data);
	free(C.data);
	return 0;
}


/*
 * matMult Function C = A*B
 * @param C the return matrix
 * @param A a matrix of double
 * @param B a matrix of double
 */
void matMult(struct doubleMatrix* A, struct doubleMatrix* B, struct doubleMatrix* C){
	long i, j, k;
	double sum = 0;
	#ifdef PARALLEL
	#pragma omp parallel for private(i,j,k, sum) shared(A, B, C)
	#endif
	for (i = 0; i < A->nrows; i++) {
      for (j = 0; j < B->ncols; j++) {
        for (k = 0; k < B->nrows; k++) {
          sum = sum + A->data[i*A->nrows+k]*B->data[k*B->nrows+j];
        }
        C->data[i*C->nrows+j] = sum;
        sum = 0;
      }
    }
}


/*
 * Function that fills a vector of size "size" with random numbers
 * @param (INPUT)size the length of the vector
 * @param (OUTPUT)vector the place where the data will be stored.  
 */
void generateMatrix(struct doubleMatrix* matrix){
	long i, j;
	#ifdef PARALLEL
	#pragma omp parallel for private(i, j) shared(matrix)
	#endif
	for(i=0; i < matrix->nrows; i++){
		for(j=0; j < matrix->ncols; j++){
			matrix->data[i*matrix->nrows+j] = ((double)rand()/(double)(RAND_MAX)) * FLOAT_RAND_MAX;
		}
	}
}

/*
 * Function that prints a vector on screen
 * @param (INPUT)size the length of the vector
 * @param (INPUT)vector the place where the data will be stored. 
 */
void printMatrix(struct doubleMatrix* matrix){
	for(long i=0; i < matrix->nrows; i++){
		printf("[");
		for(long j=0; j < matrix->ncols; j++){
			printf(" %lf ", matrix->data[i*matrix->nrows+j]);
		}
		printf("]\n");
	}
}