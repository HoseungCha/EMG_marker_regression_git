%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m 
% 2: Label_markers_from_windows.m %%%%%current code%%%%%%%%%%%%%%
% 3: Feat_extraction_from_raw_window.m
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; close all; clear ;
% path for processed data
parentdir=fileparts(pwd); % parent path which has DB files
path_DB = fullfile(parentdir,'DB','DB_processed',...
    'windows_ds_10Hz_ovsize_50_delay_0');

%% experiemnt infromation
Label_mark = {'central down lip';'central nose';'central upper lip';'head 1';...
    'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';...
    'left dimple';'left down eye';'left down lip';'left eyebrow inside';...
    'left eyebrow outside';'left nose';'left upper eye';'left upper lip';...
    'right central lip';'right cheek';'right dimple';'right down eye';...
    'right down lip';'right eyebrow inside';'right eyebrow outside';...
    'right nose';'right upper eye';'right upper lip'};
N_sub = 21;
N_trl = 15;
N_mark = 28;    
N_trg = 26;
N_emgpair = 3;
% %trigger path
% path_trg = fullfile(cd,'DB_v2','trg_win_10Hz');

%baseline range
% load(fullfile(cd,'DB_v2','basline_of_markers'));
% load('E:\OneDrive - 한양대학교\연구\EMG_maker_regression\코드\DB_v2\emg_feat_set_10Hz\EMG_feat_znormalized.mat')
%% Get features from EMG and median value from marker
for i_emg_pair = 1 : N_emgpair
for i_mark = 1 : N_mark
    %% set path 
    path_mark = fullfile(path_DB,sprintf('mark_%d',i_mark));
    path_emg = fullfile(path_DB,sprintf('emg_pair_%d',i_emg_pair));
    
    marker_set = cell(N_sub,N_trl);
    for i_sub = 1 : N_sub
        for i_trl = 1 : N_trl
            %% read EMG and marker DB
            fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            load(fullfile(path_emg,fname)); % get EMG
            fname = sprintf('sub_%03d_trl_%03d_raw',i_sub,i_trl);
            load(fullfile(path_mark,fname)); % get markers
            
            %% get RMS from EMG, get medial value from marker
            len_win = length(emg_win); % number of windows
            mark_median = zeros(len_win,6);
            emg_rms = zeros(len_win,4);
            for i_win = 1 : len_win
                %% EMG feature extration
                emg_rms(i_win,:) = rms(emg_win{i_win});
                %% marker values extraion
                mark_median(i_win,:)= median(mark_win{i_win},1);
            end
            
            emg_feat = zeros(len_win,4);

            % polyfit
            mark_fit = zeros(len_win,6);
            for i_markType = 1 : 6
                p = polyfit(1:len_win,mark_median(:,i_markType)',3); % 3차 polyfit
                mark_fit(:,i_markType) = polyval(p,1:len_win);
            end
            
            mark_base_corr = mark_median - mark_fit;
            
            %% Calibration session에서 Nomalization
%             Max = max(d_2_norm(1 : trg_w(6),:));
%             Min = min(d_2_norm(1 : trg_w(6),:));
%             mark_n = (d_2_norm-Min)./(Max-Min);
%             mark_n = (d_2_norm-Min)./(Max-Min);

            %% zscore normaliztion
            mark_n = zscore(mark_base_corr(:,1));
            emg_n = zscore(emg_rms);
            figure;
            plot(mark_n); hold on;
            plot(emg_n(:,1))
            
            % 저장
            marker_set{i_sub,i_trl} = mark_n;
            disp([i_sub,i_trl]);
        end
    end
    fname = sprintf('mark_%d',i_mark); %파일 이름 설정
    fname_path = fullfile(cd,'DB_v2','DB_markset_10Hz_basecorr_zeropadding',fname);
%     save(fname_path,'marker_set');
end
end

% 각 피험자,Trial 별로 되어있는 마커별로 합치는 코드
% clc; close all; clear ;
% % 실험 정보
% N_sub = 21;
% N_trl = 15;
% N_mark = 28;    
% 
% path_mark = fullfile(cd,'DB_v2','mark_nose_10Hz');
% path_trg = fullfile(cd,'DB_v2','trg_win_10Hz');
% marker_set_nose = cell(N_sub,N_trl);
% for i_sub = 1 : N_sub
%     for i_trl = 1 : N_trl
%         % window로 구분된 데이터 불러오기
%         fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
%         load(fullfile(path_mark,fname));
%         load(fullfile(path_trg,fname));
%         marker_set_nose{i_sub,i_trl} = mark_nose_w(1:trg_w(27),:);
%         disp([i_sub,i_trl]);
%     end
% end
