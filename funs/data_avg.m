function A_avg = data_avg(As)
    [n,d] = size(As{1});
    num_views = numel(As);
    aa = As{1};
    A_avg = sparse(n, d);
    for v = 1:num_views
        A_avg = A_avg .+ As{v};
    end
    A_avg = A_avg ./ num_views;
end
