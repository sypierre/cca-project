




tmpp = textread(['./data/webqueries/queries_en_trans.txt'],'%s');


for cc = 1 : length(cls)
    
    clinds(cc) = find( strcmp( tmpp, num2str(cls(cc) ) ) );
end

for cc = 1 : length(cls) -1
    ih = clinds(cc);
    it = clinds(cc+1);
    tmpp{ih+1} = tmpp{ ih+1}(2:end);
    tmpp{it-1} = tmpp{ it-1 }(1:end-1);
    
    textSEM{cls(cc)+1} = {tmpp{ih+1:it-1}};

end

ih = clinds(length(cls));
tmpp{ih+1} = tmpp{ ih+1}(2:end);
tmpp{end} = tmpp{end}(1:end-1);

    textSEM{cls(end)+1} = {tmpp{ih+1:end}};





