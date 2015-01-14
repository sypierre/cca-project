fid = fopen('./data/webqueries/queries_en_trans.txt');

tline = fgetl(fid);
% inria_PBA.dict{1} = tline;
% break;
semantic{1} = tline(1+2:end);
l = 1;
while ischar(tline)
    l = l + 1;
    if mod(l, 300) == 1
    disp(['in line ',int2str(l)]);
    end
    tline = fgetl(fid);
    cl_id = str2num( tline(1: 1+ fix(log10(l))) );
    semantic{cl_id +1} = tline(3+ fix(log10(l)):end );
end
fclose(fid);
