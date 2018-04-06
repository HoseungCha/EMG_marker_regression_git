% 마커 데이터 csv와 EMG 동시에 추출하는 코드
% 윈도우를 추출할 때 데이터의 수가 맞아야 하기 떄문에(아니면 하나 기준으로 잘라야
% 하기 때문에 같은 코드에 작성
% 1.central_down_lip  ^2.central_nose^  3.central_upper_lip  4.head1  5.head2  6. head3  7.head4  8.jaw
% 9.left_central_lip  10.left_cheek  11.left_dimple  12.left_down_eye  13.left_down_lip  14.left_eyebrow_inside
% 15. left_eyebrow_outside  16.left_nose  17.left_upper_eye  18.left_upper_lip  19.right_central_lip
% 20.right_cheek  21.right_dimple  22.right_down_eye  23.right_down_lip  24.right_eyebrow_inside
% 25.right_eyebrow_outside  26.right_nose  27.right_upper_eye  28.right_upper_lip
% Nose 중심으로 좌표를 추출 한 후, xyz 및 az,el,r 모두 추출

clear; close all; clc

addpath(genpath(fullfile(cd,'functions')));
% read file path of data
[Sname,Spath] = read_names_of_file_in_folder(fullfile(cd,'DB'));

% 실험 정보
N_subject = length(Sname);
N_trial = 15;
N_marker = 28;
emg.SR = 2048;
cam.SR = 120;
cam.delay = 480E-03;
% 파라미터 설정
% biploar 채널 
emg.rc_matrix = [1,2;1,3;2,3]; %% 오른쪽 전극 조합  
emg.lc_matrix = [10,9;10,8;9,8]; %% 왼쪽 전극 조합

% 윈도우 사이즈 및 오버랩 설정
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

    for i_trl = 1 : N_trial
        
        % 카메라 시점에 맞춰 동기화 바꿔주기
        emg.trg = Trg_all{i_sub,i_trl};
%         cam.trg = round((Trg_all{i_sub,i_trl}(2:end)- Trg_all{i_sub,i_trl}(1)...
%             -round(emg.SR*cam.delay)+1)/(emg.SR/cam.SR)); % round(emg.SR*cam.delay) 카메라 delay 뺴주기
        cam.trg = round((Trg_all{i_sub,i_trl}(2:end)- Trg_all{i_sub,i_trl}(1)...
            +1)/round(emg.SR/cam.SR)); % round(emg.SR*cam.delay) 카메라 delay 뺴주기

        
        % marker CSV Read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.csv'];
        [Marker_Data ,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(fname);
        
        % 카메라 첫번째 샘플을 없애줌(가짜 데이터)
        Marker_Data(1,:,:) = [];
        
        % nose 마커 기준으로 뺴줌
        nose_marker = permute(Marker_Data(:,2,:),[1 3 2]);
        for i_marker = 1 : N_marker
%         for i_marker = 15
            Labels{i_marker}(1:2) = [];
            mark_nose = nose_marker - permute(Marker_Data(:,i_marker,:),[1 3 2]);
            [az,el,r] = cart2sph(mark_nose(:,1),mark_nose(:,2),mark_nose(:,3));
            mk = [mark_nose(:,1),mark_nose(:,2),mark_nose(:,3),az,el,r];
            % window 적용 (평균)
            [mark_w ,cam.trg_w] = getmovfilter(mk,cam.winsize,cam.wininc,[],[],cam.trg);
        
            % 동기화 자르기, 처음 부터 교통 까지
            temp_mark = mark_w(1:cam.trg_w(27),:);
            
            % 데이터 저장
            cam.d{i_trl,i_marker} = temp_mark;
            
            % Calibration session에서 Nomalization
            Max = max(temp_mark(1 : cam.trg_w(6),:));
            Min = min(temp_mark(1 : cam.trg_w(6),:));
            mark_n = (temp_mark-Min)./(Max-Min);
            cam.n_set{i_trl,i_marker} = mark_n;
        end
        
        % EMG BDF read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.bdf'];
        OUT = pop_biosig(fname);
        
        % EMG channel 선정 방법
        for i_comb = 1 : 3
            % channel bipolar configuratino
            emg_bip.RZ= OUT.data(emg.rc_matrix(i_comb,1),:) - OUT.data(emg.rc_matrix(i_comb,2),:); 
            emg_bip.RF= OUT.data(4,:) - OUT.data(5,:);
            emg_bip.LF= OUT.data(6,:) - OUT.data(7,:);
            emg_bip.LZ= OUT.data(emg.lc_matrix(i_comb,1),:) - OUT.data(emg.lc_matrix(i_comb,2),:); 
            
            % bipolar channel 이름 list
            emg.ch_name = fieldnames(emg_bip);
            
            % 데이터로 바꿔주기
            emg_bipol = double(cell2mat(struct2cell(emg_bip)))';
        
            % filtering
            temp = filter(emg.bB,emg.bA,emg_bipol); %% bandpassfilter
            temp = filter(emg.nB,emg.nA,temp); %%notchfilter
            
            % 카메라 onset시점 자르기
            temp = temp(emg.trg(1)+round(emg.SR*cam.delay):end,:);
%             temp = temp(emg.trg(1):end,:);
%             emg.trigger = emg.trg(2:end)-emg.trg(1)+1-round(emg.SR*cam.delay);%카메라 마커와 동일하게 delay 빼줌
            emg.trigger = emg.trg(2:end)-emg.trg(1)+1;
            % window 적용 (feature)
            [temp_feat,emg.trg_w] = getEMGfeat(temp,emg.winsize,emg.wininc,[],[],emg.trigger);
            
            % 동기화 자르기
            temp_feat = temp_feat(1:emg.trg_w(27),:); % 교통 까지
            
            % 데이터 저장
            emg.d{i_trl,i_comb} = temp_feat;
            
            % Calibration session에서 Nomalization
            Max = max(temp_feat(1 : emg.trg_w(6),:));
            Min = min(temp_feat(1 : emg.trg_w(6),:));
            feat_n = (temp_feat-Min)./(Max-Min);
           
            emg.n_set{i_trl,i_comb} = feat_n;
        end
        % 카메라 마커와 EMG의 시점이 적절한지 파악하기 위한 plot 저장
        figure;
        
   
        plot(mark_n); hold on; plot(feat_n);
        hold on;
        stem(emg.trg_w,ones(length(emg.trg_w),1))
        h=gcf;
        h.Position = [1 41 1920 962];
        c = getframe(h);
        cdata{i_trl,1} = c.cdata;
        close(h);
        fprintf('sub: %d trl: %d\n', i_sub, i_trl); 
    end
    
    % DB check ( EMG와, Marker간의 길이가 안맞을 경우 
    for i_trl2check = 1 : length(emg.n_set)
        len_emg = length(emg.n_set{i_trl2check,1});
        len_DB = length(cam.n_set{i_trl2check,1});
        if len_emg > len_DB
            smp2rejt = len_emg - len_DB;
            for i_etd_pos = 1 : 3
                emg.n_set{i_trl2check,i_etd_pos}(end-smp2rejt+1:end,:) = [];
                emg.d{i_trl2check,i_etd_pos}(end-smp2rejt+1:end,:) = [];
            end
        elseif len_emg < len_DB
            smp2rejt = len_DB - len_emg;
            for i_marker = 1 : N_marker
                cam.n_set{i_trl2check,i_marker}(end-smp2rejt+1:end,:) = [];
                cam.d{i_trl2check,i_marker}(end-smp2rejt+1:end,:) = [];
            end
        end
        len_emg = length(emg.n_set{i_trl2check,1});
        len_DB = length(cam.n_set{i_trl2check,1});
        if len_emg~=len_DB
            keyboard;
        end
%          fprintf('Length of maker : %d Length of EMG : %d\n ',...
%                 length(emg.n_set{i_trl2check,1}),length(cam.n_set{i_trl2check,i_marker}));
%             fprintf('Length of raw maker : %d Length of raw EMG : %d\n ',...
%                 length(emg.d{i_trl2check,1}),length(cam.d{i_trl2check,i_marker}));
    end
         
    %DB저장
    fname = sprintf('sub_%d',i_sub);
%     save(fullfile(cd,'DB_normalized','feat_4_type_all',fname),'cam','emg');
    save(fullfile(cd,'DB_norm',fname),'cam','emg');
    sprintf('it has been done for %dth subject',i_sub)
    %그림저장
%     temp = cell2mat(cdata);
%     imwrite(temp,[fname,'.jpg']);
end
% save('marker_set.mat','marker_set','Labels','Sname','-v7.3');


