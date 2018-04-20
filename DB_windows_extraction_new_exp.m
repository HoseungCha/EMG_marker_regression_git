%--------------------------------------------------------------------------
% this code is for new expreimnet(Myoexpression)
% ��Ŀ ������ csv�� EMG�� windows�� �����ϴ� �ڵ�
% �����츦 ������ �� �������� ���� �¾ƾ� �ϱ� ������(�ƴϸ� �ϳ� �������� �߶��
% �ϱ� ������ ���� �ڵ忡 �ۼ�
% Nose �߽����� ��ǥ�� ���� �� ��, xyz �� az,el,r ��� ����
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
% get toolbox
addpath(genpath(fullfile(fileparts(fileparts(fileparts(cd))),'_toolbox')));
path_parent=fileparts(cd); % parent path which has DB files
% get function
addpath(genpath(fullfile(cd,'functions'))); % add path for functions
%% read file path of data from raw DB
[name_sub,path_sub] = read_names_of_file_in_folder(fullfile(path_parent,'DB','DB_raw2'));

%% experiment information
n_sub = length(name_sub);
n_trl = 20;
n_marker = 28;
n_emg_pair = 3;
name_trl = {"ȭ��",1,1;"��ݴϱ�����",1,2;"�����(����)",1,3;"�����(������)",...
    1,4;"�� ���� ����",1,5;"�η���",1,6;"�ູ",1,7;"Ű��",2,1;"��ǥ��",2,2;...
    "����",2,3;"���",2,4};
name_FE = name_trl(:,1);
n_FE = length(name_FE);
idx_trg = cell2mat(name_trl(:,2:3));
%% set parameters
p_emg.SR = 2048;
p_cam.SR = 120;
% cam.delay = 480E-03;
p_cam.delay = 0; % ������ 480E-03 ������ delay�� ������ ����-> EMG,marker ����
% pairs biploar configuration of electrodes on cheek
p_emg.rc_matrix = [1,2;1,3;2,3]; % ������ ���� ����
p_emg.lc_matrix = [10,9;10,8;9,8]; % ���� ���� ����

% set window size and overlap size
overlap_size = 0;
sr_down = 120;
[p_cam.winsize,p_cam.wininc] = calculate_window(p_cam.SR,sr_down,overlap_size,1);
[p_emg.winsize,p_emg.wininc] = calculate_window(p_emg.SR,sr_down,overlap_size,1);

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
name_folder4saving = sprintf('windows_ds_%dHz_ovsize_%d_delay_%d',sr_down,overlap_size,p_cam.delay);
path_DB_process = make_path_n_retrun_the_path(fullfile(path_parent,'DB',...
    'DB_processed2'),name_folder4saving);

%% get windows from EMG and marker set with each subject and trials
% for i_sub= 5
for i_sub= 1 : n_sub
%% get file path
sub_name = name_sub{i_sub}(5:7); % get subject names
% get path of csv
[~,path_csv] = read_names_of_file_in_folder(path_sub{i_sub},'*csv');
% get path of bdf
[~,path_bdf] = read_names_of_file_in_folder(path_sub{i_sub},'*bdf');

for i_trl = 1 : n_trl
% for i_trl = 10
    %% read BDF
    out = pop_biosig(path_bdf{i_trl});
    %% get triggers of EMG corresponding to each subject and trial
    tmp = cell2mat(permute(struct2cell(out.event),[3 1 2]));
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
    
    for i_comb = 1 : n_emg_pair  %pairs biploar configuration of electrodes on cheek
        %%  bipolar configuration
        emg_bip.RZ= out.data(p_emg.rc_matrix(i_comb,1),:) - ...
            out.data(p_emg.rc_matrix(i_comb,2),:);
        emg_bip.RF= out.data(4,:) - out.data(5,:);
        emg_bip.LF= out.data(6,:) - out.data(7,:);
        emg_bip.LZ= out.data(p_emg.lc_matrix(i_comb,1),:) - ...
            out.data(p_emg.lc_matrix(i_comb,2),:);

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
            round(p_emg.SR*p_cam.delay):end,:);% �̷��� �ϴ� ������,
        %Motive���� ���� ��ư�� ������ ��ī�޶� �����ʹ� �ٷ� �����Ǵµ� ����,
        %EMG ����ȭ�� ������ DELAY �� �����Ǳ� ������
        %(delay�� ������ ���(0��) EMG�� marker�� delay�� ������� ����
        % ������� ���� ��� �쿬�� EMG activation�� ��Ŀ ������ ���ÿ� �Ͼ�� ����
        % �׸��� ���� Ȯ��

        p_emg.trigger = lat_trg-lat_trg_onset+1;% EMG ǥ��
        %����ȭ�� DELAY�� ���� ������, DELAY ��� �ʿ� ����

        %% get windows from EMG
        [emg_win,trg_w] = getWindows(emg_data,p_emg.winsize,...
            p_emg.wininc,[],[],p_emg.trigger);

        % get parts of facial expression task
%         emg_win = emg_win(1:trg_w(27));

        %% save
        name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl); % file name to save
        path_temp = make_path_n_retrun_the_path(path_DB_process,...
            sprintf('emg_pair_%d',i_comb)); % get folder for saving
        save(fullfile(path_temp,name_file),'emg_win','trg_w','idx_seq_FE');
    end
    disp(name_file); % for check code processing

    %% marker CSV Read
%     fname = [Spath{i_sub},'\',num2str(i_trl),'.csv'];
    [marker_raw ,~,~,n_marker,~,~] = csv2mat(path_csv{i_trl});

    %% ī�޶� ù��° ������ ������(��¥ ������)
    marker_raw(1,:,:) = [];
    %% nose ��Ŀ �������� ����
    nose_marker = permute(marker_raw(:,2,:),[1 3 2]);
    for i_marker = 1 : n_marker
%     for i_marker = 1:
        %% get relative marker values 
        if i_marker == 2 % marker�� nose�� ���  ������ ���� �׳� �־���
            mark_nose = nose_marker;
        else % marker�� nose�� �ƴ� ���  ����
            mark_nose = nose_marker - permute(marker_raw(:,i_marker,:),[1 3 2]);
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
            path_temp = make_path_n_retrun_the_path(path_DB_process,...
                sprintf('mark_%d',i_marker)); % set folder name
            name_file = sprintf('sub_%03d_trl_%03d_%s',...
                i_sub,i_trl,name_mk{i_mktype}); % name for saving
            save(fullfile(path_temp,name_file),'mark_win','trg_w','idx_seq_FE');
        end
    end
end
end

%% to confim the DB was extracted well
load(fullfile(path_DB_process,'emg_pair_1','sub_001_trl_001'));
load(fullfile(path_DB_process,'mark_10','sub_001_trl_001_raw'));
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
stem(trg_w,ones(n_FE,1))
