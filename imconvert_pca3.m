function [F,V,D,I,m]=imconvert_pca3(f,n)
  % IMCONVERT_PCA transforms an image into a PCA color space representation
  %
  % INPUT
  % f: the image
  % n: number of PCA components and resulting color channels you want to keep
  %
  % OUTPUT
  % F: transformed image
  % V: the eigenaxes
  % D: the eigenvalues
  % I: the order of the output image channels of F, which is ordered in
  %    such way that the eigenvalues of the channels are descending
  %
  % If you use any of this work in scientific research or as part of a larger
  % software system, you are kindly requested to cite the use in any related 
  % publications or technical documentation. The work is based upon:
  %
  % [1] B. Schauerte, T. Woertwein, R. Stiefelhagen, "Color Decorrelation
  %     Helps Visual Saliency Detection". In Proceedings of the 20th 
  %     International Conference on Image Processing (ICIP), 2015.
  %
  % @author B. Schauerte
  % @date 2012

  % Copyright 2012-2015 B. Schauerte. All rights reserved.
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
    
  m = mean(mean(f,1), 2);
  [h, w, c] = size(f);
  fc = f - repmat(m, [h w 1]);
  X = reshape( fc, [h*w size(f,3)] );
  C = (X'*X)/(h*w);
  [V,D] = eig3x3(C);
  [D,I] = sort(D, 'descend'); 
  V = V(:,I);
  applymat_f = @(f,T)reshape( reshape(f, [h*w c])*T, [h w c] );
  rgb2pca_f = @(f,V,m) applymat_f(fc,V);
  F = rgb2pca_f(f,V,m);
  
  if n ~= size(f,3)
    F = F(:,:,1:n);
    D = D(1:n);
    V = V(:,1:n);
  end