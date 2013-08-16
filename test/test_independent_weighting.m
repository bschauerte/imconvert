addpath(genpath('..'));

% X           = rand(10,10,3);
X           = uint8(255*rand(10,10,3));
weights     = [1,2,2];
weights_str = strrep(mat2str(weights),' ',',');

from = 'rgb';
to   = 'labm:zca:01'; %'rgb:pca';

Y  = imconvert(X,from,sprintf('%s',to));
YC = imconvert(X,from,sprintf('%s%s',to,weights_str));

error = 0;
for i=1:size(Y,3)
    error = error + sum(sum(abs(Y(:,:,i)*weights(i) - YC(:,:,i))));
end
error