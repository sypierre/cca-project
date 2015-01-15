function [Wx,Wy,LAM,Wall, D] = MultiviewCCAnew(X, index, reg)


% implements the multiview CCA method from F. Bach and M. I. Jordan.
% written by Yunchao Gong
% Y. Gong, Q. Ke, M. Isard, S. Lazebnik.  A Multi-View Embedding Space for Internet Images, Tags, and Their Semantics.
% Microsoft Research Technical Report (MSR-TR-2012-125). Under review: International Journal of Computer Vision


% X is the n*(d1+d2+...+dk) feature matrix
% X = [X1,X2,X3,...,Xk]
% index is the index of different feature views [1,1,1,2,2,2,2,3,3,3,3...]
% This implementation corresponds to average kernel K = K1 + K2 + ... + K_k
% output P is the projected data scaled by eigenvalue
% set power to be 2,3,or 4
% P = X*W*eigenvale = [X1,X2,...,X_k]*V*D;
% if want projection for independent feature, simply do P(:,index_of_feature)


% some covariance matrixes
disp('calculating covariance matrix ...');
C_all = cov(X);
C_diag = zeros(size(C_all));
p = sum(index == 1) ;


for i = 1 : max(index) % max is 2 /  % index = [1:1x1000, 2:1x1400]
    index_f = find(index == i);
    % also add regularization here
    C_diag(index_f,index_f) = C_all(index_f,index_f) + reg*eye(length(index_f),length(index_f));
    C_all(index_f,index_f) = C_all(index_f,index_f) + reg*eye(length(index_f),length(index_f));
    
end
Cxx = C_diag(1:p,1:p);
Cyy = C_diag(p+1:end, p+1:end);
Cxy = C_all(1:p, p+1:end);
Cyx = C_all(p+1:end, 1:p);
disp('Solving the eigenvalue problem...');

%% solve generalized eigenvalue problem
% solve Cxy Cyy^-1 Cyx wx = \lambda^2 Cxx wx
% wy = Cyy^-1 Cyx wx / lambda
disp('---solving eig x ...');
tic;
Cyyyx = inv( Cyy )* Cyx;

[Wx , lam2] = eig( double(Cxy*Cyyyx), double(Cxx) );
% % invlam = inv( sqrt(lam2)  );
% % Wy = Cyyyx*(invlam * Wx);

[ll, inds] = sort(diag(lam2),'descend');
lam2 = diag(ll); % lam2 reordered ! 
Wx = Wx(:,inds);
% % Wy = Wy(:,inds);

LAM = sqrt(lam2);
% invlam = inv(LAM);
% Wy = Cyyyx*(invlam*Wx);

disp('---solving eig y ...');
tic;
Cyyyx = inv( Cxx )* Cxy;

[Wy , lam2y] = eig( double(Cyx*Cyyyx), double(Cyy) );

[ll, inds] = sort(diag(lam2y),'descend');
lam2y = diag(ll); % lam2 reordered ! 
Wy = Wy(:,inds);

LAMy = sqrt(lam2y);
dd = min(size(LAMy,1), size(LAM,1));
verif = diag(LAM(1:dd,1:dd)) - diag(LAMy(1:dd,1:dd));
verif = sum(verif);
disp(['verfication of x compactible y: ', num2str(verif)]);

toc;


% OLD RESOLUTION 
disp('---solving eig old ...');
tic;
[Wall,D] = eig(double(C_all),double(C_diag));
toc;

disp('done eigen decomposition');

[a, index] = sort(diag(D),'descend');
D = diag(a);
Wall = Wall(:,index);




end

