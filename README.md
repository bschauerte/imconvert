# imconvert

**imconvert** is an image color space conversion library. Apart from the 
typical color conversions such as, e.g., RGB to Grey, it allows to perform
color decorrelation (PCA, ZCA, ICA), color space normalization (01, Median
Absolute Deviation, and TanH), and color space weighting. Furthermore, it 
allows to train own decorrelated color spaces based on given image sets.

If you use any of this work in scientific research or as part of a larger
software system, you are kindly requested to cite the use in any related 
publications or technical documentation. The work is based upon:

    B. Schauerte, T. Woertwein, R. Stiefelhagen, "Color Decorrelation Helps
    Visual Saliency Detection". In Proceedings of the 20th International 
    Conference on Image Processing (ICIP), 2015.


## 3rd Party Software

* FastICA, Copyright (c) Hugo Gävert, Jarmo Hurri, Jaakko Särelä, and Aapo Hyvärinen, GPL
* 3x3: Numerical diagonalization of 3x3 matrices, Copyright (c) Joachim Kopp, LGPL
* colorspace, Copyright (c) Pascal Getreuer, BSD
* zcawhiten, Copyright (c) Colorado Reed, BSD
* eig3, C++ module 'eig3', Connelly Barnes, Public Domain

License information:

* FastICA: http://research.ics.aalto.fi/ica/fastica/about.shtml
* zcawhiten: http://de.mathworks.com/matlabcentral/fileexchange/34471-data-matrix-whitening/content/whiten.m
* eig3: http://barnesc.blogspot.de/2007/02/eigenvectors-of-3x3-symmetric-matrix.html

## Authors and Contact

* [Boris Schauerte](http://www.schauerte.me "Boris Schauerte")
* Torsten Woertwein