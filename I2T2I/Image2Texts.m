function [pool_sel,indx,occd,occ, pool,inds,sims] = Image2Texts(x, T , W, D,simI2T,T_class,opt)

% T_class is text feature in training data
% opt.Nss = 1, bound1, bound2,...
sims = simI2T(x,T,W,D);
% discard 'NaN':
ninds = find( isnan(sims) );
sims(ninds) = - Inf(1,length(ninds));
[~, inds] = sort(sims,'descend');

ind_pool = inds(1:opt.maxpool);

%pooltexts = [];
%count_string = cellfun(@(x) sum(ismember(e,x)), d);
l = 1;
for t = 1 : opt.maxpool
    %class id:
    i = 1;
    % find starting i/ find class position
    while opt.Nss(i) <= ind_pool(t)
        i = i + 1;
    end
    % inds(t) belongs to class i-1 / j is <~.intra> number
    j = ind_pool(t) - opt.Nss(i-1) + 1;
    for w = 1 : length(T_class{i-1}{j}.tagwords)
        pool{l} = T_class{i-1}{j}.tagwords{w};
        l = l + 1;
    end
end

% get occurrences from pool:
count_string = @(x) sum(ismember(pool,x));
% %tmppool = pool;
% %pool_sel = [];
% occ = zeros(1,length(pool));
% occ(1) = count_string(pool{1});
tmppool = unique(pool);

for w = 1 : length(pool)
        if ismember(pool{w},tmppool)
        occ(w) = count_string(pool{w});
         if length(pool{w}) < 2
             occ(w) = -1;
         end
        tmppool{find(ismember(tmppool,pool{w}))} = 'NaN';
        end
end

[occd,indx] = sort(occ,'descend');
 seuil = occd(opt.nwords_display);
pool_sel = {pool{ find(occ>=seuil) }};













