function A = weighted_sum(As, coeff)
    n = size(As{1}, 1);
    num_views = numel(As);
    A = sparse(n, n);
    for v = 1:num_views
        A = A + coeff(v) * As{v};
    end
end
