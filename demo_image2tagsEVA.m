%pipeline image2tags

% --------------------NEW START SETTINGS -------------------
%% % 01:50 - integrated addpaths into <~>

opt.window2 = 1;
if opt.window2
    disp('phrased textual vectors...');
else
    disp('not phrased textual vectors...');
end

if ~ exist('net', 'var')
    demo_ADDPATHS3;
    %---------- One of the 2 suffices
    
      tph = load('inria_objf-2tfeaturesi.mat');
      Tfeat2 = tph.Tfeature;
        % matObj = matfile('inria_objf-vfeatsi.mat');
        % whos(matObj)
    
       ts = load('inria_objf-tfeaturesi.mat');
       Tfeat1 = ts.Tfeature;
    break;
end

clearvars -except inriaPBA et net et inria_lobj et tagwords et...
    inria_objf et inria_objfv et Vfeature et Vfeat et ...
    inria_objft et Tfeat2 et Tfeat1 et inria_objfi et idx_bad et idx_badT et...
    idx_bads et idx_goods et X et T et Wall et W et Dall et D et Z et ...
    semantic et cls;
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

opt.trainall = 0;
opt.v1000 = 1;
opt.window2 = 0;
opt.observ = [0, 50, 99];%[1 , 20 , 180 ];
opt.docca = 0;
 opt.d = 300; %400,200;100;%10; %10 3 20 dimension of the latent variable z
 opt.cano_vs = [1,2]; % canonical direction ids

opt.I2T = 1;
opt.periodic = 0;
opt.i2i = 0;

opt.EVA = 1;

for k = 1 : length(opt.observ)
    opt.classes{k} = semantic{opt.observ(k) + 1};
end

%% NSS
id_class = [0 : 300];%[0,100,200]%(good);[0, 10, 130,(131:200) ];%[0, 93, 349];%
disp('creating nss...');
% nss contains the absolute line information about the classes_observe !
% nss{class id + 1} = line id !
[nss , nsst ] = indice_class(id_class , inria_objfi, idx_realtrain, idx_test);
NSS = [];

for k = 1 : length(id_class)
    NSS = [NSS; nss{ id_class(k)+1 }];
end
if opt.window2
    TF = Tfeat2;
else
    TF = Tfeat1;
end
if opt.v1000
    VF = Vfeat;
else
    VF = Vfeature;
end

%% choose CCA's 2 views

if ~ opt.trainall
ccaV = VF(NSS,:); % line classment re-ordered by class id!!
ccaT = TF(NSS, :);
else
    ccaV = VF(idx_realtrain, : );
    ccaT = TF(idx_realtrain, : );
end
%% CCA : W , Z and canonical variates plot

if opt.docca %|| ~exist('X')
    
    disp(['start CCA with saved dimension: ',int2str(opt.d),' for I2T...']);
    
    t1 = tic;
    if 1
    [X,T,Wall,W,Dall,D,Z ] = CCA_IMTnew(ccaV,ccaT,opt);
    else
    [nX,nT, nWx, nWy,nLAM,ninvU, nW, nDall,nD,nZ] = newCCA_IMTnew(ccaV,ccaT,opt);
    end
    tcca = toc(t1);
    disp(['CCA time : ', num2str(tcca)]);
    
    save([root_resultsNEW,'cca_0-300_2tv1000-d',int2str(opt.d),'.mat'],...
        'X','T','Wall','W','Dall','D','Z');
else
    if ~ exist('Z', 'var')
%         load('cca_readyNEW.mat');
    end
end
%plot_ccaNEW(nss,Z,opt);

% break;
%% EVA 
opt.maxpool = 20;  % control the amount of candiate words
opt.Nss = nss;     % decoupage des images/texts de chaque classe
opt.occ = 6;       % control the amount of retrieved text
opt.nwords_display = opt.occ; % replace the historic ~.occ

opt.randomi2t = i2tcontrol(1);
opt.imreq = i2tcontrol(3);%216;%350;     % % (2,114: hotel,valet,~; hotel,~)
 % (9/211 ~ 179/109 -- good)
% (19/434 ~ computer, keyboard -- good!)
% (19/208 ~ mont blanc ---good !)
% (19/203 ~ mont blanc ---good !!)
% (0/346 ~ )
% (0/43, 8 ~ )
% (99/539,135 ~ i2t very good !! )
% (20/128 montst good!)
opt.external_image = 0;
% Text2Image search:
opt.maxwords = 7;
opt.maxkwords = 9;
opt.tdim = 200;
opt.tmaxpool = 20; % 9;
%% similarity measure:
simI2T = @(x,t,W) (x*W{1})*(t*W{2})' ./...
    ( norm(x*W{1}) * sqrt( sum( (t*W{2}).*(t*W{2}) ,2 )') );
% wrong !  sqrt must be added!
simT2I = @(x,t,W ) (t*W{2})*(x*W{1})' ./...
    ( norm(t*W{2} ) * sqrt(sum( (x*W{1}).*(x*W{1}),2 )') );

simI2I = @(xq,x,W ) (xq*W{1})*(x*W{1})' ./...
    ( norm(xq*W{1} ) * sqrt(sum( (x*W{1} ).*(x*W{1} ) ,2 )') );

opt.i2iN = 36;

for ee = 7 : 100

i2tcontrol = [1 cls(ee) 43];


%% Image-text retrieval
opt.cl = i2tcontrol(2);

if ~ opt.EVA
[requestname, abslines] = request_nameNEW(nsst,inria_imgdir, inria_objfi, opt);
NN = 1;
requestnames = {requestname};
else
    [requestnames,abslines] = request_nameEVA(nsst,inria_imgdir, inria_objfi, opt);
    NN = length(requestnames);
end
    
% break;
if opt.I2T % opt.~
        rho = 0;
    
    for nn = 1 : NN
    
    x = image2cnnNEW(abslines(nn), VF, opt);
    disp(['-------- ',requestnames{nn}]);

    % TEMPORARY TRY
    if ~ opt.i2i
%         sims = simI2T(x,T,W,D) ; 
         % using Z{2}
          ZT = Z{2}(:,1:opt.d);
        sims = (x*W{1})*(ZT') ./...
    ( norm(x*W{1}) * sqrt(sum( ZT.*ZT ,2 )') ); % ZT.*ZT wrong!!
         % END of using Z{2}
         
    else
        sims = simI2I(x,X,W,D) ; 
    end
    % DISPLAY ranked Images:
    [inds, xx, ranknames] = display_i2it_imgranks(sims,ccaT,inria_objf, opt);
    if ~ opt.EVA
    figure(101) ; clf ; set(101,'name','ranked training images (subset)') ;
    displayRankedImageList( ranknames, sims(inds(1:opt.i2iN)));
    saveas(figure(101), [root_fig,'ranksI2IT.png']);
    saveas(figure(100), [root_fig,'ranksI2IT-r.png']);
%     end
    %%DISPLAY ranked Texts:
%     if ~ opt.EVA
    [ pool_sel, occ_idx, pool, unipool, occd, occ ] = ...
        Image2TextsNEW(inria_objf, xx,opt);
    plotI2Tnew( pool_sel, occd, inria_imgdir, requestnames{nn}, opt );
    end
    
    % END of temporary try
    %     break;
    %     [responses,indx,occd,occ, pool,inds,sims] = Image2Texts(x, T , W, D,simI2T,T_class,opt);
    %     listj = plotI2T(responses, cl_request,id_class,T_class,im_request);
    
    
    % FIND LABELS
% %     xx_cls = []; scores = sims( inds(1:opt.i2iN) );
% %     for i = 1 : length(xx)
% %         xx_cls(i) = inria_objf{ xx(i) }.id_class;
% %         labels(i) =2*( xx_cls(i) == opt.cl ) - 1;
% %     end
% %     figure(102) ;  %set(2,'name','precision-recall on train data') ;
% %     vl_pr(labels, scores);
    
% %     saveas( figure(102), [root_fig,'I2I-APRnew.png']);
    
     for i = 1 : length(xx)
         rho = rho + ( inria_objf{ xx(i) }.id_class == opt.cl );
     end    
    end
         rho = rho/(NN*opt.i2iN);
         disp( ['query_',int2str(cls(ee)),': P@36 = ',num2str(rho)]);
         if opt.EVA
             save([root_resultsNEW, 'EVA-I2I-cl',int2str(opt.cl),'.mat'],'rho','NN','opt');
         end

    
    
else
    %     tt_request = {'arc','de','triomphe'};
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
    
end


end