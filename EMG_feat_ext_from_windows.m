%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m
% 2: Marker_v_ext_from_windows.m 
% 3: EMG_feat_ext_from_windows.m %%%%%current code%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; close all; clear ;
addpath(genpath(fullfile(cd,'functions')));
% path for processed data
parentdir=fileparts(pwd); % parent path which has DB files
name_folder = 'windows_ds_10Hz_ovsize_50_delay_0';
path_DB = fullfile(parentdir,'DB','DB_processed',name_folder);

%% experiemnt infromation
Trg_Inform = {"����",1,1;"�����(������)",1,2;"�����(����)",1,3;"���",1,4;...
    "�� ���� ����",1,5;"Inner brow raiser",1,6;"Outer brow raiser",1,7;...
    "Brow lowerer",2,1;"cheek raiser",2,2;"Nose winkler",2,3;...
    "Upper lip raiser",2,4;"Lip corner puller",2,5;"Cheek puffer",2,6;...
    "Dimpler",2,7;"Lip corner depressor",3,1;"Lower lip depressor",3,2;...
    "Chin raiser",3,3;"Lip puckerer",3,4;"Lip stretcher",3,5;...
    "Lip funneler",3,6;"Lup tightener",3,7;"Jaw drop",4,1;...
    "Mouth stretch",4,2;"Lip suck",4,3;"Eyes closed",4,4;...
    "���� �ٿø���",4,5;"����",4,6;"����",4,7;"����",4,1;"����",4,2;...
    "����",4,3;"����",4,4;"����",4,5;"�ð�",4,6;"�Ʒ�",4,7;"�˶�",5,1;...
    "����",5,2;"����",5,3;"����",5,4;"����",5,5;"����",5,6;"��ȭ",5,7;...
    "����",6,1;"����",6,2;"�߰�",6,3;"���",6,4};
Trg_name = Trg_Inform(:,1);
N_sub = 21;
N_trl = 15;
% N_mark = 28;
N_emgpair = 3;
% N_mark_type = 3; % 1:X,2:Y,3:Z
N_ch_emg = 4;
N_order_cc = 4;
name_feat_list = {'RMS','WL','CC','SampEN'};
%% determine normalization type
str_use_z_norm = 'z_norm';
str_use_cal_norm = 'cal_norm';
id_type_norm = str_use_z_norm;%%%%%%%%%%%%%%%%%%%%decide normalization type
%% decide feature to extract
str_features2use = {'RMS','WL'};
id_feat2use = contains(name_feat_list,str_features2use);
N_feat = sum([id_feat2use(1:3)*N_ch_emg,...
    id_feat2use(N_ch_emg)*N_ch_emg*N_ch_emg]);

%% Get median value from marker
for i_emg_pair = 1 : N_emgpair
    % folder name 4 saving
    name_folder = sprintf('emg_pair_%d',i_emg_pair);
    %% set saving folder;
    name_folder4norm_DB = [id_type_norm,'_',name_folder];
    path_emg_pair = make_path_n_retrun_the_path(path_DB, name_folder4norm_DB);

    %% get path
    path_emg = fullfile(path_DB,name_folder);
    feat_set = cell(N_sub,N_trl);
    for i_sub = 1 : N_sub
        for i_trl = 1 : N_trl
            %% read EMG 
            fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            load(fullfile(path_emg,fname)); % get EMG
%             fname = sprintf('sub_%03d_trl_%03d_raw',i_sub,i_trl);
%             load(fullfile(path_mark,fname)); % get markers
            
            %% get RMS from EMG, get medial value from marker
            N_window = length(emg_win); % number of windows
            temp_feat = zeros(N_window,N_feat);
            for i_win = 1 : N_window
                %% EMG feat extraion
                % time domain features 
                curr_win = emg_win{i_win};
                if id_feat2use(1) ==1
                    temp_rms = sqrt(mean(curr_win.^2));
                else
                    temp_rms = [];
                end
                if id_feat2use(2) ==1
                    temp_WL = sum(abs(diff(curr_win,2)));
                else
                    temp_WL = [];
                end
                if id_feat2use(3) ==1
                    temp_SampEN = SamplEN(curr_win,2);
                else
                    temp_SampEN = [];
                end
                if id_feat2use(4) ==1
                    temp_CC = featCC(curr_win,4);
                else
                    temp_CC = [];
                end
                temp_feat(i_win,:) = [temp_rms,temp_WL,temp_SampEN,temp_CC];
                % get image from raw emg
%                 temp_img = mat2im(curr_win,parula(numel(curr_win)));
%                 fname = sprintf('sub_%03d_trl_%03d_win_%03d',i_sub,i_trl,i_win);
%                 imwrite(temp_img,fullfile(path_img,[fname,'.png']));
                
            end
            %% type of normalization
            switch id_type_norm
                case str_use_cal_norm
                %% Calibration session���� Nomalization
                    Max = max(temp_feat(1 : trg_w(6),:));
                    Min = min(temp_feat(1 : trg_w(6),:));
                    emg_n = (temp_feat-Min)./(Max-Min);
                    emg_n(:,9:end) = temp_feat(:,9:end);% RMS, WL�� normalization
                case id_type_norm
                %% zscore normaliztion
                    emg_n = zscore(temp_feat,0,1); 
                    emg_n(:,9:end) = temp_feat(:,9:end);% RMS, WL�� normalization
            end
            %% feature set
            feat_set{i_sub,i_trl} = emg_n;
            disp([i_sub,i_trl]);
        end
    end
    %% save
    name_save_file = sprintf('feat_set_%s',cat(2,str_features2use{:}));
    save(fullfile(path_emg_pair,name_save_file),'feat_set');
end