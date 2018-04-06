% 마커 데이터 csv와 EMG의 window(down-sampling) 동시에 추출하는 코드
% 윈도우를 추출할 때 데이터의 수가 맞아야 하기 떄문에(아니면 하나 기준으로 잘라야
% 하기 때문에 같은 코드에 작성
% 좌표의 절대 위치값은 추정하기 보다는, w
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
% cam.delay = 480E-03;
cam.delay = 0; % EMG, marker 딜레이 
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

% 저장 폴더 설정
Folder_Ances = 'DB_v3';
Path_Ances = make_path_n_retrun_the_path (cd,Folder_Ances);

% EMG DB 저장 폴더 만들기
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

% EMG combination 폴더 이름 생성
for i = 1 : 3
    temp_folder{i,1} = sprintf('comb_%d',i);
end

% EMG 폴더에 comb1,2,3 추가
for i_folder = 1 : 3
    for i = 1 : 3
        Path_child_emg{i_folder,i} = ...
            make_path_n_retrun_the_path (Path_parent{i_folder},...
            temp_folder{i});
    end
end

% Marker 폴더 이름 생성
for i = 1 : N_marker
    temp_folder{i,1} = sprintf('mark_%d',i);
end

% Marker 폴더에 mark1,2,3...28 폴더 추가
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
        % EMG 동기화 기준으로 통일하여 맞추기
        emg.trg = Trg_all{i_sub,i_trl};
        
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
            emg_data = filter(emg.bB,emg.bA,emg_bipol); %% bandpassfilter
            emg_data = filter(emg.nB,emg.nA,emg_data); %%notchfilter
            
            % 카메라 onset시점 자르기
            emg_data = emg_data(emg.trg(1)+round(emg.SR*cam.delay):end,:);
            % 이렇게 하는 이유는, Motive에서 시작 버튼을 눌렀을 때
            % 카메라 데이터는 바로 측정되는데 비해, EMG 동기화는 일정한 DELAY 후
            % 측정되기 때문임
            emg.trigger = emg.trg(2:end)-emg.trg(1)+1;
            % EMG 표정 동기화는 DELAY가 없기 때문에, DELAY 계산 필요 없음
            
            % DB는 동기화 자르는 것없이 얻음. 추후 단어 및 표정 따로 분석 하기 위해서는
            % emg.trg_w(27)을 기준으로 자르면 됨
            
            % window 추출
            [emg_win,trg_w] = getWindows(emg_data,emg.winsize,emg.wininc,[],[],emg.trigger);
            fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % window로 구분된 trigger 저장
            fname_path = fullfile(Path_parent{2},fname);
            save(fname_path,'trg_w')
            
            % window별로 추출된 DB 저방
            fname_path = fullfile(Path_child_emg{1,i_comb},fname);
            save(fname_path,'emg_win');
        end
        disp(fname);
        
        % marker CSV Read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.csv'];
        [Marker_Data ,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(fname);
        
        % 카메라 첫번째 샘플을 없애줌(가짜 데이터)
        Marker_Data(1,:,:) = [];
        % nose 마커 기준으로 뺴줌
        nose_marker = permute(Marker_Data(:,2,:),[1 3 2]);
        for i_marker = 1 : NMarkers
            % marker nose기준으로 빼줌
            mark_nose = nose_marker - permute(Marker_Data(:,i_marker,:),[1 3 2]);
            [az,el,r] = cart2sph(mark_nose(:,1),mark_nose(:,2),mark_nose(:,3));
            mk_data = [mark_nose(:,1),mark_nose(:,2),mark_nose(:,3),az,el,r];
            mk.raw = mk_data;
            mk.d1 = cat(1,zeros(1,6),diff(mk_data,1,1));
            mk.d2 = cat(1,zeros(2,6),diff(mk_data,2,1));            
            
            % window 적용 (평균)
            mk_cell = struct2cell(mk);
            name_mk = fieldnames(mk);
            for i = 1 : 3
            [mark_win,~] = getWindows(mk_cell{i},cam.winsize,cam.wininc,[],[],[]);
%             mark_win = getmovfilter(mk,cam.winsize,cam.wininc,[],[]);
            
            % 윈도우는 합쳐서 저장 (마커 폴더 별로 저장)
            fname = sprintf('sub_%03d_trl_%03d_%s',i_sub,i_trl,name_mk{i});
            fname_path = fullfile(Path_child_mark{1,i_marker},fname);
            save(fname_path,'mark_win');
            end
        end
        
        % Nose 자리에는 원래 x,y,z 값을 넣어줌
%         fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
%         [mark_nose_w,~] = getWindows(nose_marker,cam.winsize,cam.wininc,[],[],[]);
% %         mark_nose_w = getmovfilter(nose_marker,cam.winsize,cam.wininc,[],[]);
%         save(fullfile( Path_parent{5},fname),'mark_nose_w');
        
        % 카메라 마커와 EMG의 시점이 적절한지 파악하기 위한 plot 저장
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
%         fig_name = sprintf('sub_%d_trl_%d.jpg', i_sub, i_trl); % 분석 경과 표시
%         close(h);
%         imwrite(cdata,fullfile(cd,'DB_v2','그림',fig_name));
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

