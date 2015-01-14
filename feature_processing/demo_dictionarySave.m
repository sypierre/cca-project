% dictionary saving:
% addpath('./text_vectors');
disp(' reading dictionary...');
root_textvectors = './text_vectors/'; % dictionary of word2vec vectors

%         dictionary_inriaPBA = textread([root_textvectors,'vectors-inriaPBA_phrase.txt'],'%s');
%         save('dictionary_inriaPBA.mat', 'dictionary_inriaPBA');

if exist('tmp_data', 'var')
    clear('tmp_data');
end
if exist('inriaPBA', 'var')
    disp('clearing old data...');
    clear('inriaPBA');
end

nwords = 22291;
wdim = 200;
idx_w = @(i) 3 + 201*(i-1);
% break;
for i = 1 : nwords
    
    if mod(i,300) == 1
        disp([' i = ',int2str(i),' / 22291 --- ',num2str(100*i/22291),' %']);
    end
    
    idx_hi = idx_w(i);
    inriaPBA.word{i} = dictionary_inriaPBA{ idx_hi };
    tmpi = [];
    for t = 1 : wdim
        tmpi = [tmpi, str2num( dictionary_inriaPBA{idx_hi+t} )];
    end
    inriaPBA.vector{i} = tmpi;
end

save([root_textvectors,'dictionary_inriaPBA.mat'], 'inriaPBA');
% tmp_data = importdata('dict_test.txt',' ');
%
% % inriaPBA = importdata('vectorsn-inriaPBA_phrase.txt', ' ');
% inriaPBA = readtable('vectors-inriaPBA_phrase.txt');

% fid = fopen('dict_test.txt');

% tline = fgetl(fid);
% inria_PBA.dict{1} = tline;
% % break;
% l = 1;
% while ischar(tline)
%     l = l + 1;
%     if mod(l, 300) == 1
%     disp(['in line ',int2str(l)]);
%     end
%     tline = fgetl(fid);
%     inria_PBA{l} = tline;
% end
% A = fread(fid,[3 200],'double');
% fclose(fid);

