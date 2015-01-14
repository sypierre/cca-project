function test_image = image2cnnNEW(requestname , opt)
% convert image to cnn feature vector

if ~ opt.external_image
% extract individual image vector from test set:
net = load('imagenet-vgg-f.mat');
source_data = './data/webqueries/images/';
 
% if nargin < 2
%     imid = randi(length(image_namelist{cl}));
% end

% requestname = ['query_',int2str(id_class(cl)),'_document_',...
%  int2str(requestname),'_imagethumb.jpg'];

else
    % directory to be built:
    requests = load('external_image_names.mat');
    source_data = './data/external_images/';
    iid = randi(length(requests.names));
    requestname = requests.names{iid};
end
    %listj = find(ismember(image_namelist{cl},requestname) );
im  = imread([ source_data, requestname]);%image_namelist{cl}{listj}]);
figure(100); imagesc(im);
imn = single(im);
imn = imresize(imn, net.normalization.imageSize(1:2));

if ndims(imn) == ndims(net.normalization.averageImage)
    imn = imn - net.normalization.averageImage;
    res = vl_simplenn(net, imn);
    if opt.v1000
    test_image(1:1000) = res(end).x(1,1,1:1000);
    else
        test_image(1: 4096) = res(20).x(1,1,1:4096);
    end
else
    disp('Bad image, change one please...');
    if opt.v1000
    test_image = zeros(1, 1000);
    else
    test_image = zeros(1, 4096);
    end
end

    

end