

% %(1)

% clear('tmpis');
% load('inria_VSEM.mat');
% 
% VS = VSEM;
% 
% SEMF = zeros(length(inria_objf), size(VS,2)+1 );
% 
% 
% for i = 1 : length(cls)
%     
%     tmpis = find( inria_objfi(:,1) == cls(i) );
%     
%     SEMF(tmpis,:) = [ones(length(tmpis),1)*VS(i,:), tmpis];
%     
% end


%(3)
clear('tmpis');
% load('inria_VSEMb.mat');
% VS = VSEMb; 
% SEMFb = zeros(length(inria_objf), size(VS,2)+1);

SEMFbb = zeros(length(inria_objf), length(cls)+1);

for i = 1 : length(cls)
    vs = zeros(1,length(cls));
    vs(i) = 1;
    tmpis = find( inria_objfi(:,1) == cls(i) );
    
    SEMFbb(tmpis,:) = [ones(length(tmpis),1)*vs, tmpis] ;
    
end

% save('inria_SEMF.mat','SEMF');
% 
% save('inria_SEMFb.mat','SEMFb');

% save('inria_SEMFbb.mat','SEMFbb');



