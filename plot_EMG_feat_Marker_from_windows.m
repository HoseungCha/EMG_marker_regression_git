%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m
% 2: Marker_v_ext_from_windows.m 
% 3: EMG_feat_ext_from_windows.m %%%%%current code%%%%%%%%%%%%%%
% 4: plot_EMG_feat_Marker_from_windows.m %%%%%current code%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; close all; clear ;
% get toolbox
addpath(genpath(fullfile(fileparts(fileparts(fileparts(cd))),'_toolbox')));
% get functions
addpath(genpath(fullfile(cd,'functions')));
%% experiment information
name_trg = {"화남",1,1;"어금니깨물기",1,2;"비웃음(왼쪽)",1,3;"비웃음(오른쪽)",1,4;"눈 세게 감기",1,5;"두려움",1,6;"행복",1,7;"키스",2,1;"무표정",2,2;"슬픔",2,3;"놀람",2,4};
name_FE = name_trg(:,1);
name_marker = {'central down lip';'central nose';'central upper lip';'head 1';...
    'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';...
    'left dimple';'left down eye';'left down lip';'left eyebrow inside';...
    'left eyebrow outside';'left nose';'left upper eye';'left upper lip';...
    'right central lip';'right cheek';'right dimple';'right down eye';...
    'right down lip';'right eyebrow inside';'right eyebrow outside';...
    'right nose';'right upper eye';'right upper lip'};
n_marker = length(name_marker);
n_emg_pair = 3;
% path for processed data
path_parent=fileparts(pwd); % parent path which has DB files
name_folder2analysis = 'windows_ds_10Hz_ovsize_50_delay_0';
path_DB_processed = fullfile(path_parent,'DB','DB_processed2',name_folder2analysis);
[Sname,Spath] = read_names_of_file_in_folder(fullfile(path_parent,'DB','DB_raw2'));
n_sub = length(Sname);
n_trl = 20;
n_FE = 11;
% enlarge subplot of matlab
id_make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);
if ~id_make_it_tight,  clear subplot;  end
map_color = colormap(hsv);
map_color4FE = map_color(1:floor(length(map_color)/n_FE):...
    floor(length(map_color)/n_FE)*n_FE,:);
idx_RMS_feat = 1:4; % RMS
period_FE_exp = 3;
period_sampling = 0.1;
n_seg2use = period_FE_exp/period_sampling;

%% get marker set
for i_emg_pair = 1 : n_emg_pair
for i_mark = 1 : n_marker
%     get path of marker set
    path_markerset = fullfile(path_DB_processed,...
        sprintf('z_norm_mark_%d',i_mark),'marker_set');
    load(path_markerset);
%     get path of emg set   
    path_emgset = fullfile(path_DB_processed,...
        sprintf('z_norm_emg_pair_%d_RMSWL',i_emg_pair),'feat_set_RMSWL');
    load(path_emgset);
    % get path of emg
    path_emg = fullfile(path_DB_processed,sprintf('emg_pair_%d',i_emg_pair));
    
    for i_sub = 1 : n_sub
       figure('Name',sprintf('Sub_%d_emg_pair_%d_mark_%d',...
           i_sub,i_emg_pair,i_mark))
       for i_trl = 1 : n_trl
           subplot(n_trl,1,i_trl)
           % get EMG
           load(fullfile(path_emg,sprintf('sub_%03d_trl_%03d',i_sub,i_trl)),...
               'idx_seq_FE','trg_w'); 
           % get feature
           feat_tmp = feat_set{i_sub,i_trl}(:,idx_RMS_feat); 
           % get marker
           marker_tmp = marker_set{i_sub,i_trl};
           % base-line preprocessing
           feat_bs = mean(feat_tmp(trg_w(1):trg_w(1)+n_seg2use-1,idx_RMS_feat),1);
           feat_bs_pc = feat_tmp(:,idx_RMS_feat) - feat_bs;
           marker_bs = mean(marker_tmp(trg_w(1):trg_w(1)+n_seg2use-1,:),1);
           mark_bs_pc = marker_tmp - marker_bs;
           % plot
           figure;
           plot(feat_tmp,'b'); hold on; plot(marker_tmp,'r')
           
           
           
           % plot emg
           figure;
           plot(feat_tmp,'b')
           % plot marker
           hold on;plot(marker_tmp,'r')
           % plot facial expression
           for i_FE = 1 : n_FE
               hold on;
               stem(trg_w(i_FE),max(max(feat_tmp)),...
                   'color',map_color4FE(idx_seq_FE(i_FE),:));
           end
       end
    end
end
end
path = 'C:\Users\A\Desktop\CHA\연구\EMG_marker_regression\코드\DB\DB_processed2\windows_ds_10Hz_ovsize_50_delay_0\z_norm_mark_10';
load(fullfile(path,'marker_set'))
path = 'C:\Users\A\Desktop\CHA\연구\EMG_marker_regression\코드\DB\DB_processed2\windows_ds_10Hz_ovsize_50_delay_0\z_norm_emg_pair_1_RMSWL';
load(fullfile(path,'feat_set_RMSWL'))


path = 'C:\Users\A\Desktop\CHA\연구\EMG_marker_regression\코드\DB\DB_processed2\windows_ds_10Hz_ovsize_50_delay_0\emg_pair_1';
fname = sprintf('sub_%03d_trl_%03d',5,10); % file name to save
load(fullfile(path,fname));
figure;
plot(marker_set{5,10},'r')
hold on;
plot(feat_set{5,10}(:,4),'b')
hold on
stem(trg_w,7*ones(length(trg_w),1),'g')
stem(trg_w,-7*ones(length(trg_w),1),'g')
% title(Label_mark{10})
% first
first_part = trg_w(1:2:end);
second_part = trg_w(2:2:end-1);
% text(first_part,-3*ones(length(first_part),1),Name_FE(1:2:end))
% text(second_part,-2*ones(length(second_part),1),Name_FE(2:2:end-1))

 
