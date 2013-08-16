function timg = imconvert_tanh(img,percentiles,spread)
  % Tanh-estimators (robust and highly efficient)
  %
  % Taken from
  %   A. Jain, et al., "Score normalization in multimodal biometric
  %   systems", Pattern Recognition, 2005, p. 2278
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

  if nargin < 2, percentiles = [0.7 0.85 0.95]; end
  if nargin < 3, spread = 0.1; end % spread of the normalized genuine scores

  [h, w, t] = size(img);
  features = reshape(img,[h*w t]);

  %%
  % estimate mu_GH & sigma_GH on the data after the influence function
  % was applied to the data
  A = zeros(1,size(features,2));
  B = zeros(1,size(features,2));
  C = zeros(1,size(features,2));
  M = zeros(1,size(features,2));
  for i = 1:size(features,2)
    x = sort(features(:,i));
    n = numel(x);
    % get the median
    if rem(n,2) % n is odd
      M(i) = x((n+1)/2,:);
    else        % n is even
      M(i) = (x(n/2,:) + x(n/2+1,:))/2;
    end
    u = abs(x - M(i));
    [su,~] = sort(u);
    A(i) = su(floor(percentiles(1)*n));
    B(i) = su(floor(percentiles(2)*n));
    C(i) = su(floor(percentiles(3)*n));
  end

  % transform the training data using the influence function
  trans_features = features;
  for i = 1:size(trans_features,2)
    a = A(i);
    b = B(i);
    c = C(i);

    abs_trans_features = abs(trans_features(:,i));
    I1 = (0 <= abs_trans_features & abs_trans_features < a);
    I2 = (a <= abs_trans_features & abs_trans_features < b);
    I3 = (b <= abs_trans_features & abs_trans_features < c);
    I4 = (c <= abs_trans_features);
    trans_features(I1,i) = trans_features(I1,i);
    trans_features(I2,i) = a * sign(trans_features(I2,i));
    trans_features(I3,i) = a * trans_features(I3,i) .* ((c - abs_trans_features(I3)) ./ (c - b));
    trans_features(I4,i) = 0;
  end

  % estimate mu_GH & sigma_GH on the training data
  mu_GH_vec = mean(trans_features, 1);
  sigma_GH_vec = std(trans_features,[],1);

  if (max(sigma_GH_vec) / min(sigma_GH_vec)) > 10
    warning('max/min deviation is %f: It might be advisable to select a higher spread',(max(sigma_GH_vec) / min(sigma_GH_vec))); % please read carefully the paragraph on page 2279
  end

  %%
  % normalize
  features = tanh_normalization(features,mu_GH_vec,sigma_GH_vec,spread);
  timg = reshape(features,[h w t]);

  function Y = tanh_normalization(X,mu_GH,sigma_GH,spread)
    if nargin < 3, spread = 0.01; end
    
    Y = bsxfun(@minus,X,mu_GH);
    Y = bsxfun(@rdivide,Y,sigma_GH);
    
    Y = 0.5 * (tanh(spread * (Y)) + 1);
  end
end
