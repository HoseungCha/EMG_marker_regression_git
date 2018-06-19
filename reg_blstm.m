%--------------------------------------------------------------------------
% explanation of this code
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clear;clc;close all

%------------------------code analysis parameter--------------------------%
% name of raw DB
name_DB_raw = 'DB_raw2';

% name of process DB to analyze in this code
name_DB_process = 'DB_processed2';

% name of anlaysis DB in the process DB
name_DB_analy = 'DB_raw2_marker_wsize_24_winc_12_emg_wsize_408_winc_204_delay_0';

n_kfold = 5;

mv_size = 5;
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));
% path of code, which 
path_code = fileparts(fullfile(cd));
path_DB_process = fullfile(path_code,'DB',name_DB_process);
path_DB_anal = fullfile(path_DB_process,name_DB_analy,'regression',...
    'DB');
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% get toolbox
addpath(genpath(fullfile(path_research,'_toolbox')));

% add functions
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%



%------------------------experiment infromation---------------------------%
% markers to be used
idx_mark_used = [1 3 9 10 11 14 15 16 19 20 21 24 25 26];
name_fe = {'angry','clench','contm_left','contm_right',...
    'frown','fear','happy','kiss','neutral',...
    'sad','surprised'};
n_fe = 11;
n_xyz = 2;
n_emg_pair = 1;
%-------------------------------------------------------------------------%

%----------------------------paramters------------------------------------%

%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%

%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
for i_emg_pair =  1 : n_emg_pair
for i_xyz = 1 : n_xyz
% for i_mark = idx_mark_used
for i_mark = 11
% get validation information( idices of cali,train,test)
name_folder = ...
sprintf('mark_%d_xyz_%d_emg_pair_%d_mv_size_%d',...
i_mark,i_xyz,i_emg_pair,mv_size);
for i_kfold = 1 : n_kfold
% path
path = fullfile(path_DB_anal,name_folder,sprintf('dep_kfold_%d',i_kfold));
% load
load(path);
% training set
xtrain_mm = cell2mat(cellfun(@transpose, xtrain_mm,'UniformOutput',false));
ytrain_mm = cell2mat(cellfun(@transpose, ytrain_mm,'UniformOutput',false));

% fit
if length(xtrain_mm)>length(ytrain_mm)
    ytrain_mm(length(xtrain_mm)+1:end) = [];
else
    xtrain_mm(length(ytrain_mm)+1:end) = [];
end

[B,FitInfo] = lasso(xtrain_mm,ytrain_mm,'Alpha',0.75,'CV',10);
idxLambda1SE = FitInfo.Index1SE;
coef = B(:,idxLambda1SE);
coef0 = FitInfo.Intercept(idxLambda1SE);


% test
xtest_mm = cell2mat(cellfun(@transpose, xtest_mm,'UniformOutput',false));
ytest_mm = cell2mat(cellfun(@transpose, ytest_mm,'UniformOutput',false));

figure;scatter(xtest_mm,ytest_mm)
yhat = xtest_mm*coef + coef0;

figure;
plot(yhat); hold on;
plot(ytest_mm);
plotregression(ytest_mm,yhat,'Regression')


% training set
xtrain = cellfun(@transpose, xtrain,'UniformOutput',false);
ytrain = cellfun(@transpose, ytrain,'UniformOutput',false);

% feature selectoin
% xtrain = cellfun(@(x) x(1,:), xtrain,'UniformOutput',false);

% bilstm newtowrk setting
n_feat_input = size(xtrain{1},1);
nResp = size(ytrain{1},1);
n_hidden_unit = 400;

layers = [ ...
    sequenceInputLayer(n_feat_input)
    bilstmLayer(n_hidden_unit,'OutputMode','sequence')
    fullyConnectedLayer(50)
    dropoutLayer(0.5)
    fullyConnectedLayer(nResp)
    regressionLayer];

maxEpochs = 60;
miniBatchSize = 20;

options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.01, ...
    'GradientThreshold',1, ...
    'Shuffle','never', ...
    'Plots','training-progress',...
    'Verbose',0);

% train
net = trainNetwork(xtrain,ytrain,layers,options);

% test
% test data feature selection
% xtest = cellfun(@(x) x(:,1), xtest,'UniformOutput',false);
xtest = cellfun(@transpose, xtest,'UniformOutput',false);

ypred = predict(net,xtest,'MiniBatchSize',1);


% validation
rmse = NaN(length(ytest),1);
for i = 1 : length(ytest)
    % final ouputs
    output_f = ypred{i}*yhat(i);
    
    % get interest part
    output_f_cell = cell(n_fe,1);
    ytest_cell = cell(n_fe,1);
    for i_fe = 1 : n_fe
        idx2val = ytest_valid{i}(i_fe)-10+1:ytest_valid{i}(i_fe)+30;
        output_f_cell{i_fe} = output_f(idx2val);
        ytest_cell{i_fe} = ytest{i}(idx2val)';
    end
    rmse(i) = mean(sqrt((cat(2,output_f_cell{:})-cat(2,ytest_cell{:})).^2));
end

% sort rmse in the ascending order
[~,idx_sorted] = sort(rmse,'ascend');

for i = 1 : 5
    k = idx_sorted(i);
    figure(i);
    plot(ytest{k}); hold on;
    plot(ypred{k}*yhat(k));
    stem(ytest_valid{k}-10,repmat(max(ytest{k}),[n_fe,1]),'k');
    stem(ytest_valid{k}+30,repmat(max(ytest{k}),[n_fe,1]),'k');
end

end
end
end
end