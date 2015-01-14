function [X,T, W,Ds,D,Z,nss] = CCA_IMT(V_class_features,T_class_features,opt)

% CCA based on final V_class_features and T_class_features cell 1x[N=\sum_k N_k] - [1x dimT]

X = []; T = [];
%figure(1);
for k = 1 : length(V_class_features)%3

feature_v = V_class_features{k}'; 
X = [X;feature_v];

feature_t = T_class_features{k}';
T = [T; feature_t]; %ones(size(V_class_features{k},2), 1)*vec_class{k}'];



% figure(1); hold on; scatter(feature_v(:,20),feature_v(:,3),colors(k));

ns(k) = size(V_class_features{k},2);

end

p = size(X,2);
disp(['image feature space : ',int2str(p),' dimensions']);
q = size(T,2);
disp(['text feature space : ',int2str(q),' dimensions']);

n = size(X,1);
%disp(['total number of images/texts :',int2str(n)]);
%% CCA - Resolution
[Wx, Ds] = CCA2(X, T);
%% Low-dimensional visualization
d = opt.d;%16;
W{1} = Wx(1:p,1:d);
W{2} = Wx(p+1:end,1:d);
D = Ds(1:d,1:d);
%D{2} = Ds(1+p:1+p+d-1, 1+p:1+p+d-1);

Z{1} = X*W{1};%(:, 1:d );
Z{2} = T*W{2};%(:, 1:d );

% cs = opt.cano_vs;%[2 4]; % choice for 2-d visualization
% 
% cano_var{1} = [Z{1}(:,cs(1)),Z{1}(:,cs(2))];
% %cano_var_v2 = Z{1}(:,cs(2));
% 
% cano_var{2} = [Z{2}(:,cs(1) ), Z{2}(:,cs(2) )];
% 
% request1_1 = [Z{2}(1,cs(1)), Z{2}(1,cs(2)) ];
% 
% figure(2); 
ns = [1, ns];
nss = cumsum(ns);
% for k = 1 : 3
%     
% scatter(cano_var{1}(nss(k):nss(k+1)-1,1), ...
%                        cano_var{1}(nss(k):nss(k+1)-1,2) ,colors(k));
% hold on;
% end
% classes = opt.classes;
% legend(classes{1}, classes{2},classes{3});
% %saveas(figure(2), ['PGM-report/figures/',int2str(cs(1)),int2str(cs(2)),'real1.png']);
% 
% figure(3); 
% for k = 1 : 3
% scatter(cano_var{2}(nss(k):nss(k+1)-1,1), ...
%                        cano_var{2}( nss(k):nss(k+1)-1, 2 ) ,colors(k) ); 
% hold on;
% end
% scatter(request1_1(1), request1_1(2), 'y*');
% 
% legend(classes{1}, classes{2},classes{3});
% end
% 
