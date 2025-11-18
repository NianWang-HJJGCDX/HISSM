function [y_pred,  y_init,W, coeff,coeff_sum,iter] = My(X,As, num_clusters,choice_Y_ini)
    max_iter = 10;
    n = length(As{1});
    %% [Step 1] choose the method to obtain the initial clustering label Y_init
    % finchpp is suggested since it stably produces better results by first neighbor
    if 1 == choice_Y_ini
            Y_init = random_Y(n,num_clusters);
        elseif 2 == choice_Y_ini
            Y_init = ind2vec(kmeans(X{1}', num_clusters)')'; 
        elseif 3 == choice_Y_ini
            Y_init = Ncut(graph_avg(As), num_clusters);
        elseif 4 == choice_Y_ini
            Y_init = Rcut(graph_avg(As), num_clusters);
        elseif 5 == choice_Y_ini
            Y_init = HI(graph_avg(As), num_clusters); 
        else
            error('Invalid input: choice_Y_ini');
    end
    Y = Y_init;
    y_init = vec2ind(Y_init')'; 
    Ls = calc_laps(As);
    m = length(Ls);
    for v = 1:m
        coeff(v) = m; % Initial weights. Ensure the sum of 1./coeff as 1
    end;
   %% [Step 2] improve Y_init by supercluster strategy, and the refined clustering label y_pred is finally obtained.
   % iter...
    for iter = 1:max_iter
        % update Y 
        L = weighted_sum(Ls, coeff);
        W = weighted_sum(As, coeff);
        [Y, ~]= SSM(L, W, Y);
        % update weight 
        view_objs = calc_view_objs(Ls, Y , As);
        coeff = sum(sqrt(view_objs)) ./ sqrt( view_objs);
        coeff_verify = 1./coeff;
        coeff_sum  = sum(coeff_verify); % sum to 1
        obj(iter) = sum(view_objs);
%         early exit if Y can not be updated 
         if iter > 2&& abs((obj(iter) - obj(iter - 1)) / obj(iter - 1)) < 1e-9
            break;
         end
    end
    obj=obj';
    y_pred = vec2ind(Y')';  

