%% load lib and example image
addpath(genpath('..'));
img = im2double(imread('../examples/AdinaVoicu-Sunset.jpg'));

%% show ruderman & LMS:PCA & Lab
% first_normalization = @(img)mat2gray(img);
% second_normalization = @(img)mat2gray(img);
% first_normalization = @(img)img;
% second_normalization = @(img)img;
first_normalization = @(img)img;
second_normalization = @(img)mat2gray(img);

figure('name','image');
subplot(5,3,2); imshow(img);
ruderman = first_normalization(imconvert(img, 'rgb', 'ruderman'));
lms_pca = first_normalization(imconvert(img, 'rgb', 'cat02lms:pca'));
labm = first_normalization(imconvert(img, 'rgb', 'labm'));
% color space trained on the Toronto eye tracking dataset
learned_pca = first_normalization(project_color(im2double(img),[0.5570907897725 0.562528366809925 0.610910540492478;0.565198819120867 0.282144940798979 -0.775206119200512;0.608440750455646 -0.777146105256727 0.160760020742941],'R',[0.507003308228661;0.505992716583961;0.459234908092328]));

subplot(5,3,4); imshow(second_normalization(ruderman(:,:,1))); title('Ruderman l');
subplot(5,3,5); imshow(second_normalization(ruderman(:,:,2))); title('Ruderman a');
subplot(5,3,6); imshow(second_normalization(ruderman(:,:,3))); title('Ruderman b');

subplot(5,3,7); imshow(second_normalization(lms_pca(:,:,1))); title('LMS:PCA 1');
subplot(5,3,8); imshow(second_normalization(lms_pca(:,:,2))); title('LMS:PCA 2');
subplot(5,3,9); imshow(second_normalization(lms_pca(:,:,3))); title('LMS:PCA 3');

subplot(5,3,10); imshow(second_normalization(labm(:,:,1))); title('Lab L');
subplot(5,3,11); imshow(second_normalization(labm(:,:,2))); title('Lab a');
subplot(5,3,12); imshow(second_normalization(labm(:,:,3))); title('Lab b');

subplot(5,3,13); imshow(second_normalization(learned_pca(:,:,1))); title('learned:pca 1st');
subplot(5,3,14); imshow(second_normalization(learned_pca(:,:,2))); title('learned:pca 2nd');
subplot(5,3,15); imshow(second_normalization(learned_pca(:,:,3))); title('learned:pca 3rd');