% tagwords

% % 01:50 - integrated addpaths into <~>
% demo_ADDPATHS2;
% break;

% break;
clearvars -except inriaPBA et net et inria_lobj et tagwords;
close all;
% break;
inria_imgdir = './data/webqueries/images/';
root_textvectors = './text_vectors/'; % dictionary of word2vec vectors
root_texttags{1} = './text_tags/inria_tagptexts/'; % tags of images with <tagname> id
root_texttags{2} = './text_tags/inria_tagbtexts/'; % tags of images with <tagname> id
root_texttags{3} = './text_tags/inria_tagatexts/'; % tags of images with <tagname> id
root_save = './inria_objects/';
% break;
% ------------------------------------------------------------------
firstrun = [0, 1 ];

% TO BE REPLAECED by sth adpated to <inria_obj> / 00:12 11 jan 2015

% load [n]class_namelist/taglist;
% OR
% LOADING inria_(l)obj.mat
% load inria_lobj.mat;
% load('inria_obj.mat'); % don't need it because we DO NOT clear it
% break;
root_features = './inria_obj_features/';
% addpath(root_features(1:end-1));

% inria_objf = inria_lobj;
% break;

if firstrun(1)
    % loop class
    good = 1;
    for i = 1 : length(inria_lobj)%image_namelist)
        if mod(i, 300) == 1
            disp(['i = ', int2str(i),' / 71478...']);
            disp('extracting text tags...');
        end
        
        for w = 1 : 3
            tmp = textread([root_texttags{w},inria_lobj{i}.tag_file],'%s');
            tagwords{i}{w} = tmp(2:end-1); % without '<ptitle>', '</ptitle>'!
        end
        % --- end (T): T_class ---
        %                 end
    end
    save([root_save,'inria_objf-tagwords.mat'], 'tagwords');
else
    disp('loading <tagwords> object...');
    if ~ exist('tagwords', 'var')
        load([root_save,'inria_objf-tagwords.mat'], 'tagwords');
    end
    disp(int2str(length(tagwords)) );
end
% break;
%-----------------------------------------------------------------------
% go for dictionary to get T features

idx_badT = []; % to collect idx of cases where PBA together have 0 words
prior = [4; 3; 3];

opt.maxwords = 7; % 9
opt.dim = 200; % word2vec setted
opt.window2 = 1; % search features for 2 word short phrases

% function wordvec2class_objf.m
% dictionary_inriaPBA = dictionary_inriaPBA;
vecdim = opt.dim * opt.maxwords;
% creat tagvectors [200 x opt.maxwords,1]

inria_objft.T = zeros(length(tagwords) , vecdim+1);
for i = 1 : length(tagwords)
    if mod(i, 300) == 1
        disp(['i = ', int2str(i),' / 71478 --- ',num2str(100*i/71478),' % ']);
        disp('extracting text tags...');
    end
    pd = zeros(3,1);
    tmp_wordvecm = zeros(3,vecdim);
    for dic = 1 : 3
        tmp_wordvec{dic} = [];%zeros(opt.dim * opt.maxwords,1);
        
        if length(tagwords{i}{dic}) < 1
            tmp_wordvec{dic} = zeros(vecdim,1); % in fact (1, vecdim)
            pd(dic) = 0;
        else
            pd(dic) = prior(dic);
            
            %             for w = 1 : min(opt.maxwords, length(tagwords{i}{dic}) )
            w = 1;
            mir = 0;
            while w <= min(opt.maxwords + mir, length(tagwords{i}{dic}))
                
                % enter this while loop only if there are >=1 word, assume
                % added this one first word: so w = 1 already
                
                % simple 1-word search !
%                 ind = find( ismember(dictionary_inriaPBA, tagwords{i}{dic}{w}) );
                idx_w = find( ismember(inriaPBA.word, tagwords{i}{dic}{w}) );

                if ~ isempty(idx_w)
                        tmp_wordvec{dic} = [tmp_wordvec{dic}, inriaPBA.vector{idx_w}];
                end
                w = w + 1;
                if opt.window2
                    if w  <= min(opt.maxwords, length(tagwords{i}{dic}))
                        if ismember([tagwords{i}{dic}{w-1},'_',tagwords{i}{dic}{w}], inriaPBA.word)
                            idx_w = find( ismember(inriaPBA.word,[tagwords{i}{dic}{w-1},'_',tagwords{i}{dic}{w}]) );
                            if ~ isempty(idx_w)
                                if length(tmp_wordvec{dic}) >= opt.dim
                                tmp_wordvec{dic}(end-opt.dim+1 : end) = inriaPBA.vector{idx_w};
                                else
                                    tmp_wordvec{dic}(1 : opt.dim) = inriaPBA.vector{idx_w};
                                end
%                                 for t = 1 : opt.dim
%                                     tmp_wordvec{dic}(end-opt.dim+t) = str2num( dictionary_inriaPBA{idx_w+t} );
%                                 end
                                w = w + 1;
                                mir = mir + 1;
                            end
                        end
                    end
                end
                
            end
            % end of simple 1-word search - to be replaced by : 1-2-window search: 10 jan 2015 -
            wlen = length(tmp_wordvec{dic});
            dlen = vecdim - wlen;
            %             tmp_wordvec{dic} = [tmp_wordvec{dic}; zeros(dlen,1)];
            tmp_wordvecm(dic,:) = [tmp_wordvec{dic}, zeros(1,dlen)];
        end
    end
    % weighted mean of the three [vecdim x 1] vectors
    if sum(pd) < 1
        % 0 word for all PBA
        idx_badT = [idx_badT, i];
%         tfeature{i} = zeros(vecdim,1);
        inria_objft.T(i,:) = zeros(1, vecdim+1);
%         inria_objft.ti{i} = zeros(1,vecdim);
        inria_objft.t3{i} = [];
    else
        ip = find(pd>0);
        pdp = pd/sum(pd);
        tmpt = sum( (pdp(ip)*ones(1,vecdim)).* tmp_wordvecm(ip,:), 1); %[1x1400]
%         tfeature{i} = tmpt;
        inria_objft.T(i,:) = [tmpt, i];
        inria_objft.t3{i} = tmp_wordvec;
    end
    
end
inria_objft.idx_badT = idx_badT;

save([root_save, 'inria_objf-2tfeature.mat'], 'inria_objft', '-v7.3');

Tfeature = inria_objft.T;
save([root_save, 'inria_objf-2tfeaturesi.mat'], 'Tfeature', '-v7.3');


% end of function






