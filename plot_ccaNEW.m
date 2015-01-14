
function plot_ccaNEW(nss,Z,opt)

colors = 'brg';

cs = opt.cano_vs;%[1 2], [2 4]; % choice for 2-d visualization
if length(cs) < 3
cano_var{1} = [Z{1}(:,cs(1)), Z{1}(:,cs(2)) ];
cano_var{2} = [Z{2}(:,cs(1)), Z{2}(:,cs(2)) ];
% request1_1 = [Z{2}(1,cs(1)), Z{2}(1,cs(2)) ];


else
cano_var{1} = [Z{1}(:,cs(1)), Z{1}(:,cs(2)), Z{1}(:,cs(3)) ];
cano_var{2} = [Z{2}(:,cs(1)), Z{2}(:,cs(2)), Z{2}(:,cs(3)) ];
% request1_1 = [Z{2}(1,cs(1)), Z{2}(1,cs(2)),Z{2}(1,cs(3)) ];
end    


figure(1); 
% ns = [1, ns];
% nss = cumsum(ns);
observ = opt.observ;%[1 , 20, 180];

for k = 1 : 3 %length(nss)%3 % 3 classes
    
    % <nss(k) : nss(k+1)-1> encodes the indices for each class k
    
    for s = 1 : length(nss{ observ(k) + 1 })
        ids{k}(s) = find( Z{1}(:,end) == nss{ observ(k) + 1 }(s) );
    end
    
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
classes = opt.classes;
legend(classes{1}, classes{2},classes{3});
saveas(figure(1), ['PGM-report/figures/',int2str(cs(1)),int2str(cs(2)),'realI2015.png']);

figure(2); 
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
%scatter(request1_1(1), request1_1(2), 'y*');

legend(classes{1}, classes{2},classes{3});
saveas(figure(2), ['PGM-report/figures/',int2str(cs(1)),int2str(cs(2)),'realT2015.png']);

end

