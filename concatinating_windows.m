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
name_DB_processed = 'windows_ds_10Hz_ovsize_50_delay_0';

% name folder to concatinate
name_2_concat = 'median_v_proc_mark_19';
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
path_DB_process = fullfile(parentdir,'DB','DB_processed2',name_DB_processed);

% Get median value from marker
for i_mark = 1 : n_mark
for i_sub = 1 : n_sub
for i_trl = 1 : n_trl
        
end
end
end