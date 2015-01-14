
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
else
    % TO BE REPLAECED by sth adpated to <inria_obj> / 00:12 11 jan 2015
    
%     tmp1 = load('4class_namelist.mat');
    tmp1 = load('3class_namelist.mat');
    image_namelist = tmp1.image_namelist;

%     tmp2 = load('4class_btaglist.mat');
%     image_taglist = tmp2.image_btaglist;
    tmp2 = load('3class_taglist.mat');
    image_taglist = tmp2.image_taglist;
 
    if firstrun(3)
        for i = 1 : length(image_namelist)
            t = 0;
            for j = 1 : length(image_namelist{i})
                
                im  = imread([ inria_image, image_namelist{i}{j}]);
                imn = single(im);
                imn = imresize(imn, net.normalization.imageSize(1:2));
                % (V): v_feature length < image_namelist : old fashioned! 
                % this if is contagious! - undermines the i-j bijections
                % between i-j indices and real names(image_name/taglist) ! 
                if ndims(imn) == ndims(net.normalization.averageImage)
                    t = t + 1;
                    imn = imn - net.normalization.averageImage;
                    res = vl_simplenn(net, imn);
                    v_features{i}{j}.vector(1:1000) = res(end).x(1,1,1:1000);
                else
                    v_features{i}{t}.vector(1:1000) = zeros(1,1000);
                end
                    v_features{i}{t}.name = image_namelist{i}{j};
                    v_features{i}{t}.tagname = image_taglist{i}{j};
                    
                    % (T): T_class  / 10 jan 2015
                    T_class{i}{t}.tagname = v_features{i}{t}.tagname;
                    % (1) extract phrases/words in tagname files
                    disp('extracting text tags...');
                    
                    tmp = textread([root_texttags,v_features{i}{t}.tagname],'%s');
                    T_class{i}{j}.tagwords = tmp(2:end-1); % without '<ptitle>', '</ptitle>'!
                    
                    % --- end (T): T_class ---
%                 end
            end
        end
        save('4class_vfeatures.mat', 'v_features');
        
    else
        load('4class_vfeatures.mat');
    end
    
end

break;

%%%  NOT USEFUL NOW at 00:12 11 jan 2015

disp('beging processing text...'); pause(.1);

thm{1} = 'b';
thm{2} = 'a';
thm{3} = 'p';
root_textvectors = './text_vectors/'; % dictionary of word2vec vectors
root_texttags = './text_tags/inria_tagbtexts'; % tags of images with <tagname> id

if 0 % not useful now/ 
    disp('beging reading files...'); pause(.1);
    for th = 1 : 3
        
        dictionary_inria{th} = textread([root_textvectors,'vectors_inria',thm{th},'-phrase.txt'],'%s');
        disp('---just finished one..');
    end
else
    load('4class_dictionary_inria.mat');
end

% CONCLUSION:

% 4class_namelist; 4class_btaglist
% 4class_vfeatures % contains CNN visual vectors and text_tagnames
% 4class_dictionary_inria

