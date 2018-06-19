%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m 
% 2: Marker_v_ext_from_windows.m
% 3: EMG_feat_ext_from_windows.m   
% 4: minmax_n_ouliers_ext.m 
% 5: cali_train_text_val_indx_selection.m  %%%%%current code%%%%%%%%%%%%%%
% 6: reg_db_construction.m
% To use this code, you first should have emg_out.mat, mark_out.mat, which
% contains '0' or '1' by
% emg_out{i_sub,i_emg_ch,i_emg_pair}(i_ses,2) number 2 means <Min,Max> and
% mark_out{i_sub,i_emg_ch,i_emg_pair}(i_ses,2) number 2 means <Min,Max>
% if you want to filter out conataminated data, you should also have
% label_inspected(i_sub,i_ses,i_fe,i_mark,i_mark_type)
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clear;clc;close all

%------------------------code analysis parameter--------------------------%
% name of process DB to analyze in this code
name_DB_process = 'DB_processed2';

% name of anlaysis DB in the process DB
name_DB_analy = 'DB_raw2_marker_wsize_24_winc_12_emg_wsize_408_winc_204_delay_0';

% Name to load
name4save = 'regression';

% decide what numberth of calibration session is going to be used 
numberth_cali_session = 1;

% decide k fold croess validation
kfold = 5;
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));
% path of code, which 
path_code = fileparts(fullfile(cd));
path_DB_process = fullfile(path_code,'DB',name_DB_process);
path_DB_save = fullfile(path_DB_process,name_DB_analy,name4save);
path_DB_inspect = fullfile(path_DB_process,name_DB_analy,'inspection');
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% get toolbox
addpath(genpath(fullfile(path_research,'_toolbox')));

% add functions
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%
%-----------------------------load DB-------------------------------------%
% get DB ouliter
load(fullfile(path_DB_save,'emg_out')); 
load(fullfile(path_DB_save,'mark_out')); 

% inspection
load(fullfile(path_DB_inspect,'label_inspected')); 
%-------------------------------------------------------------------------%

%------------------------experiment infromation---------------------------%
% EMG
% [n_sub, n_ses,n_fe, n_emg_ch, n_emg_pair] = size(emg_seg_n);
[n_sub, n_emg_ch, n_emg_pair] = size(emg_out);
n_ses = 20;
n_fe = 11;

% MARKER
[~,n_mark, n_xyz] = size(mark_out);
n_xyz = 2;
% markers to be used
idx_mark_used = [1 3 9 10 11 14 15 16 19 20 21 24 25 26];
name_fe = {'angry','clench','contm_left','contm_right',...
    'frown','fear','happy','kiss','neutral',...
    'sad','surprised'};

%-------------------------------------------------------------------------%

%----------------------------paramters------------------------------------%

%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%

%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%

%==========CALI/TRAIN/TEST INDEX SELECTOIN========%
val_inform = cell(n_mark,n_xyz,n_emg_pair);

for i_emg_pair = 1 : n_emg_pair;
for i_xyz = 1 : n_xyz;
for i_mark = idx_mark_used

% get idices of facial expression and emg channel by marker position
% which will be used as training set 
[idx_fe_used,idx_emg_ch] = get_idx_fe_emg_ch(i_mark);

%------------------------INDEXING-----------------------------------------%
% get vaild session idx by filtering out outliers of min/max value
valid_idx = NaN(n_sub,n_ses);
for i_sub = 1 : n_sub
tmp1 = emg_out(i_sub,idx_emg_ch,i_emg_pair);
tmp2 = mark_out(i_sub,i_mark,i_xyz);
valid_idx(i_sub,:) = ~any([cell2mat(tmp1),cell2mat(tmp2)],2)';
end

%======= CALIBRATION
% decide calibration session as labeling '3'
idx_cali_session = NaN(n_sub,1);
for i_sub = 1 : n_sub
idx_cali_session(i_sub) = find(valid_idx(i_sub,:)==1,numberth_cali_session);
valid_idx(i_sub,idx_cali_session(i_sub)) = 3;
end
idx_cali_session = [(1:n_sub)',idx_cali_session];

%======= IDEXINGF for TRAIN/TEST with facial expression
% valid idx event if this was filtered out by visual inspection 
valid_idx_vinp = cell(n_fe,1);
valid_idx_total = [];
for i_fe = idx_fe_used
% this condition was included because inspector could have made a mistake
% of labeling, which gives unexpected 'NaN' values in the label data. If
% 'Nan' is included, resercher should tell the inspector to get it fixed.
if any(any(isnan(label_inspected(:,:,i_fe,i_mark,i_xyz))))
    
valid_idx_vinp{i_fe} = valid_idx;
disp(['fe:',num2str(i_fe),' mark:',num2str(i_mark),]);

else
% label_inspected was miltiplicated to valid_idx so that we can have
% valid indices which are good in MinMax and Signal shape property
valid_idx_vinp{i_fe} = valid_idx.*(~label_inspected(:,:,i_fe,i_mark,i_xyz));
end

% you need a index of subject, session and facial expression, which are goo
% in MinMax and Signal Shape property. You will use this for training set
% later
[i_sub,i_ses] = ind2sub([n_sub n_ses],find(valid_idx_vinp{i_fe} == 1==1));
valid_idx_total = [valid_idx_total;[i_sub,i_ses,i_fe*ones(length(i_sub),1)]];
end

% For validation, you should split the valid indices of subject, session 
% and facial expression. Depending on how we validate, we can split the
% indices in subject independent manner or subject dependt manner

%===========subject independet manner

% counts the occurences of each unique subjct for sepration
[valid_sub_idx,~,idx] = unique(valid_idx_total(:,1));
ncount_sub = accumarray(idx(:),1);

% In total unique subjects, choose indices of subject to be used in
% training set by cross-validaiton KFold method
n_sub_valid = length(valid_sub_idx);
n_sub_train = floor(n_sub_valid*(kfold-1)/kfold);
cvo = cvpartition(n_sub_valid,'KFold',kfold);

% memory allocation
idx_db_train_ind = cell(kfold,1);
idx_db_test_ind = cell(kfold,1);
trainsize = NaN(kfold,1);
testsize = NaN(kfold,1);
for i_kfold = 1 : kfold
    tmp = randperm(n_sub_valid);
    trainsize(i_kfold) = sum(ncount_sub(cvo.training(i_kfold)));
    testsize(i_kfold) = sum(ncount_sub(cvo.test(i_kfold)));
    
    idx = countmember(valid_idx_total(:,1),find(cvo.training(i_kfold)==1))==1;
    idx_db_train_ind{i_kfold} = valid_idx_total(idx==1,:);
    idx_db_test_ind{i_kfold} = valid_idx_total(idx==0,:);
end

%===========subject dependet manner
% we do not care how index is included in subject or session, which means
% there is little chance that the indices were splited 
% in subject independent manner

cvo_sub = cvpartition(length(valid_idx_total),'KFold',kfold);
idx_db_train = cell(kfold,1);
idx_db_test = cell(kfold,1);
for i_kfold = 1 : kfold
    idx_db_train{i_kfold} = valid_idx_total(training(cvo_sub,i_kfold),:); 
    idx_db_test{i_kfold} = valid_idx_total(test(cvo_sub,i_kfold),:);    
end

% saving necessary indices by collecting into variable 'tmp'
clear tmp;
tmp.idx_cali_session = idx_cali_session;
tmp.cvo_sub = cvo_sub;
tmp.idx_db_train_ind = idx_db_train_ind;
tmp.idx_db_test_ind = idx_db_test_ind;
tmp.trainsize_ind = trainsize;
tmp.testsize_ind = testsize;
tmp.cvo = cvo;
tmp.idx_db_train = idx_db_train;
tmp.idx_db_test = idx_db_test;
tmp.idx_fe_used = idx_fe_used;
tmp.idx_emg_ch = idx_emg_ch;
tmp.kfold = kfold;
tmp.numberth_cali_session = numberth_cali_session; 

% save validation information in varible 'val_inform'
val_inform{i_mark,i_xyz,i_emg_pair} = tmp;

end
end
end
%-------------------------------------------------------------------------%

%-------------------------------save results------------------------------%
save(fullfile(path_DB_save,'val_inform.mat'),'val_inform');
%-------------------------------------------------------------------------%

function [idx_fe_used,idx_emg_ch] = get_idx_fe_emg_ch(i_mark)
%============EYE BROW REGRESSION
if any(countmember([24 25],i_mark))
idx_fe_used = [1,5,11];
idx_emg_ch = 2;
elseif any(countmember([14 15],i_mark))
idx_fe_used = [1,5,11];
idx_emg_ch = 3;  

%============ZYGOMATICUS REGRESSION
elseif any(countmember([10 16],i_mark))
idx_fe_used = [3 5 7];
idx_emg_ch = 4;  
elseif any(countmember([20 26 ],i_mark))
idx_fe_used = [4 5 7];
idx_emg_ch = 1;

%============LIP REGRESSION
elseif any(countmember([1 3],i_mark))
idx_fe_used = [3 4 7 8 11];
idx_emg_ch = [1,4];  
elseif any(countmember([9],i_mark))
idx_fe_used = [3 7 8 11];
idx_emg_ch = [4];  
elseif any(countmember([11],i_mark))
idx_fe_used = [3 7];
idx_emg_ch = [4];  
elseif any(countmember([19],i_mark))
idx_fe_used = [4 7 8 11];
idx_emg_ch = 4;  
elseif any(countmember([21],i_mark))
idx_fe_used = [4 7];
idx_emg_ch = [1]; 
end
end