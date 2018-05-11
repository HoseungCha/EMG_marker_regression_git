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
name_DB_analy =...
    'DB_raw2_marker_wsize_24_winc_12_emg_wsize_408_winc_204_delay_0';

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
path_DB_plot = fullfile(path_DB_analy,'do_all_emotion'); %do_each 
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
addpath(genpath(fullfile(path_research,'_toolbox')));
%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%

% find typical fig
[name_fig,path_fig] = read_names_of_file_in_folder(path_DB_plot,'*fig');
tmp_idx = contains(name_fig,'rep');
name_fig = name_fig(tmp_idx);
path_fig = path_fig(tmp_idx);

% name_fig_reshape= reshape(name_fig,[5,10])';

% plot emg
f1 = figure;
for i = 1 : numel(path_fig)
    s = subplot(10,5,i);
    h = openfig(path_fig{i});
    copyobj(h.Children(1).Children,s);
    s.YLim = [0 1];
    s.XTickLabel = [];
    s.YTickLabel = [];
    s.XLabel.String = strrep(name_fig{i}, '_',' ');
    pause(0.01);
    close(h);
end
tightfig(f1);
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
    s.XLabel.String = strrep(name_fig{i}, '_',' ');
    pause(0.01);
    close(h);
end
tightfig(f2);
%-------------------------------main end----------------------------------%

%-------------------------------save fig----------------------------------%
savefig(f1,fullfile(path_DB_plot,'emg_rep'));
savefig(f2,fullfile(path_DB_plot,'mark_rep'));
%-------------------------------------------------------------------------%




