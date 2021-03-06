%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m
% 2: Marker_v_ext_from_windows.m %%%%%current code%%%%%%%%%%%%%%
% 3: EMG_feat_ext_from_windows.m
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; close all; clear ;
% path for processed data
parentdir=fileparts(pwd); % parent path which has DB files
name_folder = 'windows_ds_10Hz_ovsize_50_delay_0';
path_DB = fullfile(parentdir,'DB','DB_processed',name_folder);

%% experiemnt infromation
Label_mark = {'central down lip';'central nose';'central upper lip';'head 1';...
    'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';...
    'left dimple';'left down eye';'left down lip';'left eyebrow inside';...
    'left eyebrow outside';'left nose';'left upper eye';'left upper lip';...
    'right central lip';'right cheek';'right dimple';'right down eye';...
    'right down lip';'right eyebrow inside';'right eyebrow outside';...
    'right nose';'right upper eye';'right upper lip'};
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
N_mark = 28;
N_trg = 26;
N_emgpair = 3;
N_mark_type = 3; % 1:X,2:Y,3:Z
%% determine normalization type
str_use_z_norm = 'z_norm';
str_use_cal_norm = 'cal_norm';
id_type_norm = str_use_z_norm;

%% Get median value from marker
for i_mark = 1 : N_mark
    % folder name 4 saving
    name_folder = sprintf('mark_%d',i_mark);
    %% set saving folder;
    name_folder4norm_DB = [id_type_norm,'_',name_folder];
    path_mark_norm = make_path_n_retrun_the_path(path_DB, name_folder4norm_DB);
    %% set path
    path_mark = fullfile(path_DB,name_folder);
    marker_set = cell(N_sub,N_trl);
    for i_sub = 1 : N_sub
        for i_trl = 1 : N_trl
            %% read marker 
            fname = sprintf('sub_%03d_trl_%03d_raw',i_sub,i_trl);
            load(fullfile(path_mark,fname)); % get markers

            %% get RMS from EMG, get medial value from marker
            len_win = length(mark_win); % number of windows
            mark_median = zeros(len_win,N_mark_type);
            for i_win = 1 : len_win
                %% marker values extraion
                temp = median(mark_win{i_win},1);
                mark_median(i_win,:)= temp(1:3);
            end
            %% polyfit amd reject baseline of marker values
            mark_fit = zeros(len_win,N_mark_type);
            for i_markType = 1 : N_mark_type
                p = polyfit(1:len_win,mark_median(:,i_markType)',3); % 3�� polyfit
                mark_fit(:,i_markType) = polyval(p,1:len_win);
            end
            mark_base_corr = mark_median - mark_fit;
            
            switch id_type_norm
                case str_use_cal_norm
                %% Calibration session���� Nomalization
                    Max = max(d_2_norm(1 : trg_w(6),:));
                    Min = min(d_2_norm(1 : trg_w(6),:));
                    mark_n = (d_2_norm-Min)./(Max-Min);
                case id_type_norm
                %% zscore normaliztion
                    mark_n = zscore(mark_base_corr(:,1:N_mark_type),0,1);
            end
            % ����
            marker_set{i_sub,i_trl} = mark_n;
            disp([i_sub,i_trl]);
        end
    end
    % set saving file name for each marker
    save(fullfile(path_mark_norm,'marker_set'),'marker_set');
end
