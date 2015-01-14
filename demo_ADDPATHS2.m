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
% addpath('./text_vectors');
addpath('./inria_objects');

load('inria_lobj.mat');