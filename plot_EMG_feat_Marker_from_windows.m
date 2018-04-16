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
Name_Trg = {"화남",1,1;"어금니깨물기",1,2;"비웃음(왼쪽)",1,3;"비웃음(오른쪽)",1,4;"눈 세게 감기",1,5;"두려움",1,6;"행복",1,7;"키스",2,1;"무표정",2,2;"슬픔",2,3;"놀람",2,4};
Name_FE = Name_Trg(:,1);
Label_mark = {'central down lip';'central nose';'central upper lip';'head 1';...
    'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';...
    'left dimple';'left down eye';'left down lip';'left eyebrow inside';...
    'left eyebrow outside';'left nose';'left upper eye';'left upper lip';...
    'right central lip';'right cheek';'right dimple';'right down eye';...
    'right down lip';'right eyebrow inside';'right eyebrow outside';...
    'right nose';'right upper eye';'right upper lip'};
% path for processed data
parentdir=fileparts(pwd); % parent path which has DB files
name_folder = 'windows_ds_10Hz_ovsize_50_delay_0';
path_DB = fullfile(parentdir,'DB','DB_processed',name_folder);
%% get marker set
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

 
