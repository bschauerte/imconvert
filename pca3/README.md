# PCA-3

A fast implementation of a PCA for data with 3 dimensions.

## Why

1. **Specialization**: We only need to calculate eigenvectors/-values for symmetric 3x3 matrices. There exist optimized algorithms for that!
2. **Speed-up**: We can calculate the eigenvectors/-values roughly 10x faster; from 1.5~2ms to 0.15~0.2ms (see test_eig.m); however, consider that eigs comes with a lot of overhead (i.e., the comparison is a little unfair at this point)
3. **Further**: ... libraries may not be the optimal choice because they are optimized mainly for large (and often sparse) matrices.

## Links

* http://barnesc.blogspot.de/2007/02/eigenvectors-of-3x3-symmetric-matrix.html
* http://www.mpi-hd.mpg.de/personalhomes/globes/3x3/