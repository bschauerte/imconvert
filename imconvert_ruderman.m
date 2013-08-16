function F = imconvert_ruderman(f)
% IMCONVERT_RUDERMAN converts an RGB image into the de-correlated ruderman
% lab color space
%
%   D.L. Ruderman, T.W. Cronin, and C.C. Chiao, “Statistics
%   of Cone Responses to Natural Images: Implications for Visual Coding,”
%   J. Optical Soc. of America, vol. 15, no. 8,1998, pp. 2036-2045
%
% INPUT
% f: the RGB image
%
% OUTPUT
% F: transformed image
%
% If you use any of this work in scientific research or as part of a larger
% software system, you are kindly requested to cite the use in any related 
% publications or technical documentation. The work is based upon:
%
% [1] B. Schauerte, T. Woertwein, R. Stiefelhagen, "Color Decorrelation
%     Helps Visual Saliency Detection". In Proceedings of the 20th 
%     International Conference on Image Processing (ICIP), 2015.
%
% @author T. Wörtwein
% @date 2014

% Copyright 2014-2015 T. Wörtwein. All rights reserved.
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
% official policies, either expressed or implied, of T. Wörtwein.

%% convert to LMS
[h, w, c] = size(f);
assert(c == 3);
lms = imconvert(f, 'rgb', 'cat02lms');

%% normalize values
% L = log_10(L) - mean(log_10(L))
% M = log_10(M) - mean(log_10(M))
% S = log_10(S) - mean(log_10(S))

lms = lms + eps;
assert(any(lms(:) == 0) == false);

lms_log = log10(lms);
lms_log_mean = mean(mean(lms_log, 1), 2);
lms = bsxfun(@minus, lms_log, lms_log_mean);

%% convert LMS to lab
%
%       | 1/sqrt(3)   0           0          |   |-1.004     1.005   0.991|
% lab = | 0           1/sqrt(6)   0          | * | 1.014     0.968  -2.009| * LMS
%       | 0           0           1/sqrt(2)  |   | 0.993    -1.007   0.016|
a = [1/sqrt(3) 0            0;
    0           1/sqrt(6)   0;
    0           0           1/sqrt(2)];
b = [-1.004     1.005       0.991;
    1.014       0.968       -2.009;
    0.993       -1.007      0.016];
m = a*b;

tmp = m * reshape(lms, h*w, c)';
F = reshape(tmp', h, w, c);
% tmp = reshape(lms, h*w, c) * m;
% F = reshape(tmp, h, w, c);
end