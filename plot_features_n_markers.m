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
% name of raw DB
name_DB_raw = 'DB_raw2';
% name of process DB to analyze in this code
name_folder_in_DB_prc = 'DB_raw2_to_10Hz_cam_winsize_24_wininc_12_emg_winsize_408_wininc_204_delay_0';
name_folder_emg = 'feat_seg_emg_pair';
name_folder_marker = 'median_v_proc';
id_plot = 1;
%-------------------------------------------------------------------------%

% get toolbox
addpath(genpath(fullfile(fileparts(fileparts(fileparts(cd))),'_toolbox')));

% add functions
addpath(genpath(fullfile(cd,'functions')));

% path for processed data
path_code=fileparts(pwd); % parent path which has DB files

% get path
path_DB = fullfile(path_code,'DB');
path_DB_process = fullfile(path_DB,'DB_processed2');
path_DB_analy = fullfile(path_DB_process,name_folder_in_DB_prc);
%--------------------experiment information-------------------------------%

% list of markers
name_mark = {'central down lip';'central nose';'central upper lip';'head 1';...
    'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';...
    'left dimple';'left down eye';'left down lip';'left eyebrow inside';...
    'left eyebrow outside';'left nose';'left upper eye';'left upper lip';...
    'right central lip';'right cheek';'right dimple';'right down eye';...
    'right down lip';'right eyebrow inside';'right eyebrow outside';...
    'right nose';'right upper eye';'right upper lip'};

name_trl = {"ȭ��",1,1;"��ݴϱ�����",1,2;"�����(����)",1,3;"�����(������)",...
    1,4;"�� ���� ����",1,5;"�η���",1,6;"�ູ",1,7;"Ű��",2,1;"��ǥ��",2,2;...
    "����",2,3;"���",2,4};
name_FE = name_trl(:,1);

% read file path of data from raw DB
[name_sub,path_sub] = read_names_of_file_in_folder(fullfile(path_DB,name_DB_raw));
n_sub = length(name_sub);
idx_sub2use = 1:n_sub;
n_emg_pair = 3;
n_mark = 28;
n_fe = 11;
idx_trl2use = 1:20;
n_seg2use = 40;
% idx_trl2use(13) = [];
n_trl2use = length(idx_trl2use);
n_trl= 20;
basline_text = 50;
n_mark_type = 3;
idx_marker2use = [1,3,9,10,11,14,15,16,19,20,21,25,25,26];

for i_emg_pair = 1
for i_mark = idx_marker2use(1:7)
    fprintf('i_mark: %d',i_mark);
    % read file names
    tmp_mark = cell(n_trl,n_sub);
    tmp_emg = cell(n_trl,n_sub);
    for i_sub = 1 : n_sub
        for i_trl = 1 : n_trl
            %--------------------------marker-----------------------------%
            % folder name to load 
            name_folder4file = sprintf('%s_mark_%d',name_folder_marker,i_mark);
    
            % set path
            path = fullfile(path_DB_analy,name_folder4file);
    
            % load 
            load(fullfile(path, sprintf('sub_%03d_trl_%03d.mat',...
                i_sub,i_trl)));
            
            % rearrange with faxial expression
            tmp_mark{i_trl,i_sub} = mat2cell(mark_median_proc,n_seg2use*ones(n_fe,1),n_mark_type);
            %-------------------------------------------------------------%
            
             %--------------------------emg-------------------------------%
            % folder name to load 
            name_folder4file = sprintf('%s_%d_RMS',name_folder_emg,i_emg_pair);
             
            % set path
            path = fullfile(path_DB_analy,name_folder4file);
    
            % load 
            load(fullfile(path, sprintf('sub_%03d_trl_%03d.mat',...
                i_sub,i_trl)));
            
            % rearrange with faxial expression
            tmp_emg{i_trl,i_sub} = mat2cell(emg_segment_proc,n_seg2use*ones(n_fe,1),4);
            %-------------------------------------------------------------%
        end
    end
    tmp_mark = cat(2,tmp_mark{:});
    tmp_emg = cat(2,tmp_emg{:});
    
    for i_fe = 1: n_fe
        tmp_mark_ = reshape(tmp_mark(i_fe,:),n_sub,n_trl);
        tmp_mark_ = cellfun(@minmax_norm_abs,tmp_mark_,'UniformOutput',false);
        
        tmp_emg_ = reshape(tmp_emg(i_fe,:),n_sub,n_trl);
        tmp_emg_ = cellfun(@minmax_norm,tmp_emg_,'UniformOutput',false);
        
        name_save = sprintf('����-%s ��Ŀ-%s',name_FE{i_fe},name_mark{i_mark});
        disp(name_save); %#ok<DSPS>
        figure('Name',name_save,'NumberTitle','off');
        c = 0;
        for i_sub = 1 : n_sub
            for i_trl = 1 : n_trl
                c = c + 1;
                subplot(n_trl,n_sub,c)
                % upper part: [14,15,24,25]
                if ~isempty(find(countmember([14,15,24,25],i_mark)==1, 1))
                    idx_tmp = [2,3]; 
                else 
                %bottom part:[1,3,9,10,11,16,19,20,21,26];
                    idx_tmp = [1,4];
                end
                plot(tmp_mark_{i_sub,i_trl})
                hold on;
                plot(tmp_emg_{i_sub,i_trl}(:,idx_tmp),'k');
                set(gca,'XTick',[]);
                set(gca,'YTick',[]);
            end
        end
        % make it more tight
        tightfig;

        %-----------------------save fig----------------------------------%
        savefig(gcf,fullfile(path_DB_analy,name_save));
        %-----------------------------------------------------------------%
        
        close;
    end

    
end
end
% data [samples, channels]
function d_n =  minmax_norm(d)
v_max = max(d);
v_min = min(d);

d_n = (d - v_min)./(v_max-v_min);

d_n(:,(v_max-v_min)==0) = 0;
end

function d_n =  minmax_norm_abs(d)
v_max = max(abs(d));
v_min = min(abs(d));

d_n = (d - v_min)./(v_max-v_min);
d_n(:,(v_max-v_min)==0) = 0;
end


% back up 
    
%     %get number of features
%     n_mark_type = size(tmp_mark{1},2);
%     
%     %----------------------plot raw data of Marker with subject--------------%
%     % plot
%     if(id_plot)
%     for i_sub= 1:n_sub
%     %cell -> mat
%     mark_raw = cell2mat(tmp_mark(:,i_sub));
%     figure;
%     set(gcf,'Position',[1 41 1920 962]);
%     plot(mark_raw);
%     ylim([-20 20])
%     hold on
%     for i = 1 : n_trl
%         text(basline_text+n_session*(i-1),max(max(mark_raw)),num2str(i));
%     end
%     stem(1:n_session:n_trl*(n_session),...
%         min(min(mark_raw))*ones(n_trl,1),'r','LineWidth',2)
%     stem(1:n_session:n_trl*(n_session),...
%         max(max(mark_raw))*ones(n_trl,1),'r','LineWidth',2)
%     hold off
%     title(strrep(name_sub{i_sub},'_',' '))
%     savefig(gcf,fullfile(path_DB_analy,sprintf('%s_%s.fig',...
%         name_folder4file,name_sub{i_sub})))
% %     c = getframe(gcf);
% %     imwrite(c.cdata,fullfile(path_DB_analy,sprintf('%s_%s.png',...
% %         name_folder4file,name_sub{i_sub})));
%     close(gcf);
%     end
%     end
%     %---------------------------------------------------------------------%
%     % z- normalizaiton
%     [mark_z,mark_mean,mark_std] = zscore(mark_raw,0,1);
%         
    %--------------------plot z-normalization of Marker ------------------%
%     % plot
%     if(id_plot)
%     figure;
%     plot(mark_raw(:,4:6))
%     hold on
%     for i = 1 : n_trl
%         text(basline_text+n_session*(i-1),max(max(mark_raw(:,4:6))),num2str(i));
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
%     mark_max = max(mark_raw);
%     mark_min = min(mark_raw);
%     mark_n = (mark_raw-mark_min)./(mark_max-mark_min);
%     
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