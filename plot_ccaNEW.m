
function plot_ccaNEW(nss,Z, Zw, opt, figf, semantic)

colors = 'brg';

cs = opt.cano_vs;%[1 2], [2 4]; % choice for 2-d visualization
if length(cs) < 3
cano_var{1} = [Z{1}(:,cs(1)), Z{1}(:,cs(2)) ];
cano_var{2} = [Z{2}(:,cs(1)), Z{2}(:,cs(2)) ];
cano_varr{1} = [Zw{1}(:,cs(1)), Zw{1}(:,cs(2)) ];
cano_varr{2} = [Zw{2}(:,cs(1)), Zw{2}(:,cs(2)) ];

else
cano_var{1} = [Z{1}(:,cs(1)), Z{1}(:,cs(2)), Z{1}(:,cs(3)) ];
cano_var{2} = [Z{2}(:,cs(1)), Z{2}(:,cs(2)), Z{2}(:,cs(3)) ];

cano_varr{1} = [Zw{1}(:,cs(1)), Zw{1}(:,cs(2)), Zw{1}(:,cs(3)) ];
cano_varr{2} = [Zw{2}(:,cs(1)), Zw{2}(:,cs(2)), Zw{2}(:,cs(3)) ];

end

observ = opt.observ;%[1 , 20, 180];

for k = 1 : 3 %length(nss)%3 % 3 classes
    
    % <nss(k) : nss(k+1)-1> encodes the indices for each class k
    for s = 1 : length(nss{ observ(k) + 1 })
        ids{k}(s) = find( Z{1}(:,end) == nss{ observ(k) + 1 }(s) );
    end
end

for k = 1 : length(opt.observ)
    classes{k} = semantic{opt.observ(k) + 1};
end

if ishandle(figf)
close(figf);
end
figure(figf); 

subplot(121);
for k = 1 : 3 %length(nss)%3 % 3 classes
    
    if length(cs) < 3
scatter(cano_var{1}( ids{k},1), ...%nss(k):nss(k+1)-1,1), ...
                      cano_var{1}( ids{k},2) , colors(k) );%nss(k):nss(k+1)-1,2) ,colors(k));
    else
        scatter3(cano_var{1}(ids{k}, 1), ...
                cano_var{1}(ids{k}, 2),...
                cano_var{1}(ids{k}, 3) ,colors(k));
    end
hold on;
end

legend(classes{1}, classes{2},classes{3});

subplot(122);
for k = 1 : 3
     if length(cs) < 3
scatter(cano_var{2}( ids{k},1), ...%nss(k):nss(k+1)-1,1), ...
                      cano_var{2}( ids{k},2) , colors(k) );%nss(k):nss(k+1)-1,2) ,colors(k));
    else
        scatter3(cano_var{2}(ids{k}, 1), ...
                cano_var{2}(ids{k}, 2),...
                cano_var{2}(ids{k}, 3) ,colors(k));
    end
hold on;
end

legend(classes{1}, classes{2},classes{3});
saveas(figure(figf), ['PGM-report/figures/',int2str(cs(1)),int2str(cs(2)),'realI2015.png']);

%% Zw
if ishandle(figf+1)
close(figf + 1);
end
figure(figf + 1); 

subplot(121);
for k = 1 : 3 %length(nss)%3 % 3 classes
    
    if length(cs) < 3
scatter(cano_varr{1}( ids{k},1), ...%nss(k):nss(k+1)-1,1), ...
                      cano_varr{1}( ids{k},2) , colors(k) );%nss(k):nss(k+1)-1,2) ,colors(k));
    else
        scatter3(cano_varr{1}(ids{k}, 1), ...
                cano_varr{1}(ids{k}, 2),...
                cano_varr{1}(ids{k}, 3) ,colors(k));
    end
hold on;
end

legend(classes{1}, classes{2},classes{3});

subplot(122);
for k = 1 : 3
     if length(cs) < 3
scatter(cano_varr{2}( ids{k},1), ...%nss(k):nss(k+1)-1,1), ...
                      cano_varr{2}( ids{k},2) , colors(k) );%nss(k):nss(k+1)-1,2) ,colors(k));
    else
        scatter3(cano_varr{2}(ids{k}, 1), ...
                cano_varr{2}(ids{k}, 2),...
                cano_varr{2}(ids{k}, 3) ,colors(k));
    end
hold on;
end

legend(classes{1}, classes{2},classes{3});

saveas(figure( figf+1 ), ['PGM-report/figures/',int2str(cs(1)),int2str(cs(2)),'realT2015.png']);

end

