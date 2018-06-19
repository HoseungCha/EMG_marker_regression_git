%--------------------------------------------------------------------------
% plot max or min value of marker
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
name_DB_analy = 'DB_raw2_to_10Hz_cam_winsize_24_wininc_12_emg_winsize_408_wininc_204_delay_0';

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
% tmp = load(fullfile(path_DB_process,name_DB_analy)); 
% tmp_name = fieldnames(tmp);
% feat = getfield(tmp,tmp_name{1}); %#ok<GFLD>
%-------------------------------------------------------------------------%

%------------------------experiment infromation---------------------------%

%-------------------------------------------------------------------------%

%----------------------------paramters------------------------------------%

%-------------------------------------------------------------------------%

%----------------------set saving folder----------------------------------%
% % set folder for saving
% name_folder_saving = ['Result_',name_DB_analy];
% 
% % set saving folder for windows
% path_saving = make_path_n_retrun_the_path(path_DB_process,name_folder_saving);
%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%

%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
[n_sub,n_trl,n_fe,n_mark] = size(mark_seg);
minmax_n_indices = cell(n_mark,n_sub,n_trl,3);
n_xyz = 3;
for i_mark = 1 : n_mark
for i_sub = 1 : n_sub
for i_trl = 1 : n_trl
    max_v = cell(n_fe,1);
    min_v = cell(n_fe,1);
    for i_fe = 1 : n_fe
        tmp = mark_seg{i_sub,i_trl,i_fe,i_mark};
        max_v{i_fe} = max(tmp);
        min_v{i_fe} = min(tmp);
    end
    [max_values,idx_max] = max(cell2mat(max_v));
    [min_values,idx_min] = min(cell2mat(min_v));
    
    for i_xyz = 1 : n_xyz
        minmax_n_indices{i_mark,i_sub,i_trl,i_xyz} = ...
            [max_values(i_xyz),idx_max(i_xyz),min_values(i_xyz),idx_min(i_xyz)];
    end
end
end
end
for i_mark = 1 : n_mark
    for i_xyz = 1 : n_xyz
        tmp = minmax_n_indices(i_mark,:,:,i_xyz);
        tmp = cell2mat(tmp(:));
        
        [a,b] = histc(tmp(:,2),unique(tmp(:,2)));
        y = a(b);
        figure
        histogram(tmp(:,2))
        title(['max',sum2str(i_xyz)]);
        
    end
end


%-------------------------------------------------------------------------%

%-------------------------preprocessing of results------------------------%

%-------------------------------------------------------------------------%

%-------------------------------save results------------------------------%
save(fullfile(path_saving,'results.mat'),'r');
%-------------------------------------------------------------------------%
