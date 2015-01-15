function test_image = image2cnnNEW( absline,requestname,VF, opt)
% convert image to cnn feature vector
% NOT NEEDED IN FACT / 15 JAN
if ~opt.EVA
im  = imread([ opt.imgdir, requestname]);%image_namelist{cl}{listj}]);
figure(100); imagesc(im);
end
% imn = single(im);
% imn = imresize(imn, net.normalization.imageSize(1:2));
%
% if ndims(imn) == ndims(net.normalization.averageImage)
%     imn = imn - net.normalization.averageImage;
%     res = vl_simplenn(net, imn);
%     if opt.v1000
%     test_image(1:1000) = res(end).x(1,1,1:1000);
%     else
%         test_image(1: 4096) = res(20).x(1,1,1:4096);
%     end
% else
%     disp('Bad image, change one please...');
%     if opt.v1000
%     test_image = zeros(1, 1000);
%     else
%     test_image = zeros(1, 4096);
%     end
% end

if opt.v1000
    test_image = VF(absline, 1:1000);
else
    test_image = VF(absline,1:4096);
end


end