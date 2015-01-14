% see bad image classes:

% class_bad = [inria_lobj{idx_bad(1)}.id_class];
% for k = 2 : length(idx_bad)
%     
%     tmp = inria_lobj{idx_bad(k)}.id_class;
%     
%     if tmp ~= class_bad(end)
%    class_bad =[class_bad, inria_lobj{idx_bad(k)}.id_class];
%     end
% end

for k = 1 : length(idx_bad)
    
   class_bads(k) = inria_lobj{idx_bad(k)}.id_class;
end

n = length(unique(class_bads));
hist(class_bads,n);