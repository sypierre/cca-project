function [Wx,Wy,LAM, Wall, D] = CCA2new(X, T)


% implements the 2 view CCA that takes 2 views as input

T = full(T);
XX = [X,T];
index = [ones(size(X,2),1);ones(size(T,2),1)*2];

    
[Wx,Wy,LAM, Wall, D] = MultiviewCCAnew(XX, index, 0.0001);

% Wx = V;































