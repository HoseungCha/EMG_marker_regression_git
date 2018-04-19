%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m
% 2-1: Marker_v_ext_from_windows.m %%%%%current code%%%%%%%%%%%%%%
% 2-2: concatinating_windows.m 
% 3: EMG_feat_ext_from_windows.m
% you should check Code anlaysis parmaters before starting code
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

% determine normalization type
% str_use_z_norm = 'z_norm';
% str_use_cal_norm = 'cal_norm';
% id_type_norm = str_use_z_norm;
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
% list of markers
name_mark = {'central down lip';'central nose';'central upper lip';'head 1';...
    'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';...
    'left dimple';'left down eye';'left down lip';'left eyebrow inside';...
    'left eyebrow outside';'left nose';'left upper eye';'left upper lip';...
    'right central lip';'right cheek';'right dimple';'right down eye';...
    'right down lip';'right eyebrow inside';'right eyebrow outside';...
    'right nose';'right upper eye';'right upper lip'};

% list of paris of instruction and trigger
name_Trg = {"화남",1,1;"어금니깨물기",1,2;"비웃음(왼쪽)",1,3;"비웃음(오른쪽)",...
    1,4;"눈 세게 감기",1,5;"두려움",1,6;"행복",1,7;"키스",2,1;"무표정",2,2;...
    "슬픔",2,3;"놀람",2,4};
name_FE = name_Trg(:,1);
%--------------------------------------------------------------------------

% changed expreesion order like
%["무표정";"화남";"어금니깨물기";"비웃음(왼쪽)";"비웃음(오른쪽)";
%"눈 세게 감기";"두려움";"행복";"키스";"슬픔";"놀람"]
idx_FE_2_change  = [9,1:8,10:11];

% number of experimnet information
n_sub = 5;
n_trl = 20;
n_mark = 28;
n_trg = 26;
n_emgpair = 3;

% period of facial expression
period_FE_exp = 3;
period_sampling = 0.1;
n_FE = length(name_FE);
n_seg = period_FE_exp/period_sampling;
period_margin_FE =1; % 표정 인스트럭션 전 후 1초
n_seg2margin = period_margin_FE/period_sampling;

idx_marker_type = 1 : 3;% 1:X,2:Y,3:Z
n_mark_type = length(idx_marker_type); % 1:X,2:Y,3:Z

% %% prepare save folder
% Name_folder = sprintf('N_word_%d_N_line_%d_size_line_spac_%d',...
%     N_word_in_line,N_line,size_inc_height);
% path4saving = make_path_n_retrun_the_path(path_DB,Name_folder);

% Get median value from marker
for i_sub = 1 : n_sub
    for i_trl = 1 : n_trl
        for i_mark = 1 : n_mark
            % display of marker
%             disp(name_mark(i_mark));
            
            % folder name 4 saving
            name_mark_folder = sprintf('mark_%d',i_mark);
            
            % set path
            path_mark = fullfile(path_DB_process,name_mark_folder);
            marker_set = cell(n_sub,n_trl);
            
            % read marker
            name_file = sprintf('sub_%03d_trl_%03d_raw',i_sub,i_trl);
            
            % load mark windows with respect of subject and trial
            load(fullfile(path_mark,name_file)); % get markers
            
            % get median value from windows
            len_win = length(mark_win); % number of windows
            mark_median = zeros(len_win,n_mark_type);
            for i_win = 1 : len_win
                % get median value
                mark_median(i_win,:)= median(mark_win{i_win}(:,idx_marker_type),1);
            end
            
            % change unit ( m --> mm) 
            mark_median = mark_median * 1000;

            %--------------------save median_v----------------------------%
            % set saving folder;
            name_folder = ['median_v','_',name_mark_folder];
            path_tmp = make_path_n_retrun_the_path(path_DB_process,name_folder);
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % save
            save(fullfile(path_tmp,name_file),'mark_median');
            
            % plot
%             figure;plot(mark_median)
            %-------------------------------------------------------------%    
            
            % extracted part of preiod of facial expression
            mark_median_cell = cell(n_FE,1);
            mark_median_diff_cell= cell(n_FE,1);
            for i_FE = 1 : n_FE
                mark_median_cell{idx_seq_FE(i_FE)} = mark_median(trg_w(i_FE)-n_seg2margin:...
                    trg_w(i_FE)+n_seg-1+n_seg2margin,:);

            end
            % change it in the order like
            %["무표정";"화남";"어금니깨물기";"비웃음(왼쪽)";"비웃음(오른쪽)";
            %"눈 세게 감기";"두려움";"행복";"키스";"슬픔";"놀람"]
            mark_median_diff_cell = mark_median_diff_cell(idx_FE_2_change);
            mark_median_cell = mark_median_cell(idx_FE_2_change);
            
            % normalization of median data
            % get median mark values of non-expression
            mark_median_nonexp = mark_median_cell{1};
            
            % substract median values of non-expression from other median mark values
            %             mark_median_cell_non_exp = cellfun(@(x) x-median(mark_median_nonexp),...
            %                 mark_median_cell,'UniformOutput',false);
            
            % get median values of front and end of signal segment whose
            % lengh is n_seg2margin (10 --> 1-sec)
            mark_median_each_front = cellfun(@(x) median(x(1:n_seg2margin,:)), mark_median_cell,...
                'UniformOutput',false);
            
            % substract median values of front and end of signal from
            % median mark values
            mark_median_cell_each_front = cellfun(@(x) x-median(x(1:n_seg2margin,:)), mark_median_cell,...
                'UniformOutput',false);
            
            % substitue front and end part with zeros
            % cf: this values shoud have been zeros if marker is collected
            % properly
            mark_median_cell_each_frontend_zero = cellfun(@(x)...
                x-[x(1:n_seg2margin,:);zeros(n_seg+2*n_seg2margin-2*n_seg2margin,3);...
                x(n_seg+2*n_seg2margin-n_seg2margin+1:n_seg+2*n_seg2margin,:)],...
                mark_median_cell_each_front,'UniformOutput',false);
            
            % to plot, change cell to mat
            mark_median_proc = cell2mat(mark_median_cell_each_frontend_zero);
            
            
            % substitue signal part who ranged with non-expression with zeros
            % it's beacause this values shoud have been zeros if marker is collected
            % properly
            % I should first get min and max for non-expression to get
            % ranges of non-exprression
            minmax_mark_medain = minmax(mark_median_proc(1:n_seg+2*n_seg2margin,:)');
            
            for i_marktype = 1 : n_mark_type
                % get idices of values who are in range of
                % non - expression
                idx_min = mark_median_proc(:,i_marktype)>=minmax_mark_medain(i_marktype,1);
                idx_max = mark_median_proc(:,i_marktype)<=minmax_mark_medain(i_marktype,2);
                idx_range_in_nonexp = idx_min.*idx_max;
                
                % substitue idices with zeros
                mark_median_proc(logical(idx_range_in_nonexp),i_marktype) = 0;
            end
            
            %--------------------save median_v----------------------------%
            % set saving folder;
            name_folder = ['median_v_proc','_',name_mark_folder];
            path_tmp = make_path_n_retrun_the_path(path_DB_process,name_folder);
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % save
            save(fullfile(path_tmp,name_file),'mark_median_proc');
            
            % plot
%             figure;title('substitue signal part who ranged with non-expression with zeros')
%             plot(mark_median_proc)
%             text(1:n_seg+n_seg2margin*2:n_FE*(n_seg+n_seg2margin*2),...
%                 min(min(mark_median_proc))*ones(n_FE,1),...
%                 name_FE(idx_FE_2_change))
%             hold on;
%             stem(1:n_seg+n_seg2margin*2:n_FE*(n_seg+n_seg2margin*2),...
%                 min(min(mark_median_proc))*ones(n_FE,1),'k')
%             hold on
%             stem(1:n_seg+n_seg2margin*2:n_FE*(n_seg+n_seg2margin*2),...
%                 max(max(mark_median_proc))*ones(n_FE,1),'k')
            %-------------------------------------------------------------% 
            
            
            % restore signal wih baseline of non-expression
            mark_median_cell_return = mat2cell(mark_median_proc,...
                n_seg+n_seg2margin*2*ones(n_FE,1),n_mark_type);
            mark_restored = cell(size(mark_median_cell_return));
            for i = 1 : numel(mark_median_cell_return)
                % 처음 무표정 값의 baseline으로 맞추어줌
                mark_restored{i} = mark_median_cell_return{i}+mark_median_each_front{1};
            end
            mark_restored_mat = cell2mat(mark_restored);
            
            %-----------save resored singal with fixed baseline-----------%
            % set saving folder;
            name_folder = ['median_v_restored','_',name_mark_folder];
            path_tmp = make_path_n_retrun_the_path(path_DB_process,name_folder);
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % save
            save(fullfile(path_tmp,name_file),'mark_restored_mat');
            
            % plot
%             figure;title('restored signal who ranged with non-expression with zeros and baselin_with_non-exp')
%             plot(mark_reconst_mat)
%             text(1:n_seg+n_seg2margin*2:n_FE*(n_seg+n_seg2margin*2),...
%                 min(min(mark_reconst_mat))*ones(n_FE,1),...
%                 name_FE(idx_FE_2_change))
%             hold on;
%             stem(1:n_seg+n_seg2margin*2:n_FE*(n_seg+n_seg2margin*2),...
%                 min(min(mark_reconst_mat))*ones(n_FE,1),'k')
%             hold on
%             stem(1:n_seg+n_seg2margin*2:n_FE*(n_seg+n_seg2margin*2),...
%                 max(max(mark_reconst_mat))*ones(n_FE,1),'k')
            %-------------------------------------------------------------% 
            disp([i_sub,i_trl]);
        end
    end
end



%-----------------------just for back up----------------------------
% differentiate
% mark_diff_prcd = diff(mark_median);
% mark_diff_prcd(abs(mark_diff_prcd)<0.1) = 0;
% mark_raw_prcd= cumsum(mark_diff_prcd);
% temp_diff = diff(mark_diff_prcd(trg_w(i_FE)-n_seg2margin:...
% trg_w(i_FE)+n_seg-1+n_seg2margin,:));
% mark_median_diff_cell{idx_seq_FE(i_FE)} = [temp_diff(1,:);temp_diff];

            % z-normalization of each cell            
%             plot(zscore(mark_median_proc))
%             
%             tmp_m_set_median_znorm = cellfun(@zscore,tmp_m_set_median,'UniformOutput',false);
%             tmp_m_set_median_mat = cell2mat(tmp_m_set_median_znorm);
%             figure;
%             plot(tmp_m_set_median_mat)
%             text(1:n_seg2use+20:n_FE*(n_seg2use+20),min(min(tmp_m_set_median_mat))*ones(n_FE,1),...
%                  name_FE(idx_FE_2_change))
%              hold on;
%             stem(1:n_seg2use+20:n_FE*(n_seg2use+20),min(min(tmp_m_set_median_mat))*ones(n_FE,1),'k')
%             hold on
%             stem(1:n_seg2use+20:n_FE*(n_seg2use+20),max(max(tmp_m_set_median_mat))*ones(n_FE,1),'k')
            
% minmax norm of each cell
%     tmp_m_set_median_norm_minmax = cellfun(@norm_minmax,tmp_m_set_median,'UniformOutput',false);
%     tmp_m_set_median_mat = cell2mat(tmp_m_set_median_norm_minmax);
%     figure;
%     plot(tmp_m_set_median_mat)
%     text(1:n_seg2use+20:n_FE*(n_seg2use+20),min(min(tmp_m_set_median_mat))*ones(n_FE,1),...
%          name_FE(idx_FE_2_change))
% 
% 
% zscore
%     figure;
%     plot(zscore(tmp_m_set_median))
%      text(1:n_seg2use:n_FE*n_seg2use,min(min(zscore(tmp_m_set_median)))*ones(n_FE,1),...
%          name_FE(idx_FE_2_change))
% 
% 
%     marker_non_exp = mark_median_diff_cell_corrected_order{1};
% 
% diff --> 적분
%     mark_median_integ_cell = cellfun(@cumsum,mark_median_diff_cell,'UniformOutput',false);
% 
%     %cell to mat
%     tmp_m_set_median_mat = cell2mat(mark_median_integ_cell);
%     % 무표정으로 뺀 그림
%     figure;
%     plot(tmp_m_set_median_mat)
%     text(1:n_seg2use+20:n_FE*(n_seg2use+20),min(min(tmp_m_set_median_mat))*ones(n_FE,1),...
%          name_FE(idx_FE_2_change))
%      hold on;
%     stem(1:n_seg2use+20:n_FE*(n_seg2use+20),min(min(tmp_m_set_median_mat))*ones(n_FE,1),'k')
%     hold on
%     stem(1:n_seg2use+20:n_FE*(n_seg2use+20),max(max(tmp_m_set_median_mat))*ones(n_FE,1),'k')
% 
% 
% 
% change it in the order like
% ["무표정";"화남";"어금니깨물기";"비웃음(왼쪽)";"비웃음(오른쪽)";
% "눈 세게 감기";"두려움";"행복";"키스";"슬픔";"놀람"]
%     tmp_m_set_median = tmp_m_set_median(idx_FE_2_change);
%     marker_non_exp = tmp_m_set_median{1};
%     tmp_m_set_median_mat = cell2mat(tmp_m_set_median);
% 
% 무표정 빼기
% 
%     marker_bs = median(marker_non_exp);
%     mark_bs_pc = tmp_m_set_median - marker_bs;
%     figure;
%     plot(mark_bs_pc);title(name_mark(i_mark))
%     text(1:n_seg2use:n_FE*n_seg2use,min(min(mark_bs_pc))*ones(n_FE,1),...
%         name_FE(idx_FE_2_change))
% 
%     get min max normalization
%     Max = max(tmp_m_set_median);
%     Min = min(tmp_m_set_median);
%     mark_n = (tmp_m_set_median-Min)./(Max-Min);
%     figure;
%     plot(mark_n);title(name_mark(i_mark))
%     text(1:n_seg2use:n_FE*n_seg2use,min(min(mark_n))*ones(n_FE,1),...
%     name_FE(idx_FE_2_change))
% 
% a=1;
% 
%      zscore(mark_bs_pc);
% 
%      Max = max(mark_bs_pc);
%      Min = min(mark_bs_pc);
%      mark_n = (mark_bs_pc-Min)./(Max-Min);
% 
% polyfit amd reject baseline of marker values
%     mark_fit = zeros(len_win,n_mark_type);
%     for i_markType = 1 : n_mark_type
%         p = polyfit(1:len_win,mark_median(:,i_markType)',3); % 3차 polyfit
%         mark_fit(:,i_markType) = polyval(p,1:len_win);
%     end
%     mark_base_corr = mark_median - mark_fit;
% 
%     switch id_type_norm
%         case str_use_cal_norm
%         %% Calibration session에서 Nomalization
%             Max = max(d_2_norm(1 : trg_w(6),:));
%             Min = min(d_2_norm(1 : trg_w(6),:));
%             mark_n = (d_2_norm-Min)./(Max-Min);
%         case id_type_norm
%         %% zscore normaliztion
%             mark_n = zscore(mark_base_corr(:,1:n_mark_type),0,1);
%     end
% 저장
%     marker_set{i_sub,i_trl} = mark_n;
    % set saving file name for each marker
%     save(fullfile(path_tmp,'marker_set'),'marker_set');