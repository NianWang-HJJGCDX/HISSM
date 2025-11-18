
%%
clc;  close all; clear all;

%% setting
runtimes = 1; % running times on each dataset, default: 1
dataname = {'MSRCV1','3Sources','HW2sources','BBC','yaleA','COIL20','ORL','Hdigit'};
choice_Y_ini =5; % [initialization for Y] (1: 'random initialization', 2: 'kmeans', 3: 'Ncut', 4: 'Rcut' and 5: 'FINCH')
[userview,systemview] = memory;
numdata = length(dataname);
currentFolder = pwd;
addpath(genpath(currentFolder));

%% buidling the path for results record
result_y_dir = 'Results_y/'; % log the results after step 2
if(~exist('Results_y','file'))
    mkdir('Results_y');
    addpath(genpath('Results_y/'));
end
result_y_ini_dir = 'Results_y_ini/';  % log the results after step 1
if(~exist('Results_y_ini','file'))
    mkdir('Results_y_ini');
    addpath(genpath('Result_y_ini/'));
end
result_y_compare_dir = 'Results_y_compare/';  % show the differences  between y and y_ini (for all testing data sets)
if(~exist('Results_y_compare','file'))
    mkdir('Results_y_compare');
    addpath(genpath('Result_y_compare/'));
end
result_time_dir = 'Results_time/';  % log the time cost
if(~exist('Results_time','file'))
    mkdir('Results_time');
    addpath(genpath('Results_time/'));
end

%% read dataset
for cdata = 1:numdata
disp(char(dataname(cdata)));
datadir = 'Dataset/';
dataf = [datadir, cell2mat(dataname(cdata))];
load(dataf);
X = data;
X = normalization(X); % [necessary] for data normalization
y0 = truelabel{1}; % true label
c = length(unique(y0)); % label number
m = length(X); % view number
for v = 1:m
    As{v} = constructW_PKN(X{v}', 10);  % initialize graphs by adaptive neighbor
end
%% iter ...
for rtimes = 1:runtimes
time = 0;
tic;
[y,y_ini, obj, coeff,coeff_sum,iter] = HISSM(X,As,c,choice_Y_ini); 
flag = ceil(coeff_sum); 
if flag ~= 1 % to verify the correctness of weight updation. (the sum of weights (coeff_sum) should be 1)
    disp ("the weights for graphs are updated by an error way")
end;
time = time + toc;
toc;
% calculate and print results
metric_y_ini =ClusteringMeasure_new(y0, y_ini); 
metric_y =ClusteringMeasure_new(y0, y);
ACC_y(rtimes) = metric_y(1); ACC_y_ini(rtimes) = metric_y_ini(1);
NMI_y(rtimes) = metric_y(2); NMI_y_ini(rtimes) = metric_y_ini(2);
Pu_y(rtimes)  = metric_y(3); Pu_y_ini(rtimes)  = metric_y_ini(3);
Fscore_y(rtimes) = metric_y(4); Fscore_y_ini(rtimes) = metric_y_ini(4);
Precision_y(rtimes) = metric_y(5); Precision_y_ini(rtimes) = metric_y_ini(5);
Recall_y(rtimes) = metric_y(6); Recall_y_ini(rtimes) = metric_y_ini(6);
ARI_y(rtimes) = metric_y(7); ARI_y_ini(rtimes) = metric_y_ini(7);
Time_cost(rtimes)=time;
fprintf('=====In runtime %d=====\n ACC:%.4f\t NMI:%.4f\t Pu:%.4f\t Fscore:%.4f\t Precision:%.4f\t Recall:%.4f\t ARI:%.4f Time_cost:%.4f\n',rtimes,metric_y(1),metric_y(2),metric_y(3),metric_y(4),metric_y(5),metric_y(6),metric_y(7),time);
end;
%% record results
% record metrics for y and y_ini
Result_y(1,:) = ACC_y; Result_y_ini(1,:) = ACC_y_ini;
Result_y(2,:) = NMI_y; Result_y_ini(2,:) = NMI_y_ini;
Result_y(3,:) = Pu_y; Result_y_ini(3,:) = Pu_y_ini;
Result_y(4,:) = Fscore_y; Result_y_ini(4,:) = Fscore_y_ini;
Result_y(5,:) = Precision_y;  Result_y_ini(5,:) = Precision_y_ini;
Result_y(6,:) = Recall_y; Result_y_ini(6,:) = Recall_y_ini;
Result_y(7,:) = ARI_y; Result_y_ini(7,:) = ARI_y_ini;
% record average value for matrics (only work by setting [runtimes]>=2)
Result_y(8,1) = mean(ACC_y);  Result_y_ini(8,1) = mean(ACC_y_ini);
Result_y(8,2) = mean(NMI_y); Result_y_ini(8,2) = mean(NMI_y_ini);
Result_y(8,3) = mean(Pu_y); Result_y_ini(8,3) = mean(Pu_y_ini);
Result_y(8,4) = mean(Fscore_y); Result_y_ini(8,4) = mean(Fscore_y_ini);
Result_y(8,5) = mean(Precision_y); Result_y_ini(8,5) = mean(Precision_y_ini);
Result_y(8,6) = mean(Recall_y); Result_y_ini(8,6) = mean(Recall_y_ini);
Result_y(8,7) = mean(ARI_y); Result_y_ini(8,7) = mean(ARI_y_ini);
% record standard deviation for matrics (only work by setting [runtimes]>=2)
Result_y(9,1) = std(ACC_y); Result_y_ini(9,1) = std(ACC_y_ini);
Result_y(9,2) = std(NMI_y); Result_y_ini(9,2) = std(NMI_y_ini);
Result_y(9,3) = std(Pu_y); Result_y_ini(9,3) = std(Pu_y_ini);
Result_y(9,4) = std(Fscore_y); Result_y_ini(9,4) = std(Fscore_y_ini);
Result_y(9,5) = std(Precision_y);  Result_y_ini(9,5) = std(Precision_y_ini);
Result_y(9,6) = std(Recall_y);    Result_y_ini(9,6) = std(Recall_y_ini);
Result_y(9,7) = std(ARI_y);  Result_y_ini(9,7) = std(ARI_y_ini);
% record average value of all data set in one '.mat' document to better show the differences between y_ini and y
result_y_compare(1,2*cdata-1) = mean(ACC_y_ini); result_y_compare(1,2*cdata) = mean(ACC_y); 
result_y_compare(2,2*cdata-1) = mean(NMI_y_ini); result_y_compare(2,2*cdata) = mean(NMI_y); 
result_y_compare(3,2*cdata-1) = mean(Pu_y_ini); result_y_compare(3,2*cdata) = mean(Pu_y); 
result_y_compare(4,2*cdata-1) = mean(Fscore_y_ini); result_y_compare(4,2*cdata) = mean(Fscore_y); 
result_y_compare(5,2*cdata-1) = mean(Precision_y_ini);  result_y_compare(5,2*cdata) = mean(Precision_y);  
result_y_compare(6,2*cdata-1) = mean(Recall_y_ini); result_y_compare(6,2*cdata) = mean(Recall_y); 
result_y_compare(7,2*cdata-1) = mean(ARI_y_ini); result_y_compare(7,2*cdata) = mean(ARI_y); 
% record time cost
Result_time(1,:) = Time_cost;
Result_time(2,1) = mean(Time_cost);
Result_time(2,2) = std(Time_cost);

%% save results
save([result_y_dir,char(dataname(cdata)),'_result_y.mat'],'Result_y','obj');
save([result_y_ini_dir,char(dataname(cdata)),'_result_y_ini.mat'],'Result_y_ini');
save([result_y_compare_dir,'all_result_y_compare.mat'],'result_y_compare');
save([result_time_dir,char(dataname(cdata)),'_result_time.mat'],'Result_time');
clear ACC_y NMI_y Pu_y Fscore_y Precision_y Recall_y ARI_y metric_y Result_y ACC_y_ini NMI_y_ini Pu_y_ini Fscore_y_ini Precision_y_ini Recall_y_ini ARI_y_ini metric_y_ini Result_y_ini Result_time As;
% imshow(A0,[]); colormap jet; colorbar;

end;
