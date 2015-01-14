function [ pool,inds,ind_pool,sims] = Texts2Image(X, tt_request,dict, W, D,simT2I,opt)

% (0) convert tt
tvec = text2vec(tt_request, dict,opt); % vertical vector
% T_class is text feature in training data
% V_class is the image feature in training data
 namelist = load('4class_vfeaturess.mat');
v_class = namelist.v_features;
l = 0;
for cl = 1 : length(v_class)
    for j = 1 : length(v_class{cl})
        l = l + 1;
    v_class_names{l} = v_class{cl}{j}.name;
    end
end

% opt.Nss = 1, bound1, bound2,...
sims = simT2I(X,tvec',W,D);
% discard 'NaN':
ninds = find( isnan(sims) );
if ~ isempty(ninds)
sims(ninds) = - Inf(1,length(ninds));
end
[~, inds] = sort(sims,'descend');

ind_pool = inds(1:opt.tmaxpool);

%pooltexts = [];
%count_string = cellfun(@(x) sum(ismember(e,x)), d);
l = 1;
for t = 1 : opt.tmaxpool
    pool{t} = v_class_names{ind_pool(t)};
end
end

% get occurrences from pool:
% count_string = @(x) sum(ismember(pool,x));
% % %tmppool = pool;
% % %pool_sel = [];
% % occ = zeros(1,length(pool));
% % occ(1) = count_string(pool{1});
% tmppool = unique(pool);
% 
% for w = 1 : length(pool)
%         if ismember(pool{w},tmppool)
%         occ(w) = count_string(pool{w});
%          if length(pool{w}) < 2
%              occ(w) = -1;
%          end
%         tmppool{find(ismember(tmppool,pool{w}))} = 'NaN';
%         end
% end
% 
% [occd,indx] = sort(occ,'descend');
%  seuil = occd(opt.occ);
% pool_sel = {pool{ find(occ>=seuil) }};
% 
% 
% 










