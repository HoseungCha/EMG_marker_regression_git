%--------------------------------------------------------------------------
% NARX�� �̿��� regression �ϴ� �Լ�
% NARX�� �Է� �Ӹ� �ƴ϶� ����� feedback �Ͽ�, �̷��� data�� ���� �ϴ� �Լ���
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------

clc; close all; clear ;


%------------------------code analysis parameter--------------------------%
% name of raw DB
name_DB_raw = 'DB_raw2';

% name of process DB to analyze in this code
name_DB_process = 'DB_processed2';

% name of anlaysis DB in the process DB
name_DB_analy = 'DB_raw2_to_10Hz_cam_winsize_24_wininc_12_emg_winsize_408_wininc_204_delay_0';

% name of processed Marker
name_marker_process = 'median_v_proc_mark';

% name of proccessed EMG
name_emg_process = 'feat_seg_emg_pair';
name_emg_feat = 'RMS';

% idx of subject and trial you want to anlayize
idx_sub = 2; % idices of subjects
idx_trl = 1 : 20; % idices of trials
idx_trl(2:3) = [] % 2,3 tiral ���� �м�

% decide validation typ
id_val_type= 'sjdt'; %choose 'sjit' (subject independent) or 'sjdt'(subject dependent)

% idx of subject you want to use as train DB in subject independent
% validation
idx_sub4train = 1 : 19; 

% idx of trial you want to use as train DB in subject-depedent
% validation
idx_trl4train = [1,4,5,6,7];

% decide if you are going to use saved network or not
id_using_saved_network = 0;

% decide if you are going to save network trained in this code
id_save_network = 1;

% decide paramter of NARX network
idx_num_of_hidden_layer = 30;
idx_num_of_input_delay = 5;
idx_num_of_ouput_delay = 5;
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
path_research = fileparts(fileparts(fileparts(fullfile(cd))));
path_code = fileparts(fullfile(cd));
path_DB = fullfile(path_code,'DB');
path_DB_raw = fullfile(path_DB,name_DB_raw);
path_DB_process = fullfile(path_DB,name_DB_process);
path_DB_analy = fullfile(path_DB_process,name_DB_analy);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
addpath(genpath(fullfile(path_research,'_toolbox')));
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%

%------------------------experiment infromation---------------------------%
% experiment information
n_mark = 28;
n_mark_type = 3; 
n_sub = length(idx_sub);
n_trl = 20;
n_fe = 11;
name_markers = {'central down lip';'central nose';'central upper lip';...
    'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';...
    'left cheek';'left dimple';'left down eye';'left down lip';...
    'left eyebrow inside';'left eyebrow outside';'left nose';...
    'left upper eye';'left upper lip';'right central lip';'right cheek';...
    'right dimple';'right down eye';'right down lip';...
    'right eyebrow inside';'right eyebrow outside';'right nose';...
    'right upper eye';'right upper lip'}; % name_markers
n_emg_pair = 3;
%-------------------------------------------------------------------------%


%----------------------------paramters------------------------------------%

%-------------------------------------------------------------------------%

%----------------------set saving folder----------------------------------%
path_save_network = make_path_n_retrun_the_path(path_DB_analy,'network');

% name_folder4saving = sprintf(...
% 'emg_set_n_sub_%d_n_seg_%d_n_wininc_%d_winsize_%d',...
%     n_sub,n_seg,n_wininc,n_winsize);
% path_save = make_path_n_retrun_the_path(fullfile(path_DB_process),...
%     name_folder4saving);
%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%
target = cell(n_mark,1);
output = cell(n_mark,1);
%-------------------------------------------------------------------------%


%----------construct NARX network with respect to each marker-------------%
% for i_emg_pair = 1 : n_emg_pair
for i_emg_pair = 1    
% for i_mark = 1 : N_mark
for i_mark = 12
    count_net = 0;
    %display curr marker
    disp(name_markers(i_mark)); 
    
    % if it is nose marker, skip
    if(i_mark==2) 
        continue;
    end

    %--------do analysis with many different network parameters-----------%
    for n_hidden_layer = idx_num_of_hidden_layer % apply num of hidden layer
    for n_input_delay = idx_num_of_input_delay % apply num of input delay
    for n_output_delay = idx_num_of_ouput_delay % apply num of ouput delay
        
        %--------------------input and out delays-------------------------%
        delay_input = 0:n_input_delay;
        delay_output = 1:n_output_delay;
        %-----------------------------------------------------------------%
        
        %---------display of current network parameters-------------------%
        disp([n_hidden_layer,n_input_delay,n_output_delay]); 
        count_net = count_net + 1;
        %-----------------------------------------------------------------%
        
        %-------------------------set path to save------------------------%
        name_folder4saving = sprintf(...
            'hl_%d_input_d_%s_output_d_%s_sub_%s',...
            n_hidden_layer,strrep(num2str(delay_input),' ',''),...
            strrep(num2str(delay_output),' ',''),...
            strrep(num2str(idx_sub),' ',''));
        path_save = make_path_n_retrun_the_path(path_DB_analy,...
        name_folder4saving);
        %-----------------------------------------------------------------%
    
    
        %-----------------------load marker proc--------------------------%
        path_marker_analy = fullfile(path_DB_analy,...
            sprintf('%s_%d',name_marker_process,i_mark));
        
        % read file path of marker data 
        [name,path] = read_names_of_file_in_folder(path_marker_analy,'*.mat');
        
        % get indices from subject and trial from file name;
        n_file = length(name);
        idx_sub_marker = zeros(n_file,1);
        idx_trl_marker = zeros(n_file,1);
        for i_trl = 1 : n_file
            tmp = strsplit(name{i_trl},'.');
            tmp = strsplit(tmp{1},'_');
            idx_sub_marker(i_trl) = str2double(tmp{2});
            idx_trl_marker(i_trl) = str2double(tmp{4});
        end
        
        % load and change struct into cell
        marker_set = struct2cell(cellfun(@load, path))';
        %-----------------------------------------------------------------%
        
        %-----------------------load emg processed------------------------%
        path_emg_analy = fullfile(path_DB_analy,...
            sprintf('%s_%d_%s',name_emg_process,i_emg_pair,name_emg_feat));
        
        % read file path of marker data 
        [name,path] = read_names_of_file_in_folder(path_emg_analy,'*.mat');
        
        % get indices from subject and trial from file name;
        n_file = length(name);
        idx_sub_emg = zeros(n_file,1);
        idx_trl_emg = zeros(n_file,1);
        for i_trl = 1 : n_file
            tmp = strsplit(name{i_trl},'.');
            tmp = strsplit(tmp{1},'_');
            idx_sub_emg(i_trl) = str2double(tmp{2});
            idx_trl_emg(i_trl) = str2double(tmp{4});
        end
        
        % load and change struct into cell
        emg_set = struct2cell(cellfun(@load, path))';
        %-----------------------------------------------------------------%

        %-------get marker and emg of subjejct and trial------------------%
        % which you will train/testd emg processed
        tmp = logical(countmember(idx_sub_emg,idx_sub).*...
            countmember(idx_trl_emg,idx_trl));
        emg_set = emg_set(tmp);
        idx_sub_emg = idx_sub_emg(tmp);
        idx_trl_emg = idx_trl_emg(tmp);
        
        tmp = logical(countmember(idx_sub_marker,idx_sub).*...
            countmember(idx_trl_marker,idx_trl));
        marker_set = marker_set(tmp);
        idx_sub_marker = idx_sub_marker(tmp);
        idx_trl_marker = idx_trl_marker(tmp);
        %-----------------------------------------------------------------%
        
        %--------------------Divide Train/Test----------------------------%
        switch id_val_type
            case 'sjit' % subject independnet
                tmp = countmember(idx_sub_emg,idx_sub4train)==1;
                tr_input = emg_set(tmp);
                
                tmp = countmember(idx_sub_marker,idx_sub4train)==1;
                tr_target = marker_set(tmp);
                
                tmp = countmember(idx_sub_emg,idx_sub4train)==0;
                te_input = emg_set(tmp);
                
                tmp = countmember(idx_sub_marker,idx_sub4train)==0;
                te_target = marker_set(tmp);
             
            case 'sjdt' % subject dependent
                tmp = countmember(idx_trl_emg,idx_trl4train)==1;
                tr_input = emg_set(tmp);
                
                tmp = countmember(idx_trl_marker,idx_trl4train)==1;
                tr_target = marker_set(tmp);
                
                tmp = countmember(idx_trl_emg,idx_trl4train)==0;
                te_input = emg_set(tmp);
                
                tmp = countmember(idx_trl_marker,idx_trl4train)==0;
                te_target = marker_set(tmp);
        end        
        %-----------------------------------------------------------------%
        
        %--------------------get train/test sequence----------------------%
        n_emg_feat = size(emg_set{1},2);
        n_samp_fe = size(emg_set{1},1)/n_fe;
        % train
        % target (Marker)
        tmp = cellfun(@(x) mat2cell(x,repmat(n_samp_fe,n_fe,1),n_mark_type),...
            tr_target,'UniformOutput',false);
        tmp = cat(1,tmp{:});
        tmp = cellfun(@(x) con2seq(x'),tmp,'UniformOutput', false);
        tr_target_seq = catsamples(tmp{:});
        
        
%         % do normalization to EMG <max(abs(marker_tr))/max(emg_tr)>
        tr_target_max = mean(cell2mat(cellfun(@(x) max(abs(x)),...
            tr_target,'UniformOutput',false)));
        
        tr_input_max = mean(cell2mat(cellfun(@(x) max(abs(x)),...
            tr_input,'UniformOutput',false)));
        
        
       
        % input (EMG)
        tmp = cellfun(@(x) mat2cell(x,repmat(n_samp_fe,n_fe,1),n_emg_feat),...
            tr_input,'UniformOutput',false);
        tmp = cat(1,tmp{:});
        tmp = cellfun(@(x) con2seq(x'),tmp,'UniformOutput', false);
        tr_input_seq = catsamples(tmp{:});
        
        % test
        te_input_seq = cellfun(@(x) con2seq(x'),te_input,'UniformOutput', false);
        te_target_seq = cellfun(@(x) con2seq(x'),te_target,'UniformOutput', false);
        %-----------------------------------------------------------------%

        % decide if you use existing network
        if id_using_saved_network ~=1
            
        %--------------------construct networks---------------------------%
        % Get Network using NARX 
        % which network can be regarded as system matrix in perspective of Kalman filter
        % Network creation
        net.narx = narxnet(delay_input,delay_output,n_hidden_layer);
        net.narx.divideFcn = '';
        net.narx.trainParam.min_grad = 1e-10;
        %-----------------------------------------------------------------%
        
        % data preperation as [Xs,Xi,Ai,Ts]
        [tr_is,tr_ii,tr_ai,tr_ts] = ...
            preparets(net.narx,tr_input_seq,{},tr_target_seq);
        
        % train in open loop
        net.narx = train(net.narx,tr_is,tr_ts,tr_ii);
%         view(net.narx)
        
        % close loop
        net.narx_c = closeloop(net.narx);
%         view(net.narx_c)
        
        %-------------------------save network----------------------------%
        save(fullfile(path_save,'net.mat'),'net');
        %-----------------------------------------------------------------%
        end
        
        %-----------validattion of network on Test DB---------------------%
        n_test = numel(te_input_seq);
        r.rmse = zeros(n_test,n_mark_type);
        db.input = cell(n_test,n_mark_type);
        db.output = cell(n_test,n_mark_type);
        db.target = cell(n_test,n_mark_type);
        for i_trl = 1 : n_test
            
            % data preperation as [Xs,Xi,Ai,Ts]
            [te_is,te_ii,te_ai,te_ts] = ...
                preparets(net.narx_c,te_input_seq{i_trl},{},...
                te_target_seq{i_trl});
            
            % classify test DB
            te_output = net.narx_c(te_is,te_ii,te_ai);
%             view(net.narx_c)
            
            % save target, ouputs
            db.input{i_trl} = cell2mat(te_is);
            db.output{i_trl} = cell2mat(te_output);
            db.target{i_trl} = cell2mat(te_ts);
            
            % plot target and outputs of test DB
            n_samp_test = size(db.target{i_trl},2);
            figure(i_trl);
            for i_m_type = 1 : n_mark_type
                subplot(n_mark_type,1,i_m_type)
                plot(1:n_samp_test,db.target{i_trl}(i_m_type,:),'b',...
                    1:n_samp_test,db.output{i_trl}(i_m_type,:),'r')
            end
            savefig(gcf,fullfile(path_save,sprintf('fig_test_%d.fig',...
                i_trl)))
            close;
            % get RMSE
            r.rmse(i_trl,:) = rms((db.target{i_trl}-db.output{i_trl})');
            
            % get R^2
            r.r_square = compute_r_square(db.target{i_trl},db.output{i_trl});
        end
        %-----------------------------------------------------------------%
        
        %-------------------------save results----------------------------%
        save(fullfile(path_save,'results.mat'),'r','db');
        %-----------------------------------------------------------------%

    end
    end
    end
end 
end
%     % ��� ����
%     temp = cell2mat(model);
%     [~,idx_sorted] = sort(mean(cat(1,temp.rmse),2));
%
%     model = model(idx_sorted); % RMSE ����� ���� ������ Sorting
%     temp = cell2mat(model);
%     hidden_layer = cat(1,temp.hiddenlayer);
%     x_delay = cat(1,{temp.xdelay}');
%     y_delay = cat(1,{temp.ydelay}');
%     RMSE =  cat(1,temp.rmse);
%
%     results_arranged = [x_delay,y_delay,num2cell(hidden_layer),...
%         num2cell(RMSE(:,1)),num2cell(RMSE(:,2)),num2cell(RMSE(:,3)),...
%         num2cell(mean(RMSE,2))];

