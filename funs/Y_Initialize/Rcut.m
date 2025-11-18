function y = RCut(ave_As,c)

n = size(ave_As,1);
D = diag(sum(ave_As)); %度矩阵


% fprintf('Ratio Cut\n');
[Fng, tmpD] = eig1(full(D-ave_As), c, 0, 1); %full将稀疏矩阵转换为满储存，Fg：特征向量； tmpD：特征值
y = ind2vec(kmeans(Fng,c)')';



