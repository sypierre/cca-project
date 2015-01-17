% demo_relevanceNEW
if exist('relevance','var')
clear('relevance');
end
% relevance = load('./data/webqueries/labels_orig.txt');
relevance = zeros( length(inria_objf),3);
fid = fopen('./data/webqueries/labels.txt');

tline = fgetl(fid);
relevance(1,:) = str2num(tline);
% % % break;
l = 1;
while ischar(tline)
    l = l + 1;
    if mod(l, 300) == 1
    disp(['in line ',int2str(l)]);
    end
    tline = fgetl(fid);
    if ischar(tline)
    tmpl = str2num(tline);
     absl = intersect( find(inria_objfi(:,1)==tmpl(1)), find(inria_objfi(:,2)==tmpl(2)) );
     if length(absl) > 1
         disp('problem...');
     end
    relevance(absl,:) = tmpl;
    end
end


fclose(fid);
