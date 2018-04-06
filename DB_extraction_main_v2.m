% ��Ŀ ������ csv�� EMG ���ÿ� �����ϴ� �ڵ�
% �����츦 ������ �� �������� ���� �¾ƾ� �ϱ� ������(�ƴϸ� �ϳ� �������� �߶��
% �ϱ� ������ ���� �ڵ忡 �ۼ�
% 1.central_down_lip  ^2.central_nose^  3.central_upper_lip  4.head1  5.head2  6. head3  7.head4  8.jaw
% 9.left_central_lip  10.left_cheek  11.left_dimple  12.left_down_eye  13.left_down_lip  14.left_eyebrow_inside
% 15. left_eyebrow_outside  16.left_nose  17.left_upper_eye  18.left_upper_lip  19.right_central_lip
% 20.right_cheek  21.right_dimple  22.right_down_eye  23.right_down_lip  24.right_eyebrow_inside
% 25.right_eyebrow_outside  26.right_nose  27.right_upper_eye  28.right_upper_lip
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
cam.delay = 480E-03;

% �Ķ���� ����
% biploar ä��
emg.rc_matrix = [1,2;1,3;2,3]; %% ������ ���� ����
emg.lc_matrix = [10,9;10,8;9,8]; %% ���� ���� ����

% ������ ������ �� ������ ����
overlap_size = 50;
[cam.winsize,cam.wininc] = calculate_window(cam.SR,5,overlap_size);
[emg.winsize,emg.wininc] = calculate_window(emg.SR,5,overlap_size);

% emg.winsize_spec = 0.5*2048;

% [emg.winsize,emg.wininc] = calculate_window(emg.SR,10,overlap_size);

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

% memory allocation
mark_win = cell(N_subject,N_trial,N_marker);
emg_win = cell(N_subject,N_trial,3);
emg_rms = cell(N_subject,N_trial,3);
emg_img = cell(N_subject,N_trial,3);

% DB ���� ���� �����
mkdir(fullfile(cd,'DB_v2'));

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
        for i_comb = 1
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
            temp = filter(emg.bB,emg.bA,emg_bipol); %% bandpassfilter
            temp = filter(emg.nB,emg.nA,temp); %%notchfilter
            
            % ī�޶� onset���� �ڸ���
            temp = temp(emg.trg(1)+round(emg.SR*cam.delay):end,:);
            % �̷��� �ϴ� ������, Motive���� ���� ��ư�� ������ �� 
            % ī�޶� �����ʹ� �ٷ� �����Ǵµ� ����, EMG ����ȭ�� ������ DELAY ��
            % �����Ǳ� ������
            emg.trigger = emg.trg(2:end)-emg.trg(1)+1;
            % EMG ǥ�� ����ȭ�� DELAY�� ���� ������, DELAY ��� �ʿ� ����
            
            % Window �����Ͽ�, RMS ��� ��, ����ȭ�� ���Ե� window ���
            [temp_feat,emg.trg_w] = getEMGfeat(temp,emg.winsize,emg.wininc,[],[],emg.trigger);
            tic;
            % EMG window rawdata �� spectrum IMG���� ����.
            [window_DB,spec] = getEMG_spectro(temp,emg.winsize,emg.wininc,[],[]);
            toc;
            
            % DB�� ����ȭ �ڸ��� �;��� ����. ���� �ܾ� �� ǥ�� ���� �м� �ϱ� ���ؼ���
            % emg.trg_w(27)�� �������� �ڸ��� ��
            
            % EMG ������ ����
            
            emg_win{i_sub,i_trl,i_comb} = window_DB;
            emg_rms{i_sub,i_trl,i_comb} = temp_feat;
            emg_img{i_sub,i_trl,i_comb} = spec;
        end
        
        
        % marker CSV Read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.csv'];
        [Marker_Data ,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(fname);
        
        % ī�޶� ù��° ������ ������(��¥ ������)
        Marker_Data(1,:,:) = [];
        
        % nose ��Ŀ �������� ����
        nose_marker = permute(Marker_Data(:,2,:),[1 3 2]);
        for i_marker = 1 : NMarkers
            Labels{i_marker}(1:2) = [];
            mark_nose = nose_marker - permute(Marker_Data(:,i_marker,:),[1 3 2]);
            [az,el,r] = cart2sph(mark_nose(:,1),mark_nose(:,2),mark_nose(:,3));
            mk = [mark_nose(:,1),mark_nose(:,2),mark_nose(:,3),az,el,r];
            
            % window ���� (���)
            mark_w = getmovfilter(mk,cam.winsize,cam.wininc,[],[]);
            
            % ������ ����
            mark_win{i_sub,i_trl,i_marker} = mark_w;
        end
        % Nose �ڸ����� ���� x,y,z ���� �־���
         mark_win{i_sub,i_trl,i_marker} = nose_marker;
        
        % ī�޶� ��Ŀ�� EMG�� ������ �������� �ľ��ϱ� ���� plot ����
        figure;
        plot(zscore(mark_w(:,6))); hold on; plot(zscore(temp_feat(:,1)));
        hold on;
        stem(emg.trg_w,ones(length(emg.trg_w),1))
        h=gcf;
        h.Position = [1 41 1920 962];
        c = getframe(h);
        cdata =c.cdata;
        fig_name = sprintf('sub_%d_trl_%d.jpg', i_sub, i_trl) % �м� ��� ǥ��
        close(h);
        imwrite(cdata,fullfile(cd,'DB_ver2',fig_name));
    end
end
% save('mark_raw.mat','mark_raw');
% save('marker_set.mat','marker_set','Labels','Sname','-v7.3');


