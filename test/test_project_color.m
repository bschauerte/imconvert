%% load lib
addpath(genpath('..'));

%% simple test
tmat = [1 0 0; 0 1 0; 0 0 1];
m = [];

img = im2double(imread('../examples/AdinaVoicu-Sunset.jpg'));
img_t = project_color(img,tmat,'R',m);

figure('name','image');
subplot(2,1+size(img_t,3),1); imshow(img);
for i = 1:size(img_t,3)
  subplot(2,1+size(img_t,3),1+i); imshow(img_t(:,:,i));
  subplot(2,1+size(img_t,3),1+size(img_t,3)+1+i); imshow(mat2gray(img_t(:,:,i)));
end