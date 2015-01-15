function [X,T, Wx, W, Ds,D,Z] = CCA_IMTnew(ccaV,ccaT,opt)

% CCA based on final V_class_features and T_class_features cell 1x[N=\sum_k N_k] - [1x dimT]

X = ccaV(:, 1:end-1); T = ccaT(:, 1:end-1);

p = size(X,2);
disp(['image feature space : ',int2str(p),' dimensions']);
q = size(T,2);
disp(['text feature space : ',int2str(q),' dimensions']);

n = size(X,1);
disp(['total number of images/texts :',int2str(n)]);
%% CCA - Resolution
[Wx, Ds] = CCA2(X, T);
%% Low-dimensional visualization
d = opt.d;%16;
W{1} = Wx(1:p,1:d);
W{2} = Wx(p+1:end,1:d);
D = Ds(1:d,1:d);
%D{2} = Ds(1+p:1+p+d-1, 1+p:1+p+d-1);

Z{1} = [X*W{1} , ccaV(:,end) ];%(:, 1:d );
Z{2} = [T*W{2} , ccaT(:,end) ];%(:, 1:d );


% 
