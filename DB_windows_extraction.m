%--------------------------------------------------------------------------
% ��Ŀ ������ csv�� EMG�� windows�� �����ϴ� �ڵ�
% �����츦 ������ �� �������� ���� �¾ƾ� �ϱ� ������(�ƴϸ� �ϳ� �������� �߶��
% �ϱ� ������ ���� �ڵ忡 �ۼ�
% ��ǥ�� ���� ��ġ���� �����ϱ� ���ٴ�,
% Nose �߽����� ��ǥ�� ���� �� ��, xyz �� az,el,r ��� ����
% EMG marker regression code processs
% 1: DB_windows_extraion.m %%%%%current code%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2: Label_markers_from_windows.m
% 3: Feat_extraction_from_raw_window.m
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
[Sname,Spath] = read_names_of_file_in_folder(fullfile(parentdir,'DB','DB_raw'));

%% experiment information
N_subject = length(Sname);
N_trial = 15;
N_marker = 28;

%% set parameters
p_emg.SR = 2048;
p_cam.SR = 120;
% cam.delay = 480E-03;
p_cam.delay = 0; % ������ 480E-03 ������ delay�� ������ ����-> EMG,marker ����
% pairs biploar configuration of electrodes on cheek
p_emg.rc_matrix = [1,2;1,3;2,3]; % ������ ���� ����
p_emg.lc_matrix = [10,9;10,8;9,8]; % ���� ���� ����

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
p_emg.NOF_Freq = [59.5 60.5];
[p_emg.nB, p_emg.nA] = butter(p_emg.filter_order, p_emg.NOF_Freq/p_emg.Fn, 'stop');

% get EMG triggers information
% which was proccessed by code in folder (\code_EMG_trigger_extraction)
load(fullfile(cd,'code_EMG_trigger_extraction','EMG_trg'));

% set saving folder for windows
Folder_Ances = sprintf('windows_ds_%dHz_ovsize_%d_delay_%d',SR_down,overlap_size,p_cam.delay);
path_ances = make_path_n_retrun_the_path(fullfile(parentdir,'DB',...
    'DB_processed'),Folder_Ances);

%% get windows from EMG and marker set with each subject and trials
for i_sub= 1 : N_subject
%% get file path
sub_name = Sname{i_sub}(5:7); % get subject names
% get path of csv
[c_fname,c_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*csv');
% get path of bdf
[b_fname,b_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');

for i_trl = 1 : N_trial
    %% get triggers of EMG corresponding to each subject and trial
    p_emg.trg = Trg_all{i_sub,i_trl};

    %% read BDF
    fname = [Spath{i_sub},'\',num2str(i_trl),'.bdf'];
    OUT = pop_biosig(fname);

    for i_comb = 1 : 3  %pairs biploar configuration of electrodes on cheek
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
        emg_data = emg_data(p_emg.trg(1)+...
            round(p_emg.SR*p_cam.delay):end,:);% �̷��� �ϴ� ������,
        %Motive���� ���� ��ư�� ������ ��ī�޶� �����ʹ� �ٷ� �����Ǵµ� ����,
        %EMG ����ȭ�� ������ DELAY �� �����Ǳ� ������
        %(delay�� ������ ���(0��) EMG�� marker�� delay�� �������� ����
        % �������� ���� ��� �쿬�� EMG activation�� ��Ŀ ������ ���ÿ� �Ͼ�� ����
        % �׸��� ���� Ȯ��

        p_emg.trigger = p_emg.trg(2:end)-p_emg.trg(1)+1;% EMG ǥ��
        %����ȭ�� DELAY�� ���� ������, DELAY ��� �ʿ� ����

        %% get windows from EMG
        [emg_win,trg_w] = getWindows(emg_data,p_emg.winsize,...
            p_emg.wininc,[],[],p_emg.trigger);

        % get parts of facial expression task
        emg_win = emg_win(1:trg_w(27));

        %% save
        fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl); % file name to save
        path_temp = make_path_n_retrun_the_path(path_ances,...
            sprintf('emg_pair_%d',i_comb)); % get folder for saving
        save(fullfile(path_temp,fname),'emg_win','trg_w');
    end
    disp(fname); % for check code processing

    %% marker CSV Read
    fname = [Spath{i_sub},'\',num2str(i_trl),'.csv'];
    [Marker_Data ,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(fname);

    %% ī�޶� ù��° ������ ������(��¥ ������)
    Marker_Data(1,:,:) = [];
    %% nose ��Ŀ �������� ����
    nose_marker = permute(Marker_Data(:,2,:),[1 3 2]);
    for i_marker = 1 : NMarkers
        %% get relative marker values 
        if i_marker == 2 % marker�� nose�� ���  ������ ���� �׳� �־���
            mark_nose = nose_marker;
        else % marker�� nose�� �ƴ� ���  ����
            mark_nose = nose_marker - permute(Marker_Data(:,i_marker,:),[1 3 2]);
        end
        [az,el,r] = cart2sph(mark_nose(:,1),mark_nose(:,2),mark_nose(:,3));
        mk_data = [mark_nose(:,1),mark_nose(:,2),mark_nose(:,3),az,el,r];
        mk.raw = mk_data;
        mk.d1 = cat(1,zeros(1,6),diff(mk_data,1,1)); % 1st order differentiation
        mk.d2 = cat(1,zeros(2,6),diff(mk_data,2,1)); % 2nd order differentiation

        %% window ����
        mk_cell = struct2cell(mk);
        name_mk = fieldnames(mk);
        for i_mktype = 1 : 3
            [mark_win,~] = getWindows(mk_cell{i_mktype},...
                p_cam.winsize,p_cam.wininc,[],[],[]); % get windows

            %% get parts of facial expression task
            mark_win = mark_win(1:trg_w(27));

            %% save
            path_temp = make_path_n_retrun_the_path(path_ances,...
                sprintf('mark_%d',i_marker)); % set folder name
            fname = sprintf('sub_%03d_trl_%03d_%s',...
                i_sub,i_trl,name_mk{i_mktype}); % name for saving
            save(fullfile(path_temp,fname),'mark_win','trg_w');
        end
    end
end
end

