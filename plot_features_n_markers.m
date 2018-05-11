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

%------------------------code analysis parameter--------------------------%
% name of raw DB
name_DB_raw = 'DB_raw2';

% name of process DB to analyze in this code
name_DB_process = 'DB_processed2';

% name of anlaysis DB in the process DB
name_DB_analy...
    = 'DB_raw2_marker_wsize_24_winc_12_emg_wsize_408_winc_204_delay_0';

% name of file emg DB
name_emg_file = 'emg_pair_emg_seg';

% name of file emg DB
name_marker_file = 'mark_mark_seg';

name_norm_method ='do_all_emotion'; %do_each, do_all_emotion
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

%--------------------experiment information-------------------------------%
% list of markers
name_mark = {'central down lip';'central nose';'central upper lip';'head 1';...
    'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';...
    'left dimple';'left down eye';'left down lip';'left eyebrow inside';...
    'left eyebrow outside';'left nose';'left upper eye';'left upper lip';...
    'right central lip';'right cheek';'right dimple';'right down eye';...
    'right down lip';'right eyebrow inside';'right eyebrow outside';...
    'right nose';'right upper eye';'right upper lip'};

name_fe = {'angry','clench','contm_left','contm_right',...
    'frown','fear','happy','kiss','neutral',...
    'sad','surprised'};

% idices of channels of emg and marekr of each part
fu.right_bottom = {1,[1,3,19,20,21,26]};
fu.right_top = {2,[24,25]};
fu.left_top = {3,[14,15]};
fu.left_bottom = {4,[1,3,9,10,11,16]};

name_fu = fieldnames(fu);
fu_cell = struct2cell(fu);


n_face_part = 4;

% idices of markers should be used in each emotions
idx_mark2use.happy.zygo = [10,16,20,26];
idx_mark2use.happy.lips = [1,3,9,11,19,21];

idx_mark2use.surprised.eyes = [14,15,24,25];
idx_mark2use.surprised.lips = [1,3,9,19];

idx_mark2use.frown.eyes = [14,15,24,25];
idx_mark2use.frown.zygo = [10,16,20,26];

idx_mark2use.contm_left.zygo = [10,16];
idx_mark2use.contm_left.lips = [1,3,9,11];

idx_mark2use.contm_right.zygo = [20,26];
idx_mark2use.contm_right.lips = [1,3,19,21];

idx_mark2use.angry.eyes = [14,15,24,25];

idx_mark2use.kiss.lips = [1,3,9,19];

names_fe2use = string(fieldnames(idx_mark2use));
idx_mark2use_cell = struct2cell(idx_mark2use);

n_win2use = 40;
% idx_trl2use(13) = [];
% n_trl2use = length(idx_trl2use);
basline_text = 50;
n_emg_ch = 4;
n_mark_type = 3;
% idx_marker2use = [1,3,9,10,11,14,15,16,19,20,21,25,25,26];

i_emg_pair = 1;


%-------------------------main--------------------------------------------%

% load emg
load(fullfile(path_DB_analy,name_emg_file));
[n_sub,n_trl,n_fe,n_emg_pair] = size(emg_seg);

% load marker
load(fullfile(path_DB_analy,name_marker_file));
[~,~,~,n_mark] = size(mark_seg);

%-------------------------normalization-----------------------------------%
switch name_norm_method
    case 'do_each'
        emg_seg = cellfun(@minmax_norm,emg_seg,...
                'UniformOutput',false);
        mark_seg = cellfun(@minmax_norm_abs,mark_seg,...
                'UniformOutput',false);
            
        % get path for saving
        path_DB_save = make_path_n_retrun_the_path(...
            path_DB_analy,name_norm_method);
    case 'do_all_emotion'
        for i_sub = 1 : n_sub
        for i_trl = 1 : n_trl
            tmp = cat(1,emg_seg{i_sub,i_trl,:,i_emg_pair});
            emg_seg(i_sub,i_trl,:,i_emg_pair) = mat2cell(minmax_norm(tmp),...
                n_win2use*ones(n_fe,1),4);
            for i_mark = 1 : n_mark
                tmp = cat(1,mark_seg{i_sub,i_trl,:,i_mark});
                mark_seg(i_sub,i_trl,:,i_mark) = ...
                    mat2cell(minmax_norm_abs(tmp),...
                    n_win2use*ones(n_fe,1),3);
            end
        end
        end
        % get path for saving
        path_DB_save = make_path_n_retrun_the_path(...
            path_DB_analy,name_norm_method);
end
%-------------------------------------------------------------------------%

for i_fe = 1 : length(idx_mark2use_cell)
    % display of facial expression
    disp(names_fe2use{i_fe});
    
    % get original index of fe
    idx_fe_org = find(contains(name_fe,names_fe2use{i_fe}));
    
    % get names of facial units of that emotion
    names_face_unit = fieldnames(idx_mark2use_cell{i_fe});
    
    % number of facial units
    n_fu = length(names_face_unit);
    
    % get facial unit of that emotion as cell format
    idx_fu_type_cell = struct2cell(idx_mark2use_cell{i_fe});
    
    for i_fu = 1 : n_fu
        % display of facial unit
        disp(names_face_unit{i_fu});
        
        % get index of marker which will be plotted
        idx_mark = idx_fu_type_cell{i_fu};
        disp(idx_mark);
        for i_mark = idx_mark
            % display of marker name
            disp(i_mark);
            
            % get channel of EMG to be plotted based on face parts
            tmp = [];
            for i_face_part = 1 : n_face_part
                if any(countmember(fu_cell{i_face_part}{2},i_mark))
                    tmp = [tmp;i_face_part];
                end
            end
            tmp2 = cat(1,fu_cell{tmp});
            idx_emg_chan2plot = cat(1,tmp2{:,1});
            
            % get DB of that emotion
            tmp_mark = mark_seg(:,:,idx_fe_org,i_mark);
            tmp_emg = emg_seg(:,:,idx_fe_org,i_emg_pair);
            
            %------------------get median values--------------------------%
            mark_rep = zeros(n_win2use,n_mark_type);
            for i_mark_type = 1 : n_mark_type
                tmp = cellfun(@(x) x(:,i_mark_type), tmp_mark,...
                    'UniformOutput',false);
                tmp = cat(2,tmp{:});
                mark_rep(:,i_mark_type) = nanmedian(tmp,2);
            end
            
            emg_rep = zeros(n_win2use,n_emg_ch);
            for i_emg_ch = 1 : n_emg_ch
                tmp = cellfun(@(x) x(:,i_emg_ch), tmp_emg,...
                        'UniformOutput',false);
                tmp = cat(2,tmp{:});
                emg_rep(:,i_emg_ch) = nanmedian(tmp,2);
            end
            %-------------------------------------------------------------%

            name_save = sprintf('%d-%s_%s_%d-%s',...
                idx_fe_org,names_fe2use{i_fe},...
                names_face_unit{i_fu},...
                i_mark,name_mark{i_mark});
            disp(name_save); 
            %--------------------------plot---------------------------%            
            h1 = figure('Name',name_save,'NumberTitle','off');
            subplot(2,1,1);
            title('marker median 값')
            plot(mark_rep(:,1:2));
            ylim([-1 1])
            subplot(2,1,2);
            title('emg median 값')
            plot(emg_rep);
            ylim([-1 1])
            % make it more tight
            tightfig(h1);
            
            h2 = figure('Name',name_save,'NumberTitle','off');
            c = 0;
            for i_sub = 1 : n_sub
                for i_trl = 1 : n_trl
                    c = c + 1;
                    subplot(n_sub,n_trl,c)
                    plot(tmp_mark{i_sub,i_trl}(:,1:2))
                    hold on;
                    plot(tmp_emg{i_sub,i_trl}(:,idx_emg_chan2plot),'k');
                    ylim([-1 1])
                    set(gca,'XTick',[]);
                    set(gca,'YTick',[]);
                end
            end
            % make it more tight
            tightfig(h2);
            %-----------------------save fig--------------------------%
            savefig(h1,fullfile(path_DB_save,[name_save,'_rep']));
            savefig(h2,fullfile(path_DB_save,name_save));
            %---------------------------------------------------------%
            close all;
        end
    end
end



%=========================functions=======================================%




%=========================================================================%

% back up 
% for i_emg_pair = 1
% for i_mark = idx_marker2use(1:7)
%     fprintf('i_mark: %d',i_mark);
%     % read file names
%     tmp_mark = cell(n_trl,n_sub);
%     emg_seg = cell(n_trl,n_sub);
%     for i_sub = 1 : n_sub
%         for i_trl = 1 : n_trl
%             %--------------------------marker-----------------------------%
%             % folder name to load 
%             name_folder4file = sprintf('%s_mark_%d',name_folder_marker,i_mark);
%     
%             % set path
%             path = fullfile(path_DB_analy,name_folder4file);
%     
%             % load 
%             load(fullfile(path, sprintf('sub_%03d_trl_%03d.mat',...
%                 i_sub,i_trl)));
%             
%             % rearrange with faxial expression
%             tmp_mark{i_trl,i_sub} = mat2cell(mark_median_proc,n_seg2use*ones(n_fe,1),n_mark_type);
%             %-------------------------------------------------------------%
%             
%              %--------------------------emg-------------------------------%
%             % folder name to load 
%             name_folder4file = sprintf('%s_%d_RMS',name_folder_emg,i_emg_pair);
%              
%             % set path
%             path = fullfile(path_DB_analy,name_folder4file);
%     
%             % load 
%             load(fullfile(path, sprintf('sub_%03d_trl_%03d.mat',...
%                 i_sub,i_trl)));
%             
%             % rearrange with faxial expression
%             emg_seg{i_trl,i_sub} = mat2cell(emg_segment_proc,n_seg2use*ones(n_fe,1),4);
%             %-------------------------------------------------------------%
%         end
%     end
%     tmp_mark = cat(2,tmp_mark{:});
%     emg_seg = cat(2,emg_seg{:});
%     
%     for i_fe = idx_fe2use
%         tmp_mark_ = reshape(tmp_mark(i_fe,:),n_sub,n_trl);
%         tmp_mark_ = cellfun(@minmax_norm_abs,tmp_mark_,'UniformOutput',false);
%         
%         emg_seg_ = reshape(emg_seg(i_fe,:),n_sub,n_trl);
%         emg_seg_ = cellfun(@minmax_norm,emg_seg_,'UniformOutput',false);
%         
%         name_save = sprintf('감정-%s 마커-%s',name_fe{i_fe},name_mark{i_mark});
%         disp(name_save); %#ok<DSPS>
%         figure('Name',name_save,'NumberTitle','off');
%         c = 0;
%         for i_sub = 1 : n_sub
%             for i_trl = 1 : n_trl
%                 c = c + 1;
%                 subplot(n_trl,n_sub,c)
%                 % upper part: [14,15,24,25]
%                 if ~isempty(find(countmember([14,15,24,25],i_mark)==1, 1))
%                     idx_tmp = [2,3]; 
%                 else 
%                 %bottom part:[1,3,9,10,11,16,19,20,21,26];
%                     idx_tmp = [1,4];
%                 end
%                 plot(tmp_mark_{i_sub,i_trl})
%                 hold on;
%                 plot(emg_seg_{i_sub,i_trl}(:,idx_tmp),'k');
%                 set(gca,'XTick',[]);
%                 set(gca,'YTick',[]);
%             end
%         end
%         % make it more tight
%         tightfig;
% 
%         %-----------------------save fig----------------------------------%
%         savefig(gcf,fullfile(path_DB_analy,name_save));
%         %-----------------------------------------------------------------%
%         
%         close;
%     end
% 
%     
% end
% end


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
    
    %memory allocations
% tmp_mark = cell(n_sub,n_trl,n_mark,n_fe);
% emg_seg = cell(n_sub,n_trl,n_fe);
%     
% for i_sub = 1 : n_sub
% for i_trl = 1 : n_trl
% for i_mark = 1 : n_mark
%     fprintf('i_sub-%d i_trl-%d i_mark-%d\n',i_sub,i_trl,i_mark)
%     %--------------------------marker-----------------------------%
%     folder name to load 
%     name_folder4file = sprintf('%s_mark_%d',name_folder_marker,i_mark);
% 
%     set path
%     path = fullfile(path_DB_analy,name_folder4file);
% 
%     load 
%     load(fullfile(path, sprintf('sub_%03d_trl_%03d.mat',...
%         i_sub,i_trl)));
% 
%     rearrange with faxial expression
%     tmp_mark(i_sub,i_trl,i_mark,:) = mat2cell(mark_median_proc,...
%         n_win2use*ones(n_fe,1),n_mark_type);
%     %-------------------------------------------------------------%
% 
%      
%     
% end
%     %--------------------------emg-------------------------------%
%     folder name to load 
%     name_folder4file = sprintf('%s_%d_RMS',name_folder_emg,i_emg_pair);
% 
%     set path
%     path = fullfile(path_DB_analy,name_folder4file);
% 
%     load 
%     load(fullfile(path, sprintf('sub_%03d_trl_%03d.mat',...
%         i_sub,i_trl)));
% 
%     rearrange with faxial expression
%     emg_seg(i_sub,i_trl,:) = mat2cell(emg_segment_proc,n_win2use*ones(n_fe,1),4);
%     -------------------------------------------------------------%
% end
% end