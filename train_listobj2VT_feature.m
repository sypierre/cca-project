%------------------------------------------------------------------
% clear; close all;
% net = load('imagenet-vgg-f.mat');
% firstrun = 0;
% querie_classes{1} = 'arc de triomphe'; %'aeroplane';
% querie_classes{2} = 'taj mahal';
% querie_classes{3} = 'nba';
% %querie_classes{4} = 'background';
%
% root_textvectors = './text_vectors/'; % dictionary of word2vec vectors
% root_texttags = './text_tags/inria_tagbtexts/'; % tags of images with <tagname> id
% inria_image = './data/webqueries/images/';
% ------------------------------------------------------------------

% demo_ADDPATHS;
% t1 = tic;
% if ~ exist('dictionary_inriaPBA', 'var')
%     load('dictionary_inriaPBA.mat');
%     addpath('./matconvnet-1.0-beta7/matlab');
%     run vl_setupnn;
%     addpath('./data');
%     net = load('imagenet-vgg-f.mat');
% end
% tl = toc(t1);
% % break;
%
% addpath('./structures');
% addpath('./feature_processing');
% addpath('./I2T2I');
% % addpath('./text_vectors');
% addpath('./inria_objects');

% % 01:50 - integrated addpaths into <~>
% demo_ADDPATHS2;
% break;

% break;
% used to be <dictionary_inriaPBA>
% clearvars -except inriaPBA et net et inria_lobj et tagwords; 
clearvars -except inriaPBA et net et inria_lobj et tagwords et...
                   inria_objf et inria_objfv et Vfeature et Tfeature; 

close all;
break;
inria_imgdir = './data/webqueries/images/';
root_textvectors = './text_vectors/'; % dictionary of word2vec vectors
root_texttags{1} = './text_tags/inria_tagptexts/'; % tags of images with <tagname> id
root_texttags{2} = './text_tags/inria_tagbtexts/'; % tags of images with <tagname> id
root_texttags{3} = './text_tags/inria_tagatexts/'; % tags of images with <tagname> id
root_save = './inria_objects/';
% break;
% ------------------------------------------------------------------
firstrun = [0, 1, 1];

% TO BE REPLAECED by sth adpated to <inria_obj> / 00:12 11 jan 2015

% load [n]class_namelist/taglist;
% OR
% LOADING inria_(l)obj.mat
% load inria_lobj.mat;
% load('inria_obj.mat'); % don't need it because we DO NOT clear it
% load('inria_objf-tagwords.mat');
% break;
root_features = './inria_obj_features/';

inria_objf = inria_lobj;
% break;
idx_bad = [];

if firstrun(3)
    % loop class
    good = 1;
    for i = 1 : length(inria_lobj)%image_namelist)
        if mod(i, 300) == 1
        disp(['i = ', int2str(i),' / 71478...']);
        disp('extracting text tags...');
        end
        % loop intra-class
        im  = imread([ inria_imgdir, inria_lobj{i}.img_file]);
        imn = single(im);
        imn = imresize(imn, net.normalization.imageSize(1:2));
        % (V): v_feature length < image_namelist : old fashioned!
        % this if is contagious! - undermines the i-j bijections
        % between i-j indices and real names(image_name/taglist) !
        
        if ndims(imn) == ndims(net.normalization.averageImage)
            
            imn = imn - net.normalization.averageImage;
            res = vl_simplenn(net, imn);
            % use the 2nd/3rd last layer
%             inria_objf{i}.v(1:1000) = res(end).x(1,1,1:1000);
            inria_objf{i}.v(1:4096) = res(20).x(1,1,1:4096);
        else
            good = 0;
%             inria_objf{i}.v(1:1000) = zeros(1,1000);
            inria_objf{i}.v(1:4096) = zeros(1,4096);

            idx_bad = [idx_bad, i];
        end
        
%         for w = 1 : 3
%             tmp = textread([root_texttags{w},inria_lobj{i}.tag_file],'%s');
%             inria_objf{i}.tagwords{w} = tmp(2:end-1); % without '<ptitle>', '</ptitle>'!
%         end
        inria_objf{i}.tagwords = tagwords{i};
        % --- end (T): T_class ---
        %                 end
    end
    save([root_save,'inria_objf20_nobad.mat'], 'inria_objf','idx_bad');
    
else
    disp('to be continued...');
end



% CONCLUSION:

% 4class_namelist; 4class_btaglist
% 4class_vfeatures % contains CNN visual vectors and text_tagnames
% 4class_dictionary_inria

