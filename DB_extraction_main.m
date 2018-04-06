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

% memory allocation
cam.d = cell(N_trial,N_marker);
emg.d = cell(N_trial,3);
cam.n_set = cell(N_trial,N_marker);
emg.n_set = cell(N_trial,3);
for i_sub= 1 : N_subject
    sub_name = Sname{i_sub}(end-2:end);

    [c_fname,c_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*csv');
    [b_fname,b_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');

    for i_trl=1: N_trial
        
        % ī�޶� ������ ���� ����ȭ �ٲ��ֱ�
        emg.trg = Trg_all{i_sub,i_trl};
%         cam.trg = round((Trg_all{i_sub,i_trl}(2:end)- Trg_all{i_sub,i_trl}(1)...
%             -round(emg.SR*cam.delay)+1)/(emg.SR/cam.SR)); % round(emg.SR*cam.delay) ī�޶� delay ���ֱ�
        cam.trg = round((Trg_all{i_sub,i_trl}(2:end)- Trg_all{i_sub,i_trl}(1)...
            +1)/(emg.SR/cam.SR)); % round(emg.SR*cam.delay) ī�޶� delay ���ֱ�

        
        % marker CSV Read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.csv'];
        [Marker_Data ,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(fname);
        
        % ī�޶� ù��° ������ ������(��¥ ������)
        Marker_Data(1,:,:) = [];
%         plot3dmtx(Marker_Data)
        % nose ��Ŀ �������� ����
        nose_marker = permute(Marker_Data(:,2,:),[1 3 2]);
        for i_marker = 1 : N_marker
            Labels{i_marker}(1:2) = [];
            mark_nose = nose_marker - permute(Marker_Data(:,i_marker,:),[1 3 2]);
            [az,el,r] = cart2sph(mark_nose(:,1),mark_nose(:,2),mark_nose(:,3));
            mk = [mark_nose(:,1),mark_nose(:,2),mark_nose(:,3),az,el,r];
            % window ���� (���)
            [mark_w ,cam.trg_w] = getmovfilter(mk,cam.winsize,cam.wininc,[],[],cam.trg);
        
            % ����ȭ �ڸ���, ó�� ���� ���� ����
            temp_mark = mark_w(1:cam.trg_w(27),:);
            
            % ������ ����
            cam.d{i_trl,i_marker} = temp_mark;
            
            % Calibration session���� Nomalization
            Max = max(temp_mark(1 : cam.trg_w(6),:));
            Min = min(temp_mark(1 : cam.trg_w(6),:));
            mark_n = (temp_mark-Min)./(Max-Min);
            cam.n_set{i_trl,i_marker} = mark_n;
        end
        
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
            temp = filter(emg.bB,emg.bA,emg_bipol); %% bandpassfilter
            temp = filter(emg.nB,emg.nA,temp); %%notchfilter
            
            % ī�޶� onset���� �ڸ���
            temp = temp(emg.trg(1)+round(emg.SR*cam.delay):end,:);
%             temp = temp(emg.trg(1):end,:);
            emg.trigger = emg.trg(2:end)-emg.trg(1)+1-round(emg.SR*cam.delay);%ī�޶� ��Ŀ�� �����ϰ� delay ����
            
            % window ���� (feature)
            [temp_feat,emg.trg_w] = getEMGfeat(temp,emg.winsize,emg.wininc,[],[],emg.trigger);
            
            % ����ȭ �ڸ���
            temp_feat = temp_feat(1:emg.trg_w(27),:); % ���� ����
            
            % ������ ����
            emg.d{i_trl,i_comb} = temp_feat;
            
            % Calibration session���� Nomalization
            Max = max(temp_feat(1 : emg.trg_w(6),:));
            Min = min(temp_feat(1 : emg.trg_w(6),:));
            feat_n = (temp_feat-Min)./(Max-Min);
            fprintf('Length of maker : %d\nLength of EMG : %d\n ',...
                length(mark_n),length(feat_n));
            emg.n_set{i_trl,i_comb} = feat_n;
        end
        % ī�޶� ��Ŀ�� EMG�� ������ �������� �ľ��ϱ� ���� plot ����
        figure;
        plot(mark_n(:,1)); hold on; plot(feat_n(:,1));
        h=gcf;
        h.Position = [1 41 1920 962];
        c = getframe(h);
        cdata{i_trl,1} = c.cdata;
        close(h);
    end
    
    

    
    % DB check
    for i_trl2check = 1 : N_trial
        len_emg = length(emg.n_set{i_trl2check,1});
        len_DB = length(cam.n_set{i_trl2check,1});
        if len_emg > len_DB
            smp2rejt = len_emg - len_DB;
            for i_etd_pos = 1 : 3
                emg.n_set{i_trl2check,i_etd_pos}(end-smp2rejt+1:end,:) = [];
            end
        elseif len_emg < len_DB
            smp2rejt = len_DB - len_emg;
            for i_marker = 1 : N_marker
                cam.n_set{i_trl2check,i_marker}(end-smp2rejt+1,:) = [];
            end
        end
    end
         
    %DB����
    fname = sprintf('sub_%d',i_sub);
    save(fullfile(cd,'DB_normalized',fname),'cam','emg');
    sprintf('it has been done for %dth subject',i_sub)
    %�׸�����
    temp = cell2mat(cdata);
    imwrite(temp,[fname,'.jpg']);
end
% save('marker_set.mat','marker_set','Labels','Sname','-v7.3');


