function [X,T, Wx, Wy,LAM, invU, W, Dall,D,Z] = newCCA_IMTnew(ccaV,ccaT,opt)

%% CCA - organization

X = ccaV(:, 1:end-1); T = ccaT(:, 1:end-1);

p = size(X,2);
disp(['image feature space : ',int2str(p),' dimensions']);
q = size(T,2);
disp(['text feature space : ',int2str(q),' dimensions']);

n = size(X,1);
disp(['total number of images/texts :',int2str(n)]);
%% CCA - Resolution

% implements the 2 view CCA that takes 2 views as input

T = full(T);
XX = [X,T];
index = [ones(size(X,2),1);ones(size(T,2),1)*2];
[Wx,Wy,LAM, Wall, Dall] = MultiviewCCAnew(XX, index, 0.0001);

%% discarded CCA2new/ CCA2
% [Wx,Wy,LAM, Wall, Dall] = CCA2new(X, T);
%% Low-dimensional visualization
d = opt.d; %16;
W{1} = Wall(1:p,1:d);
W{2} = Wall(p+1:end,1:d);
D = Dall(1:d,1:d);
%D{2} = Ds(1+p:1+p+d-1, 1+p:1+p+d-1);

Z{1} = [X*W{1} , ccaV(:,end) ];%(:, 1:d );
Z{2} = [T*W{2} , ccaT(:,end) ];%(:, 1:d );

%% get invmu_x and invmu_t
rap = bsxfun(@rdivide, Wx(:,1:d), W{1} );
rap = rap(1,:);
invU{1} = diag(rap);
clear('rap');

rap = bsxfun(@rdivide, Wy(:,1:d), W{2} );
rap = rap(1,:);
invU{2} = diag(rap);


end