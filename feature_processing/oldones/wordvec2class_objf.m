function [T_class_features] = wordvec2class_objf(T_class, dictionary,opt)

% dictionary has 3 versions: after, before and ptitle
% when dictionary has only 1 version, just make dict == dictionary
% dict = dictionary{find(ismember(opt.thm, opt.choix)) };
dict = dictionary;
vecdim = opt.dim*opt.maxwords;
% creat tagvectors [200 x opt.maxwords,1]


for i = 1 : length(T_class)
        T_class_features{i} = [];
    for j = 1 : length(T_class{i})
%        tmp_wordvec = zeros(opt.dim * opt.maxwords,1);

        tmp_wordvec = [];%zeros(opt.dim * opt.maxwords,1);

        % to be replaced by : 1-2-window search: 10 jan 2015
        for w = 1 : min(opt.maxwords, length(T_class{i}{j}.tagwords) )
            ind = find( ismember(dict, T_class{i}{j}.tagwords{w}) );
            if ~ isempty(ind)
            %wordbase = word_pos(ind);
            for t = 1 : opt.dim
            tmp_wordvec = [tmp_wordvec; str2num( dict{ind+t} )];
            end
            end
        end
        % end - to be replaced by : 1-2-window search: 10 jan 2015 -
        
        wlen = length(tmp_wordvec);
         dlen = vecdim - wlen;
         tmp_wordvec = [tmp_wordvec; zeros(dlen,1)];

         if length(T_class{i}{j}.tagwords) < 1
             % make tmp_wordvec a random one from previous data
             tmp_wordvec = T_class_features{i}(:, randi(size(T_class_features{i},2)) );
             % or make tmp_wordvec a zeros
         end
         
         T_class_features{i} = [T_class_features{i},tmp_wordvec];
    end

end


