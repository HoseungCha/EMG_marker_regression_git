%--------------------------------------------------------------------------
% copy raw DB to somewhere lese
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

% path to folder you are moving
path_destination = 'E:\Hanyang\¿¬±¸\EMG_FU_recog\Code\DB\DB_raw2';
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%

% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));

% path of code, which 
path_code = fileparts(fullfile(cd));
path_DB = fullfile(path_code,'DB');
path_DB_raw = fullfile(path_DB,name_DB_raw);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% get toolbox
addpath(genpath(fullfile(path_research,'_toolbox')));

% add functions
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
[name_sub,path_sub] = read_names_of_file_in_folder(fullfile(path_code,...
    'DB',name_DB_raw));
for i = 1 : length(path_sub)
    % read files you want to copy
    [name_file,path_file] = read_names_of_file_in_folder(...
        fullfile(path_sub{i},'emg'),'*bdf');
    
    
    % set destination path you will copy the files
    % path for saving
    path_dest = make_path_n_retrun_the_path(path_destination,name_sub{i});
    
    for j = 1 : length(path_file)
        % check file exist
        if exist(fullfile(path_dest,name_file{j}), 'file') ~= 2
            % copy file
            copyfile(path_file{j},path_dest)
        end
    end
end
%-------------------------------------------------------------------------%
