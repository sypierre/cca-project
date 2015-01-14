function plotI2Tnew(pool_sel, occd, inria_imgdir, requestname, opt )


im  = imread([ inria_imgdir, requestname]);%image_namelist{cl}{listj}]);

figure(200);
subplot(171);
imagesc(im);
axis off;
for j = 1 : 6%length(pool_sel)
subplot(1,7,1+j);
text(0.5, 0.55, pool_sel{j}, 'FontSize',24, 'Color','r', ...
    'HorizontalAlignment','Center', 'VerticalAlignment','Middle');
text(0.7, 0.4, int2str(occd(j)), 'FontSize',20, 'Color','b', ...
    'HorizontalAlignment','Center', 'VerticalAlignment','Middle');
axis off;
end

% listj = find(ismember(v_class_names,requestname) );
% %refname = T_class{cl}{listj}.tagname;
% ref = T_class{cl}{listj}.tagwords;
xlabel('Retrieved text');

% subplot(422);
% text(0.5, 0.5, ref, 'FontSize',24, 'Color','k', ...
%     'HorizontalAlignment','Center', 'VerticalAlignment','Middle');
% xlabel('(Inria websearch tag)');
% saveas(figure(12), ['PGM-report/figures/I2T-t.png']);


% figure(11); 
% imagesc(im);
saveas(figure(200), ['PGM-report/figures/I2T-new.png']);





