%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m
% 2: Marker_v_ext_from_windows.m
% 3: EMG_feat_ext_from_windows.m 
% 4: minmax_n_ouliers_ext.m %%%%%current code%%%%%%%%%%%%%%
% 5: cali_train_text_val_indx_selection.m 
% 6: reg_db_construction.m
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clear;
%------------------------code analysis parameter--------------------------%
% name of process DB to analyze in this code
name_DB_process = 'DB_processed2';

% name of anlaysis DB in the process DB
name_DB_analy = 'DB_raw2_marker_wsize_24_winc_12_emg_wsize_408_winc_204_delay_0';

% Name to load
name_load_folder = 'regression';
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));
% path of code, which 
path_code = fileparts(fullfile(cd));
path_DB_process = fullfile(path_code,'DB',name_DB_process);
path_DB_save = fullfile(path_DB_process,name_DB_analy,name_load_folder);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% get toolbox
addpath(genpath(fullfile(path_research,'_toolbox')));
% add functions
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%

%-----------------------------load DB-------------------------------------%
% get DB ouliter
load(fullfile(path_DB_save,'emg_seg')); 
load(fullfile(path_DB_save,'mark_seg')); 

[n_sub,n_trl,n_fe, n_mark,n_xyz] = size(mark_seg);
[~,~,~,n_emg_ch,n_emg_pair] = size(emg_seg);
%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
% get minmax of absolute mark and emg
mark_minmax = cell(n_sub,n_trl,n_mark,n_xyz);
emg_minmax = cell(n_sub,n_trl,n_emg_ch,n_emg_pair);
for i_sub = 1 : n_sub
for i_trl = 1 : n_trl
% get mark_minmax
for i_mark = 1 : n_mark
for i_xyz = 1 : n_xyz
    tmp = mark_seg(i_sub,i_trl,:, i_mark,i_xyz);
    tmp = abs(cell2mat(tmp(:))); % for marker, you should get it absoluted
    mark_minmax{i_sub,i_trl,i_mark,i_xyz} =  minmax(tmp');
end
end
% get emg_minmax
for i_emg_ch = 1 : n_emg_ch
for i_emg_pair = 1 : n_emg_pair
    tmp = emg_seg(i_sub,i_trl,:,i_emg_ch,i_emg_pair);
    tmp = cell2mat(tmp(:));
    emg_minmax{i_sub,i_trl,i_emg_ch,i_emg_pair} =  minmax(tmp');
end
end
end
end
% saving minmax of marker and emg
save(fullfile(path_DB_save,'mark_minmax.mat'),'mark_minmax');
save(fullfile(path_DB_save,'emg_minmax.mat'),'emg_minmax');


% get outliers of marker and emg
mark_out = cell(n_sub,n_mark,n_xyz);
emg_out = cell(n_sub,n_emg_ch,n_emg_pair);
for i_sub = 1 : n_sub
% get mark_minmax
for i_mark = 1 : n_mark
for i_xyz = 1 : n_xyz
    tmp = mark_minmax(i_sub,:,i_mark,i_xyz);
    tmp = cell2mat(tmp(:)); 
    mark_out{i_sub,i_mark,i_xyz} = isoutlier(tmp);
end
end
% get emg_minmax
for i_emg_ch = 1 : n_emg_ch
for i_emg_pair = 1 : n_emg_pair
    tmp = emg_minmax(i_sub,:,i_emg_ch,i_emg_pair);
    tmp = cell2mat(tmp(:)); 
    emg_out{i_sub,i_emg_ch,i_emg_pair} = isoutlier(tmp);
end
end
end
% saving minmax of marker and emg
save(fullfile(path_DB_save,'mark_out.mat'),'mark_out');
save(fullfile(path_DB_save,'emg_out.mat'),'emg_out');
