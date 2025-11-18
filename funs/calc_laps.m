function Ls = calc_laps(As)
    n = size(As{1}, 1);
    Ls = cellfun(@(A) spdiags(sum(A, 2), 0, n, n) - A, As, 'UniformOutput', false);
end
