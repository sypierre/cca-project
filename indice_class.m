function [nss, nsst] = indice_class(id_class , inria_objfi, idx_realtrain , idx_test)

% there is an error!!!
for k = 1 : length(id_class)
    
    % id_class(k) does not contain 5, e.g.,
    tmp = find( inria_objfi(:,1) == id_class(k) );
    
    nss{ id_class(k) + 1 } = intersect( tmp , idx_realtrain  );
    nsst{ id_class(k) + 1 } = intersect( tmp, idx_test );
end




