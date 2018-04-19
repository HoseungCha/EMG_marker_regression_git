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
name_folder = 'windows_ds_10Hz_ovsize_50_delay_0';

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
parentdir=fileparts(pwd); % parent path which has DB files
% get path
path_DB_process = fullfile(parentdir,'DB','DB_processed2',name_folder);

%-----------------------experiment information-----------------------------
% list of paris of instruction and trigger
name_Trg = {"ȭ��",1,1;"��ݴϱ�����",1,2;"�����(����)",1,3;"�����(������)",...
    1,4;"�� ���� ����",1,5;"�η���",1,6;"�ູ",1,7;"Ű��",2,1;"��ǥ��",2,2;...
    "����",2,3;"���",2,4};
name_FE = name_Trg(:,1);
%--------------------------------------------------------------------------

% changed expreesion order like
%["��ǥ��";"ȭ��";"��ݴϱ�����";"�����(����)";"�����(������)";
%"�� ���� ����";"�η���";"�ູ";"Ű��";"����";"���"]
idx_FE_2_change  = [9,1:8,10:11];

% number of experimnet information
n_sub = 5;
n_trl = 20;
n_mark = 28;
n_trg = 26;
n_emg_pair = 3;
n_ch_emg = 4;

% period of facial expression
period_FE_exp = 3;
period_sampling = 0.1;
n_FE = length(name_FE);
n_seg = period_FE_exp/period_sampling;
period_margin_FE =1; % ǥ�� �ν�Ʈ���� �� �� 1��
n_seg2margin = period_margin_FE/period_sampling;

idx_marker_type = 1 : 3;% 1:X,2:Y,3:Z
n_mark_type = length(idx_marker_type); % 1:X,2:Y,3:Z

name_feat_list = {'RMS','WL','CC','SampEN'};
id_feat2use = contains(name_feat_list,str_features2use);
n_feat = sum([id_feat2use(1:3)*n_ch_emg,...
    id_feat2use(n_ch_emg)*n_ch_emg*n_ch_emg]);

% %% prepare save folder
% Name_folder = sprintf('N_word_%d_N_line_%d_size_line_spac_%d',...
%     N_word_in_line,N_line,size_inc_height);
% path4saving = make_path_n_retrun_the_path(path_DB,Name_folder);

% Get EMG features from windows
for i_sub = 1 : n_sub
    for i_trl = 1 : n_trl
        for i_emg_pair = 1 : n_emg_pair
            % folder name 4 saving 
            name_emgpair = sprintf('emg_pair_%d',i_emg_pair);
            
            % set path
            path_emg_pair = fullfile(path_DB_process,name_emgpair);
            marker_set = cell(n_sub,n_trl);
            
            % read marker
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
            name_folder = ['feat_',name_emgpair,'_',cat(2,str_features2use{:})];
            
            path_tmp = make_path_n_retrun_the_path(path_DB_process,name_folder);
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);

            % save
            save(fullfile(path_tmp,name_file),'emg_feat');
            
            % plot
            figure;plot(emg_feat)
            %-------------------------------------------------------------%    
            
            % extracted part of preiod of facial expression
            emg_segment = cell(n_FE,1);
            for i_FE = 1 : n_FE
                emg_segment{idx_seq_FE(i_FE)} = emg_feat(trg_w(i_FE)-n_seg2margin:...
                    trg_w(i_FE)+n_seg-1+n_seg2margin,:);
            end
            % change it in the order like
            %["��ǥ��";"ȭ��";"��ݴϱ�����";"�����(����)";"�����(������)";
            %"�� ���� ����";"�η���";"�ູ";"Ű��";"����";"���"]
            emg_segment = emg_segment(idx_FE_2_change);
            
            % normalization of median data
            % get median mark values of non-expression
            emg_feat_nonexp = emg_segment{1};
            
%             % substract median values of non-expression from other median mark values
%             %             mark_median_cell_non_exp = cellfun(@(x) x-median(mark_median_nonexp),...
%             %                 mark_median_cell,'UniformOutput',false);
%             
%             % get median values of front and end of signal segment whose
%             % lengh is n_seg2margin (10 --> 1-sec)
%             mark_median_each_front = cellfun(@(x) median(x(1:n_seg2margin,:)), emg_segment,...
%                 'UniformOutput',false);
%             
%             % substract median values of front and end of signal from
%             % median mark values
%             mark_median_cell_each_front = cellfun(@(x) x-median(x(1:n_seg2margin,:)), emg_segment,...
%                 'UniformOutput',false);
%             
%             % substitue front and end part with zeros
%             % cf: this values shoud have been zeros if marker is collected
%             % properly
%             mark_median_cell_each_frontend_zero = cellfun(@(x)...
%                 x-[x(1:n_seg2margin,:);zeros(n_seg+2*n_seg2margin-2*n_seg2margin,3);...
%                 x(n_seg+2*n_seg2margin-n_seg2margin+1:n_seg+2*n_seg2margin,:)],...
%                 mark_median_cell_each_front,'UniformOutput',false);
            
            % to plot, change cell to mat
            emg_segment_proc = cell2mat(emg_segment);
            
            
%             % substitue signal part who ranged with non-expression with zeros
%             % it's beacause this values shoud have been zeros if marker is collected
%             % properly
%             % I should first get min and max for non-expression to get
%             % ranges of non-exprression
%             minmax_mark_medain = minmax(emg_segment_prco(1:n_seg+2*n_seg2margin,:)');
%             
%             for i_marktype = 1 : n_mark_type
%                 % get idices of values who are in range of
%                 % non - expression
%                 idx_min = emg_segment_prco(:,i_marktype)>=minmax_mark_medain(i_marktype,1);
%                 idx_max = emg_segment_prco(:,i_marktype)<=minmax_mark_medain(i_marktype,2);
%                 idx_range_in_nonexp = idx_min.*idx_max;
%                 
%                 % substitue idices with zeros
%                 emg_segment_prco(logical(idx_range_in_nonexp),i_marktype) = 0;
%             end
            
            %--------------------save median_v----------------------------%
            % set saving folder;
            name_folder = ['feat_seg_',name_emgpair,'_',cat(2,str_features2use{:})];
%             name_folder = ['median_v_proc','_',name_emgpair];
            path_tmp = make_path_n_retrun_the_path(path_DB_process,name_folder);
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % save
%             save(fullfile(path_tmp,name_file),'emg_segment_proc');
            
            % plot
            figure;
            plot(emg_segment_proc)
            text(1:n_seg+n_seg2margin*2:n_FE*(n_seg+n_seg2margin*2),...
                min(min(emg_segment_proc))*ones(n_FE,1),...
                name_FE(idx_FE_2_change))
            hold on;
            stem(1:n_seg+n_seg2margin*2:n_FE*(n_seg+n_seg2margin*2),...
                min(min(emg_segment_proc))*ones(n_FE,1),'k')
            hold on
            stem(1:n_seg+n_seg2margin*2:n_FE*(n_seg+n_seg2margin*2),...
                max(max(emg_segment_proc))*ones(n_FE,1),'k')
            %-------------------------------------------------------------% 
            disp([i_sub,i_trl]);
        end
    end
end



%-----------------------just for back up----------------------------

% 
% % experiemnt infromation
% Name_Trg = {"ȭ��",1,1;"��ݴϱ�����",1,2;"�����(����)",1,3;"�����(������)",1,4;"�� ���� ����",1,5;"�η���",1,6;"�ູ",1,7;"Ű��",2,1;"��ǥ��",2,2;"����",2,3;"���",2,4};
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
%                 %% Calibration session���� Nomalization
%                     Max = max(emg_feat(1 : trg_w(6),:));
%                     Min = min(emg_feat(1 : trg_w(6),:));
%                     emg_n = (emg_feat-Min)./(Max-Min);
%                     emg_n(:,9:end) = emg_feat(:,9:end);% RMS, WL�� normalization
%                 case id_type_norm
%                 %% zscore normaliztion
%                     emg_n = zscore(emg_feat,0,1); 
%                     emg_n(:,9:end) = emg_feat(:,9:end);% RMS, WL�� normalization
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