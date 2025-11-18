function [y,y_init] = Choose_initialization(X,As, num_clusters,choice_Y_ini)
   
    n = length(As{1});
    %% [Step 1] choose the method to obtain the initial clustering label Y_init
    % finchpp is suggested since it stably produces better results by first neighbor
    if 1 == choice_Y_ini
            Y_init = random_Y(n,num_clusters);
        elseif 2 == choice_Y_ini
            Y_init = full(ind2vec(kmeans_ldj(X{1}', num_clusters)')'); 
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
    y = y_init;
   

