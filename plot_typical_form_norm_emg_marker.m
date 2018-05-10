%--------------------------------------------------------------------------
% explanation of this code
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
close all; clc; clear
%------------------------code analysis parameter--------------------------%
% name of raw DB
% name_DB_raw = 'DB_raw2';

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
% path_DB_raw = fullfile(path_DB,name_DB_raw);
path_DB_process = fullfile(path_DB,name_DB_process);
path_DB_analy = fullfile(path_DB_process,name_DB_analy);
path_DB_plot = fullfile(path_DB_analy,'Norm_type-do_all_emotion');
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
addpath(genpath(fullfile(path_research,'_toolbox')));
%-------------------------------------------------------------------------%

%------------------------experiment infromation---------------------------%
%-------------------------------------------------------------------------%


%----------------------------paramters------------------------------------%

%-------------------------------------------------------------------------%

%----------------------set saving folder----------------------------------%

%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%

%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%

% find typical fig
[name_fig,path_fig] = read_names_of_file_in_folder(path_DB_plot,'*fig');
tmp_idx = contains(name_fig,'template');
name_fig = name_fig(tmp_idx);
path_fig = path_fig(tmp_idx);

name_fig_reshape= reshape(name_fig,[5,10])';

% plot emg
f = figure;
for i = 1 : numel(path_fig)
    s = subplot(10,5,i);
    h = openfig(path_fig{i});
    copyobj(h.Children(1).Children,s);
    s.YLim = [0 1];
    s.XTickLabel = [];
    s.YTickLabel = [];
    idx_dot = strfind(name_fig{i},'.');
    s.XLabel.String  = name_fig{i}(idx_dot-35:idx_dot-10)
    pause(0.1);
    close(h);
end
% tightfig(f);
clear s h

% plot marker
f2 = figure;
for i = 1 : numel(path_fig)
    s = subplot(10,5,i);
    h = openfig(path_fig{i});
    copyobj(h.Children(2).Children,s);
    s.YLim = [-1 1];
    s.XTickLabel = [];
    s.YTickLabel = [];
    idx_dot = strfind(name_fig{i},'.');
    s.XLabel.String  = name_fig{i}(idx_dot-35:idx_dot-10)
    pause(0.1);
    close(h);
end
tightfig(f2);



%-------------------------------------------------------------------------%

%-------------------------------save results------------------------------%
%-------------------------------------------------------------------------%




