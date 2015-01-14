function text = string2words(input)
% convert a long string input into cells of words:

sp_inds = find(ismember(input,' '));
nb_sp = length(sp_inds);
sp_inds = [0, sp_inds,length(input)+1];

for i = 1 : nb_sp+1
    text{i} = input( sp_inds(i)+1: sp_inds(i+1)-1 );
end
end





