


setup;

demo_ADDPATHS;
t1 = tic;
% dict used to be <dictionary_inriaPBA>
if ~ exist('inriaPBA', 'var')
    load('dictionary_inriaPBA.mat');
    addpath('./matconvnet-1.0-beta7/matlab');
    run vl_setupnn;
    addpath('./data');
    net = load('imagenet-vgg-f.mat');
end
tl = toc(t1);
% break;

addpath('./structures');
addpath('./feature_processing');
addpath('./I2T2I');
 addpath('./inria_obj_features');
addpath('./inria_objects');
addpath('./inria_I2T2I_display');
addpath('./inria_results');

disp('loading feature archives...');
load('inria_objf-tfeaturesi.mat');
load('inria_objf-vfeaturesi.mat');
load('inria_objf-vfeatsi.mat');

load('inria_objf-tfeaturesall.mat');
load('inria_objf-vfeaturesall.mat');

disp('continue loading ...');
load('inria_objf20_nobad.mat');
load('inria_objfi-classind.mat');

load('inria_semantics.mat');

