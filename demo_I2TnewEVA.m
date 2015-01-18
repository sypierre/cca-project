%pipeline image2tags

% --------------------NEW START SETTINGS -------------------
%% % 01:50 - integrated addpaths into <~>


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

clearvars -except inriaPBA net inria_lobj tagwords ...
    inria_objf inria_objfv Vfeature  Vfeat ...
    inria_objft Tfeat2  Tfeat1 inria_objfi idx_bad  idx_badT ...
    idx_bads  idx_goods  X  T  Wall  W  Dall  D  Z  ...
    semantic  cls  Wx  Wy  LAM Zw  invU ccaV ccaT NSS nss nsst relevance ...
    rel_train rel_all rel_test rel_test_ids rel_cls_intras rel_testxval...
    rel_testeval;
close all;

inria_imgdir = './data/webqueries/images/';
opt.imgdir = inria_imgdir;
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
if ~ exist('rel_test')
rel_train = intersect( idx_train, find(relevance(:,3)==1) );
rel_all = intersect( [1:71478], find(relevance(:,3)==1) );
rel_test = intersect( idx_test, find(relevance(:,3)==1) );
rel_test_ids = inria_objfi(rel_test, :);
for i = 1 : 355
rel_cls_intras{i} = rel_test_ids(find(rel_test_ids(:,1)== i-1 ),2);
end

end
% rel_cls_intras{} = rel_test_ids(find(rel_test_ids(:,1)==19),2);

% hist(modidx, 5);
NT = length(idx_train);
partial = 1;
idx_realtrain = idx_train(1: fix(NT/partial) );
% END OF create train set

opt.trainall = 0;
opt.v1000 = 1;
opt.window2 = 0;
if opt.window2
    disp('phrased textual vectors...');
else
    disp('not phrased textual vectors...');
end

opt.docca = 0;
opt.d = 256; %300 400,200;100;%10; %10 3 20 dimension of the latent variable z
opt.cano_vs = [1,2]; % canonical direction ids

opt.I2T = 1;
opt.periodic = 0;
opt.i2i = 0; % i2i: doptimal = 128
i2tcontrol = [0 101 rel_cls_intras{102}( 10 )]; % 57
% we may enable rel_test_cl{:} to replace <nsst> !
opt.oldZ = 1;
 opt.puiss = 3;

opt.EVA = 0;  opt.EVA1 = find(cls == 19); opt.EVA2 = opt.EVA1;
if ~ opt.EVA
    opt.EVA1 = 1;
    opt.EVA2 = 1;
end
opt.observ = [0, 50, 99];%[1 , 20 , 180 ];

%% NSS
id_class = [0 : 355];%[0,100,200]%(good);[0, 10, 130,(131:200) ];%[0, 93, 349];%
disp('creating nss...');

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
% break;
p = size(VF,2) - 1;
%% CCA : W , Z and canonical variates plot

if opt.docca %|| ~exist('X')
    
    disp(['start CCA with saved dimension: ',int2str(opt.d),' for I2T...']);
% %     % nss contains the absolute line information about the classes_observe !
% nss{class id + 1} = line id !
[nss , nsst ] = indice_class(id_class , inria_objfi, idx_realtrain, idx_test);
 NSS = [];

for k = 1 : length(id_class)
    NSS = [NSS; nss{ id_class(k)+1 }]; % nss{id_class(k)+1} may be empty
end
% % % choose CCA's 2 views

if ~ opt.trainall
    ccaV = VF(NSS,:); % line classment re-ordered by class id!!
    ccaT = TF(NSS, :);
else
    ccaV = VF(idx_realtrain, : );
    ccaT = TF(idx_realtrain, : );
end

 t1 = tic;
    [X,T, Wx, Wy, LAM, Wall , Dall] = newCCA_IMTnew(ccaV,ccaT,opt);
    
    tcca = toc(t1);
    disp(['CCA time : ', num2str(tcca)]);
    
    save([root_resultsNEW,'NEWcca_ALL_tv1000-d',int2str(opt.d),'.mat'],...
       'Wx','Wy','LAM','Zw','invU','W','Dall','D','Z');
end

W{1} = Wall(1:p,1:opt.d);
W{2} = Wall(p+1:end,1:opt.d);

D = Dall(1:opt.d,1:opt.d);

Z{1} = [X*W{1} , ccaV(:,end) ];%(:, 1:opt.d );
Z{2} = [T*W{2} , ccaV(:,end) ];%(:, 1:opt.d );

%% get invmu_x and invmu_t
rap = bsxfun(@rdivide, Wx(:,1:opt.d), W{1} );
rap = rap(1,:);
invU{1} = diag(rap);
clear('rap');

rap = bsxfun(@rdivide, Wy(:,1:opt.d), W{2} );
rap = rap(1,:);
invU{2} = diag(rap);

Zw{1} = [X*( Wx(:,1:opt.d)*(invU{1}.^3) ), ccaV(:,end) ];
Zw{2} = [T*( Wy(:,1:opt.d)*(invU{2}.^3) ), ccaT(:,end) ];

% plot_ccaNEW(nss,Z, Zw, opt, 1, semantic);

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
% (0/43, 8 ,30(100%P@36!)~ )
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

for ee = opt.EVA1 : opt.EVA2
    if opt.EVA
        i2tcontrol(2) = cls(ee); % = [1 cls(ee) 43];
    end
    
    %% Image-text retrieval
    opt.cl = i2tcontrol(2);
    
    if ~ opt.EVA
%         [requestname, abslines] = request_nameNEW(rel_cls_intras,inria_imgdir, inria_objfi, opt);
        
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
            rhon = 0; 
            x = image2cnnNEW(abslines(nn),requestnames{nn}, VF, opt);
            disp(['-------- ',requestnames{nn}]);
            
            % TEMPORARY TRY
            if ~ opt.i2i
                %         sims = simI2T(x,T,W,D) ;
                % using Z{2}
                if opt.oldZ
                    ZT = Z{2}(:,1:opt.d);
                    WW = W{1};
                else
                    ZT = Zw{2}(:,1:opt.d);
                    WW = Wx(:,1:opt.d);
                end
                sims = (x*WW)*(ZT') ./...
                    ( norm(x*WW) * sqrt(sum( ZT.*ZT ,2 )') ); % ZT.*ZT wrong!!
                % END of using Z{2}
                
            else
                sims = simI2I(x,X,W) ;
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
                  
%                 rhon = rhon +  ( inria_objf{ xx(i) }.id_class == opt.cl ) ;
                rhon = rhon +  ( inria_objfi( xx(i),1 ) == opt.cl ) ;

            end
            disp(['--- partially: ',num2str(rhon/(opt.i2iN) ) ]);
            rho = rho + rhon;
        end
        taux = rho/(NN*opt.i2iN);
        disp( ['query_',int2str(cls(ee)),': P@36 = ',num2str(taux), '// NN = ', int2str(NN)]);
        if opt.EVA
            save([root_resultsNEW, 'EVA-I2I-cl',int2str(opt.cl),'.mat'],'rho','NN','opt');
        end
        
    else
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