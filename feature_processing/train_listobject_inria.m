
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
% MAY NOT WORK WELL NOW(18H 11 JAN 2015), TRY <demo_ADDPATH2.m> for INIT!
addpath('./structures');
addpath('feature_processing/');
addpath('I2T2I/');
addpath('text_tags/');
addpath('text_vectors/');
addpath('./data');
addpath('./inria_objects/');

if ~exist('dictionary_inriaPBA')
    load('dictionary_inriaPBA.mat');
    addpath('./matconvnet-1.0-beta7/matlab');
    run vl_setupnn;

    net = load('imagenet-vgg-f.mat');
end
% break;
clearvars -except dictionary_inriaPBA et net;
close all;
% break;


root_textvectors = './text_vectors/'; % dictionary of word2vec vectors
root_texttags = './text_tags/inria_tagbtexts/'; % tags of images with <tagname> id
inria_image = './data/webqueries/images/';
root_save = './inria_objects/';
% ------------------------------------------------------------------
firstrun = [0, 1, 1];
if firstrun(1)
listing = dir(inria_image);
inria_filenames = {listing(3:end).name};
for i = 1 : length(inria_filenames)
    li = length(inria_filenames{i});
    ni = li - 14;
    inria_tagnames{i} = [inria_filenames{i}(1:ni),'textmeta.xml.txt'];
end
save([root_save,'inria_filenames.mat'], 'inria_filenames');
save([root_save,'inria_tagnames.mat'], 'inria_tagnames');
else
    load('inria_filenames.mat');
    load('inria_tagnames.mat');
end
% for each of the sub directories {btexts,atexts,ptexts}, we can find these tag files

% break;
% queries_id = [0, 93, 349]; % to be extended.
queries_id = [0:354]; % to be extended.

if firstrun(2)
    % small scale management:
    if length(queries_id) < 5
    for i = 1 : length(queries_id)
        % subsampling
        t = 0;
        it = 6 + length(int2str(queries_id(i)) ) + 1;
        for j = 1 : length(inria_filenames)
           % 10 Jan 2015 : divide into train/test data  
            % change(1) : image_btaglist -> image_taglist
            % old 
           if strcmp(inria_filenames{j}(6:it),['_',int2str(queries_id(i) ),'_'])
                t = t + 1;
                image_namelist{i}{t} = inria_filenames{j};
                image_taglist{i}{t} = inria_tagnames{j};
            end
            % end of old
        end
    end
        save([root_save,int2str(length(queries_id)),'class_namelist.mat'],'image_namelist');
       save([root_save,int2str(length(queries_id)),'class_taglist.mat'],'image_taglist');

    else
        for j = 1 : length(inria_filenames)
            disp(['j = ',int2str(j),' / 71478...']);
            tmp_name = inria_filenames{j};
            limiters = find( ismember(tmp_name,'_') );
            id_class = str2num( tmp_name(limiters(1)+1:limiters(2)-1) );
            id_intra = str2num( tmp_name(limiters(3)+1:limiters(4)-1) );
            % linear cell or array: to be later re-considered :  
            inria_lobj{j}.id_class = id_class;
            inria_lobj{j}.id_intra = id_intra;
            inria_lobj{j}.img_file = inria_filenames{j};
            inria_lobj{j}.tag_file = inria_tagnames{j};
            % 2d cell
            inria_obj{id_class+1}{id_intra+1}.id_class = id_class;
            inria_obj{id_class+1}{id_intra+1}.id_intra = id_intra;
            inria_obj{id_class+1}{id_intra+1}.img_file = inria_filenames{j};
            inria_obj{id_class+1}{id_intra+1}.tag_file = inria_tagnames{j};
        end
           save([root_save,'inria_lobj.mat'],'inria_lobj');
           save([root_save, 'inria_obj.mat'],'inria_obj');
    end
end

% CONCLUSION:
% [n]class_namelist.mat
% [n]class_taglist.mat
% OR
% inria_lobj.mat  1x71748 cell
% inria_obj.mat   2d cell 


%%%  NOT USEFUL NOW at 00:12 11 jan 2015
% dictionary saving and loading
%%%%

% CONCLUSION:

% 4class_namelist; 4class_btaglist
% 4class_vfeatures % contains CNN visual vectors and text_tagnames
% 4class_dictionary_inria

