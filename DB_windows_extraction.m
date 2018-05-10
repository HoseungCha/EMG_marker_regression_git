%--------------------------------------------------------------------------
% this code is about extraction of DB of marker and EMG)
% 1: DB_windows_extraion.m %-current code-%
% 2: Marker_v_ext_from_windows.m
% 3: EMG_feat_ext_from_windows.m
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clear; close all; clc

%-----------------------Code anlaysis parmaters---------------------------%
% name of DB raw to analyze in this code
name_DB_raw = 'DB_raw2';

% name of DB process
name_DB_process = 'DB_processed2';

% set window size and overlap size
size_overlap = 50;
sf_down = 10; % down sampling rate 
ratio_winsize_by_wininc = 2; %this value will be multipied wininc to get winsize

%=============the reason why you should set delay as zero=================%
% trigger singal which tell us that camera acquasition has started, 
% was obtained with delay after cliking start button in motive program
% it is regared that original delay is about 480E-03
% Interestingly, when delay is zero, the signal of emg and marker almost
% moves at the same time (I checked it by plotting both signals)
size_delay_between_marker_and_emg = 0;
%=========================================================================%


% name of csv folder to extract
name_csv_folder = 'csv_2_without_filleverything';

% name of emg folder to extract
name_emg_folder = 'emg';
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));

% path of code, which 
path_code = fileparts(fullfile(cd));
path_DB = fullfile(path_code,'DB');
path_DB_raw = fullfile(path_DB,name_DB_raw);
path_DB_process = fullfile(path_DB,name_DB_process);
%-------------------------------------------------------------------------%


%-------------------------add functions-----------------------------------%
addpath(genpath(fullfile(path_research,'_toolbox')));
addpath(genpath(fullfile(cd,'functions'))); % add path for functions
%-------------------------------------------------------------------------%


%-----------------------experiment information----------------------------%
% name and trial
name_trl = {"화남",1,1;"어금니깨물기",1,2;"비웃음(왼쪽)",1,3;"비웃음(오른쪽)",...
    1,4;"눈 세게 감기",1,5;"두려움",1,6;"행복",1,7;"키스",2,1;"무표정",2,2;...
    "슬픔",2,3;"놀람",2,4};
name_fe = name_trl(:,1);
n_fe = length(name_fe);

% read file path of data from raw DB
[name_sub,path_sub] = read_names_of_file_in_folder(fullfile(path_code,...
    'DB',name_DB_raw));

% number of subjects, trials, channels, marker types, 
n_sub = length(name_sub);
n_trl = 20;
n_marker = 28;
n_emg_pair = 3;
n_marker_type = 3;
idx_trg = cell2mat(name_trl(:,2:3));
%-------------------------------------------------------------------------%

%----------------------------paramters------------------------------------%
% set parameters
sf_emg = 2048;
sf_marker = 120;
% cam.delay = 480E-03;
% pairs biploar configuration of electrodes on cheek
idx_emg_comb_right = [1,2;1,3;2,3]; % 오른쪽 전극 조합
idx_emg_comb_left = [10,9;10,8;9,8]; % 왼쪽 전극 조합

% window and window increase sizze
[winsize_marker,wininc_marker] = calculate_window(sf_marker,sf_down,size_overlap,...
    ratio_winsize_by_wininc);
[winsize_emg,wininc_emg] = calculate_window(sf_emg,sf_down,size_overlap,...
    ratio_winsize_by_wininc);

% Bandpassfilter Parameters
n_filter_order = 4;
range_freq_BPF = [20 450];
[b_bpf,a_bpf] = butter(n_filter_order,range_freq_BPF/(sf_emg/2),'bandpass');

% Notchfilter Parameters
range_freq_notch = [58 62];
[b_notch, a_notch] = butter(n_filter_order,range_freq_notch/(sf_emg/2),'stop');
%-------------------------------------------------------------------------%

%----------------------set saving folder----------------------------------%
% folder for saving
name_folder4saving = ...
    sprintf(...
'%s_marker_wsize_%d_winc_%d_emg_wsize_%d_winc_%d_delay_%d',...
    name_DB_raw,winsize_marker,wininc_marker,...
    winsize_emg,wininc_emg,...
    size_delay_between_marker_and_emg);

% path for saving
path_DB_save = make_path_n_retrun_the_path(fullfile(path_DB_process),...
    name_folder4saving);
%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
% get windows from EMG and marker set with each subject and trials
for i_sub= 10 : n_sub
    
% get file path
sub_name = name_sub{i_sub}(5:7); % get subject names
disp(sub_name);

% get path of csv
[name_csv,path_csv] = read_names_of_file_in_folder(...
    fullfile(path_sub{i_sub},name_csv_folder),'*csv');
disp(name_csv);
% get path of bdf
[name_bdf,path_bdf] = read_names_of_file_in_folder(...
    fullfile(path_sub{i_sub},name_emg_folder),'*bdf');
disp(name_bdf);

for i_trl = 10 : n_trl
    
    % read BDF
    out = pop_biosig(path_bdf{i_trl});
    
    % get triggers and make it cell data
    tmp = cell2mat(permute(struct2cell(out.event),[3 1 2]));
    tmp(:,1) = tmp(:,1)-tmp(1,1);
    tmp(:,1) = tmp(:,1)/128;
    
    %check if triggers were properly acquired
    if size(tmp,1) ~= n_fe*2+1 % if it is not
        
         % just load sample files for size
        load(fullfile(path_DB_save,'emg_pair_1','sub_001_trl_001'));
        load(fullfile(path_DB_save,'mark_10','sub_001_trl_001'));
        
        % put NaN data instead for data consistency
        for i = 1  : length(emg_win)
            emg_win{i} = NaN(size(emg_win{1}));
            mark_win{i} = NaN(size(mark_win{1}));
        end
        
        % save NAN data for emg
        for i_comb = 1 : n_emg_pair
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl); 
            path_temp = make_path_n_retrun_the_path(path_DB_save,...
                sprintf('emg_pair_%d',i_comb)); % get folder for saving
            save(fullfile(path_temp,name_file),...
                'emg_win','trg_w','idx_seq_fe');
        end
        
        % save NAN data for marker
        for i_marker = 1 : n_marker
            path_temp = make_path_n_retrun_the_path(path_DB_save,...
                sprintf('mark_%d',i_marker)); % set folder name
            name_file = sprintf('sub_%03d_trl_%03d',...
                i_sub,i_trl); % name for saving
            save(fullfile(path_temp,name_file),'mark_win','trg_w','idx_seq_fe');
        end 
        
        % continue this loop
        continue;
    end
    
    % get trigger latency when marker DB acquasition has started
    lat_trg_onset = tmp(1,2);
    
    % check which triger is correspoing to each FE and get latency
    tmp_emg_trg = tmp(2:end,:);
    Idx_trg_obtained = reshape(tmp_emg_trg(:,1),[2,size(tmp_emg_trg,1)/2])';
    tmp_emg_trg = reshape(tmp_emg_trg(:,2),[2,size(tmp_emg_trg,1)/2])';
    lat_trg = tmp_emg_trg(:,1);
    
    % get sequnece of facial expression in this trial
    [~,idx_in_order] = sortrows(Idx_trg_obtained);    
    tmp_emg_trg = sortrows([idx_in_order,(1:length(idx_in_order))'],1); 
    idx_seq_fe = tmp_emg_trg(:,2); 
    
    % clear temp file
    clear tmp_emg_trg tmp ;
    
    %pairs biploar configuration  bottom poart of VR frame
    for i_comb = 1 : n_emg_pair  
        
        %  bipolar configuration
        emg_bip.RZ= out.data(idx_emg_comb_right(i_comb,1),:) - ...
            out.data(idx_emg_comb_right(i_comb,2),:);
        emg_bip.RF= out.data(4,:) - out.data(5,:);
        emg_bip.LF= out.data(6,:) - out.data(7,:);
        emg_bip.LZ= out.data(idx_emg_comb_left(i_comb,1),:) - ...
            out.data(idx_emg_comb_left(i_comb,2),:);

        % get bipolar channel names
        p_emg.ch_name = fieldnames(emg_bip);

        % struct to double
        emg_bipol = double(cell2mat(struct2cell(emg_bip)))'; clear emg_bip;

        % filtering
        emg_data = filter(b_bpf,a_bpf,emg_bipol); % bandpassfilter
        emg_data = filter(b_notch,a_notch,emg_data); % notchfilter
        
        % use emg data during marker acquasition
        emg_data = emg_data(lat_trg_onset+...
            round(sf_emg*size_delay_between_marker_and_emg):end,:);

        lat_trg_emg = lat_trg-lat_trg_onset+1;% EMG 표정
        %동기화는 DELAY가 없기 때문에, DELAY 계산 필요 없음

        % get windows from EMG
        [emg_win,trg_w] = getWindows(emg_data,winsize_emg,...
            wininc_emg,[],[],lat_trg_emg);

        %-------------------------save------------------------------------%
        % file name to save
        name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl); 
        
        % path temp for saving
        path_temp = make_path_n_retrun_the_path(path_DB_save,...
            sprintf('emg_pair_%d',i_comb)); % get folder for saving
        
        % save it with tigger information
        save(fullfile(path_temp,name_file),'emg_win','trg_w','idx_seq_fe');
        %-----------------------------------------------------------------%
    end
    disp(name_file); % for check code processing

    % marker CSV Read
    [marker_raw ,~,~,n_marker,~,~] = csv2mat(path_csv{i_trl});

    % get rid of first sample
    marker_raw(1,:,:) = [];
    
    % get marker on nose 
    nose_marker = permute(marker_raw(:,2,:),[1 3 2]);
        
    for i_marker = 1 : n_marker
        if i_marker == 2 
            % if nose marker, just use raw nose marker
            mark_v = nose_marker;
        else 
            % substract markers from nose markers
            mark_v = permute(marker_raw(:,i_marker,:),...
                [1 3 2])-nose_marker;
        end

        % get windows of markers
        [mark_win,~] = getWindows(mark_v,...
                winsize_marker,wininc_marker,[],[],[]); % get windows

        %---------------------------save----------------------------------%
        % get path for saving
        path_temp = make_path_n_retrun_the_path(path_DB_save,...
            sprintf('mark_%d',i_marker)); 
        
        % file name
        name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
        
        % save it
        save(fullfile(path_temp,name_file),'mark_win','trg_w','idx_seq_fe');
        %-----------------------------------------------------------------%
    end
end
end
%----------------------------main end-------------------------------------%

