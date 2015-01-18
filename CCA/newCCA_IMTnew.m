function [X,T,SS, Wx, Wy,LAM, Wall,Dall] = newCCA_IMTnew(ccaV,ccaT, ccaS,  opt)

%% CCA - organization

X = ccaV(:, 1:end-1); T = ccaT(:, 1:end-1);

SS = ccaS(:,1:end-1);

p = size(X,2);
disp(['image feature space : ',int2str(p),' dimensions']);
q = size(T,2);
disp(['text feature space : ',int2str(q),' dimensions']);
qq = size(SS,2);

n = size(X,1);
disp(['total number of images/texts :',int2str(n)]);
%% CCA - Resolution

% implements the 2 view CCA that takes 2 views as input

% T = full(T);
if opt.view3
XX = [X,T,SS];
index = [ones(p,1);ones(q,1)*2; ones(qq,1)*3 ];
else
    XX = [X,T];
    index = [ones(p,1);ones(q,1)*2 ];
end
[Wx,Wy,LAM, Wall, Dall] = MultiviewCCAnew(XX, index, 0.0001);

%% discarded CCA2new/ CCA2
% [Wx,Wy,LAM, Wall, Dall] = CCA2new(X, T);
%% Low-dimensional visualization

end