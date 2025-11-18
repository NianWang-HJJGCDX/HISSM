function Y = Y_Initialize(n, c)
labels = 1:c;
labels = [labels, randi(c, 1, n - c)];
labels = labels(randperm(n));
Y = ind2vec(labels)';
% Y = full(Y);
end
