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

% DB 저장 폴더 만들기
mkdir(fullfile(cd,'DB_v2'));

for i_sub= 1 : N_subject
    sub_name = Sname{i_sub}(end-2:end);
    
    [c_fname,c_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*csv');
    [b_fname,b_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');
    
    for i_trl = 1 : N_trial
        % EMG 동기화 기준으로 통일하여 맞추기 
        emg.trg = Trg_all{i_sub,i_trl};


        % EMG BDF read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.bdf'];
        OUT = pop_biosig(fname);
        
        % EMG channel 선정 방법
        for i_comb = 1
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
            % 이렇게 하는 이유는, Motive에서 시작 버튼을 눌렀을 때 
            % 카메라 데이터는 바로 측정되는데 비해, EMG 동기화는 일정한 DELAY 후
            % 측정되기 때문임
            emg.trigger = emg.trg(2:end)-emg.trg(1)+1;
            % EMG 표정 동기화는 DELAY가 없기 때문에, DELAY 계산 필요 없음
            
            % Window 적용하여, RMS 계산 및, 동기화가 포함된 window 계산
            [temp_feat,emg.trg_w] = getEMGfeat(temp,emg.winsize,emg.wininc,[],[],emg.trigger);
            tic;
            % EMG window rawdata 및 spectrum IMG파일 뽑음.
            [window_DB,spec] = getEMG_spectro(temp,emg.winsize,emg.wininc,[],[]);
            toc;
            
            % DB는 동기화 자르는 것없이 얻음. 추후 단어 및 표정 따로 분석 하기 위해서는
            % emg.trg_w(27)을 기준으로 자르면 됨
            
            % EMG 데이터 저장
            
            emg_win{i_sub,i_trl,i_comb} = window_DB;
            emg_rms{i_sub,i_trl,i_comb} = temp_feat;
            emg_img{i_sub,i_trl,i_comb} = spec;
        end
        
        
        % marker CSV Read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.csv'];
        [Marker_Data ,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(fname);
        
        % 카메라 첫번째 샘플을 없애줌(가짜 데이터)
        Marker_Data(1,:,:) = [];
        
        % nose 마커 기준으로 뺴줌
        nose_marker = permute(Marker_Data(:,2,:),[1 3 2]);
        for i_marker = 1 : NMarkers
            Labels{i_marker}(1:2) = [];
            mark_nose = nose_marker - permute(Marker_Data(:,i_marker,:),[1 3 2]);
            [az,el,r] = cart2sph(mark_nose(:,1),mark_nose(:,2),mark_nose(:,3));
            mk = [mark_nose(:,1),mark_nose(:,2),mark_nose(:,3),az,el,r];
            
            % window 적용 (평균)
            mark_w = getmovfilter(mk,cam.winsize,cam.wininc,[],[]);
            
            % 데이터 저장
            mark_win{i_sub,i_trl,i_marker} = mark_w;
        end
        % Nose 자리에는 원래 x,y,z 값을 넣어줌
         mark_win{i_sub,i_trl,i_marker} = nose_marker;
        
        % 카메라 마커와 EMG의 시점이 적절한지 파악하기 위한 plot 저장
        figure;
        plot(zscore(mark_w(:,6))); hold on; plot(zscore(temp_feat(:,1)));
        hold on;
        stem(emg.trg_w,ones(length(emg.trg_w),1))
        h=gcf;
        h.Position = [1 41 1920 962];
        c = getframe(h);
        cdata =c.cdata;
        fig_name = sprintf('sub_%d_trl_%d.jpg', i_sub, i_trl) % 분석 경과 표시
        close(h);
        imwrite(cdata,fullfile(cd,'DB_ver2',fig_name));
    end
end
% save('mark_raw.mat','mark_raw');
% save('marker_set.mat','marker_set','Labels','Sname','-v7.3');


