% Check the eigenvector/eigenvalue implementation. If it is correct, then
% X*v(:,i) - v(:,i)*e(i) is (close to) a zero matrix (just see the 
% definition of eigenvectors and eigenvalues).
%
% @author B. Schauerte
% @date   2013

addpath(genpath('eig3'));
addpath(genpath('3x3'));

X = rand(3,3);
X = X*X';

fprintf('eigs:\n');
tic;
[v,e] = eigs(X);
t_eigs = toc();
e=diag(e);
for i = 1:3
  sum(X*v(:,i) - v(:,i)*e(i))
end

[v,e]

% % @Note: eig3 seems to be broken!
% fprintf('eig3:\n');
% [v,e] = eig3(X);
% v = v';
% for i = 1:3
%   sum(X*v(:,i) - v(:,i)*e(i))
% end

fprintf('eig3x3:\n');
tic;
[v,e] = eig3x3(X);
[e,I] = sort(e, 'descend'); 
v = v(:,I);
t_3x3 = toc();
for i = 1:3
  sum(X*v(:,i) - v(:,i)*e(i))
end

[v,e]

fprintf('Time of eigs: %fs\n',t_eigs);
fprintf('Time of 3x3:  %fs\n',t_3x3);
fprintf('Speed-up of eigs vs 3x3: %.3f\n',t_eigs / t_3x3);