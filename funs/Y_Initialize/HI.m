function y_init = HI(A0, c)
    % HI initialization， which is heavily based on FINCH
    [esti_y, esti_num_clust] = FINCH(A0, [], 0);
    idx = find(esti_num_clust == c, 1);
    if ~isempty(idx)
        y_init = esti_y(:, idx);
    elseif any(esti_num_clust > c)
        refine_starter = find(esti_num_clust > c, 1, 'last');
        y_init = req_numclust(esti_y(:, refine_starter), A0,c);
    else
        error('FINCH failed to find cluster');
    end
    y_init = ind2vec(y_init')';
end

function [c, num_clust]= FINCH(mat,initial_rank, verbose)
% Input
% data: feature Matrix (feature vecotrs in rows)
% initial_rank [Optional]: Nx1  1-neighbour indices vector ... pass empty [] to compute the 1st neighbor via pdist or flann
% verbos : 1 for printing some output
%
% Output
% c: N x P matrix  Each coloumn vector contains cluster labels for each partion P
% num:clust: shows total number of cluster in each partion P
%
% The code implements the FINCH algorithm described in our CVPR 2019 paper
% M. Saquib Sarfraz, Vivek Sharma and Ranier Stiefelhagen,"Efficient Parameter-free Clustering Using First Neighbor Relations", CVPR 2019.
% https://arxiv.org/abs/1902.11266
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% For academic purpose only. The code or its re-implemntation should not be used for commercial use.
% Please contact the author below for licensing information.
% Copyright
% M. Saquib Sarfraz (saquib.sarfraz@kit.edu)
% Karlsruhe Institute of Technology (KIT)



%% Initialize FINCH clustering
   min_sim=inf;

   [Affinity_,  orig_sim, ~]= clustRank(mat,initial_rank); % get first neighbor， Affinity_：all first neigbors

   initial_rank=[];

  [Group_] = get_clust(Affinity_, [],inf); % calculate connected components, Group_:

  [c,num_clust, mat]=graph_merge([],Group_,mat);

  if verbose==1
  fprintf('Partition 1 : %d clusters\n',num_clust)
  end

    exit_clust=inf;
    c_=c;
k=2;
while exit_clust>1

    [Affinity_,  orig_sim,~]= clustRank(mat,initial_rank);

    [u] = get_clust(Affinity_, double(orig_sim),min_sim); 
    [c_,num_clust_curr, mat]=graph_merge(c_, u, mat);  

    num_clust =[num_clust, num_clust_curr];
    c = [c, c_];

  % exit if cluster is 1
   exit_clust=num_clust(end-1)-num_clust_curr;
     %
     if num_clust_curr==1 || exit_clust<1
         num_clust=num_clust(1:end-1);
         c=c(:,1:end-1);
         exit_clust=0;
        break
     end
    if verbose==1

      fprintf('Partition %d : %d clusters\n',k,num_clust(k))
    end
    k=k+1;

end

end

function [M]=coolMean(M,u)
% faster way of computing feature vector mean in an array
% copyright M. Saquib Sarfraz (KIT), 2019

 u_ =ind2vec(u'); nf=sum(u_,2);
 [~,idx]=sort(u);
 M=M(idx,:);
 
M=cumsum([zeros(1, size(M,2),'single'); M]); 

cnf=cumsum(nf);
nf1=[1;cnf+1];nf1=nf1(1:end-1);
s=[nf1,cnf];


M= M(s(:,2)+1,:)- M(s(:,1),:);
M= M./full(nf);
end

function [A, orig_sim,min_sim]= clustRank(orig_sim, initial_rank)
% Implements the clustering eqaution
% copyright M. Saquib Sarfraz (KIT), 2019

s=size(orig_sim,1);  % to handle direct input of initial_rank and avoid computing pdist.. if computing 1-neigbours indices via flann

if ~isempty(initial_rank)
        orig_sim=[]; min_sim=inf;
else
 orig_sim(logical(speye(size(orig_sim))))=0; % 将对角线清零，note:speye(n,m) 返回一个主对角线元素为 1 且其他位置元素为 0 的 n×m 稀疏矩阵。
 [d,initial_rank]=max(orig_sim,[],2); % d: 每行最相似的值 initial_rank: 最相似值的索引
 min_sim=min(d);% d的最小值
end


%%% Implementation of The clustering Equation %%

%%% Note only needs integer indices of first neigbours to directly deliver the adj matrix which has
%%% the clusters.
  
  A=sparse([1:s],initial_rank,1,s,s); % S = sparse(m,n) 生成 m×n 全零稀疏矩阵。
% S = sparse(i,j,v) 根据 i、j 和 v 三元组生成稀疏矩阵 S，以便 S(i(k),j(k)) = v(k)。max(i)×max(j) 输出矩阵为 length(v) 个非零值元素分配了空间。
%如果输入 i、j 和 v 为向量或矩阵，则它们必须具有相同数量的元素。参数 v 和/或 i 或 j 其中一个参数可以使标量。
  
  A= A + sparse([1:s],[1:s],1,s,s); % 加上对角线全1的矩阵
  A= (A*A');
  A(logical(speye(size(A))))=0; % remove diagonal entries
  A=spones(A); % change non-zero entries to 1
%%%

end
function req_c= req_numclust(c, data,req_clust)
%% Algo 2 procedure to refine a partion for required number of clusters
% part of FINCH code
% copyright M. Saquib Sarfraz (KIT), 2019
%
%Input:
% c: partition to refine ..  one of the partions returned form FINCH
% Example: 
% Suppose FINCH returns partitions with clusters:
% num_clust=[2061,177,37,10,2] and we want 15 clusters
% We should then pass the closest larger partion to 15 i.e. 3rd partition with 37 cluster in this example.
% c should be then c(:,3) to refine the 3rd FINCH partion from FINCH returne c mat
% we will run : req_c= req_numclust(c(:,3), data, 15)
%
% data: data mat as used in FINCH (N x d) feature vecotrs in rows
% req_clust: required number of clusters
% Output:
% req_c : required number of clusters: 1xN vector of  cluster labels


       iter=length(unique(c))- req_clust;

       [c_,~, mat]=graph_merge([],c',data); 
    for i=1:iter

    [Affinity_,  orig_sim]= clustRank(mat,[]);
    
    Affinity_= top_affinity(Affinity_, orig_sim); %update affinity only keeping one merge at a time
    
    [u] = get_clust(Affinity_, [],inf);
    
    
   [c_,~, mat]=graph_merge(c_,u,mat);    
    
  
    end
    
    %req_clust_final =length(unique(c_));
    req_c = c_;
end

  function Affinity_= top_affinity(Affinity_, orig_sim)
    
        Affinity_(logical(speye(size(Affinity_))))=0;
       
        in_=find(Affinity_>0);
        [~,v]=sort(orig_sim(in_), 'descend'); idx=in_(v(1)); 
        Affinity_= zeros(size(Affinity_),'logical');
        Affinity_(idx)=1;
        Affinity_ = Affinity_' + Affinity_;
             
  end    
    
function [u]= get_clust(A, orig_dist,min_sim)
% get the conected components of affinity matrix
 if min_sim~=inf
 ind=find((orig_dist.*A)> min_sim) ;
 A(ind)=0; 
 end
 G_d=digraph(A, 'OmitSelfLoops'); % create direct graph and omit diagonal entries
 u = (conncomp(G_d,'Type','weak')); % search weak connected components
end

 function [c,num_clust, mat]=graph_merge(c,u,data)
  %% core procedure for mergeing in aLgorthm 1
    u_ =ind2vec(u); num_clust=size(u_,1);

    if ~isempty(c)
     c=getC(c,u');
     else
        c=u';
    end
    u_ = full(u_);
    mat = u_ * data * u_';
    cnt = trace(diag(diag(mat)));
    mat = mat - diag(diag(mat));
    cnt_mul = sum(u_, 2); % the sum of data points for each connected component
    cnt_mul = cnt_mul * cnt_mul';
    mat = mat ./ cnt_mul;
  
    function G=getC(G,u)
    [~,~,ig]=unique(G); % [C, ia, ic] = unique(A); C = A(ia) and A = C(ic)
    G=u(ig);
    end
  end
