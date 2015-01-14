
function demo_ADDPATHS3(opt)

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

addpath('./structures');
addpath('./feature_processing');
addpath('./I2T2I');
 addpath('./inria_obj_features');
% addpath('./inria_objects');
addpath('./inria_I2T2I_display');
addpath('./inria_results');

disp('loading feature archives...');
%---------- One of the 2 suffices
if opt.window2
load('inria_objf-2tfeaturesi.mat'); 
% matObj = matfile('inria_objf-vfeatsi.mat');
% whos(matObj)
else
load('inria_objf-tfeaturesi.mat'); 
end

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
load('inria_semantics.mat');

end
