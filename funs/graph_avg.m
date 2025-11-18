function A_avg = graph_avg(As)
    n = size(As{1}, 1);
    num_views = numel(As);

    A_avg = sparse(n, n);
    for v = 1:num_views
        A_avg = A_avg + As{v};
    end
    A_avg = A_avg ./ num_views;
end
