function textvec = text2vec(text, dictionary, opt)
% extract individual image vector from test set:
vecdim = opt.tdim*opt.maxkwords;

tmp_wordvec = [];%zeros(opt.dim * opt.maxwords,1);

for w = 1 : min(opt.maxkwords, length(text) )
    dict = dictionary{1};
    thm = 1;
    while ~ ismember(text{w},dictionary{thm})
        
        if thm > length(dictionary)-1
            disp('the request contains unknown word(s)...');
            %tmp_wordvec = [tmp_wordvec ; zeros(opt.tdim,1)];
            break;
        end
        thm = thm + 1;
        dict = dictionary{min(thm,length(dictionary) ) };
    end
    
    ind = find( ismember(dict, text{w}) );
    if ~ isempty(ind)
        for t = 1 : opt.tdim
            tmp_wordvec = [tmp_wordvec; str2num( dict{ind+t} )];
        end
    end
end
wlen = length(tmp_wordvec);
dlen = vecdim - wlen;
tmp_wordvec = [tmp_wordvec; zeros(dlen,1)];
% 
% 
% if length(T_class{i}{j}.tagwords) < 1
%     % make tmp_wordvec a random one from previous data
%     tmp_wordvec = T_class_features{i}(:, randi(size(T_class_features{i},2)) );
%     % or make tmp_wordvec a zeros
% end

textvec = tmp_wordvec;

end