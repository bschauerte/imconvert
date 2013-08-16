function [out,intervals] = imconvert(in,from,to)
  % IMCONVERT provides a generic interface to convert between image formats
  %   (e.g. rgb -> Lab).
  %
  %   Input:
  %     in:   the input image
  %     from: the input image's color space
  %     to:   the desired output image's color space
  %   Output:
  %     out:  the convert image in the desired color space
  %     intervals: the value range of the colorspace
  %
  %   The interface also allows a simple weighting of the color channels
  %   after the conversion. For example, imconvert(image,'rgb','lab[0.5 1 1]')
  %   would convert the RGB image 'image' into and Lab image in which L, a,
  %   and b have the weights 0.5, 1, and 1, respectively.
  %
  %   Furthermore, we allow transformation chains, e.g. 'rgb2xyz:lab' would
  %   first transform the image from RGB to XYZ and then from XYZ to LAB.
  %
  %   Note: In order to allow all color space conversion, the "Colorspace
  %   Transformations" package (available from Mathwork's file exchange)
  %   is supported and can be used.
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
  % @date   2009-2015
  % @url    http://www.schauerte.me

  % Copyright 2009-2015 B. Schauerte. All rights reserved.
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

% let's allow weighted color spaces
% Usage example: imconvert(image,'rgb','lab[0.5 1 1]') would convert the
%   RGB image 'image' into and Lab image in which L, a, and b have the
%   weights 0.5, 1, and 1, respectively.
has_weights = false;
if ~isempty(strfind(to,']'))
  in = im2double(in); % force double
  % determine the weights
  t = strfind(to,'[');
  weights = to(t:end);
  to = to(1:t-1);
  % convert weights to real numbers
  weights = str2num(weights);
  has_weights = true;
end

%%%BEGIN PUBLIC-PRIVATE MIXED SECTION
%%%
% Conversions that are independent of the input color space (e.g., PCA)
%
% Note: easy to use with different color spaces by using the recursive/
%       chain interface, e.g. rgb2lab:npca will convert the image first
%       from RGB to LAB and then perform the PCA and normalize the range
%%%
do_enable_crash_protection = true;
is_independent_conversion = false;
switch lower(to)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % True color space conversions
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  case 'pca3' % optimized PCA for 3 color channels and corresponding 3x3 covariance matrices
    assert(size(in,3) == 3);
    out = imconvert_pca3(in);
    intervals = repmat([NaN,NaN],size(out,3),1);
    is_independent_conversion = true;
  
  case 'pca' % general PCA
    out = imconvert_pca(in);
    intervals = repmat([NaN,NaN],size(out,3),1);
    is_independent_conversion = true;
    
  case 'npca' % PCA with normalized output intervals
    out = imconvert_pca(in);
    for i = 1:size(out,3)
      out(:,:,i) = out(:,:,i) - min(min(out(:,:,i)));
      out(:,:,i) = out(:,:,i) / (max(max(out(:,:,i)))+eps);
    end
    intervals = [0,1; 0,1; 0,1];
    is_independent_conversion = true;
    
  case 'ica' % general ICA
    if do_enable_crash_protection
      try
        out = imconvert_ica(in);
      catch err
        warning('imconvert: ICA threw an exception');
        out=in;
      end
    else
      out = imconvert_ica(in);
    end
    intervals = repmat([NaN,NaN],size(out,3),1);
    is_independent_conversion = true;
    
  case 'nica' % ICA with normalized output intervals
    if do_enable_crash_protection
      try
        out = imconvert_ica(in);
      catch err
        warning('imconvert: ICA threw an exception');
        out = in;
      end
    else
      out = imconvert_ica(in);
    end
    for i = 1:size(out,3)
      out(:,:,i) = out(:,:,i) - min(min(out(:,:,i)));
      out(:,:,i) = out(:,:,i) / (max(max(out(:,:,i)))+eps);
    end
    intervals = [0,1; 0,1; 0,1];
    is_independent_conversion = true;
    
  case 'zca' % ZCA whitening
    if isinteger(in), in = double(in); end
    out = imconvert_zca(in);
    intervals = repmat([NaN,NaN],size(out,3),1);
    is_independent_conversion = true;
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Color space stretch
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  case 'decorrstretch'
    out = decorrstretch(in);
    intervals = repmat([NaN,NaN],size(out,3),1);
    is_independent_conversion = true;
    
  case 'decovstretch'
    out = decorrstretch(in,'mode','covariance');
    intervals = repmat([NaN,NaN],size(out,3),1);
    is_independent_conversion = true;
    
  case 'lognorm'
    [h, w, c] = size(in);
    f = reshape(in, h*w, c);
    
    %f = log10(f + eps);
    f = log10(f + 0.001);
    f_mean = mean(f);
    %f_mean
    f = bsxfun(@minus, f, f_mean);
    
    out = reshape(f, h, w, c);
    intervals = repmat([NaN,NaN],size(out,3),1);
    is_independent_conversion = true;
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Color space normalizations
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case '01' % normalize to the interval [0,1]
    out = in;
    for i = 1:size(out,3)
      out(:,:,i) = out(:,:,i) - min(min(out(:,:,i)));
      out(:,:,i) = out(:,:,i) / (max(max(out(:,:,i)))+eps);
    end
    intervals = [0,1; 0,1; 0,1];
    is_independent_conversion = true;
    
  case 'mad' % Median absolute deviation
    % Taken from
    %   A. Jain, et al., "Score normalization in multimodal biometric
    %   systems", Pattern Recognition, 2005, p. 2277
    
    out = in;
    for i = 1:size(out,3)
      X = out(:,:,i);
      X = X - median(X(:));
      X = X / median(abs(X(:)));
      out(:,:,i) = X;
    end
    intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
    is_independent_conversion = true;
  
  case 'tanh'
    percentiles = [0.7 0.85 0.95];
  	spread = 0.1;
    out = imconvert_tanh(in,percentiles,spread); % @note: the chosen percentiles and the spread substantially influence the results
    intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
    is_independent_conversion = true;
    
  otherwise
    % do nothing
end

%%%
% Allow for convenient recursive conversions
%%%
if ~isempty(strfind(to,':'))
  [to1,to2] = strtok(to,':');
  to2 = to2(2:end);
  [out,intervals] = imconvert(imconvert(in,from,to1),to1,to2);
  is_independent_conversion = true;
end

if is_independent_conversion
%   if has_weights
%     warning('Independent color space conversions currently do NOT allow weighting');
%   end
  % allow weighting for independent conversions
  if has_weights
    assert(numel(weights) == size(out,3));
    for i = 1:numel(weights)
      out(:,:,i) = out(:,:,i) * weights(i); % scale/weights the channels
      intervals(i,:) = intervals(i,:) * weights(i); % also scale the range intervals to reflect the weights
    end
  end
  return
end
%%%END PUBLIC-PRIVATE MIXED SECTION

in_excess=[];
if size(in,3) > 3
  warning('imconvert: more than 3 image channels. Just processing the first three channels.');
  in_excess = in(:,:,4:end);
  in = in(:,:,1:3);
end

switch lower(from)
  case 'rgb'
    switch lower(to)
      case 'gauss'
        % Gaussian color space according to J. M. Geusebroek et al., "Color
        % Invariance", PAMI 2001
        tmat = [0.06,0.63,0.27;0.3,0.04,-0.35; 0.34 -0.6 0.17];
        in = im2double(in);
        insz = size(in);
        tmp = reshape(in,[insz(1)*insz(2) insz(3)]);
        tmp = (tmat*tmp')';
        out = reshape(tmp,[insz(1) insz(2) insz(3)]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'rgb8'
        out = im2uint8(in);
        intervals =[0,255; 0,255; 0,255];
      case 'rgb'
        out = im2double(in);
        intervals = [0,1; 0,1; 0,1];
        %out=in;
        %if strcmp(class(in), 'uint8') || ((max(max(in(:,:,3))) > 1.0 || max(max(in(:,:,2))) > 1.0 || max(max(in(:,:,1))) > 1.0))
        %	intervals=[0,255; 0,255; 0,255];
        %else
        %	intervals=[0,1; 0,1; 0,1];
        %end
      case 'ruderman'
        out = imconvert_ruderman(in);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'lab'
        out = rgb2Lab(in);
        intervals = [0,100; -110,110; -110,110];
      case 'rgblab'
        out(:,:,1:3) = im2double(in);
        out(:,:,4:6) = rgb2Lab(in);
        intervals = [0,1; 0,1; 0,1; 0,100; -110,110; -110,110];
      case 'nlab' % normalized lab
        out = rgb2Lab(in);
        out(:,:,1) = out(:,:,1)-min(min(out(:,:,1)));
        out(:,:,2) = out(:,:,2)-min(min(out(:,:,2)));
        out(:,:,3) = out(:,:,3)-min(min(out(:,:,3)));
        out(:,:,1) = out(:,:,1)/(max(max(out(:,:,1)))+eps);
        out(:,:,2) = out(:,:,2)/(max(max(out(:,:,2)))+eps);
        out(:,:,3) = out(:,:,3)/(max(max(out(:,:,3)))+eps);
        intervals = [0,1; 0,1; 0,1];
      case 'labn' % normalized value range with respect to the original value range
        out = rgb2Lab(in);
        out(:,:,1) = out(:,:,1) / 100;
        out(:,:,2) = (out(:,:,2) + 110) / 220;
        out(:,:,3) = (out(:,:,3) + 110) / 220;
        intervals = [0,1; 0,1; 0,1];
        %out(:,:,2) = (out(:,:,2) + 110) / 2.2;
        %out(:,:,3) = (out(:,:,3) + 110) / 2.2;
        %intervals=[0,100; 0,100; 0,100];
        %out(:,:,2) = out(:,:,2) * 2; %+ 110) / 2.2;
        %out(:,:,3) = out(:,:,3) * 2; %+ 110) / 2.2;
        %intervals=[0,100; -220,220; -220,220];
      case 'labm' % use Matlab's conversion
        C = makecform('srgb2lab');
        out = applycform(in,C);
        intervals = [0,100; -128,127; -128,127];
      case 'labmn' % use Matlab's conversion
        C = makecform('srgb2lab');
        out = applycform(in,C);
        %intervals = [0,100; -128,127; -128,127];
        out(:,:,1) = out(:,:,1) / 100;
        out(:,:,2) = (out(:,:,2) + 128) / 255;
        out(:,:,3) = (out(:,:,3) + 128) / 255;
        intervals = [0,1; 0,1; 0,1];
      case 'hsv'
        out = rgb2hsv(in);
        intervals = [0,1; 0,1; 0,1];
      case 'hsl'
        out = colorspace([to '<-' from],im2double(in));
        out(:,:,1) = out(:,:,1) / 360;
        mx = max(max(out(:,:,2)));
        if mx > 1
          out(:,:,2) = out(:,:,2) / (mx + eps);
        end
        mx = max(max(out(:,:,3)));
        if mx > 1
          out(:,:,3) = out(:,:,3) / (mx + eps);
        end
        intervals = [0,1; 0,1; 0,1];
      case 'lch'
        out = colorspace([to '<-' from],im2double(in));
        intervals = [0,100; -156,156; 0,360];
      case 'icopp'
        out = rgb2icopp2(in);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'loglms'
        out = imconvert(in,from,'cat02lms');
        out = log10(out + eps);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'loglmsnorm'
        out = imconvert(in,from,'loglms');
        meanmap = repmat(mean(mean(out,1),2),size(out,1),size(out,2));
        out = out - meanmap;
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
        
      %%
      % image-independent decorrelated color spaces that have been
      % trained on some image dataset
      % generated with 'print_trained_spaces_conversions.m' in
      % color-decorrelation-analysis/
      case 'gcat02lmsxjudd' % trained on the Judd dataset
        out = project_color(imconvert(in,'rgb','cat02lms'),[0.523970269224442 0.539809997157632 0.658832546203922;0.582041111568239 0.337802375651646 -0.739674049462675;0.621838645802329 -0.771034838365155 0.137193209066427],'R',[0.23093498584216;0.246350213795407;0.246393152882464]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'ggaussxjudd' % trained on the Judd dataset
        out = project_color(imconvert(in,'rgb','gauss'),[-0.992083110269512 0.0774987491859886 0.098818248277225;0.0450478317204897 0.95411977300327 -0.296017147512558;0.117225403284674 0.289222064578062 0.950057262582603],'R',[0.405835073498123;0.0106894884838466;-0.0383412832392179]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gicoppxjudd' % trained on the Judd dataset
        out = project_color(imconvert(in,'rgb','icopp'),[0.903123155830167 -0.284090286093613 0.321964710411886;-0.0338285469849873 -0.794578801160804 -0.606217913092929;0.428046953980805 0.536597836459587 -0.727212876051192],'R',[108.496631922588;12.4816379018201;23.765676580556]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsxjudd' % trained on the Judd dataset
        out = project_color(imconvert(in,'rgb','loglms'),[0.5721080579141 0.53271315333813 0.623625742196635;0.577567214243825 0.278182508028729 -0.767483293145508;0.582330218261413 -0.799269158974242 0.148527197550557],'R',[-1.10003944732228;-1.08928874165509;-1.15103520514796]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsnormxjudd' % trained on the Judd dataset
        out = project_color(imconvert(in,'rgb','loglmsnorm'),[0.574264686461433 0.51672249408437 0.63499443618868;0.577526680849011 0.294051178244552 -0.761575234287798;0.580243916634096 -0.804071992224713 0.129557819250347],'R',[-2.30339815708389e-14;2.67050286460303e-14;1.63100074787763e-14]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbxjudd' % trained on the Judd dataset
        out = project_color(im2double(in),[0.560887908054059 -0.724107671533364 -0.401338802790451;0.579855367909198 -0.00240741756199375 0.814715874797816;0.590908205143261 0.689682741822074 -0.418527428882692],'R',[0.445745549612605;0.430014663024651;0.400670751210231]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbicoppxjudd' % trained on the Judd dataset
        out = project_color(imconvert(in,'rgb','rgb:icopp'),[0.328490626610085 0.944415299642598 0.0131776337137937;-0.414307589696946 0.131540257195075 0.900581135632187;0.848789213732609 -0.30129205521891 0.434488167978306],'R',[0.425476987936259;0.0235963298870571;-0.040052261568397]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgblabmxjudd' % trained on the Judd dataset
        out = project_color(imconvert(in,'rgb','rgb:labm'),[-0.999219233232908 -0.0112378302101377 0.0378765773217069;0.0334543015223654 0.269333585478088 0.962465702995784;-0.0210174605290408 0.962981376198774 -0.268747345004978],'R',[45.5394197158268;1.70302296334538;5.19917945147904]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gcat02lmsxkootstra' % trained on the Kootstra dataset
        out = project_color(imconvert(in,'rgb','cat02lms'),[0.56641306892117 0.5534503636649 0.610629945478022;0.595805546894881 0.2369128730248 -0.767390409690157;0.569378596054149 -0.7984766656292 0.195558249125628],'R',[0.231345480656324;0.222338060924434;0.176918372019998]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'ggaussxkootstra' % trained on the Kootstra dataset
        out = project_color(imconvert(in,'rgb','gauss'),[-0.992414563523315 0.102611348712229 0.0677070544499329;0.0254413262194337 0.710249085971057 -0.70349056482477;0.120274989199855 0.696431724573727 0.707472105443203],'R',[0.392993422963815;0.0495213278268112;-0.0275837105834543]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gicoppxkootstra' % trained on the Kootstra dataset
        out = project_color(imconvert(in,'rgb','icopp'),[-0.942936294773735 -0.0177155136758806 -0.33250158582115;-0.0808875819592908 0.980858183163395 0.177128268794633;-0.322998983099264 -0.193915922751599 0.926319745994998],'R',[108.507665184848;25.950037727356;10.9955694580078]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsxkootstra' % trained on the Kootstra dataset
        out = project_color(imconvert(in,'rgb','loglms'),[0.560623139262134 0.533721662082718 0.633121539001423;0.561905142298544 0.316409909319231 -0.76429534889534;0.608246912678004 -0.784235906286021 0.122514229824211],'R',[-0.891150647030185;-0.91757834584272;-1.11003939634758]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsnormxkootstra' % trained on the Kootstra dataset
        out = project_color(imconvert(in,'rgb','loglmsnorm'),[0.571850120565446 0.518470517284449 0.635748190965638;0.567293896959475 0.309877512932052 -0.762989882928718;0.592591827552337 -0.796971925280836 0.116921667078175],'R',[-1.43588844518187e-15;8.0953762212251e-16;-7.01290877221557e-16]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbxkootstra' % trained on the Kootstra dataset
        out = project_color(im2double(in),[0.612475790651568 -0.745317330706289 -0.263392259595054;0.553700185246333 0.166689014084724 0.815862045594498;0.564171525977617 0.645536094368328 -0.514775329773847],'R',[0.505947288511977;0.429363740254912;0.341249738098]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbicoppxkootstra' % trained on the Kootstra dataset
        out = project_color(imconvert(in,'rgb','rgb:icopp'),[-0.142016521994065 0.822529750765847 0.550705108552466;-0.541866438526844 0.400983006951744 -0.738642938728972;0.828379182668748 0.403308117003628 -0.388755054603853],'R',[0.425520255626427;0.114875322378658;-0.200980218076611]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgblabmxkootstra' % trained on the Kootstra dataset
        out = project_color(imconvert(in,'rgb','rgb:labm'),[-0.95038646401606 0.310777285517744 0.0135295166681231;-0.169077982566043 -0.552586114825098 0.816125738789005;-0.26110956479311 -0.773347311696837 -0.577715960195689],'R',[47.4012472798484;5.68677796683547;15.7487620030352]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gcat02lmsxmcgillfull' % trained on the McGillFull dataset
        out = project_color(imconvert(in,'rgb','cat02lms'),[0.548187928412342 0.564273772600089 0.617320909008149;0.591726078411994 0.259954158273599 -0.763075411557355;0.591058578543741 -0.783593609693141 0.191391775105214],'R',[0.24997825442307;0.246394978456131;0.205591872037782]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'ggaussxmcgillfull' % trained on the McGillFull dataset
        out = project_color(imconvert(in,'rgb','gauss'),[-0.991555939121231 0.0995517019340399 0.0831040205733126;0.0503015475343235 0.885925498711837 -0.461091926895099;0.119526456941824 0.453018177752527 0.883452294533618],'R',[0.413463677504193;0.0453485938754238;-0.0327591923709577]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gicoppxmcgillfull' % trained on the McGillFull dataset
        out = project_color(imconvert(in,'rgb','icopp'),[-0.927556117653221 0.102238344344601 -0.359425888814034;0.00706262462350993 0.966469306488025 0.256685018943419;-0.373617140850779 -0.235551269498237 0.897176588805268],'R',[113.23826655981;24.8516577023358;15.1411944274815]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsxmcgillfull' % trained on the McGillFull dataset
        out = project_color(imconvert(in,'rgb','loglms'),[0.563923825793711 0.544536030282252 0.620862650210681;0.56857380297741 0.289235447801345 -0.770108230252709;0.598927165246317 -0.787288617636253 0.146502161316511],'R',[-0.881082107804299;-0.90095260911942;-1.08519414477935]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsnormxmcgillfull' % trained on the McGillFull dataset
        out = project_color(imconvert(in,'rgb','loglmsnorm'),[0.571434004910997 0.53247735025828 0.624444592812925;0.572195185793807 0.286925710194607 -0.768287905790344;0.588265116580756 -0.796330024732988 0.140721868673594],'R',[-2.44319070881971e-15;4.5613571834956e-15;1.16238505079646e-15]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbxmcgillfull' % trained on the McGillFull dataset
        out = project_color(im2double(in),[0.583482922232628 -0.734352491299436 -0.346805562217773;0.563200527902096 0.058225086352981 0.824266343295654;0.585109258885615 0.676266410404583 -0.447561054298546],'R',[0.516669724915131;0.450739712640756;0.364805463174114]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbicoppxmcgillfull' % trained on the McGillFull dataset
        out = project_color(imconvert(in,'rgb','rgb:icopp'),[0.0327155090193238 0.983839020081749 -0.176041125973993;-0.467487982858944 0.170743333672521 0.867353272829975;0.883393842718004 0.0539212070615902 0.46551887402869],'R',[0.444071633569897;0.0988950184277538;-0.186291773834614]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgblabmxmcgillfull' % trained on the McGillFull dataset
        out = project_color(imconvert(in,'rgb','rgb:labm'),[-0.980546537670422 -0.196283856035936 -0.00106551499822721;-0.0832004138608676 0.410703299893039 0.90796502718461;-0.177781266155711 0.890390615020527 -0.419044596776333],'R',[49.1888539210262;4.99835882652813;14.8850664907935]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gcat02lmsxmcgilllandwater' % trained on the McGillLandWater dataset
        out = project_color(imconvert(in,'rgb','cat02lms'),[0.528719465472316 0.644797107280153 0.551989508300489;0.585426697458178 0.193863591511027 -0.78720549400373;0.614598493924187 -0.739360262882442 0.274981986567352],'R',[0.285686114581655;0.288065795196691;0.270212089829037]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'ggaussxmcgilllandwater' % trained on the McGillLandWater dataset
        out = project_color(imconvert(in,'rgb','gauss'),[-0.989545070524556 0.111719911393479 0.0912097297374778;0.07786891364809 0.946179180242066 -0.314135943762758;0.121395987115789 0.303749272056223 0.944986451774573],'R',[0.468165090628873;0.0300271653680372;-0.0342307801128364]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gicoppxmcgilllandwater' % trained on the McGillLandWater dataset
        out = project_color(imconvert(in,'rgb','icopp'),[-0.886066792152784 0.237714881337199 -0.39796642450704;0.106469116165985 0.939915272510827 0.324381885751551;-0.45116512182006 -0.245052883459346 0.858137003724551],'R',[127.606123687281;22.2519905948706;22.3805254943549]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsxmcgilllandwater' % trained on the McGillLandWater dataset
        out = project_color(imconvert(in,'rgb','loglms'),[0.573779220251355 0.584934098059624 0.573262162832086;0.576008155275897 0.209382341141229 -0.790173171066872;0.58223020487038 -0.783588626860672 0.216787574346877],'R',[-0.895248770983007;-0.905026641855733;-1.00645352105394]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsnormxmcgilllandwater' % trained on the McGillLandWater dataset
        out = project_color(imconvert(in,'rgb','loglmsnorm'),[0.583690174180208 0.540880787900013 0.605601976421922;0.578707932210032 0.246057187644606 -0.777530057043209;0.569563789019866 -0.804303321943337 0.169390839623178],'R',[1.66813482430986e-14;3.7672006596594e-14;-1.00672440335153e-14]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbxmcgilllandwater' % trained on the McGillLandWater dataset
        out = project_color(im2double(in),[0.552014367136142 -0.747741444064626 -0.369002535632795;0.578094824171571 0.0242799528049102 0.815608274944431;0.600904745147951 0.663545941679956 -0.445668341414035],'R',[0.555442150889162;0.498530120961178;0.447276242116334]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbicoppxmcgilllandwater' % trained on the McGillLandWater dataset
        out = project_color(imconvert(in,'rgb','rgb:icopp'),[0.115357711718556 0.993301299085568 -0.00671770660132598;-0.523111424193994 0.0664981957503434 0.849666068429051;0.844421124928072 -0.0945014243113402 0.527278336913568],'R',[0.500416171322774;0.0853680449026455;-0.114365660804118]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgblabmxmcgilllandwater' % trained on the McGillLandWater dataset
        out = project_color(imconvert(in,'rgb','rgb:labm'),[-0.999798186054835 -0.0134475973541156 0.0149247876656218;0.00670818522574524 0.476801704965116 0.878985286790021;-0.0189364044221548 0.878908013541668 -0.476615270758083],'R',[53.8439349308883;5.16373907145995;9.61403375315669]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gcat02lmsxtoronto' % trained on the Toronto dataset
        out = project_color(imconvert(in,'rgb','cat02lms'),[0.523015907279006 0.455134195180793 0.720629742038344;0.57812383576564 0.431821089688846 -0.692317396155521;0.626280441378095 -0.77870624170933 0.0372746277002065],'R',[0.279904899786045;0.305440023655087;0.293782249910726]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'ggaussxtoronto' % trained on the Toronto dataset
        out = project_color(imconvert(in,'rgb','gauss'),[-0.994400889144581 -0.00766097347755423 -0.105395356414995;0.0436631049572641 0.878461902732274 -0.475813218304708;0.0962309977811648 -0.477750975858102 -0.873208795267588],'R',[0.473189035128504;0.0116084833010608;-0.0531445707773891]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gicoppxtoronto' % trained on the Toronto dataset
        out = project_color(imconvert(in,'rgb','icopp'),[0.881733477789957 -0.438696485918205 -0.173468923405451;-0.0256645121902775 -0.411778933027723 0.910922303563034;0.471049261710984 0.7987386954177 0.374338202009851],'R',[125.139629297607;6.9139407819934;25.580496669933]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsxtoronto' % trained on the Toronto dataset
        out = project_color(imconvert(in,'rgb','loglms'),[0.55418802308322 0.456784207857199 0.695861927772589;0.562408573291054 0.410821888580419 -0.717580638361946;0.613654814826571 -0.789033309382746 0.0292267843711543],'R',[-0.821291611776035;-0.789558638022176;-0.876177780449278]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'gloglmsnormxtoronto' % trained on the Toronto dataset
        out = project_color(imconvert(in,'rgb','loglmsnorm'),[0.555948659488473 0.480603824663539 0.678189539680279;0.562691482736887 0.382924063417095 -0.732630505037501;0.611800117087545 -0.788916424835305 0.0575455589663322],'R',[-1.81701672527307e-16;-5.57017806836698e-15;1.74868359416195e-15]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbxtoronto' % trained on the Toronto dataset
        out = project_color(im2double(in),[0.557090789772493 0.562528366810074 0.610910540492346;0.56519881912086 0.28214494079881 -0.775206119200579;0.608440750455659 -0.77714610525668 0.160760020743117],'R',[0.507003308235406;0.505992716589564;0.45923490809189]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgbicoppxtoronto' % trained on the Toronto dataset
        out = project_color(imconvert(in,'rgb','rgb:icopp'),[0.945512703147298 -0.325530722509848 -0.00595624792176086;-0.0466654427399387 -0.153600762132329 0.987030466766985;0.322223625206121 0.932971893775254 0.160422507100598],'R',[0.490743644304558;0.00151588746859456;-0.0721580746498444]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      case 'grgblabmxtoronto' % trained on the Toronto dataset
        out = project_color(imconvert(in,'rgb','rgb:labm'),[-0.997708082827991 0.0605373305329381 0.0302293412372622;0.0143607029965219 -0.247131474304242 0.968875536184941;0.0661237602465161 0.967089068297309 0.245695710810555],'R',[52.7259040839861;-1.01098272240554;6.71254867631167]);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
        
      otherwise
%         if ~isempty(strfind(to,':'))
%           %%%
%           % Some convenient recursive conversions
%           %%%
%           [to1,to2] = strtok(to,':');
%           to2 = to2(2:end);
%           [out,intervals] = imconvert(imconvert(in,from,to1),to1,to2);
%         else
%           if exist('colorspace','file')
%             out = colorspace([to '<-' from],im2double(in));
%             intervals = [0,1; 0,1; 0,1];
%           else
%             error('%s -> %s: unsupported conversion\n', from, to);
%           end
%         end
          if exist('colorspace','file')
            out = colorspace([to '<-' from],im2double(in));
            intervals = [0,1; 0,1; 0,1];
          else
            error('%s -> %s: unsupported conversion\n', from, to);
          end
    end
  case 'lab'
    switch lower(to)
      case 'rgb'
        out = Lab2rgb(in);
        intervals = [0,255; 0,255; 0,255];
      case 'lab'
        out = in;
        intervals = [0,100; -110,110; -110,110];
      otherwise
        if exist('colorspace','file')
          out = colorspace([to '<-' from],in);
          intervals = [0,1; 0,1; 0,1];
        else
          error('%s -> %s: unsupported conversion\n', from, to);
        end
    end
  case 'hsv'
    switch lower(to)
      case 'rgb'
        out = hsv2rgb(in);
        intervals = [0,1; 0,1; 0,1];
      case 'hsv'
        out = in;
        if isa(in, 'uint8') || ((max(max(in(:,:,3))) > 1.0 || max(max(in(:,:,2))) > 1.0 || max(max(in(:,:,1))) > 1.0))
          intervals = [0,255; 0,255; 0,255];
        else
          intervals = [0,1; 0,1; 0,1];
        end
      otherwise
        if exist('colorspace','file')
          out = colorspace([to '<-' from],in);
          intervals = [0,1; 0,1; 0,1];
        else
          error('%s -> %s: unsupported conversion\n', from, to);
        end
    end
  otherwise
    if exist('colorspace','file')
      out = colorspace([to '<-' from],in);
      intervals = [0,1; 0,1; 0,1];
    else
      error('%s -> %s: unsupported conversion\n', from, to);
    end
end

if ~isempty(in_excess)
  out = cat(3,out,in_excess);
end

% scale/weight the image channels with the specified weights
if has_weights
  assert(numel(weights) == size(out,3));
  for i = 1:numel(weights)
    out(:,:,i) = out(:,:,i) * weights(i); % scale/weights the channels
    intervals(i,:) = intervals(i,:) * weights(i); % also scale the range intervals to reflect the weights
  end
end