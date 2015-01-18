function [ pool_sel,occ_idx,pool, unipool, occd, occ ] = ...
    Image2TextsNEW(inria_objf, xx,opt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%pool = inria_objf{xx(1)}.tagwords{1};
n = 1;
for i = 1 : opt.maxpool
    for j = 1 : 3
        for w = 1 : length( inria_objf{xx(i)}.tagwords{j} )
            pool{n} = inria_objf{xx(i) }.tagwords{j}{w};
            n = n + 1;
        end
    end
end

unipool = unique( pool );

count_string = @(x) sum(ismember(pool,x)); % equivalent to the following
% count_string = @(x) length( find(ismember(pool,x)) );

for w = 1 : length(pool)
        if ismember(pool{w},unipool)
        occ(w) = count_string(pool{w});
         if length(pool{w}) < 2 || ismember(pool{w},{'that','her','at','for','with','is','des','en','sur','over','in','by','on','le','la','of','the','and','has','to','du'} )
             occ(w) = -1;
         end
        unipool{find(ismember(unipool,pool{w}))} = 'NaN';
        end
end

[occd, occ_idx] = sort(occ,'descend');
 seuil = occd(opt.nwords_display);
 
% pool_sel = {pool{ find(occ >= seuil) }};
pool_sel = {pool{ occ_idx(1:opt.nwords_display) } };

    %% language filter
    
    
    
    
    
end

