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
if 1 % ~ exist('rel_test')
    rel_train = intersect( idx_train, find(relevance(:,3)==1) );
    rel_all = intersect( [1:71478], find(relevance(:,3)==1) );
    rel_test = intersect( idx_test, find(relevance(:,3)==1) );

    rel_testxval = rel_test( find(mod(rel_test,2) == 0 ) );
    rel_testxval = rel_testxval( randi(length(rel_testxval),1,min(1000,length(rel_testxval)))   );
    
    rel_testeval = setdiff(rel_test, rel_testxval );
    rel_testeval = rel_testeval( randi(length(rel_testeval),1,min(1000,length(rel_testeval)))   );
    
    rel_test_ids = inria_objfi(rel_test, :);
    for i = 1 : 355
        rel_cls_intras{i} = rel_test_ids(find(rel_test_ids(:,1)== i-1 ),2);
        % rel equivalence of nss, nsst
        %  nss{classid + 1} : absline values of train set
        % nsst{classid + 1 }: absline values of test set
        rel_cls_test{ i } = rel_test( find(inria_objfi(rel_test,1) == i-1) );
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
opt.cano_vs = [1,2]; % canonical direction ids

opt.I2T = 1;
opt.periodic = 0;
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


% break;
%% CCA : W , Z and canonical variates plot

if opt.docca %|| ~exist('X')
    
    disp(['start CCA .... ']);
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
    
    save([root_resultsNEW,'NEWcca_ALL_tv1000.mat'],...
        'Wx','Wy','LAM','Zw','invU','W','Dall','D','Z');
end

p = size(VF,2) - 1;
q = size(TF,2) - 1;
W0{1} = Wall(1:p , 1: min( p,q ));
W0{2} = Wall(p+1:end, 1: min(p,q)  );

Z0{1} = [VFtest(:,1:p) *W0{1} , VFtest(:,end) ];%(:, 1:opt.d );
Z0{2} = [TFtest(:,1:q) *W0{2} , TFtest(:,end) ];%(:, 1:opt.d );
Z0val{1} = [VFxval(:,1:p) *W0{1} , VFxval(:,end) ];%(:, 1:opt.d );
Z0val{2} = [TFxval(:,1:q) *W0{2} , TFxval(:,end) ];%(:, 1:opt.d );

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

opt.i2iN = 36;
opt.randomi2t = i2tcontrol(1);

%% Validation : choose dimensionality of W
dimensions = [64  128  200  256 280 300 310 380 512]; %round( linspace(64,664, 20) ); %[64  128  200  256  300  512]; %2.^[6:9];

% dd = 1;
opt.i2i = 0;
if opt.i2i 
    savech = 'I2I';
else
    savech = 'I2T';
end
for dd =  1 : length(dimensions)
    opt.d = dimensions(dd); %300 400,200;100;%10; %10 3 20 dimension of the latent variable z
    
    disp(['Dimensionality of W: ',int2str(opt.d),' for I2T2I...']);
    
    W{1} = W0{1}(: , 1:opt.d);
    W{2} = W0{1}(: , 1:opt.d);
    
    D = Dall(1:opt.d, 1:opt.d);
    
    Z{1} = [Z0{1}(:, 1 : opt.d), Z0{1}(:,end)];
    Z{2} = [Z0{2}(:, 1 : opt.d), Z0{2}(:,end)];
    
    Zval{1} = [ Z0val{1}(:,1:opt.d), Z0val{1}(:,end) ];
    Zval{2} = [ Z0val{2}(:,1:opt.d), Z0val{2}(:,end) ];
    
    % plot_ccaNEW(nss,Z, Zw, opt, 1, semantic);
    
    % break;
    %% EVA
    if opt.i2i
    VALmatrix = simI2Tval( Zval{1}(:,1:end-1), Z{1}(:,1:end-1) );
    
    else
        VALmatrix = simI2Tval( Zval{1}(:,1:end-1), Z{2}(:,1:end-1) );
    end
    VALmatrix( find(isnan(VALmatrix)) ) = 0;
    
    
    simsSUM = sum(sum(VALmatrix));
    if simsSUM == 0
        disp('SUM of val matrix singular...');
    end
    %for l = 1 : size(I2Tval,1)
    valscore = zeros(1,355 );
    for cc = 1 : length(cls)
        clid = cls(cc);%inria_objfi( Zval{1}(l,end),1 );
        
        % find clid in Z{2}
        vallines = find( inria_objfi(Zval{1}(:,end) ,1 ) == clid  );
        abslines = find( inria_objfi(Z{2}(:,end),1) == clid  );
        simsid = sum(sum( VALmatrix(vallines, abslines) ));
        valscore( clid+1 ) = simsid/simsSUM;
        disp(['---validation score of class ', int2str(clid),' is: ',num2str(valscore(clid+1))] );
    end
    VALSCORE(dd) = sum(valscore);
    disp(['VALIDATION SCORE of dd =  ', int2str(opt.d),' is: ',num2str(VALSCORE(dd))] );
    
end
figure(23); plot(dimensions,VALSCORE);
saveas(23, [root_fig, 'XValidation-',savech,'-9d64-512.png']);





