%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m 
% 2: Marker_v_ext_from_windows.m
% 3: EMG_feat_ext_from_windows.m   
% 4: minmax_n_ouliers_ext.m 
% 5: cali_train_text_val_indx_selection.m  
% 6: reg_db_construction.m %%%%%current code%%%%%%%%%%%%%%
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

% Name to load
name4save = 'regression';

mv_size = 5;
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
% DB
load(fullfile(path_DB_save,'emg_seg')); 
load(fullfile(path_DB_save,'emg_seq')); 
load(fullfile(path_DB_save,'mark_seg')); 
load(fullfile(path_DB_save,'mark_seq')); 
load(fullfile(path_DB_save,'emg_minmax')); 
load(fullfile(path_DB_save,'mark_minmax')); 

% inspection
load(fullfile(path_DB_save,'val_inform')); 
%-------------------------------------------------------------------------%

%------------------------experiment infromation---------------------------%
% EMG
[n_sub, n_ses,n_fe, n_emg_ch, n_emg_pair] = size(emg_seg);
% MARKER
[~, ~, ~,n_mark, n_xyz] = size(mark_seg);

% markers to be used
idx_mark_used = [1 3 9 10 11 14 15 16 19 20 21 24 25 26];
% idx_mark_used = [10 14 15 16 20 24 25 26];
name_fe = {'angry','clench','contm_left','contm_right',...
    'frown','fear','happy','kiss','neutral',...
    'sad','surprised'};
n_xyz = 2;
n_emg_pair = 1;
%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
for i_emg_pair =  1 : n_emg_pair
for i_xyz = 1 : n_xyz
for i_mark = idx_mark_used
% for i_mark = 9
% get validation information
val = val_inform{i_mark, i_xyz,i_emg_pair};

%======CALIBRATION

model = cell(n_sub,1);
for i_sub = 1 : n_sub
    
% you should first get calibration session of each subject
tmp1 = emg_seg(i_sub,val.idx_cali_session(i_sub,2),:,val.idx_emg_ch,i_emg_pair);
tmp1 = cell2mat(permute(tmp1,[3 4 1 2]));

% normlalize the calibration session with the minmax of the calibration session
norm = cell2mat(permute(emg_minmax(...
    i_sub,val.idx_cali_session(i_sub,2),val.idx_emg_ch,i_emg_pair),[3 1 2]))';

tmp1 = (tmp1 - norm(1,:))./(norm(2,:)-norm(1,:));
tmp1 = mat2cell(tmp1,40*ones(n_fe,1),size(tmp1,2));

% for marker's direction, you split the cali session with 
% the marker's direction

mdl = cell(4,1);
if any(countmember(val.idx_emg_ch,1))
% get EMG channel of 1   
idx = logical(countmember(val.idx_emg_ch,1));
% Zygo TRAIN (0:neutrl, +1:contem_right(up), -1: fear(down)
tmp2 = cat(1,tmp1{9}(11:end,idx),tmp1{4}(11:end,idx),tmp1{6}(11:end,idx));
% classifier 
mdl{1} = fitcdiscr(tmp2,[zeros(30,1);ones(30,1);-1*ones(30,1)]);
end
if any(countmember(val.idx_emg_ch,4))
% get EMG channel of 4   
idx = logical(countmember(val.idx_emg_ch,4));
% Zygo TRAIN (0:neutrl, +1:contem_right(up), -1: fear(down)
tmp2 = cat(1,tmp1{9}(11:end,idx),tmp1{3}(11:end,idx),tmp1{6}(11:end,idx));
mdl{4} = fitcdiscr(tmp2,[zeros(30,1);ones(30,1);-1*ones(30,1)]);
end
if  any(countmember(val.idx_emg_ch,2))
% get EMG channel of 2   
idx = logical(countmember(val.idx_emg_ch,2));

% EYE BROW TRAIN (0:neutrl, +1:surprised(up), -1: angry(down)
cat(1,tmp1{9}(11:end,idx),tmp1{11}(11:end,idx),tmp1{1}(11:end,idx))

tmp2 = cat(1,tmp1{9}(11:end,idx),tmp1{3}(11:end,idx),tmp1{6}(11:end,idx));
mdl{2} = fitcdiscr(tmp2,[zeros(30,1);ones(30,1);-1*ones(30,1)]);
end
if any(countmember(val.idx_emg_ch,3))
% get EMG channel of 3   
idx = logical(countmember(val.idx_emg_ch,3));

% EYE BROW TRAIN (0:neutrl, +1:surprised(up), -1: angry(down)
cat(1,tmp1{9}(11:end,idx),tmp1{11}(11:end,idx),tmp1{1}(11:end,idx))
tmp2 = cat(1,tmp1{9}(11:end,idx),tmp1{3}(11:end,idx),tmp1{6}(11:end,idx));
mdl{3} = fitcdiscr(tmp2,[zeros(30,1);ones(30,1);-1*ones(30,1)]);
end

% saving model
model{i_sub}.mdl = mdl;
end
%-------------------------------------------------------------------------%

%-----------------------calibration Min/Max-------------------------------%
minmax_mark = NaN(n_sub,2);
minmax_emg = NaN(n_sub,2,length(val.idx_emg_ch));
for i_sub = 1 : n_sub
    minmax_mark(i_sub,:) = mark_minmax{i_sub,val.idx_cali_session(i_sub,2),i_mark,i_xyz};
    minmax_emg(i_sub,:,:) = cat(3,emg_minmax{i_sub,val.idx_cali_session(i_sub,2),val.idx_emg_ch,i_emg_pair});
end
cali.model = model;
cali.minmax_mark = minmax_mark;
cali.minmax_emg = minmax_emg;
%-------------------------------------------------------------------------%
%===========================CALIBRATION ENDS==============================%


%=============================TRAIN/TEST SET==============================%
for i_kfold = 1 : val.kfold

%============================SUBJECT DEPENDENT============================%
%------------TRAIN
n = length(val.idx_db_train{i_kfold});
xtrain = cell(n,1); ytrain = cell(n,1);
% xtrain_mm = cell(n,1); ytrain_mm = cell(n,1);
for i = 1 : n
    i_sub = val.idx_db_train{i_kfold}(i,1);
    i_ses = val.idx_db_train{i_kfold}(i,2);
    i_fe = val.idx_db_train{i_kfold}(i,3);
    
    [xtrain{i},ytrain{i}] = get_train...
    (emg_seg,mark_seg,emg_minmax,mark_minmax,i_sub,i_ses,i_fe,i_mark,i_xyz,val,i_emg_pair,cali,mv_size);
end


%-------------TEST
n =length(val.idx_db_test{i_kfold});
xtest = cell(n,1); ytest = cell(n,1);
ytest_valid =cell(n,1);
% xtest_mm = cell(n,1); ytest_mm = cell(n,1);
for i = 1 : n
    i_sub = val.idx_db_test{i_kfold}(i,1);
    i_ses = val.idx_db_test{i_kfold}(i,2);
    
    [xtest{i},ytest{i}] = get_test...
    (emg_seq,mark_seq,i_sub,i_ses,i_mark,i_xyz,val,i_emg_pair,cali,mark_minmax,mv_size);

    % for facial expression part
    path = fullfile(path_DB_process,name_DB_analy,['mark_',num2str(i_mark)],...
        sprintf('sub_%03d_trl_%03d',i_sub,i_ses));
    load(path,'trg_w')
    ytest_valid{i} = trg_w;
end

% set file name for saving
name2save = sprintf('mark_%d_xyz_%d_emg_pair_%d_mv_size_%d',...
    i_mark,i_xyz,i_emg_pair,mv_size);

% save train/test DB
path_saving = make_path_n_retrun_the_path(fullfile(path_DB_save,'DB'),name2save);
save(fullfile(path_saving,sprintf('dep_kfold_%d',i_kfold)),...
    'xtrain','ytrain','xtest','ytest',...
    'ytest_valid','val');
%=========================================================================%

%==========================SUBJECT INDEPENDENT============================%
%------------TRAIN
n = length(val.idx_db_train_ind{i_kfold});
xtrain = cell(n,1); ytrain = cell(n,1);
% xtrain_mm = cell(n,1); ytrain_mm = cell(n,1);
for i = 1 : n
    i_sub = val.idx_db_train_ind{i_kfold}(i,1);
    i_ses = val.idx_db_train_ind{i_kfold}(i,2);
    i_fe = val.idx_db_train_ind{i_kfold}(i,3);
    
    [xtrain{i},ytrain{i}] = get_train...
    (emg_seg,mark_seg,emg_minmax,mark_minmax,i_sub,i_ses,i_fe,i_mark,i_xyz,val,i_emg_pair,cali,mv_size);
end

%-------------TEST
n = length(val.idx_db_test_ind{i_kfold});
xtest = cell(n,1); ytest = cell(n,1);
ytest_valid =cell(n,1);
% xtest_mm = cell(n,1); ytest_mm = cell(n,1);
for i = 1 : n
    i_sub = val.idx_db_test_ind{i_kfold}(i,1);
    i_ses = val.idx_db_test_ind{i_kfold}(i,2);
    
    [xtest{i},ytest{i}] = get_test...
    (emg_seq,mark_seq,i_sub,i_ses,i_mark,i_xyz,val,i_emg_pair,cali,mark_minmax,mv_size);

    % for facial expression part
    path = fullfile(path_DB_process,name_DB_analy,['mark_',num2str(i_mark)],...
        sprintf('sub_%03d_trl_%03d',i_sub,i_ses));
    load(path,'trg_w')
    ytest_valid{i} = trg_w;
end

save(fullfile(path_saving,sprintf('ind_kfold_%d',i_kfold)),...
    'xtrain','ytrain','xtest','ytest',...
    'ytest_valid','val');
%=========================================================================%

end

end
end
end
%==========================TRAIN/TEST SET ENDS============================%

%-------------------------------functions
function [xtrain,ytrain,xtrain_mm,ytrain_mm] = get_train...
(emg_seg,mark_seg,emg_minmax,mark_minmax,i_sub,i_ses,i_fe,i_mark,i_xyz,val,i_emg_pair,cali,mv_size)
    %---------------------------FaceTrack REGRESSION----------------------%
% emg (input X)
tmp = emg_seg(i_sub,i_ses,i_fe,val.idx_emg_ch,i_emg_pair);
tmp = squeeze(tmp);
tmp = cat(2,tmp{:});

% normalization by calibration
% tmp1 = cell2mat(squeeze(emg_minmax(i_sub,i_ses,val.idx_emg_ch,i_emg_pair)));
tmp1 = permute(cali.minmax_emg(i_sub,:,:),[3 2 1]);
xtrain = (tmp - tmp1(:,1)')./(tmp1(:,2)'-tmp1(:,1)');


% classification by face part classfier
% output = NaN(size(xtrain,1),length(val.idx_emg_ch));
% for j = 1 :length(val.idx_emg_ch)
%     c = val.idx_emg_ch(j);
%     mdl = cali.model{i_sub}.mdl{c};
%     temp = predict(mdl,xtrain(:,j));
%     output(:,j) = majority_vote_simple(temp,[-1 0 1],mv_size);
% end

% cancatinating
% xtrain = [xtrain,output];

% marker (target Y)
tmp = mark_seg(i_sub,i_ses,i_fe,i_mark,i_xyz);
tmp = squeeze(tmp);
tmp = cat(2,tmp{:});

% normalization by calibration
% tmp1 = cell2mat(squeeze(mark_minmax(i_sub,i_ses,i_mark,i_xyz)));
tmp1 = permute(cali.minmax_mark(i_sub,:,:),[3 2 1]);
ytrain = (tmp - tmp1(:,1)')./(tmp1(:,2)'-tmp1(:,1)');
%---------------------------------------------------------------------%

%---------------------------MINMAX REGRESSION-------------------------%
% MINMAX emg (input X)
% tmp = emg_minmax(i_sub,i_ses,val.idx_emg_ch,i_emg_pair);
% tmp = cell2mat(squeeze(tmp));
% xtrain_mm = tmp(:,2);
% 
% % marker (target Y)
% tmp = mark_minmax(i_sub,i_ses,i_mark,i_xyz);
% tmp = cell2mat(squeeze(tmp));
% ytrain_mm = tmp(:,2);
%---------------------------------------------------------------------%
end

function [xtest,ytest,xtest_mm,ytest_mm] = ...
get_test(emg_seq,mark_seq,i_sub,i_ses,i_mark,i_xyz,val,i_emg_pair,cali,mark_minmax,mv_size)
%---------------------------FaceTrack REGRESSION----------------------%
% emg (input X)
tmp = emg_seq(i_sub,i_ses,val.idx_emg_ch,i_emg_pair);
tmp = squeeze(tmp);
tmp = cat(2,tmp{:});

% normalization by calibration
tmp1 = permute(cali.minmax_emg(i_sub,:,:),[3 2 1]);
xtest = (tmp - tmp1(:,1)')./(tmp1(:,2)'-tmp1(:,1)');

% classification by face part classfier
% output = NaN(length(xtest),length(val.idx_emg_ch));
% for j = 1 :length(val.idx_emg_ch)
%     c = val.idx_emg_ch(j);
%     mdl = cali.model{i_sub}.mdl{c};
%     temp = predict(mdl,xtest(:,j));
%     output(:,j) = majority_vote_simple(temp,[-1 0 1],mv_size);
% end

% concatinating
% xtest = [xtest,output];

% marker (target Y)
tmp1 = permute(cali.minmax_mark(i_sub,:,:),[3 2 1]);
tmp = mark_seq{i_sub,i_ses,i_mark,i_xyz};
ytest = (tmp - tmp1(:,1)')./(tmp1(:,2)'-tmp1(:,1)');

% ytest = cat(2,tmp{:});
%---------------------------------------------------------------------%

%---------------------------MINMAX REGRESSION-------------------------%
% MINMAX emg (input X)
% xtest_mm = permute(cali.minmax_emg(i_sub,:,:),[3 2 1]);
% xtest_mm = xtest_mm(:,2);
% marker (target Y)
% tmp = mark_minmax(i_sub,i_ses,i_mark,i_xyz);
% tmp = cell2mat(squeeze(tmp));
% ytest_mm = tmp(:,2);
%---------------------------------------------------------------------%
end

function yp = majority_vote_simple(xp,idx_target2classify,maj_size)
% final decision using majoriy voting
% yp has final prediction X segments(times)
% xp has <N_Seg,N_trl,N_label>
% yp has <N_Seg,N_trl,N_label>
n = size(xp,1);

% yp = zeros(N_label*N_trl,1);
yp = zeros(n,1);
for i = 1 : n
    if i-maj_size<1
        continue;
    end
    tmp1 = xp(i-maj_size+1:i);
    tmp2 = countmember(idx_target2classify,tmp1);
    maxval = max(tmp2);
    idx = find(tmp2 == maxval);
    if length(idx)>1
      tmp = idx_target2classify(idx);
      tmp3 = tmp((tmp~=0));
      yp(i) = tmp3(randi(length(tmp3)));
    else
      yp(i) = idx_target2classify(idx);
    end

end
end