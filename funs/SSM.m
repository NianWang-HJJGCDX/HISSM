function [Y, obj] = SSM(L, W, Y, max_iter, early_stop)
    max_iter = 500;
    early_stop = true;
    n_cluster = sum(Y)';
    [n,d_Y] = size(Y);
   
    % initialize
    I=sparse(ones(n,d_Y));
    YL = Y' * L;
    yLy = diag(YL * Y);
    YW = Y' * W;
    IW = I' * W;
    yWy = diag(YW * Y);
    W_sum = sum(sum(W));
    yWI = diag(YW * I);
    P = W_sum - 2 * yWI + yWy; 
    p_all = vec2ind(Y'); %clustering label
    obj(1) = sum(yLy ./ yWy ./ P); %每一类的值再求总和
    
    for iter = 1:max_iter
        for i = 1:size(Y, 1)
            m = p_all(i);
            % avoid generating empty cluster
            if n_cluster(m) == 1
                continue;
            end
            
           Lii = L(i, i);
           Wii = W(i, i);
            
            % #1
            yLy_s = yLy + 2.*YL(:,i) + L(i, i);
            yLy_s(m) = yLy(m); 
            % #2
            yWy_s = yWy + 2.*YW(:,i) + W(i, i);
            yWy_s(m) = yWy(m);
            % #3
%             P_s = W_sum - 2 * yWI - 2 * IW(:,i) + yWy + 2.*YW(:,i) + Wii;
            P_s = W_sum - 2 * yWI - 2 * IW(:,i) + yWy + 2.*YW(:,i) + W(i, i);
            P_s(m) = P(m);
            % #4
            yLy_0 = yLy; 
            yLy_0(m) = yLy(m) - 2.* YL(m,i) + L(i, i);
            % #5
            yWy_0 = yWy;
            yWy_0(m) = yWy(m)-2.* YW(m,i) + W(i, i);
            % #6
            P_0 = P;
            P_0(m) = W_sum - 2 * yWI(m) + 2 * IW(m,i) + yWy(m) - 2.*YW(m,i) + W(i, i);
           
            delta = yLy_s ./ yWy_s ./  P_s - yLy_0 ./ yWy_0 ./ P_0;
            [~, r] = min(delta);
            
       
            if r ~= m
                yLy(m) = yLy_0(m);
                yWy(m) = yWy_0(m);
                P(m) = P_0(m);
                yLy(r) = yLy_s(r);
                yWy(r) = yWy_s(r);
                P(r) = P_s(r);
                
                Li = L(i, :);
                Wi = W(i, :);
                YL(r, :) = YL(r, :) + Li;
                YL(m, :) = YL(m, :) - Li;
                YW(r, :) = YW(r, :) + Wi;
                YW(m, :) = YW(m, :) - Wi;

                n_cluster(r) = n_cluster(r) + 1;
                n_cluster(m) = n_cluster(m) - 1;

                Y(i, r) = 1;
                Y(i, m) = 0;
                p_all(i) = r;
            end
        end
        obj(iter + 1) = sum(yLy ./ yWy ./ P);
        if early_stop && iter > 2 && abs((obj(iter + 1) - obj(iter)) / obj(iter)) < 1e-9
            break;
        end
    end
end
