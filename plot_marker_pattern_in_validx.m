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

mark_count = 0;
for i_mark = idx_mark_used
figure;
mark_count = mark_count + 1;
% for i_mark = 9
% get validation information
val = val_inform{i_mark, i_xyz,i_emg_pair};

valid_idx = unique(val.valid_idx_total(:,1:2),'row');
n = length(valid_idx);
xtrain = cell(n,1); ytrain = cell(n,1);
% subplot(length(idx_mark_used),1,mark_count);
for i = 1 : n
    i_sub = valid_idx(i,1);
    i_ses = valid_idx(i,2);
    
    tmp_d = mark_seg(i_sub,i_ses,:,i_mark,i_xyz);
    tmp_d = cell2mat(squeeze(tmp_d));
    plot(tmp_d);
    hold on;

%     [xtrain{i},ytrain{i}] = get_train...
%     (emg_seg,mark_seg,emg_minmax,mark_minmax,i_sub,i_ses,i_fe,i_mark,i_xyz,val,i_emg_pair,cali,mv_size);
end
tmp_n = sprintf('xyz-%d mark-%d',i_xyz,i_mark);
title(tmp_n);
set(gcf,'Position',[1 41 1920 962]);
tmp_path = make_path_n_retrun_the_path(path_DB_save,'figure');
% tmp_n = sprintf('xyz-%d',i_xyz);
savefig(gcf,fullfile(tmp_path,[tmp_n,'.fig']))
c = getframe(gcf);
imwrite(c.cdata,fullfile(tmp_path,[tmp_n,'.png']));
close

end
% tightfig;


end
end
%==========================TRAIN/TEST SET ENDS============================%

%-------------------------------functions
function [xtrain,ytrain,xtrain_mm,ytrain_mm] = get_train...
(emg_seg,mark_seg,emg_minmax,mark_minmax,i_sub,i_ses,i_mark,i_xyz,val,i_emg_pair,cali,mv_size)
    %---------------------------FaceTrack REGRESSION----------------------%
% emg (input X)
tmp = emg_seg(i_sub,i_ses,:,:,i_emg_pair);
tmp = squeeze(tmp);
tmp = cell2mat(tmp);

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
tmp = mark_seg(i_sub,i_ses,:,i_mark,i_xyz);
tmp = squeeze(tmp);
tmp = cell2mat(tmp);

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