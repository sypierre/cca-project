
opt.window2 = 1;
if opt.window2
    disp('phrased textual vectors...');
else
    disp('not phrased textual vectors...');
end

if ~ exist('net', 'var')
    demo_ADDPATHS3;
    %---------- One of the 2 suffices
    if opt.window2
        load('inria_objf-2tfeaturesi.mat');
        % matObj = matfile('inria_objf-vfeatsi.mat');
        % whos(matObj)
    else
        load('inria_objf-tfeaturesi.mat');
    end
    break;
end

clearvars -except inriaPBA et net et inria_lobj et tagwords et...
    inria_objf et inria_objfv et Vfeature et ...
    inria_objft et Tfeature et inria_objfi et idx_bad et idx_badT et...
    idx_bads et idx_goods et X et T et Wx et W et Ds et D et Z et ...
    Vfeat et semantic;
close all;

inria_imgdir = './data/webqueries/images/';
root_textvectors = './text_vectors/'; % dictionary of word2vec vectors
root_texttags{1} = './text_tags/inria_tagptexts/'; % tags of images with <tagname> id
root_texttags{2} = './text_tags/inria_tagbtexts/'; % tags of images with <tagname> id
root_texttags{3} = './text_tags/inria_tagatexts/'; % tags of images with <tagname> id
root_save = './inria_objects/';
root_results = './inria_results/';
root_resultsNEW = './inria_resultsNEW/';
root_fig = './PGM-report/figures/';
% -----------------------end of SETTINGS --------------------
% train
N = size(Vfeature,1);

if ~exist('idx_bads', 'var')
    idx_bads = union(inria_objfv.idx_bad, inria_objft.idx_badT );
    idx_goods = setdiff((1:N) , idx_bads);
end

% create train set
modidx = mod(idx_goods , 5);
if ~ exist('idx_test')
    idx_test =  idx_goods( find (modidx == 0) );
    idx_train = setdiff(idx_goods, idx_test );
end
% hist(modidx, 5);
NT = length(idx_train);
partial = 1;
idx_realtrain = idx_train(1: fix(NT/partial) );
% END OF create train set

opt.trainall = 1;
opt.v1000 = 1;
opt.window2 = 1;
opt.observ = [0, 50, 99];%[1 , 20 , 180 ];

id_class = [0 : 300];%[0,100,200]%(good);[0, 10, 130,(131:200) ];%[0, 93, 349];%
for k = 1 : length(opt.observ)
    querie_classes{k} = semantic{opt.observ(k) + 1};
end
%% NSS
disp('creating nss...');
% nss contains the absolute line information about the classes_observe !
% nss{class id + 1} = line id !
[nss , nsst ] = indice_class(id_class , inria_objfi, idx_realtrain, idx_test);
NSS = [];

for k = 1 : length(id_class)
    NSS = [NSS; nss{ id_class(k)+1 }];
end
if opt.v1000
    VF = Vfeat;
else
    VF = Vfeature;
end
if ~ opt.trainall
tmppV = VF(NSS,:); % line classment re-ordered by class id!!
tmppT = Tfeature(NSS, :);
else
    tmppV = VF(idx_realtrain, : );
    tmppT = Tfeature(idx_realtrain, : );
end

% NSS created.
%% choose CCA's 2 views
ccaV = tmppV; % trainV
ccaT = tmppT; % trainT

% break;
%% CCA : W , Z and canonical variates plot
opt.d = 300; %400,200;100;%10; %10 3 20 dimension of the latent variable z
opt.classes = querie_classes;
opt.cano_vs = [1,2]; % canonical direction ids


opt.docca = 0;
if opt.docca %|| ~exist('X')
    
    disp(['start CCA with saved dimension: ',int2str(opt.d),' for I2T...']);
    t1 = tic;
    [X,T,Wx,W,Ds,D,Z ] = CCA_IMTnew(ccaV,ccaT,opt);
    tcca = toc(t1);
    disp(['CCA time : ', num2str(tcca)]);
    
    save([root_resultsNEW,'cca_0-300_2tv1000-d',int2str(opt.d),'.mat'],...
        'X','T','Wx','W','Ds','D','Z');
else
    if ~ exist('Z', 'var')
%         load('cca_readyNEW.mat');
    end
end
%plot_ccaNEW(nss,Z,opt);
% break;
%% Image-text retrieval
opt.maxpool = 20;  % control the amount of candiate words
opt.Nss = nss;     % decoupage des images/texts de chaque classe
opt.occ = 6;       % control the amount of retrieved text
opt.nwords_display = opt.occ; % replace the historic ~.occ
opt.I2T = 0;
opt.periodic = 0;

opt.i2i = 0;
i2tcontrol = [0 0 43];
opt.randomi2t = i2tcontrol(1);
opt.cl = i2tcontrol(2);
opt.imreq = i2tcontrol(3);%216;%350;     % % (2,114: hotel,valet,~; hotel,~)
% (9/211 ~ 179/109 -- good)
% (19/434 ~ computer, keyboard -- good!)
% (19/208 ~ mont blanc ---good !)
% (19/203 ~ mont blanc ---good !!)
% (0/346 ~ )
% (0/43 ~ )
% (99/539,135 ~ i2t very good !! )
% (20/128 montst good!)
opt.external_image = 0;
% Text2Image search:
opt.maxwords = 7;
opt.maxkwords = 9;
opt.tdim = 200;
opt.tmaxpool = 20; % 9;


%% similarity measure:
simI2T = @(x,t,W,D) (x*W{1}*D)*(t*W{2}*D)' ./...
    ( norm(x*W{1}*D) * sum( (t*W{2}*D).*(t*W{2}*D) ,2 )' );

simT2I = @(x,t,W,D) (t*W{2}*D)*(x*W{1}*D)' ./...
    ( norm(t*W{2}*D) * sum( (x*W{1}*D).*(x*W{1}*D),2 )' );

simI2I = @(xq,x, W,D) (xq*W{1}*D)*(x*W{1}*D)' ./...
    ( norm(xq*W{1}*D) * sum( (x*W{1}*D).*(x*W{1}*D) ,2 )' );

opt.i2iN = 36;

% for each of the sub directories {btexts,atexts,ptexts}, we can find these tag files
requestname = request_name(nsst,inria_imgdir, inria_objfi, opt);
% break;
    tt_request = input('Please input your request key words:\n','s');
    tt_request = string2words(tt_request);
        tvec = text2vecNEW(tt_request, inriaPBA, opt); % vertical vector
    
     % NEW T2I
    sims_t2i = simT2I(X,tvec,W,D);
%      break;
    [inds, xx, ranknames] = display_i2it_imgranks(sims_t2i,ccaT,inria_objf, opt);
     figure(300) ; clf ; set(300,'name','ranked training images (subset)') ;
     displayRankedImageList( ranknames, sims_t2i(inds(1:opt.i2iN)));
     saveas(figure(300), [root_fig,'ranksT2I.png']);
     % END of NEW T2I
    


