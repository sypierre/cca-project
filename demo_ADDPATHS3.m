
% demo_ADDPATHS3

setup;
% demo_ADDPATHS;
addpath('./data/webqueries/images');

t1 = tic;
    load('dictionary_inriaPBA.mat');
    addpath('./matconvnet-1.0-beta7/matlab');
    run vl_setupnn;
    addpath('./inria_objects');
    net = load('imagenet-vgg-f.mat');
tl = toc(t1);

% addpath('./structures');
addpath('./feature_processing');
addpath('./I2T2I');
 addpath('./inria_obj_features');
% addpath('./inria_objects');
addpath('./inria_I2T2I_display');
addpath('./inria_resultsNEW');

disp('loading feature archives...');

%-----------
load('inria_objf-vfeaturesi.mat'); % 4096 + 1 ! 
load('inria_objf-vfeatsi.mat');    % 1000 + 1
% -----------

% load('inria_objf-tfeaturesall.mat');
% load('inria_objf-vfeaturesall.mat');

% ------------------------
disp('continue loading ...');
load('inria_objf_nobad.mat');
% -------------------------

load('inria_objfi-classind.mat');
load('inria_idxbads.mat');

load('inria_semantics.mat');

