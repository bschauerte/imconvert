http://www.mpi-hd.mpg.de/personalhomes/globes/3x3/

Numerical diagonalization of 3x3 matrices

A common scientific problem is the numerical calculation of the eigensystem
of symmetric or hermitian 3x3 matrices. If this calculation has to be 
performed many times, standard packages like LAPACK, the GNU Scientific 
Library, and the Numerical Recipes Library may not be the optimal choice 
because they are optimized mainly for large matrices.

This website offers C and FORTRAN implementations of several algorithms
which were specifically optimized for 3x3 problems. All algorithms are
discussed in detail in the following paper:

Joachim Kopp
Efficient numerical diagonalization of hermitian 3x3 matrices
Int. J. Mod. Phys. C 19 (2008) 523-548
arXiv.org: physics/0610206