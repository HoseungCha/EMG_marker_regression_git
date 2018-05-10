%-------------------------------------------------------------------------%
% 1: DB_windows_extraion.m
% 2: Marker_v_ext_from_windows.m
% 3: EMG_feat_ext_from_windows.m %%%%%current code%%%%%%%%%%%%%%
%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
clc; clear; close all;


%------------------------code analysis parameter--------------------------%
% name of raw DB
name_DB_raw = 'DB_raw2';

% name of process DB to analyze in this code
name_DB_process = 'DB_processed2';

% name of anlaysis DB in the process DB
name_DB_analy =...
    'DB_raw2_marker_wsize_24_winc_12_emg_wsize_408_winc_204_delay_0';

% name of emg DB in the processed DB
name_DB_emg = 'emg_pair';

% decide feature to extract
name_feat2use = {'RMS'};
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%

% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));

% path of code, which
path_code = fileparts(cd);
path_DB = fullfile(path_code,'DB');
path_DB_raw = fullfile(path_DB,name_DB_raw);
path_DB_process = fullfile(path_DB,name_DB_process);
path_DB_analy = fullfile(path_DB_process,name_DB_analy);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% get toolbox
addpath(genpath(fullfile(path_research,'_toolbox')));

% add functions
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%

%-----------------------experiment information----------------------------%
% period of facial expression
period_FE_exp = 3;
period_margin_FE_front =1; % time period to be used before instruction
period_margin_FE_end = 0; % time period to be used after instruction

% samping period of facial expression (window increase size)
period_sampling = 0.1;

% list of paris of instruction and trigger
name_trg = {"화남",1,1;"어금니깨물기",1,2;"비웃음(왼쪽)",1,3;"비웃음(오른쪽)",...
    1,4;"눈 세게 감기",1,5;"두려움",1,6;"행복",1,7;"키스",2,1;"무표정",2,2;...
    "슬픔",2,3;"놀람",2,4};
name_fe = name_trg(:,1);

% read file path of data from raw DB
[name_sub,path_sub] = read_names_of_file_in_folder(fullfile(path_code,'DB','DB_raw2'));

% number of windows for margin front and end
n_win2margin_front = period_margin_FE_front/period_sampling;
n_win2margin_end= period_margin_FE_end/period_sampling;

%----------feautre settings
name_feat_list = {'RMS','WL','CC','SampEN','Min_Max','Teager','Hjorth'};

% value which should be multiplied by EMG channel
v_multply_of_feat = [1 1 1 4];

% indices of features to be extracted
idx_ftype2use = contains(name_feat_list,name_feat2use);

% number of subject, trials, triggers and channels
n_sub = length(name_sub);
n_trl = 20;
n_emg_pair = 3;
n_ch_emg = 4;
n_fe = length(name_fe);
n_seg = period_FE_exp/period_sampling;

% number of features to be used
n_feat2use = sum(v_multply_of_feat(idx_ftype2use)*n_ch_emg);
%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%
emg_seg = cell(n_sub,n_trl,n_fe,n_emg_pair);
%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
for i_sub = 1 : n_sub
    for i_trl = 1 : n_trl
        disp([i_sub,i_trl]);
        for i_emg_pair = 1 : n_emg_pair
            % folder name 4 saving
            name_emg_pair = sprintf('emg_pair_%d',i_emg_pair);
            
            % set path
            path_emg_pair = fullfile(path_DB_analy,...
                [name_DB_emg,'_',num2str(i_emg_pair)]);
            
            % read emg
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % load feature windows with respect of subject and trial
            load(fullfile(path_emg_pair,name_file)); % get emg
            
            % get emg features from windows
            len_win = length(emg_win); % number of windows
            
            % memory allocations
            emg_feat = zeros(len_win,n_feat2use);
            
            % get features from windows of emg
            for i_win = 1 : len_win
                % time domain features
                emg_feat(i_win,:) = EMG_feat_extraction(emg_win{i_win},...
                    name_feat_list,name_feat2use);
            end
            
            % extract signal part of during facial expression
            emg_segment = cell(n_fe,1);
            for i_fe = 1 : n_fe
                try
                    emg_segment{idx_seq_fe(i_fe)} = ...
                        emg_feat(trg_w(i_fe)-n_win2margin_front:...
                        trg_w(i_fe)+n_seg-1+n_win2margin_end,:);
                catch
                    emg_segment{idx_seq_fe(i_fe)} = ...
                        NaN(n_win2margin_front+n_seg+n_win2margin_end,n_ch_emg);
                end
            end
            % collected DB with subject, tiral, emotion and emgpair
            emg_seg(i_sub,i_trl,:,i_emg_pair) = emg_segment;
            %-------------------------------------------------------------%
        end
    end
end
%-------------------------------------------------------------------------%

%-----------------------------save emg_seg--------------------------------%
save(fullfile(path_DB_analy,[name_DB_emg,'_emg_seg']),'emg_seg');
%-------------------------------------------------------------------------%


function tmp_feat = EMG_feat_extraction(curr_win,name_feat_list,name_feat2use)

% determination of feature types to extract
id_feat2ext = contains(name_feat_list,name_feat2use);

% get number of channel of signal window
n_ch = size(curr_win,2);

if id_feat2ext(1)
    % RMS
    tmp_rms = sqrt(mean(curr_win.^2));
else
    tmp_rms = [];
end

if id_feat2ext(2)
    % WL
    tmp_WL = sum(abs(diff(curr_win,2)));
else
    tmp_WL = [];
end

if id_feat2ext(3)
    % CC
    tmp_CC = featCC(curr_win,4);
else
    tmp_CC = [];
end

if id_feat2ext(4)
    % SAMPLE ENTROPY
    tmp_SampEN = SamplEN(curr_win,2);
else
    tmp_SampEN = [];
end

if id_feat2ext(5)
    % MIN MAX
    tmp = minmax(curr_win');
    tmp_min_max = (tmp(:,2)-tmp(:,1))';
else
    tmp_min_max = [];
end

if id_feat2ext(6)
    % TEAGER
    tmp_teager = zeros(1,n_ch);
    for i = 1 : n_ch
        tmp = cal_freqweighted_energy(curr_win(:,i),1,'teager');
        tmp_teager(i) = sum(tmp)/length(tmp);
    end
else
    tmp_teager = [];
end

if id_feat2ext(7)
    % HJORTH PARAMETERS
    tmp_activity = var(curr_win);
    tmp_mobility = sqrt(var(diff(curr_win))./var(curr_win));
    tmp_complexity = sqrt(var(diff(diff(curr_win)))./var(diff(curr_win)));
    tmp_Hjorth = [tmp_activity,tmp_mobility,tmp_complexity];
else
    tmp_Hjorth = [];
end

% concatinating features
tmp_feat = [tmp_rms,tmp_WL,tmp_SampEN,tmp_CC,...
    tmp_min_max,tmp_teager,tmp_Hjorth];
end
