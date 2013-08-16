function [F, A, W]=imconvert_ica(f)
  % IMCONVERT_ICA transforms an image into a ICA color space representation
  %
  % INPUT
  % f: the image
  %
  % OUTPUT
  % F: transformed image
  %
  % NOTE
  %   requires the fastica library
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
  % @date   2012-2015
  % @url    http://www.schauerte.me

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

  % ICA requires the FastICA library [addpath(genpath('../libs/FastICA_25/'))]
  if ~exist('fastica','file')
    error('imconvert_ica requires the FastICA package');
  end
  
  [h w c] = size(f);
  ff = reshape(f,[h*w c]);
  [icasig, A, W]=fastica(ff');
  A=A';
  W=W';
  %F=reshape(icasig',[h w c]);
  F=reshape(icasig',h,w,[]);