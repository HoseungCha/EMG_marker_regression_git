%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m
% 2: Marker_v_ext_from_windows.m %-current code-%
% 3: EMG_feat_ext_from_windows.m
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; clear; close all;

%------------------------code analysis parameter--------------------------%
% name of raw DB
name_DB_raw = 'DB_raw2';

% name of process DB to analyze in this code
name_DB_process = 'DB_processed2';

% name of anlaysis DB in the process DB
name_DB_analy =...
    'DB_raw2_marker_wsize_24_winc_12_emg_wsize_408_winc_204_delay_0';

% name of marker DB in the processed DB
name_DB_marker = 'mark';

id_plot = 0;
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%

% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));

% path of code, which
path_code = fileparts(cd);
path_DB = fullfile(path_code,'DB');
path_DB_raw = fullfile(path_DB,name_DB_raw);
path_DB_process = fullfile(path_DB,name_DB_process);
path_DB_analy = fullfile(path_DB_process,name_DB_analy);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% get toolbox
addpath(genpath(fullfile(path_research,'_toolbox')));

% add functions
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%



%-----------------------experiment information----------------------------%
% period of facial expression
period_fe_exp = 3;
period_margin_FE_front =1; % time period to be used before instruction
period_margin_FE_end = 0; % time period to be used after instruction

% samping period of facial expression (window increase size)
period_sampling = 0.1;


% list of paris of instruction and trigger
name_trg = {"화남",1,1;"어금니깨물기",1,2;"비웃음(왼쪽)",1,3;"비웃음(오른쪽)",...
    1,4;"눈 세게 감기",1,5;"두려움",1,6;"행복",1,7;"키스",2,1;"무표정",2,2;...
    "슬픔",2,3;"놀람",2,4};
name_fe = name_trg(:,1);

% list of markers
name_mark = {'central down lip';'central nose';'central upper lip';'head 1';...
    'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';...
    'left dimple';'left down eye';'left down lip';'left eyebrow inside';...
    'left eyebrow outside';'left nose';'left upper eye';'left upper lip';...
    'right central lip';'right cheek';'right dimple';'right down eye';...
    'right down lip';'right eyebrow inside';'right eyebrow outside';...
    'right nose';'right upper eye';'right upper lip'};

% read file path of data from raw DB
[name_sub,path_sub] = read_names_of_file_in_folder(fullfile(path_code,'DB','DB_raw2'));



% number of subject, trials, triggers and channels
n_sub = length(name_sub);
n_trl = 20;
n_emg_pair = 3;
n_ch_emg = 4;
n_fe = length(name_fe);
n_win = period_fe_exp/period_sampling;
n_mark = 28;
n_mark_type = 3;
idx_marker_type = 1 : n_mark_type;% 1:X,2:Y,3:Z

% number of windows for margin front and end
n_win2margin_front = period_margin_FE_front/period_sampling;
n_win2margin_end= period_margin_FE_end/period_sampling;
n_win_total = n_win+n_win2margin_front+n_win2margin_end;
%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%
mark_seg = cell(n_sub,n_trl,n_fe,n_mark);
%-------------------------------------------------------------------------%

% Get median value from marker
for i_sub = 1 : n_sub
    for i_trl = 1 : n_trl
        disp([i_sub,i_trl]);
        for i_mark = 1 : n_mark
            % display of marker
            disp(name_mark(i_mark));
            
            % set path
            path_mark = fullfile(path_DB_analy,...
                [name_DB_marker,'_',num2str(i_mark)]);
            marker_set = cell(n_sub,n_trl);
            
            % read marker
            name_file = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            % load mark windows with respect of subject and trial
            load(fullfile(path_mark,name_file)); % get markers
            
            % get median value from windows
            len_win = length(mark_win); % number of windows
            mark_median = zeros(len_win,n_mark_type);
            for i_win = 1 : len_win
                
                % get median value
                mark_median(i_win,:)= nanmedian(mark_win{i_win}(:,idx_marker_type),1);
                if any(isnan(mark_median(i_win,:)))
%                     keyboard;
                    mark_median(i_win,:) = mark_median(i_win-1,:);
                    a=1;
                end
            end   
            
            % extracted part of preiod of facial expression
            mark_ext = cell(n_fe,1);
            for i_fe = 1 : n_fe
                try
                    mark_ext{idx_seq_fe(i_fe)} = ...
                    mark_median(trg_w(i_fe)-n_win2margin_front:...
                    trg_w(i_fe)+n_win-1+n_win2margin_end,:);
                catch
                    mark_ext{idx_seq_fe(i_fe)} = ...
                        NaN(n_win_total,n_mark_type);
                end
            end
            
            %-----------------marker singal processing--------------------%
            
            %=========baseline processing using 
            % get median values of front part before facial expression 
            mark_median_each_front = ...
                cellfun(@(x) median(x(1:n_win2margin_front,:)), mark_ext,...
                'UniformOutput',false);
            
            % substract median values of front part of signal from
            % median mark values
            mark_median_cell_each_front = cellfun(@(x)...
                x-median(x(1:n_win2margin_front,:)), mark_ext,...
                'UniformOutput',false);
            
            % substitue front part with zeros
            % cf: this values shoud have been zeros if marker is collected
            % properly
            mark_median_cell_each_frontend_zero = cellfun(@(x)...
                x-[x(1:n_win2margin_front,:);zeros(n_win,3);...
                x(n_win_total-n_win2margin_end+1:...
                n_win_total,:)],...
                mark_median_cell_each_front,'UniformOutput',false);
            %=========baseline processing end
          
%             % to plot, change cell to mat
%             mark_median_ = cell2mat(mark_seg);
            % collected DB with subject, tiral, emotion and emgpair
%             mark_seg(i_sub,i_trl,:,i_emg_pair) = emg_segment;
            
            mark_seg_proc = cell2mat(mark_median_cell_each_frontend_zero);
            
            
            % substitue signal part who ranged with neutral exp with zeros
            % it's beacause this values shoud have been zeros if marker is collected
            % properly
            % I should first get min and max for neutral exp to get
            % ranges of neutral exp
            minmax_mark_medain_neutral = minmax(mark_seg_proc((n_win_total)*(9-1)+1:...
                (n_win_total)*9,:)');
            
            for i_marktype = 1 : n_mark_type
                % get idices of values who are in range of
                % non - expression
                idx_min = mark_seg_proc(:,i_marktype)...
                    >=minmax_mark_medain_neutral(i_marktype,1);
                idx_max = mark_seg_proc(:,i_marktype)...
                    <=minmax_mark_medain_neutral(i_marktype,2);
                idx_range_in_nonexp = idx_min.*idx_max;
                
                % substitue idices with zeros
                mark_seg_proc(logical(idx_range_in_nonexp),i_marktype) = 0;
            end
            %-----------------marker singal processing end----------------%
            
            % collected DB with subject, tiral, emotion and emgpair
            mark_seg(i_sub,i_trl,:,i_mark) = mat2cell(mark_seg_proc,...
                    n_win_total*ones(n_fe,1),n_mark_type);
        end
    end
end
%-----------------------------save emg_seg--------------------------------%
save(fullfile(path_DB_analy,[name_DB_marker,'_mark_seg']),'mark_seg');
%-------------------------------------------------------------------------%
