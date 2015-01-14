


%% (1 )
% if exist('inria_objfv', 'var')
%     clear('inria_objfv');
% end

% break;

% inria_objfv.V = zeros(length(inria_objf), 4096);
% 
% for i = 1 : length(inria_objf)
%     if mod(i, 300) == 1
%         disp(['i = ', int2str(i),' / 71478 --- ',num2str(100*i/71478),' % ']);
%         disp('extracting text tags...');
%     end
%     
%     inria_objfv.V(i,:) = inria_objf{i}.v;
%     inria_objfv.img_file{i} = inria_objf{i}.img_file;
% %     inria_objfv.tagwords{i} = inria_objf{i}.tagwords;
% end

Vfeat = zeros(length(inria_objf), 1001);

for i = 1 : length(inria_objf)
    if mod(i, 300) == 1
        disp(['i = ', int2str(i),' / 71478 --- ',num2str(100*i/71478),' % ']);
        disp('extracting text tags...');
    end
    
    Vfeat(i,:) = [xx.inria_objf{i}.v , i];
%     inria_objfv.img_file{i} = inria_objf{i}.img_file;
%     inria_objfv.tagwords{i} = inria_objf{i}.tagwords;
end

% save([root_save,'inria_objf-vfeatures.mat'], 'inria_objfv');
%% (2 indices)
% inria_objfi = zeros(length(inria_objf), 2);
% 
% for i = 1 : length(inria_objf)
%     if mod(i, 300) == 1
%         disp(['i = ', int2str(i),' / 71478 --- ',num2str(100*i/71478),' % ']);
%         disp('extracting text tags...');
%     end
%     
%     inria_objfi(i,1) = inria_objf{i}.id_class;
%     inria_objfi(i,2) = inria_objf{i}.id_intra;
% %     inria_objfv.tagwords{i} = inria_objf{i}.tagwords;
% end

%% (3 - add VT ids)
% pv = 4096;
% qt = 1400;
% for i = 1 : length(inria_objf)
%     if mod(i, 300) == 1
%         disp(['i = ', int2str(i),' / 71478 --- ',num2str(100*i/71478),' % ']);
%         disp('extracting text tags...');
%     end
%     Vfeature(i, pv+1 ) = i;
%     Tfeature(i, qt+1 ) = i;
% end



