function [tmat,m] = learn_color_projection(data,sampling,is_verbose)
  % LEARN_PROJECTION trains a PCA color space transformation on the specified
  %   set of (training) images.
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
  % @date   2014

  % Copyright 2014-2015 B. Schauerte. All rights reserved.
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

%% data 
if nargin < 1
  %image.folder   = './examples';
  data.folder    = '/home/bschauer/data/saliency-eye-tracked/bruce-tsotsos/images';
  data.type      = 'jpg';
  data.color_in  = 'rgb';
  data.color_out = 'rgb';
end

%% parameters
if nargin < 2
  sampling.mode = 'random';
  sampling.resolution = 0;
end

if nargin < 3
  is_verbose = true;
end

%% collect data
files = dir(fullfile(data.folder,sprintf('*.%s',data.type)));
color_data = {};
parfor i = 1:length(files)
  if is_verbose, fprintf('Processing image %04d of %04d\n',i,length(files)); end
  
  % read the image
  img = imread(fullfile(data.folder,files(i).name));
  
  % perform color transformation, if wished
  if strcmp(data.color_in,data.color_out)
    warning('imconvert:warn:double','The projection is trained using im2double!');
    warning('off','imconvert:warn:double');
    img = im2double(img);
  else
    img = imconvert(img,data.color_in,data.color_out);
  end
  
  % sample color information from the image
  switch (sampling.mode)
    case 'random'
      [h,w,c] = size(img);
      
      if sampling.resolution == 0
        % use the whole image, i.e. all pixels
        samples = 1:(h*w);
      else
        % use the color information of #sampling.resolution random pixels
        nrand   = sampling.resolution;
        samples = randperm(nrand);
        samples = samples(nrand);
      end
      
      timg = reshape(img,[h*w c]);
      color_data{i} = timg(samples,:);
    otherwise
      error('Unknown sampling mode');
  end
end
color_data = cat(1,color_data{:});

%% learn the PCA transformation for the loaded image set
if is_verbose, fprintf('Calculating PCA ...'); end
f = reshape(color_data,size(color_data,1),1,size(color_data,2));
[~,tmat,~,~,m] = imconvert_pca(f);
fprintf(' done\n');

if is_verbose, fprintf('You can use the PCA transformation with:\n\t project_color(f,%s,''R'',%s)\n',mat2str(tmat),mat2str(squeeze(m))); end

% %% test precision with one image!
% assert(length(files) == 1);
% sum(sum(abs(imconvert_pca(img) - project_color(img,tmat,'R',squeeze(m)))))

%% cleanup some states
warning('on','imconvert:warn:double');