function [X,T, Wx, Wy,LAM, Wall,Dall] = newCCA_IMTnew(ccaV,ccaT,  opt)

%% CCA - organization

X = ccaV(:, 1:end-1); T = ccaT(:, 1:end-1);
%SEM = ccaS(:,1:end-1);

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

end