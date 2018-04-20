%--------------------------------------------------------------------------
% 1: DB_windows_extraion.m
% 2: Marker_v_ext_from_windows.m 
% 3: EMG_feat_ext_from_windows.m
% 4: normazliation_with_windows.m %%%%%current code%%%%%%%%%%%%%%
% do normalization and check if data is aquired properly
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; clear all; close all;

%-----------------------Code anlaysis parmaters----------------------------
% name of process DB to analyze in this code
name_folder = 'windows_ds_10Hz_ovsize_50_delay_0';
name_folder_emg = 'feat_seg_emg_pair';
name_folder_marker = 'median_v_proc';
id_plot = 1;
%-------------------------------------------------------------------------%

% get toolbox
addpath(genpath(fullfile(fileparts(fileparts(fileparts(cd))),'_toolbox')));

% add functions
addpath(genpath(fullfile(cd,'functions')));

% path for processed data
path_parent=fileparts(pwd); % parent path which has DB files

% get path
path_DB_process = fullfile(path_parent,'DB','DB_processed2',name_folder);

%--------------------experiment information-------------------------------%
idx_sub2use = [1,2,3,4,5];
n_emg_pair = 3;
n_mark = 28;
n_FE = 11;
idx_trl2use = 1:20;
% idx_trl2use(13) = [];
n_trl2use = length(idx_trl2use);
% read file path of data from raw DB
[name_sub,~] = read_names_of_file_in_folder(fullfile(path_parent,'DB','DB_raw2'));
n_sub = length(name_sub);
n_trl= 20;

for i_emg_pair = 1
% for i_emg_pair = 1   
    % folder name to load 
    name_folder4file = sprintf('%s_%d_RMS',name_folder_emg,i_emg_pair);
    
    % set path
    path = fullfile(path_DB_process,name_folder4file);
    
    % read file names
    [name_file,path_file] = read_names_of_file_in_folder(...
        path,'*.mat');
    
    % reshape of file path to fit with trial and subject size
    path_file = reshape(path_file,n_trl,[]); % n_trl X n_sub
    
    % use indices of trial to use
    path_file = path_file(idx_trl2use,idx_sub2use);
    
    %load whole files using cellfun
    tmp = permute(struct2cell(cellfun(@load,path_file)),[2 3 1]);
    
    %get number of features
    [n_trl, n_sub] = size(tmp);
    n_feat = size(tmp{1},2);
    n_session = size(tmp{1},1);
    
    %----------------------plot raw data of EMG with subject--------------%
    % plot
    if(id_plot)
    for i_sub= 1:n_sub
    %cell -> mat
    emg_raw = cell2mat(tmp(:,i_sub));
    figure;
    set(gcf,'Position',[1 41 1920 962]);
    plot(emg_raw);
    ylim([0 400])
    hold on
    for i = 1 : n_trl
        text(50+n_session*(i-1),max(max(emg_raw)),num2str(i));
    end
    stem(1:n_session:n_trl*(n_session),...
        min(min(emg_raw))*ones(n_trl,1),'r','LineWidth',2)
    stem(1:n_session:n_trl*(n_session),...
        max(max(emg_raw))*ones(n_trl,1),'r','LineWidth',2)
    hold off
    title(strrep(name_sub{i_sub},'_',' '))
    c = getframe(gcf);
    imwrite(c.cdata,fullfile(path_DB_process,sprintf('%s_%s.png',...
        name_folder4file,name_sub{i_sub})));
    close(gcf);
    end
    end
    %---------------------------------------------------------------------% 
    
    % z- normalizaiton
    [emg_z,emg_mean,emg_std] = zscore(emg_raw,0,1);
    
    %----------------------plot z-normalization of EMG ------------------%
    % plot
%     if(id_plot)
%     figure;
%     plot(emg_z)
%     hold on
%     for i = 1 : n_trl
%         text(10+n_session*(i-1),max(max(emg_z)),num2str(i));
%     end
%     stem(1:n_session:n_trl*(n_session),...
%         min(min(emg_z))*ones(n_trl,1),'k')
%     stem(1:n_session:n_trl*(n_session),...
%         max(max(emg_z))*ones(n_trl,1),'k')
%     hold off
%     title('z normalization of EMG')
%     end
    %---------------------------------------------------------------------% 
            
    % min-max normalizaiton
    emg_max = max(emg_raw);
    emg_min = min(emg_raw);
    emg_n = (emg_raw-emg_min)./(emg_max-emg_min);
    
    %----------------------plot min max normalization of EMG -------------%
%     % plot
%     if(id_plot)
%     figure;
%     plot(emg_raw(:,9:12))
%     hold on
%     for i = 1 : n_trl
%         text(10+n_session*(i-1),max(max(emg_raw(:,1:4))),num2str(i));
%     end
%     stem(1:n_session:n_trl*(n_session),...
%         min(min(emg_raw(:,1:4)))*ones(n_trl,1),'k')
%     stem(1:n_session:n_trl*(n_session),...
%         max(max(emg_raw(:,1:4)))*ones(n_trl,1),'k')
%     hold off
%     title('min-max normalization of EMG')
%     end
    %---------------------------------------------------------------------% 
    
end

% for i_mark = 1 :  n_mark  
for i_mark = 10    
    % folder name to load 
    name_folder4file = sprintf('%s_mark_%d',name_folder_marker,i_mark);
    
    % set path
    path = fullfile(path_DB_process,name_folder4file);
    
    % read file names
    [name_file,path_file] = read_names_of_file_in_folder(path,'*.mat');
    
    % reshape of file path to fit with trial and subject size
    path_file = reshape(path_file,n_trl,[]); % n_trl X n_sub
    
    % use indices of trial to use
    path_file = path_file(idx_trl2use,idx_sub2use);
    
    %load whole files using cellfun
    tmp = permute(struct2cell(cellfun(@load, path_file)),[2 3 1]);
    
    %get number of features
    n_mark_type = size(tmp{1},2);
    
    %----------------------plot raw data of Marker with subject--------------%
    % plot
    if(id_plot)
    for i_sub= 1:n_sub
    %cell -> mat
    mark_raw = cell2mat(tmp(:,i_sub));
    figure;
    set(gcf,'Position',[1 41 1920 962]);
    plot(mark_raw);
    ylim([-10 10])
    hold on
    for i = 1 : n_trl
        text(50+n_session*(i-1),max(max(mark_raw)),num2str(i));
    end
    stem(1:n_session:n_trl*(n_session),...
        min(min(mark_raw))*ones(n_trl,1),'r','LineWidth',2)
    stem(1:n_session:n_trl*(n_session),...
        max(max(mark_raw))*ones(n_trl,1),'r','LineWidth',2)
    hold off
    title(strrep(name_sub{i_sub},'_',' '))
    c = getframe(gcf);
    imwrite(c.cdata,fullfile(path_DB_process,sprintf('%s_%s.png',...
        name_folder4file,name_sub{i_sub})));
    close(gcf);
    end
    end
    %---------------------------------------------------------------------%
    % z- normalizaiton
    [mark_z,mark_mean,mark_std] = zscore(mark_raw,0,1);
        
    %--------------------plot z-normalization of Marker ------------------%
%     % plot
%     if(id_plot)
%     figure;
%     plot(mark_raw(:,4:6))
%     hold on
%     for i = 1 : n_trl
%         text(10+n_session*(i-1),max(max(mark_raw(:,4:6))),num2str(i));
%     end
%     stem(1:n_session:n_trl*(n_session),...
%         min(min(mark_raw(:,4:6)))*ones(n_trl,1),'k')
%     stem(1:n_session:n_trl*(n_session),...
%         max(max(mark_raw(:,4:6)))*ones(n_trl,1),'k')
% %     title('z normalization of Marker')
%     hold off
%     end
    %---------------------------------------------------------------------% 
    
    % min-max normalizaiton
    mark_max = max(mark_raw);
    mark_min = min(mark_raw);
    mark_n = (mark_raw-mark_min)./(mark_max-mark_min);
    
    %----------------------plot z-normalization of EMG ------------------%
%     % plot
%     if(id_plot)
%     figure;
%     plot(mark_raw(:,7:9))
%     hold on
%     for i = 1 : n_trl
%         text(10+n_session*(i-1),max(max(mark_raw(:,4:6))),num2str(i));
%     end
%     stem(1:n_session:n_trl*(n_session),...
%         min(min(mark_raw(:,4:6)))*ones(n_trl,1),'k')
%     stem(1:n_session:n_trl*(n_session),...
%         max(max(mark_raw(:,4:6)))*ones(n_trl,1),'k')
%     hold off
%     title('min max normalization of Marker')
%     end
    %---------------------------------------------------------------------% 
    
end
