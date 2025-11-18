function obj = calc_view_objs1(Ls, Y, Ws)
    m = length(Ls);
    [n,d_Y] = size(Y);
    Y=full(Y);
    I=ones(n,d_Y);
    for v = 1:m
        L = Ls{v};
        W = Ws{v};
        YL = full(Y' * L);
        yLy = full(diag(YL * Y));
        YW = full(Y' * W);
        yWy = full(diag(YW * Y));
        yWy(yWy==0)=eps;
        W_sum = full(sum(sum(W)));
        yWI = full(diag(YW * I));
        P = W_sum - 2 * yWI + yWy;
        P(P==0)=eps;
        obj(v) = sum(yLy ./ yWy ./ P);
    end

