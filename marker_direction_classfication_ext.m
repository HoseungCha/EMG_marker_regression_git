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

do_plot = 1;
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));
% path of code, which 
path_code = fileparts(fullfile(cd));
path_DB_process = fullfile(path_code,'DB',name_DB_process);
path_DB_anal = fullfile(path_DB_process,name_DB_analy,'regression','direction');
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
n_xyz = 1;
n_emg_pair = 1;
do_plot=0;
%-------------------------------------------------------------------------%

%----------------------------paramters------------------------------------%

%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%

%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
for i_emg_pair =  1 : n_emg_pair
for i_xyz = 1 : n_xyz
count = 0;
for i_mark = idx_mark_used
count = count + 1;
% for i_mark = 14
% get validation information( idices of cali,train,test)
name_folder = ...
sprintf('mark_%d_xyz_%d_emg_pair_%d_mv_size_%d',...
i_mark,i_xyz,i_emg_pair,mv_size);
output_n_target = cell(n_kfold,1);
for i_kfold = 1 : n_kfold
% path
path = fullfile(path_DB_anal,name_folder,sprintf('dep_kfold_%d',i_kfold));
% load
load(path);
if do_plot
figure;
plot(xtrain{1})
hold on;
plot(ytrain{1});
continue;
end
% training set
xtrain = cell2mat(xtrain);
ytrain = cell2mat(ytrain);

% fit lda
Mdl = fitcdiscr(xtrain,ytrain);

% test
% training set
xtest = cell2mat(xtest);
ytest = cell2mat(ytest);

ypred = predict(Mdl,xtest);

output_n_target{i_kfold} = [ypred,ytest];
% validation
end
if do_plot
    continue;
end
output_n_target = cell2mat(output_n_target);
ouput = output_n_target(:,1);
target = output_n_target(:,2);

output_tmp = full(ind2vec(ouput',3));
target_tmp = full(ind2vec(target',3));

% compute confusion
[~,mat_conf,idx_of_samps_with_ith_target,~] = ...
confusion(target_tmp,output_tmp);

for i_class = 1 : 3
    precision(i_class) = ...
        mat_conf(i_class,i_class)./sum(mat_conf(i_class,:));
    recall(i_class) = ...
        mat_conf(i_class,i_class)./sum(mat_conf(:,i_class));
end

F1 = 2*(precision.*recall)./(precision+recall)
F1(isnan(F1)) = 0;

F1_socre(count,:) = F1; 
figure(i_mark);
h = plotconfusion(target_tmp,output_tmp,strrep(name_folder,'_',' '));


end
end
end