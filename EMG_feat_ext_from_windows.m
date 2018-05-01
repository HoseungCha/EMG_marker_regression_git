%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m
% 2: Marker_v_ext_from_windows.m 
% 3: EMG_feat_ext_from_windows.m %%%%%current code%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; clear; close all;

%-----------------------Code anlaysis parmaters----------------------------
% name of process DB to analyze in this code
name_folder = 'DB_raw2_to_10Hz_cam_winsize_24_wininc_12_emg_winsize_408_wininc_204_delay_0';

% decide feature to extract
str_features2use = {'RMS'};

% decide normalization type
str_use_z_norm = 'z_norm';
str_use_cal_norm = 'cal_norm';
id_type_norm = str_use_z_norm;
%--------------------------------------------------------------------------

% get toolbox
addpath(genpath(fullfile(fileparts(fileparts(fileparts(cd))),'_toolbox')));
% add functions
addpath(genpath(fullfile(cd,'functions')));
% path for processed data
path_parent=fileparts(pwd); % parent path which has DB files
% get path
path_DB_process = fullfile(path_parent,'DB','DB_processed2');
path_folder_anlaysis = fullfile(path_DB_process,name_folder);

%-----------------------experiment information-----------------------------
% list of paris of instruction and trigger
name_Trg = {"화남",1,1;"어금니깨물기",1,2;"비웃음(왼쪽)",1,3;"비웃음(오른쪽)",...
    1,4;"눈 세게 감기",1,5;"두려움",1,6;"행복",1,7;"키스",2,1;"무표정",2,2;...
    "슬픔",2,3;"놀람",2,4};
name_FE = name_Trg(:,1);



% number of experimnet information
% read file path of data from raw DB
[name_sub,path_sub] = read_names_of_file_in_folder(fullfile(path_parent,'DB','DB_raw2'));
n_sub = length(name_sub);
n_trl = 20;
n_trg = 26;
n_emg_pair = 3;
n_ch_emg = 4;

% period of facial expression
period_FE_exp = 3;
period_sampling = 0.1;
n_FE = length(name_FE);
n_seg = period_FE_exp/period_sampling;
period_margin_FE_front =1; % 표정 인스트럭션 전
n_seg2margin_front = period_margin_FE_front/period_sampling;

period_margin_FE_end = 0; % 표정 인스트럭션 후
n_seg2margin_end= period_margin_FE_end/period_sampling;

name_feat_list = {'RMS','WL','CC','SampEN'};
id_feat2use = contains(name_feat_list,str_features2use);
n_feat = sum([id_feat2use(1:3)*n_ch_emg,...
    id_feat2use(n_ch_emg)*n_ch_emg*n_ch_emg]);
%--------------------------------------------------------------------------

% %% prepare save folder
% Name_folder = sprintf('N_word_%d_N_line_%d_size_line_spac_%d',...
%     N_word_in_line,N_line,size_inc_height);
% path4saving = make_path_n_retrun_the_path(path_DB,Name_folder);

% Get EMG features from windows
for i_sub = 1 : n_sub
    for i_trl = 1 : n_trl      
        disp([i_sub,i_trl]);
        for i_emg_pair = 1 : n_emg_pair
            try
            % folder name 4 saving 
            name_emg_pair = sprintf('emg_pair_%d',i_emg_pair);
            
            % set path
            path_emg_pair = fullfile(path_folder_anlaysis,name_emg_pair);
            
            % read emg
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % load feature windows with respect of subject and trial
            load(fullfile(path_emg_pair,name_file)); % get emg
            
            % get emg features from windows
            len_win = length(emg_win); % number of windows
            emg_feat = zeros(len_win,n_feat);
            for i_win = 1 : len_win
                % time domain features 
                curr_win = emg_win{i_win};
                if id_feat2use(1) ==1
                    temp_rms = sqrt(mean(curr_win.^2));
                else
                    temp_rms = [];
                end
                if id_feat2use(2) ==1
                    temp_WL = sum(abs(diff(curr_win,2)));
                else
                    temp_WL = [];
                end
                if id_feat2use(3) ==1
                    temp_SampEN = SamplEN(curr_win,2);
                else
                    temp_SampEN = [];
                end
                if id_feat2use(4) ==1
                    temp_CC = featCC(curr_win,4);
                else
                    temp_CC = [];
                end
                emg_feat(i_win,:) = [temp_rms,temp_WL,temp_SampEN,temp_CC];
            end
            

            %--------------------save features----------------------------%
            % set saving folder;
            name_folder = ['feat_',name_emg_pair,'_',cat(2,str_features2use{:})];
            

            
%             path_tmp = make_path_n_retrun_the_path(path_folder_anlaysis,name_folder);
%             name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
% 
%             % save
%             save(fullfile(path_tmp,name_file),'emg_feat');
            
            % plot
%             figure;plot(emg_feat)
            %-------------------------------------------------------------%    
            
            % extracted part of preiod of facial expression
            emg_segment = cell(n_FE,1);
            for i_FE = 1 : n_FE
                emg_segment{idx_seq_FE(i_FE)} = emg_feat(trg_w(i_FE)-n_seg2margin_front:...
                    trg_w(i_FE)+n_seg-1+n_seg2margin_end,:);
            end
            
            % normalization of median data
            % get median mark values of non-expression
            emg_feat_nonexp = emg_segment{9};
            
            % to plot, change cell to mat
            emg_segment_proc = cell2mat(emg_segment);
            
            %--------------------save emg_seg----------------------------%
            % set saving folder;
            name_folder = ['feat_seg_',name_emg_pair,'_',cat(2,str_features2use{:})];
%             name_folder = ['median_v_proc','_',name_emgpair];

            path_tmp = make_path_n_retrun_the_path(path_folder_anlaysis,name_folder);
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % save
            save(fullfile(path_tmp,name_file),'emg_segment_proc');
            
            % plot
%             figure;
%             plot(emg_segment_proc)
%             text(1:n_seg+n_seg2margin_front+...
%                 n_seg2margin_end:n_FE*(n_seg+n_seg2margin_front+...
%                 n_seg2margin_end),...
%                 min(min(emg_segment_proc))*ones(n_FE,1),...
%                 name_FE(idx_FE_2_change))
%             hold on;
%             stem(1:n_seg+n_seg2margin_front+n_seg2margin_end:n_FE*...
%                 (n_seg+n_seg2margin_front+n_seg2margin_end),...
%                 min(min(emg_segment_proc))*ones(n_FE,1),'k')
%             hold on
%             stem(1:n_seg+n_seg2margin_front+n_seg2margin_end:n_FE*(n_seg+n_seg2margin_front+n_seg2margin_end),...
%                 max(max(emg_segment_proc))*ones(n_FE,1),'k')
            %-------------------------------------------------------------% 
            catch ex
               load('C:\Users\A\Desktop\CHA\연구\EMG_marker_regression\코드\DB\DB_processed2\DB_raw2_to_10Hz_cam_winsize_24_wininc_12_emg_winsize_408_wininc_204_delay_0\median_v_proc_mark_9\sub_001_trl_008.mat');
                % set saving folder;
                name_folder = ['feat_seg_',name_emg_pair,'_',cat(2,str_features2use{:})];
                path_tmp = make_path_n_retrun_the_path(path_folder_anlaysis,name_folder);
                name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
                emg_segment_proc = NaN(size(emg_segment_proc));
                % save
                save(fullfile(path_tmp,name_file),'emg_segment_proc'); 
            end
        end
    end
end



%-----------------------just for back up----------------------------

% 
% % experiemnt infromation
% Name_Trg = {"화남",1,1;"어금니깨물기",1,2;"비웃음(왼쪽)",1,3;"비웃음(오른쪽)",1,4;"눈 세게 감기",1,5;"두려움",1,6;"행복",1,7;"키스",2,1;"무표정",2,2;"슬픔",2,3;"놀람",2,4};
% Name_FE = Name_Trg(:,1);
% N_sub = 5;
% N_trl = 20;
% % N_mark = 28;
% N_emgpair = 3;
% % N_mark_type = 3; % 1:X,2:Y,3:Z
% n_ch_emg = 4;
% N_order_cc = 4;
% name_feat_list = {'RMS','WL','CC','SampEN'};
% % determine normalization type
% str_use_z_norm = 'z_norm';
% str_use_cal_norm = 'cal_norm';
% id_type_norm = str_use_z_norm;%%%%%%%%%%%%%%%%%%%%decide normalization type
% % decide feature to extract
% str_features2use = {'RMS','WL'};
% 
% 
% %% Get median value from marker
% for i_emg_pair = 1 : N_emgpair
%     % folder name 4 saving
%     name_folder = sprintf('emg_pair_%d',i_emg_pair);
%     %% set saving folder;
%     name_folder4norm_DB = [id_type_norm,'_',name_folder,'_',cat(2,str_features2use{:})];
%     path_emg_pair = make_path_n_retrun_the_path(path_DB, name_folder4norm_DB);
% 
%     %% get path
%     path_emg = fullfile(path_DB,name_folder);
%     feat_set = cell(N_sub,N_trl);
%     for i_sub = 1 : N_sub
%         for i_trl = 1 : N_trl
%             %% read EMG 
%             fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
%             load(fullfile(path_emg,fname)); % get EMG
% %             fname = sprintf('sub_%03d_trl_%03d_raw',i_sub,i_trl);
% %             load(fullfile(path_mark,fname)); % get markers
%             
%             %% get RMS from EMG, get medial value from marker
%             N_window = length(emg_win); % number of windows
%             emg_feat = zeros(N_window,n_feat);
%             for i_win = 1 : N_window
%                 %% EMG feat extraion
%                 % time domain features 
%                 curr_win = emg_win{i_win};
%                 if id_feat2use(1) ==1
%                     temp_rms = sqrt(mean(curr_win.^2));
%                 else
%                     temp_rms = [];
%                 end
%                 if id_feat2use(2) ==1
%                     temp_WL = sum(abs(diff(curr_win,2)));
%                 else
%                     temp_WL = [];
%                 end
%                 if id_feat2use(3) ==1
%                     temp_SampEN = SamplEN(curr_win,2);
%                 else
%                     temp_SampEN = [];
%                 end
%                 if id_feat2use(4) ==1
%                     temp_CC = featCC(curr_win,4);
%                 else
%                     temp_CC = [];
%                 end
%                 emg_feat(i_win,:) = [temp_rms,temp_WL,temp_SampEN,temp_CC];
%                 % get image from raw emg
% %                 temp_img = mat2im(curr_win,parula(numel(curr_win)));
% %                 fname = sprintf('sub_%03d_trl_%03d_win_%03d',i_sub,i_trl,i_win);
% %                 imwrite(temp_img,fullfile(path_img,[fname,'.png']));
%                 
%             end
%             %% type of normalization
%             switch id_type_norm
%                 case str_use_cal_norm
%                 %% Calibration session에서 Nomalization
%                     Max = max(emg_feat(1 : trg_w(6),:));
%                     Min = min(emg_feat(1 : trg_w(6),:));
%                     emg_n = (emg_feat-Min)./(Max-Min);
%                     emg_n(:,9:end) = emg_feat(:,9:end);% RMS, WL만 normalization
%                 case id_type_norm
%                 %% zscore normaliztion
%                     emg_n = zscore(emg_feat,0,1); 
%                     emg_n(:,9:end) = emg_feat(:,9:end);% RMS, WL만 normalization
%             end
%             %% feature set
%             feat_set{i_sub,i_trl} = emg_n;
%             disp([i_sub,i_trl]);
%         end
%     end
%     %% save
%     name_save_file = sprintf('feat_set_%s',cat(2,str_features2use{:}));
%     save(fullfile(path_emg_pair,name_save_file),'feat_set');
% end