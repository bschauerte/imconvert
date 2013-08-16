
/* Eigen decomposition code for symmetric 3x3 matrices, copied from the public
   domain Java Matrix library JAMA. */

#include <cmath>

#ifdef __MEX
#include "mex.h"
#endif

#ifdef MAX
#undef MAX
#endif

#define MAX(a, b) ((a)>(b)?(a):(b))
#define HYPOT2(x,y) sqrt((x)*(x)+(y)*(y))

#define _N 3

#define IND3X3(x,y) ((y)*_N+(x))

// Symmetric Householder reduction to tridiagonal form.
void
tred2(double V[_N*_N], double d[_N], double e[_N])
{

//  This is derived from the Algol procedures tred2 by
//  Bowdler, Martin, Reinsch, and Wilkinson, Handbook for
//  Auto. Comp., Vol.ii-Linear Algebra, and the corresponding
//  Fortran subroutine in EISPACK.

  for (int j = 0; j < _N; j++) {
    d[j] = V[IND3X3(_N-1,j)];
  }

  // Householder reduction to tridiagonal form.

  for (int i = _N-1; i > 0; i--) {

    // Scale to avoid under/overflow.

    double scale = 0.0;
    double h = 0.0;
    for (int k = 0; k < i; k++) {
      scale = scale + fabs(d[k]);
    }
    if (scale == 0.0) {
      e[i] = d[i-1];
      for (int j = 0; j < i; j++) {
        d[j] = V[IND3X3(i-1,j)];
        V[IND3X3(i,j)] = 0.0;
        V[IND3X3(j,i)] = 0.0;
      }
    } else {

      // Generate Householder vector.

      for (int k = 0; k < i; k++) {
        d[k] /= scale;
        h += d[k] * d[k];
      }
      double f = d[i-1];
      double g = sqrt(h);
      if (f > 0) {
        g = -g;
      }
      e[i] = scale * g;
      h = h - f * g;
      d[i-1] = f - g;
      for (int j = 0; j < i; j++) {
        e[j] = 0.0;
      }

      // Apply similarity transformation to remaining columns.

      for (int j = 0; j < i; j++) {
        f = d[j];
        V[IND3X3(j,i)] = f;
        g = e[j] + V[IND3X3(j,j)] * f;
        for (int k = j+1; k <= i-1; k++) {
          g += V[IND3X3(k,j)] * d[k];
          e[k] += V[IND3X3(k,j)] * f;
        }
        e[j] = g;
      }
      f = 0.0;
      for (int j = 0; j < i; j++) {
        e[j] /= h;
        f += e[j] * d[j];
      }
      double hh = f / (h + h);
      for (int j = 0; j < i; j++) {
        e[j] -= hh * d[j];
      }
      for (int j = 0; j < i; j++) {
        f = d[j];
        g = e[j];
        for (int k = j; k <= i-1; k++) {
          V[IND3X3(k,j)] -= (f * e[k] + g * d[k]);
        }
        d[j] = V[IND3X3(i-1,j)];
        V[IND3X3(i,j)] = 0.0;
      }
    }
    d[i] = h;
  }

  // Accumulate transformations.

  for (int i = 0; i < _N-1; i++) {
    V[IND3X3(_N-1,i)] = V[IND3X3(i,i)];
    V[IND3X3(i,i)] = 1.0;
    double h = d[i+1];
    if (h != 0.0) {
      for (int k = 0; k <= i; k++) {
        d[k] = V[IND3X3(k,i+1)] / h;
      }
      for (int j = 0; j <= i; j++) {
        double g = 0.0;
        for (int k = 0; k <= i; k++) {
          g += V[IND3X3(k,i+1)] * V[IND3X3(k,j)];
        }
        for (int k = 0; k <= i; k++) {
          V[IND3X3(k,j)] -= g * d[k];
        }
      }
    }
    for (int k = 0; k <= i; k++) {
      V[IND3X3(k,i+1)] = 0.0;
    }
  }
  for (int j = 0; j < _N; j++) {
    d[j] = V[IND3X3(_N-1,j)];
    V[IND3X3(_N-1,j)] = 0.0;
  }
  V[IND3X3(_N-1,_N-1)] = 1.0;
  e[0] = 0.0;
} 

// Symmetric tridiagonal QL algorithm.
void 
tql2(double V[_N*_N], double d[_N], double e[_N]) 
{

//  This is derived from the Algol procedures tql2, by
//  Bowdler, Martin, Reinsch, and Wilkinson, Handbook for
//  Auto. Comp., Vol.ii-Linear Algebra, and the corresponding
//  Fortran subroutine in EISPACK.

  for (int i = 1; i < _N; i++) {
    e[i-1] = e[i];
  }
  e[_N-1] = 0.0;

  double f = 0.0;
  double tst1 = 0.0;
  double eps = pow(2.0,-52.0);
  for (int l = 0; l < _N; l++) {

    // Find small subdiagonal element

    tst1 = MAX(tst1,fabs(d[l]) + fabs(e[l]));
    int m = l;
    while (m < _N) {
      if (fabs(e[m]) <= eps*tst1) {
        break;
      }
      m++;
    }

    // If m == l, d[l] is an eigenvalue,
    // otherwise, iterate.

    if (m > l) {
      int iter = 0;
      do {
        iter = iter + 1;  // (Could check iteration count here.)

        // Compute implicit shift

        double g = d[l];
        double p = (d[l+1] - g) / (2.0 * e[l]);
        double r = HYPOT2(p,1.0);
        if (p < 0) {
          r = -r;
        }
        d[l] = e[l] / (p + r);
        d[l+1] = e[l] * (p + r);
        double dl1 = d[l+1];
        double h = g - d[l];
        for (int i = l+2; i < _N; i++) {
          d[i] -= h;
        }
        f = f + h;

        // Implicit QL transformation.

        p = d[m];
        double c = 1.0;
        double c2 = c;
        double c3 = c;
        double el1 = e[l+1];
        double s = 0.0;
        double s2 = 0.0;
        for (int i = m-1; i >= l; i--) {
          c3 = c2;
          c2 = c;
          s2 = s;
          g = c * e[i];
          h = c * p;
          r = HYPOT2(p,e[i]);
          e[i+1] = s * r;
          s = e[i] / r;
          c = p / r;
          p = c * d[i] - s * g;
          d[i+1] = h + s * (c * g + s * d[i]);

          // Accumulate transformation.

          for (int k = 0; k < _N; k++) {
            h = V[IND3X3(k,i+1)];
            V[IND3X3(k,i+1)] = s * V[IND3X3(k,i)] + c * h;
            V[IND3X3(k,i)] = c * V[IND3X3(k,i)] - s * h;
          }
        }
        p = -s * s2 * c3 * el1 * e[l] / dl1;
        e[l] = s * p;
        d[l] = c * p;

        // Check for convergence.

      } while (fabs(e[l]) > eps*tst1);
    }
    d[l] = d[l] + f;
    e[l] = 0.0;
  }
  
  // Sort eigenvalues and corresponding vectors.

  for (int i = 0; i < _N-1; i++) {
    int k = i;
    double p = d[i];
    for (int j = i+1; j < _N; j++) {
      if (d[j] < p) {
        k = j;
        p = d[j];
      }
    }
    if (k != i) {
      d[k] = d[i];
      d[i] = p;
      for (int j = 0; j < _N; j++) {
        p = V[IND3X3(j,i)];
        V[IND3X3(j,i)] = V[IND3X3(j,k)];
        V[IND3X3(j,k)] = p;
      }
    }
  }
}

void 
eigen_decomposition(double A[_N*_N], double V[_N*_N], double d[_N]) {
  double e[_N];
  for (int i = 0; i < _N; i++) {
    for (int j = 0; j < _N; j++) {
      V[IND3X3(i,j)] = A[IND3X3(i,j)];
    }
  }
  tred2(V, d, e);
  tql2(V, d, e);
}

#ifdef __MEX
void
mexFunction (int nlhs, mxArray* plhs[], 
	int nrhs, const mxArray* prhs[])
{
  /* Check number of input parameters */
	if (nrhs != 1) 
  {
  	mexErrMsgTxt("Two inputs required.");
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
  for (int i = 0; i < _N; i++)
  {
    for (int j = 0; j < _N; j++)
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
  
  // make a copy to allow in place manipulation
  double mat_data_c[_N*_N];
  for (int i = 1; i < (_N*_N); i++)
    mat_data_c[i] = mat_data[i];
  
  eigen_decomposition(mat_data_c,eigvecs_data,eigvals_data);
  
	return;
}
#endif