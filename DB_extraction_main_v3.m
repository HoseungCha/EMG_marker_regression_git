% ��Ŀ ������ csv�� EMG�� window(down-sampling) ���ÿ� �����ϴ� �ڵ�
% �����츦 ������ �� �������� ���� �¾ƾ� �ϱ� ������(�ƴϸ� �ϳ� �������� �߶��
% �ϱ� ������ ���� �ڵ忡 �ۼ�
% ��ǥ�� ���� ��ġ���� �����ϱ� ���ٴ�, w
% Nose �߽����� ��ǥ�� ���� �� ��, xyz �� az,el,r ��� ����

clear; close all; clc

addpath(genpath(fullfile(cd,'functions')));
% read file path of data
[Sname,Spath] = read_names_of_file_in_folder(fullfile(cd,'DB'));

% ���� ����
N_subject = length(Sname);
N_trial = 15;
N_marker = 28;
emg.SR = 2048;
cam.SR = 120;
% cam.delay = 480E-03;
cam.delay = 0; % EMG, marker ������ 
% �Ķ���� ����
% biploar ä��
emg.rc_matrix = [1,2;1,3;2,3]; %% ������ ���� ����
emg.lc_matrix = [10,9;10,8;9,8]; %% ���� ���� ����

% ������ ������ �� ������ ����
overlap_size = 50;
[cam.winsize,cam.wininc] = calculate_window(cam.SR,10,overlap_size);
[emg.winsize,emg.wininc] = calculate_window(emg.SR,10,overlap_size);

% Bandpassfilter Parameters
emg.Fn = emg.SR/2;
emg.filter_order = 4;
emg.BPF_cutoff_Freq = [20 450];
[emg.bB,emg.bA] = butter(emg.filter_order, emg.BPF_cutoff_Freq/emg.Fn,'bandpass');

% Notchfilter Parameters
emg.NOF_Freq = [59.5 60.5];
[emg.nB, emg.nA] = butter(emg.filter_order, emg.NOF_Freq/emg.Fn, 'stop');

% EMG trigger
load(fullfile(cd,'EMG_trigger_ext_code','EMG_trg'));

% ���� ���� ����
Folder_Ances = 'DB_v3';
Path_Ances = make_path_n_retrun_the_path (cd,Folder_Ances);

% EMG DB ���� ���� �����
% temp_folder.emg_img = 'emg_img';
% temp_folder.emg_rms = 'emg_rms_10Hz';
temp_folder.emg_win = 'emg_win_10Hz';
temp_folder.trg_win = 'trg_win_10Hz';
% temp_folder.mark_nose = 'mark_nose';
temp_folder.mark_win = 'mark_win_10Hz';
Folder_parent = struct2cell(temp_folder);
N_foldermake = length(Folder_parent);
clear temp_folder;
for i_folder = 1 : N_foldermake
    Path_parent{i_folder,1} = ...
        make_path_n_retrun_the_path (Path_Ances,Folder_parent{i_folder});
end

% EMG combination ���� �̸� ����
for i = 1 : 3
    temp_folder{i,1} = sprintf('comb_%d',i);
end

% EMG ������ comb1,2,3 �߰�
for i_folder = 1 : 3
    for i = 1 : 3
        Path_child_emg{i_folder,i} = ...
            make_path_n_retrun_the_path (Path_parent{i_folder},...
            temp_folder{i});
    end
end

% Marker ���� �̸� ����
for i = 1 : N_marker
    temp_folder{i,1} = sprintf('mark_%d',i);
end

% Marker ������ mark1,2,3...28 ���� �߰�
i_folder_count = 0;
for i_folder = 3
    i_folder_count = i_folder_count + 1;
    for i = 1 : N_marker
        Path_child_mark{i_folder_count,i} = ...
            make_path_n_retrun_the_path (Path_parent{i_folder},...
            temp_folder{i});
    end
end
clear temp_folder;


for i_sub= 1 : N_subject
    sub_name = Sname{i_sub}(end-2:end);
    
    [c_fname,c_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*csv');
    [b_fname,b_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');
    
    for i_trl = 1 : N_trial
        % EMG ����ȭ �������� �����Ͽ� ���߱�
        emg.trg = Trg_all{i_sub,i_trl};
        
        % EMG BDF read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.bdf'];
        OUT = pop_biosig(fname);
        
        % EMG channel ���� ���
        for i_comb = 1 : 3
            % channel bipolar configuratino
            emg_bip.RZ= OUT.data(emg.rc_matrix(i_comb,1),:) - OUT.data(emg.rc_matrix(i_comb,2),:);
            emg_bip.RF= OUT.data(4,:) - OUT.data(5,:);
            emg_bip.LF= OUT.data(6,:) - OUT.data(7,:);
            emg_bip.LZ= OUT.data(emg.lc_matrix(i_comb,1),:) - OUT.data(emg.lc_matrix(i_comb,2),:);
            
            % bipolar channel �̸� list
            emg.ch_name = fieldnames(emg_bip);
            
            % �����ͷ� �ٲ��ֱ�
            emg_bipol = double(cell2mat(struct2cell(emg_bip)))';
            
            % filtering
            emg_data = filter(emg.bB,emg.bA,emg_bipol); %% bandpassfilter
            emg_data = filter(emg.nB,emg.nA,emg_data); %%notchfilter
            
            % ī�޶� onset���� �ڸ���
            emg_data = emg_data(emg.trg(1)+round(emg.SR*cam.delay):end,:);
            % �̷��� �ϴ� ������, Motive���� ���� ��ư�� ������ ��
            % ī�޶� �����ʹ� �ٷ� �����Ǵµ� ����, EMG ����ȭ�� ������ DELAY ��
            % �����Ǳ� ������
            emg.trigger = emg.trg(2:end)-emg.trg(1)+1;
            % EMG ǥ�� ����ȭ�� DELAY�� ���� ������, DELAY ��� �ʿ� ����
            
            % DB�� ����ȭ �ڸ��� �;��� ����. ���� �ܾ� �� ǥ�� ���� �м� �ϱ� ���ؼ���
            % emg.trg_w(27)�� �������� �ڸ��� ��
            
            % window ����
            [emg_win,trg_w] = getWindows(emg_data,emg.winsize,emg.wininc,[],[],emg.trigger);
            fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % window�� ���е� trigger ����
            fname_path = fullfile(Path_parent{2},fname);
            save(fname_path,'trg_w')
            
            % window���� ����� DB ����
            fname_path = fullfile(Path_child_emg{1,i_comb},fname);
            save(fname_path,'emg_win');
        end
        disp(fname);
        
        % marker CSV Read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.csv'];
        [Marker_Data ,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(fname);
        
        % ī�޶� ù��° ������ ������(��¥ ������)
        Marker_Data(1,:,:) = [];
        % nose ��Ŀ �������� ����
        nose_marker = permute(Marker_Data(:,2,:),[1 3 2]);
        for i_marker = 1 : NMarkers
            % marker nose�������� ����
            mark_nose = nose_marker - permute(Marker_Data(:,i_marker,:),[1 3 2]);
            [az,el,r] = cart2sph(mark_nose(:,1),mark_nose(:,2),mark_nose(:,3));
            mk_data = [mark_nose(:,1),mark_nose(:,2),mark_nose(:,3),az,el,r];
            mk.raw = mk_data;
            mk.d1 = cat(1,zeros(1,6),diff(mk_data,1,1));
            mk.d2 = cat(1,zeros(2,6),diff(mk_data,2,1));            
            
            % window ���� (���)
            mk_cell = struct2cell(mk);
            name_mk = fieldnames(mk);
            for i = 1 : 3
            [mark_win,~] = getWindows(mk_cell{i},cam.winsize,cam.wininc,[],[],[]);
%             mark_win = getmovfilter(mk,cam.winsize,cam.wininc,[],[]);
            
            % ������� ���ļ� ���� (��Ŀ ���� ���� ����)
            fname = sprintf('sub_%03d_trl_%03d_%s',i_sub,i_trl,name_mk{i});
            fname_path = fullfile(Path_child_mark{1,i_marker},fname);
            save(fname_path,'mark_win');
            end
        end
        
        % Nose �ڸ����� ���� x,y,z ���� �־���
%         fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
%         [mark_nose_w,~] = getWindows(nose_marker,cam.winsize,cam.wininc,[],[],[]);
% %         mark_nose_w = getmovfilter(nose_marker,cam.winsize,cam.wininc,[],[]);
%         save(fullfile( Path_parent{5},fname),'mark_nose_w');
        
        % ī�޶� ��Ŀ�� EMG�� ������ �������� �ľ��ϱ� ���� plot ����
%         for i=1:trg_w(27)
%             rms_v(i,:) = rms(emg_win{i});
%             med_v(i,:) = mean(mark_win{i});
%         end
%         figure;
%         plot(zscore(med_v(:,6))); hold on; plot(zscore(rms_v(:,1)));
%         hold on;
%         stem(trg_w,ones(length(trg_w),1))
%         h=gcf;
%         h.Position = [1 41 1920 962];
%         c = getframe(h);
%         cdata =c.cdata;
%         fig_name = sprintf('sub_%d_trl_%d.jpg', i_sub, i_trl); % �м� ��� ǥ��
%         close(h);
%         imwrite(cdata,fullfile(cd,'DB_v2','�׸�',fig_name));
    end
end

% load('G:\CHS\DB_v3\mark_win_10Hz\mark_12\sub_001_trl_001_raw.mat')
% load('G:\CHS\DB_v3\trg_win_10Hz\sub_001_trl_001.mat')
% load('G:\CHS\DB_v3\emg_win_10Hz\comb_1\sub_001_trl_001.mat')
% for i=1:trg_w(27)
%     rms_v(i,:) = rms(emg_win{i});
%     med_v(i,:) = mean(mark_win{i});
% end
% figure;
% plot(zscore(med_v(:,6))); hold on; plot(zscore(rms_v(:,1)));
% hold on;
% stem(trg_w,ones(length(trg_w),1))

