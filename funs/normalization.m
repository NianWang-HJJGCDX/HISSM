function X_out = normalization(X)
  
m = length(X);
num = size(X{1},2);
for i = 1:m
    for  j = 1:num
        normItem = std(X{i}(:,j));
        if (0 == normItem)
            normItem = eps;
        end;
        X_out{i}(:,j) = (X{i}(:,j)-mean(X{i}(:,j)))/(normItem);
    end;
end
