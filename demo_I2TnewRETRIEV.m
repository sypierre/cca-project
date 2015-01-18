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
    
    cls = unique( inria_objfi(:,1) );
    break;
end

clearvars -except inriaPBA net inria_lobj tagwords ...
    inria_objf inria_objfv Vfeature  Vfeat ...
    inria_objft Tfeat2  Tfeat1 inria_objfi idx_bad  idx_badT ...
    idx_bads  idx_goods  X  T  Wall  W  Dall  D  Z  ...
    semantic  cls  Wx  Wy  LAM Zw  invU ccaV ccaT NSS nss nsst relevance ...
    rel_train rel_all rel_test rel_test_ids rel_cls_intras rel_testxval...
    rel_testeval textSEM VSEM VSEMb SEMF SEMFb SEMFbb SS ccaS;
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
    idx_bads = union(idx_bad, idx_badT );
    idx_goods = setdiff((1:N) , idx_bads);
end

% create train set
modidx = mod(idx_goods , 5);
if ~ exist('idx_test')
    idx_test =  idx_goods( find (modidx == 0) );
    idx_train = setdiff(idx_goods, idx_test );
end
if  ~ exist('rel_test')
    rel_train = intersect( idx_train, find(relevance(:,3)==1) );
    rel_all = intersect( [1:71478], find(relevance(:,3)==1) );
    rel_test = intersect( idx_test, find(relevance(:,3)==1) );
    
    rel_testxval = rel_test( find(mod(rel_test,2) == 0 ) );
    rel_testxval = rel_testxval( randi(length(rel_testxval),1,min(1000,length(rel_testxval)))   );
    
    rel_testeval = setdiff(rel_test, rel_testxval );
    rel_testeval = rel_testeval( randi(length(rel_testeval),1,min(3000,length(rel_testeval)))   );
    
    rel_testeval_ids = inria_objfi(rel_testeval, :);
    for i = 1 : 355
        rel_cls_intras{i} = rel_testeval_ids(find(rel_testeval_ids(:,1)== i-1 ),2);
        % rel equivalence of nss, nsst
        %  nss{classid + 1} : absline values of train set
        % nsst{classid + 1 }: absline values of test set
        rel_cls_testeval{ i } = rel_testeval( find(rel_testeval_ids(:,1) == i-1) );
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
opt.view3 = 1;
opt.cano_vs = [1,2]; % canonical direction ids

opt.I2T = 1;
opt.periodic = 0;
i2tcontrol = [0 101 1];
% i2tcontrol = [0 101 rel_cls_intras{102}( 10 )]; % 57
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
    TFtest = Tfeat2(idx_test, : );
    TFxval = Tfeat2(rel_testxval,:);
    TFeval = Tfeat2(rel_testeval,:);
else
    TF = Tfeat1;
    TFtest = Tfeat1(idx_test , : );
    TFxval = Tfeat1(rel_testxval,:);
    TFeval = Tfeat1(rel_testeval,:);
    
end
if opt.v1000
    VF = Vfeat;
    VFtest = Vfeat(idx_test, : );
    VFxval = Vfeat(rel_testxval,:);
    VFeval = Vfeat(rel_testeval,:);
    
else
    VF = Vfeature;
    VFtest = Vfeature(idx_test, : );
    VFxval = Vfeature(rel_testxval,:);
    VFeval = Vfeature(rel_testeval,:);
    
end

SF = SEMFbb;
SFtest = SEMFbb(idx_test,:);
SFxval = SEMFbb(rel_testxval,:);
SFeval = SEMFbb(rel_testeval,:);
% break;
%% CCA : W , Z and canonical variates plot

if opt.docca %|| ~exist('X')
    
    disp(['start CCA .... ']);
    % %     % nss contains the absolute line information about the classes_observe !
    % nss{class id + 1} = line id !
    [nss , nsst ] = indice_class(id_class , inria_objfi, idx_realtrain, rel_test);
    NSS = [];
    
    for k = 1 : length(id_class)
        NSS = [NSS; nss{ id_class(k)+1 }]; % nss{id_class(k)+1} may be empty
    end
    % % % choose CCA's 2 views
    
    if ~ opt.trainall
        ccaV = VF(NSS,:); % line classment re-ordered by class id!!
        ccaT = TF(NSS, :);
        ccaS = SF(NSS,:);
    else
        ccaV = VF(idx_realtrain, : );
        ccaT = TF(idx_realtrain, : );
        ccaS = SF(idx_realtrain, : );
    end
    
    t1 = tic;
    [X,T,SS, Wx, Wy, LAM, Wall , Dall] = newCCA_IMTnew(ccaV,ccaT,ccaS, opt);
%         [X,T,SS, Wx, Wy, LAM, Wall , Dall] = newCCA_IMTnew(ccaV,ccaS,ccaT, opt);

    tcca = toc(t1);
    disp(['CCA time : ', num2str(tcca)]);
    
    save([root_resultsNEW,'NEWNEWcca_ALL_tv1000.mat'],...
        'Wx','Wy','LAM','Wall','Dall');
end

%% similarity measure:
simI2T = @(x,t,W) (x*W{1})*(t*W{2})' ./...
    ( norm(x*W{1}) * sqrt( sum((t*W{2}).*(t*W{2}),2)') );

simI2Tval = @(Z1, Z) (Z1)*(Z)' ./...
    ( sqrt(sum(Z1.*Z1,2)) * sqrt( sum((Z).*(Z),2)' ) );

% wrong !  sqrt must be added!
simT2I = @(x,t,W ) (t*W{2})*(x*W{1})' ./...
    ( norm(t*W{2} ) * sqrt(sum( (x*W{1}).*(x*W{1}),2 )') );

simI2I = @(xq,x,W ) (xq*W{1})*(x*W{1})' ./...
    ( norm(xq*W{1} ) * sqrt(sum( (x*W{1} ).*(x*W{1} ) ,2 )') );

opt.randomi2t = i2tcontrol(1);
%% VAL TEST SETTING
p = size(VF,2) - 1;
q = size(TF,2) - 1;
qq = size(SF,2) -1;
% break;
W0{1} = Wall(1:p , 1: min( [p,q,qq] ) );
W0{2} = Wall(p+1: p+q, 1: min([p,q,qq] )  );

Zt{1} = [X *W0{1} , ccaV(:,end) ];
Zt{2} = [T *W0{2} , ccaT(:,end) ];

Z0{1} = [VFtest(:,1:p) *W0{1} , VFtest(:,end) ];%(:, 1:opt.d );
Z0{2} = [TFtest(:,1:q) *W0{2} , TFtest(:,end) ];%(:, 1:opt.d );


Z0val{1} = [VFxval(:,1:p) *W0{1} , VFxval(:,end) ];%(:, 1:opt.d );
Z0val{2} = [TFxval(:,1:q) *W0{2} , TFxval(:,end) ];%(:, 1:opt.d );

Z0eval{1} = [VFeval(:,1:p) *W0{1} , VFeval(:,end) ];%(:, 1:opt.d );
Z0eval{2} = [TFeval(:,1:q) *W0{2} , TFeval(:,end) ];%(:, 1:opt.d );

if opt.view3
    W0{3} = Wall(p+q+1:end, 1: min([p,q,qq] )  );
    Zt{3} = [SS *W0{3} , SF(NSS,end) ];
    Z0{3} = [SFtest(:,1:qq) *W0{3} , SFtest(:,end) ];%(:, 1:opt.d );
    Z0val{3} = [SFxval(:,1:qq) *W0{3} , SFxval(:,end) ];%(:, 1:opt.d );
    Z0eval{3} = [SFeval(:,1:qq) *W0{3} , SFeval(:,end) ];%(:, 1:opt.d );
end

%% Validation : choose dimensionality of W
dimensions = [64  128  200  256 280 300 310 380 512]; %round( linspace(64,664, 20) ); %[64  128  200  256  300  512]; %2.^[6:9];

% opt.i2i = 1;
% if opt.i2i
%     savech = 'I2I';
% else
%     savech = 'I2T';
% end

dd = 4;

retrivmode = 'T2I';
switch retrivmode
    case 'I2I'
        dd = 2;
    case 'I2T'
        dd = 4;
    case 'I2K'
        dd = 4;
    case 'K2I'
        dd = 4;
    case 'T2I'
        dd = 4;
end

opt.d = dimensions(dd); %300 400,200;100;%10; %10 3 20 dimension of the latent variable z
disp(['Dimensionality of W: ',int2str(opt.d),' for I2T2I...']);

W{1} = W0{1}(: , 1:opt.d);
W{2} = W0{2}(: , 1:opt.d);

D = Dall(1:opt.d, 1:opt.d);
tmpz = Zt; % Z0;
Z{1} = [tmpz{1}(:, 1 : opt.d), tmpz{1}(:,end)]; % Z0
Z{2} = [tmpz{2}(:, 1 : opt.d), tmpz{2}(:,end)];

Zval{1} = [ Z0val{1}(:,1:opt.d), Z0val{1}(:,end) ];
Zval{2} = [ Z0val{2}(:,1:opt.d), Z0val{2}(:,end) ];

Zeval{1} = [ Z0eval{1}(:,1:opt.d), Z0eval{1}(:,end) ];
Zeval{2} = [ Z0eval{2}(:,1:opt.d), Z0eval{2}(:,end) ];

%     plot_ccaNEW(nss,Z, Z, opt, 1, semantic);
if opt.view3
    W{3} = W0{3}(: , 1:opt.d);
    Z{3} = [tmpz{3}(:, 1 : opt.d), tmpz{3}(:,end)];
    Zval{3} = [ Z0val{3}(:,1:opt.d), Z0val{3}(:,end) ];
    Zeval{3} = [ Z0eval{3}(:,1:opt.d), Z0eval{3}(:,end) ];
end

%     break;
%% RETRIVAL of cl intra
opt.i2iN = 36;
opt.randomi2t = 0;
opt.maxpool = 20;  % control the amount of candiate words
opt.Nss = nss;     % decoupage des images/texts de chaque classe
opt.occ = 6;       % control the amount of retrieved text
opt.nwords_display = opt.occ; % replace the historic ~.occ
opt.tdim = 200;
opt.maxwords = 7;


ret_clin = 5;
ret_cl = 100;
opt.cl = ret_cl -1;
subsave = 'T2I/';
opt.imreq = inria_objfi(nsst{opt.cl+1}(ret_clin),2);

[requestname, abslines] = request_nameNEW(nsst,inria_imgdir, inria_objfi, opt);
        NN = 1;
        requestnames = {requestname};
        
        
switch retrivmode
    case 'I2I'
        Ztest = VF( nsst{ret_cl}(ret_clin),1:1000)*W0{1}(:,1:opt.d) ;     %Zeval{1};
        Zbase = Z{1};
    case 'I2T'
        Ztest = VF( nsst{ret_cl}(ret_clin),1:1000)*W0{1}(:,1:opt.d); 
        Zbase = Z{2};
    case 'I2K'
        Ztest = VF( nsst{ret_cl}(ret_clin),1:1000 )*W0{1}(:,1:opt.d); 
        Zbase = Z{3};
    case 'K2I'
%         Ztest = SF( nsst{ret_cl}(ret_clin),1:353 )*W0{3}(:,1:opt.d); 
        Zbase = Z{1};
    case 'T2I'
%         Ztest = TF( nsst{ret_cl}(ret_clin),1:1400 )*W0{2}(:,1:opt.d); 
        Zbase = Z{1};
end

if 0

disp('calculating RETmatrix...');
RETmatrix = simI2Tval( Ztest , Zbase(:,1:end-1) );
RETmatrix( find(isnan(RETmatrix)) ) = 0;

 simsSUM = sum(RETmatrix);
if simsSUM == 0
    disp('SUM of val matrix singular...');
end

%%%
%
    [~, inds] = sort(RETmatrix,'descend');
%     opt.i2iN = 36;
    
    xx = Zbase(inds(1: opt.i2iN),end); % absolute line values!
    %inria_objf{xx(1:20)}
    for r = 1  : opt.i2iN
        ranknames{r} = inria_objf{ xx(r) }.img_file;
    end

                figure(101) ; clf ; set(101,'name','ranked training images (subset)') ;
                displayRankedImageList( ranknames, RETmatrix(inds(1:opt.i2iN)));
                saveas(figure(101), [root_fig,subsave,'RETi2i.png']);
                figure(100); imagesc(imread(requestname));
                saveas(figure(100), [root_fig,subsave,'RETi2i-r.png']);
                %     end
                %%DISPLAY ranked Texts:
                %     if ~ opt.EVA
                [ pool_sel, occ_idx, pool, unipool, occd, occ ] = ...
                    Image2TextsNEW(inria_objf, xx,opt);
                plotI2Tnew( pool_sel, occd, inria_imgdir, requestnames{1}, opt );
            
                 saveas(figure(200), [root_fig,subsave,'RETi2t.png']);
                rho = sum( inria_objfi(xx,1) == opt.cl ) / opt.i2iN;
                
                disp(['--- partially: ',num2str(rho)  ]);
        disp( ['query_',int2str(ret_cl-1),': P@36 = ',num2str(rho), '// NN = ', int2str(1)]);

else
            tt_request = input('Please input your request key words:\n','s');
        tt_request = string2words(tt_request);
        tvec = text2vecNEW(tt_request, inriaPBA, opt); % vertical vector
        
        % NEW T2I
        disp('calculating RETmatrix...');
RETmatrix = simI2Tval( tvec*W0{2}(:,1:opt.d) , Zbase(:,1:end-1) );
RETmatrix( find(isnan(RETmatrix)) ) = 0;

 simsSUM = sum(RETmatrix);
if simsSUM == 0
    disp('SUM of val matrix singular...');
end

%         RETmatrix = RETmatrix;
        %      break;
        [inds, xx, ranknames] = display_i2it_imgranks(RETmatrix,ccaT,inria_objf, opt);
        figure(300) ; clf ; set(300,'name','ranked training images (subset)') ;
        displayRankedImageList( ranknames, RETmatrix(inds(1:opt.i2iN)));
        saveas(figure(300), [root_fig,subsave,'ranksT2I.png']);
end
%%%


% Rho = zeros(1,355 );
% Wei = zeros(1,355);
% for cc = 1 : length(cls)
%     clid = cls(cc);
%     % find clid in Z{2}
%     vallines = find( inria_objfi(Ztest(:,end) ,1 ) == clid  );
%     disp(['class ',int2str(cls(cc)),' : nb test images = ',int2str(length(vallines))] );
%     xx = zeros(length(vallines), opt.i2iN);
%     rho = zeros(length(vallines),1);
%     [~, INDS] = sort( RETmatrix(vallines,:),2,'descend' );
%     for ii = 1 : length(vallines)
%         
%         xx(ii,:) = Zbase(INDS(ii,1: opt.i2iN), end); % absolute line values!
%         
%         
%         rho(ii) = sum( inria_objfi(xx(ii,:),1) == clid ) / opt.i2iN;
%     end
%     Wei(clid + 1) = length(vallines);
%     Rho(clid+1) = mean(rho);
%     %
%     %         abslines = find( inria_objfi(Z{2}(:,end),1) == clid  );
%     %         simsid = sum(sum( RETmatrix(vallines, abslines) ));
%     %         valscore( clid+1 ) = simsid/simsSUM;
%     %         disp(['---validation score of class ', int2str(clid),' is: ',num2str(valscore(clid+1))] );
% end
% 
% valinds = find(~isnan(Rho));
% Rho(isnan(Rho)) = 0;
% [maxeval, maxinds] = sort(Rho,'descend');
% Rhoo = Rho(valinds);
% Weii = Wei(valinds);
% 
% EVAL = Weii*Rhoo'/sum(Weii);
% disp(['EVAL: ', num2str(EVAL)]);
% 
% figure(22); subplot(211);  bar(Rhoo);
% subplot(212); bar(Weii);
% title(['Evaluation ',retrivmode,': ', num2str(EVAL)]);
% saveas(22, [root_fig, 'Evaluation-',retrivmode,'-d',int2str(opt.d),'.png']);
% 
% disp(maxeval(1:3));
% disp(maxinds(1:3));


