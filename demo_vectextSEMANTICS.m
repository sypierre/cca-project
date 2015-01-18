
%(1)
% VSEM = zeros(size(cls,1), 3*opt.tdim);
% 
% for i = 1  : size(cls,1)
%     
%     
%     VSEM(i,:) = text2vecNEWSEM(textSEM{cls(i)+1}, inriaPBA, opt);
% end

% (2)
save('inria_VSEM.mat','VSEM');

ks = [0, 200 400 600];

for kk = 1 : 3
VSEMM{kk} = VSEM(:, ks(kk)+1:ks(kk+1));



end

VSEMb =(1/3)*( VSEMM{1} + VSEMM{2} + VSEMM{3} );
