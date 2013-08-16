function F=imconvert_zca(f,n)
  % IMCONVERT_ZCA whitens the color space information using the ZCA
  %   transformation, i.e. make the color space component covariance matrix
  %   a identity matrix.
  %
  %   See http://ufldl.stanford.edu/wiki/index.php/Whitening for the 
  %   difference of ZCA and PCA.   
  %   "When using ZCA whitening (unlike PCA whitening), we usually keep all
  %    n dimensions of the data, and do not try to reduce its dimension."
  %
  %   The algorithmic difference of PCA and ZCA can be seen easily in the
  %   equations at the end of http://ufldl.stanford.edu/wiki/index.php/Implementing_PCA/Whitening
  %
  % If you use any of this work in scientific research or as part of a larger
  % software system, you are kindly requested to cite the use in any related 
  % publications or technical documentation. The work is based upon:
  %
  % [1] B. Schauerte, T. Woertwein, R. Stiefelhagen, "Color Decorrelation
  %     Helps Visual Saliency Detection". In Proceedings of the 20th 
  %     International Conference on Image Processing (ICIP), 2015.
  %
  % INPUT
  % f: the image
  % n: number of color channels you want to keep
  %
  % OUTPUT
  % F: transformed image
  %
  % @author B. Schauerte
  % @date 2013

  % Copyright 2013-2015 B. Schauerte. All rights reserved.
  %
  % Redistribution and use in source and binary forms, with or without
  % modification, are permitted provided that the following conditions are
  % met:
  %
  %    1. Redistributions of source code must retain the above copyright
  %       notice, this list of conditions and the following disclaimer.
  %
  %    2. Redistributions in binary form must reproduce the above copyright
  %       notice, this list of conditions and the following disclaimer in
  %       the documentation and/or other materials provided with the
  %       distribution.
  %
  % THIS SOFTWARE IS PROVIDED BY B. SCHAUERTE ''AS IS'' AND ANY EXPRESS OR
  % IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  % WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  % DISCLAIMED. IN NO EVENT SHALL B. SCHAUERTE OR CONTRIBUTORS BE LIABLE
  % FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  % CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  % SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
  % BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  % WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  % OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  % ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  %
  % The views and conclusions contained in the software and documentation
  % are those of the authors and should not be interpreted as representing
  % official policies, either expressed or implied, of B. Schauerte.

  if nargin < 2, n=size(f,3); end
  
  [h, w, c] = size(f);
  
  X = reshape(f, [h*w size(f,3)] );
  Y = zcawhiten(X);
  F = reshape(Y, [h w size(f,3)]);
  
  if n ~= size(f,3)
    Y = F(:,:,1:n);
  end