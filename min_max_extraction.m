%--------------------------------------------------------------------------
% MARKER -> X,Y,Z -> sub01_trl01.mat
% contents:
% normalized marker cat(3, emg(n_fe,40), marker(n_fe,40)) -> 11 X 40 X 2
% calibrated DB
% minmax information: [max_values,idx_max,min_values,idx_min];

%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------

%------------------------code analysis parameter--------------------------%
% name of raw DB
name_DB_raw = 'DB_raw2';

% name of process DB to analyze in this code
name_DB_process = 'DB_processed2';

% name of anlaysis DB in the process DB
name_DB_analy = 'DB_raw2_marker_wsize_24_winc_12_emg_wsize_408_winc_204_delay_0';

%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%

% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));
% path of code, which 
path_code = fileparts(fullfile(cd));
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

%-----------------------------load DB-------------------------------------%
% load feature set, from this experiment 
load(fullfile(path_DB_analy,'regression','emg_seg')); 
load(fullfile(path_DB_analy,'regression','marker_set')); 

%-------------------------------------------------------------------------%

%------------------------experiment infromation---------------------------%
[n_sub, n_trl, n_emg_ch, n_emg_pair] = size(emg_feats);
[~, ~, n_fe,n_mark, n_xyz] = size(mark_seg);
emg_segs = emg_seg; clear emg_seg
mark_segs = mark_seg; clear mark_seg
name_xyz = {'x','y','z'};
%-------------------------------------------------------------------------%

%----------------------------paramters------------------------------------%
i_emg_pair = 1;
%-------------------------------------------------------------------------%

%----------------------set saving folder----------------------------------%
% set folder for saving
name_folder_saving = 'DB_regression';

% set saving folder for windows
path_folder = make_path_n_retrun_the_path(path_DB_analy,name_folder_saving);
%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%
% minmax_emg;
%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
% marker
for i_xyz = 1: n_xyz
% make xyz folder
tmp = sprintf('%s',name_xyz{i_xyz});
path_saving = make_path_n_retrun_the_path(path_folder,tmp);
for i_mark = 1 : n_mark 
% make marker folder
tmp = sprintf('mark_%02d',i_mark);
path_saving = make_path_n_retrun_the_path(path_saving,tmp);

% get max values and FE indices giving max of max values
[max_v,~] = cellfun(@max,mark_segs(:,:,:,i_mark,i_xyz));
[max_v,max_idx] = max(max_v,[],3);

% get max values and FE indices giving max of max values
[min_v,~] = cellfun(@min,mark_segs(:,:,:,i_mark,i_xyz));
[min_v,min_idx] = max(min_v,[],3);

marker_minmax = cat(3,min_v,max_v);
marker_minmax_idx = cat(3,min_idx,max_idx);

% get possible calibration idx
idx_calibration = cell(n_sub,1);
for i_sub = 1 : n_sub
[a,b] = histc(max_idx(i_sub,:),unique(max_idx(i_sub,:)));
idx_calibration{i_sub} = find(a(b) == max(a(b)));
end


% emg
for i_emg_ch = 1: n_emg_ch
for i_emg_pair = 1: n_emg_pair
% get max values and FE indices giving max of max values
[max_v,~] = cellfun(@max,emg_segs(:,:,:,i_emg_ch,i_emg_pair));
[max_v,max_idx] = max(max_v,[],3);

% get max values and FE indices giving max of max values
[min_v,~] = cellfun(@min,emg_segs(:,:,:,i_emg_ch,i_emg_pair));
[min_v,min_idx] = max(min_v,[],3);
end
end
emg_minmax = cat(3,min_v,max_v);
emg_minmax_idx = cat(3,min_idx,max_idx);

% save
save(fullfile(path_saving,'minmax_inform'),...
    'marker_minmax','marker_minmax_idx','idx_calibration')
end
end


%-------------------------------------------------------------------------%

%-------------------------------save results------------------------------%
save(fullfile(path_saving,'results.mat'),'r');
%-------------------------------------------------------------------------%
