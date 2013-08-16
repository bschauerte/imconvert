#include "mex.h"
#include "3x3C/dsyevd3.h"

#define IND3X3(x,y) ((x)*_N+(y))
#define _N 3

void
mexFunction (int nlhs, mxArray* plhs[], 
	int nrhs, const mxArray* prhs[])
{
  /* Check number of input parameters */
	if (nrhs != 1) 
  {
  	mexErrMsgTxt("One input required.");
  } 
  else 
  {
		if (nlhs > 2) 
	  {
  		mexErrMsgTxt("Wrong number of output arguments.");
	  }
  }

  /* Check type of input parameters */
	if (!mxIsDouble(prhs[0])) 
		mexErrMsgTxt("Input has to be double.");
	
	/* Input data */
	const mxArray* mat = prhs[0];
	const double* mat_data = mxGetPr(mat);
	
  if (mxGetM(mat) != _N || mxGetN(mat) != _N) 
		mexErrMsgTxt("Input has to be a 3x3 matrix.");
  
  bool is_symmetric = true;
  int i = 0, j = 0;
  for (i = 0; i < _N; i++)
  {
    for (j = 0; j < _N; j++)
    {
      if (mat_data[IND3X3(i,j)] != mat_data[IND3X3(j,i)])
      {
        is_symmetric = false;
        mexErrMsgTxt("Input has to be a symmetric matrix.");
      }
    }
  }
  
	/* Output data */
	mxArray* eigvecs = mxCreateNumericMatrix (_N, _N, mxDOUBLE_CLASS, mxREAL);
  mxArray* eigvals = mxCreateNumericMatrix (_N, 1, mxDOUBLE_CLASS, mxREAL);
	plhs[0] = eigvecs;
  plhs[1] = eigvals;
	double* eigvecs_data = mxGetPr(eigvecs);
  double* eigvals_data = mxGetPr(eigvals);
  
  double in[3][3];
  double v[3][3];
  double d[3];
  
  for (i = 0; i < _N; i++)
  {
    for (j = 0; j < _N; j++)
    {
      in[i][j] = mat_data[IND3X3(i,j)];
    }
  }
  
  /*dsyevd3(in,v,d);*/
  dsyevj3(in,v,d);
  
  for (i = 0; i < _N; i++)
  {
    eigvals_data[i] = d[i];
    for (j = 0; j < _N; j++)
    {
      eigvecs_data[IND3X3(j,i)] = v[i][j];
    }
  }
  
	return;
}