function [Ls,An] = nomalized_As(As)
    m = length(As);
    n = size(As{1}, 1);
    for i =1:m
        D{i} = diag(sum(As{i})); %度矩阵
        Dd{i} = diag(D{i});
        Dn{i} = spdiags(sqrt(1./Dd{i}),0,n,n);
        An{i} = Dn{i}*As{i}*Dn{i};
        Ls{i} = Dd{i} - An{i};
    end
end
