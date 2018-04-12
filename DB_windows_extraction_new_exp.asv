%--------------------------------------------------------------------------
% this code is for new expreimnet(Myoexpression)
% 마커 데이터 csv와 EMG의 windows를 추출하는 코드
% 윈도우를 추출할 때 데이터의 수가 맞아야 하기 떄문에(아니면 하나 기준으로 잘라야
% 하기 때문에 같은 코드에 작성
% Nose 중심으로 좌표를 추출 한 후, xyz 및 az,el,r 모두 추출
% EMG marker regression code processs
% 1: DB_windows_extraion.m %%%%%current code%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%% prepare DB and functions
parentdir=fileparts(pwd); % parent path which has DB files
addpath(genpath(fullfile(cd,'functions'))); % add path for functions

%% read file path of data from raw DB
[Sname,Spath] = read_names_of_file_in_folder(fullfile(parentdir,'DB','DB_raw2'));

%% experiment information
N_subject = length(Sname);
N_trial = 20;
N_marker = 28;
N_emgpair = 3;
Name_Trg = {"화남",1,1;"어금니깨물기",1,2;"비웃음(왼쪽)",1,3;"비웃음(오른쪽)",1,4;"눈 세게 감기",1,5;"두려움",1,6;"행복",1,7;"키스",2,1;"무표정",2,2;"슬픔",2,3;"놀람",2,4};
Name_FE = Name_Trg(:,1);
N_FE = length(Name_FE);
Idx_trg = cell2mat(Name_Trg(:,2:3));
%% set parameters
p_emg.SR = 2048;
p_cam.SR = 120;
% cam.delay = 480E-03;
p_cam.delay = 0; % 원래는 480E-03 정도의 delay가 있지만 무시-> EMG,marker 맞춤
% pairs biploar configuration of electrodes on cheek
p_emg.rc_matrix = [1,2;1,3;2,3]; % 오른쪽 전극 조합
p_emg.lc_matrix = [10,9;10,8;9,8]; % 왼쪽 전극 조합

% set window size and overlap size
overlap_size = 50;
SR_down = 10;
[p_cam.winsize,p_cam.wininc] = calculate_window(p_cam.SR,SR_down,overlap_size);
[p_emg.winsize,p_emg.wininc] = calculate_window(p_emg.SR,SR_down,overlap_size);

% Bandpassfilter Parameters
p_emg.Fn = p_emg.SR/2;
p_emg.filter_order = 4;
p_emg.BPF_cutoff_Freq = [20 450];
[p_emg.bB,p_emg.bA] = butter(p_emg.filter_order, p_emg.BPF_cutoff_Freq/p_emg.Fn,'bandpass');

% Notchfilter Parameters
p_emg.NOF_Freq = [58 62];
[p_emg.nB, p_emg.nA] = butter(p_emg.filter_order, p_emg.NOF_Freq/p_emg.Fn, 'stop');

% get EMG triggers information
% which was proccessed by code in folder (\code_EMG_trigger_extraction)
% load(fullfile(cd,'code_EMG_trigger_extraction','EMG_trg'));

% set saving folder for windows
Folder_Ances = sprintf('windows_ds_%dHz_ovsize_%d_delay_%d',SR_down,overlap_size,p_cam.delay);
path_ances = make_path_n_retrun_the_path(fullfile(parentdir,'DB',...
    'DB_processed2'),Folder_Ances);

%% get windows from EMG and marker set with each subject and trials
for i_sub= 1 : N_subject
%% get file path
sub_name = Sname{i_sub}(5:7); % get subject names
% get path of csv
[~,path_csv] = read_names_of_file_in_folder(Spath{i_sub},'*csv');
% get path of bdf
[~,path_bdf] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');

for i_trl = 1 : N_trial
    %% read BDF
    OUT = pop_biosig(path_bdf{i_trl});
    %% get triggers of EMG corresponding to each subject and trial
    tmp = cell2mat(permute(struct2cell(OUT.event),[3 1 2]));
    tmp(:,1) = tmp(:,1)-tmp(1,1);
    tmp(:,1) = tmp(:,1)/128;
    lat_trg_onset = tmp(1,2);
    %% chech which triger is correspoing to each FE and get latency
    tmp_emg_trg = tmp(2:end,:);
    Idx_trg_obtained = reshape(tmp_emg_trg(:,1),[2,size(tmp_emg_trg,1)/2])';
    tmp_emg_trg = reshape(tmp_emg_trg(:,2),[2,size(tmp_emg_trg,1)/2])';
    lat_trg = tmp_emg_trg(:,1);
    [~,idx_in_order] = sortrows(Idx_trg_obtained);
    % [idx_in_order,(1:N_FaExp)'], idices in order corresponding to
    % emotion label
    tmp_emg_trg = sortrows([idx_in_order,(1:length(idx_in_order))'],1); 
    idx_seq_FE = tmp_emg_trg(:,2); clear tmp_emg_trg tmp ;
    
    for i_comb = 1 : N_emgpair  %pairs biploar configuration of electrodes on cheek
        %%  bipolar configuration
        emg_bip.RZ= OUT.data(p_emg.rc_matrix(i_comb,1),:) - ...
            OUT.data(p_emg.rc_matrix(i_comb,2),:);
        emg_bip.RF= OUT.data(4,:) - OUT.data(5,:);
        emg_bip.LF= OUT.data(6,:) - OUT.data(7,:);
        emg_bip.LZ= OUT.data(p_emg.lc_matrix(i_comb,1),:) - ...
            OUT.data(p_emg.lc_matrix(i_comb,2),:);

        %% get bipolar channel names
        p_emg.ch_name = fieldnames(emg_bip);

        %% struct to double
        emg_bipol = double(cell2mat(struct2cell(emg_bip)))'; clear emg_bip;

        %% filtering
        emg_data = filter(p_emg.bB,p_emg.bA,emg_bipol); % bandpassfilter
        emg_data = filter(p_emg.nB,p_emg.nA,emg_data); % notchfilter

        %% reset triggers using trigger of camera onset
        %camare is turned on during EMG acquasition
        emg_data = emg_data(lat_trg_onset+...
            round(p_emg.SR*p_cam.delay):end,:);% 이렇게 하는 이유는,
        %Motive에서 시작 버튼을 눌렀을 때카메라 데이터는 바로 측정되는데 비해,
        %EMG 동기화는 일정한 DELAY 후 측정되기 때문임
        %(delay를 무시할 경우(0값) EMG와 marker의 delay를 고려하지 않음
        % 고려하지 않을 경우 우연히 EMG activation과 마커 움직임 동시에 일어나는 것을
        % 그림을 통해 확인

        p_emg.trigger = lat_trg-lat_trg_onset+1;% EMG 표정
        %동기화는 DELAY가 없기 때문에, DELAY 계산 필요 없음

        %% get windows from EMG
        [emg_win,trg_w] = getWindows(emg_data,p_emg.winsize,...
            p_emg.wininc,[],[],p_emg.trigger);

        % get parts of facial expression task
%         emg_win = emg_win(1:trg_w(27));

        %% save
        fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl); % file name to save
        path_temp = make_path_n_retrun_the_path(path_ances,...
            sprintf('emg_pair_%d',i_comb)); % get folder for saving
        save(fullfile(path_temp,fname),'emg_win','trg_w','idx_seq_FE');
    end
    disp(fname); % for check code processing

    %% marker CSV Read
%     fname = [Spath{i_sub},'\',num2str(i_trl),'.csv'];
    [Marker_Data ,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(path_csv{i_trl});

    %% 카메라 첫번째 샘플을 없애줌(가짜 데이터)
    Marker_Data(1,:,:) = [];
    %% nose 마커 기준으로 뺴줌
    nose_marker = permute(Marker_Data(:,2,:),[1 3 2]);
    for i_marker = 1 : NMarkers
        %% get relative marker values 
        if i_marker == 2 % marker가 nose일 경우  빼주지 말고 그냥 넣어줌
            mark_nose = nose_marker;
        else % marker가 nose가 아닐 경우  빼줌
            mark_nose = nose_marker - permute(Marker_Data(:,i_marker,:),[1 3 2]);
        end
        [az,el,r] = cart2sph(mark_nose(:,1),mark_nose(:,2),mark_nose(:,3));
        mk_data = [mark_nose(:,1),mark_nose(:,2),mark_nose(:,3),az,el,r];
        mk.raw = mk_data;
        mk.d1 = cat(1,zeros(1,6),diff(mk_data,1,1)); % 1st order differentiation
        mk.d2 = cat(1,zeros(2,6),diff(mk_data,2,1)); % 2nd order differentiation

        %% window extraction
        mk_cell = struct2cell(mk);
        name_mk = fieldnames(mk);
        for i_mktype = 1 : 3
            [mark_win,~] = getWindows(mk_cell{i_mktype},...
                p_cam.winsize,p_cam.wininc,[],[],[]); % get windows
            %% save
            path_temp = make_path_n_retrun_the_path(path_ances,...
                sprintf('mark_%d',i_marker)); % set folder name
            fname = sprintf('sub_%03d_trl_%03d_%s',...
                i_sub,i_trl,name_mk{i_mktype}); % name for saving
            save(fullfile(path_temp,fname),'mark_win','trg_w','idx_seq_FE');
        end
    end
end
end

%% to confim the DB was extracted well
load(fullfile(path_ances,'emg_pair_1','sub_001_trl_001'));
load(fullfile(path_ances,'mark_10','sub_001_trl_001_raw'));
% simple feat extraction
N_win = length(mark_win);
emg_rms = zeros(N_win,4);
mark_median = zeros(N_win,6);
for i_win = 1 : length(mark_win)
    emg_rms(i_win,:) = rms(emg_win{i_win});
    mark_median(i_win,:) = median(mark_win{i_win});
end
plot(zscore(emg_rms(:,1)));hold on;plot(zscore(mark_median(:,1)))
hold on;
stem(trg_w,ones(N_FE,1))
