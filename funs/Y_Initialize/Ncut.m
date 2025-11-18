function y = NCut(ave_As,c)

n = size(ave_As,1);
D = diag(sum(ave_As)); %度矩阵

% fprintf('Normalized Cut\n');
Dd = diag(D);
Dn = spdiags(sqrt(1./Dd),0,n,n);
An = Dn*ave_As*Dn;
An = (An+An')/2;
[Fng, D] = eig1(full(An), c, 1, 1);
y = ind2vec(kmeans(Fng,c)')';




