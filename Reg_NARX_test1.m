%--------------------------------------------------------------------------
% NARX를 이용해 regression 하는 함수
% NARX는 입력 뿐만 아니라 출력은 feedback 하여, 미래의 data를 예측 하는 함수임
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
%% prepare DB and functions
clc; close all; clear ;
path_parent=fileparts(pwd); % parent path which has DB files
addpath(genpath(fullfile(cd,'functions'))); % add path for functions
path_DB_processed = fullfile(path_parent,'DB','DB_processed');
%% experiment information
N_mark = 28;
N_sub = 21;
idx_sub = 1 : N_sub; % idices of subjects
idx_trl = 1 : 15; % idices of subjects
idx_sub4train = 1 : 19; % indices of subjects for train DB <subject-indepedent>
% idx_sub4train(10) = [];
idx_trl4train = 1 : 5; % indices of trials for train DB <subject-depedent>
idx_sub2use_sjdt = 1; % indices of subjects to use in <subject-depedent>
name_markers = {'central down lip';'central nose';'central upper lip';...
    'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';...
    'left cheek';'left dimple';'left down eye';'left down lip';...
    'left eyebrow inside';'left eyebrow outside';'left nose';...
    'left upper eye';'left upper lip';'right central lip';'right cheek';...
    'right dimple';'right down eye';'right down lip';...
    'right eyebrow inside';'right eyebrow outside';'right nose';...
    'right upper eye';'right upper lip'}; % name_markers
%% decide processed DB file
name_folder_analy = 'windows_ds_10Hz_ovsize_50_delay_0';
%% decide EMG bipolar pair
idx_emg_pair = 2;
%% decide validation typ
id_val_type= 'sjdt'; %choose 'sjit' (subject independent) or 'sjdt'(subject dependent)
%% decide if you are going to use saved network or not
id_using_saved_network = 0;
%% decide if you are going to save network trained in this code
id_save_network = 0;
%% decide features of EMG and channels of Markers
idx_use_mark_type = 1:3; % X Y Z
idx_use_emg_feat = 1:8;
idx_emg_feat_for_net1 = 1:4;
%% decide sequence sizes which fed into NARX network
len_seq = 100;% seq size
%% decide paramter of NARX network
idx_num_of_hidden_layer = 40:20:100;
idx_num_of_input_delay = 2:10;
idx_num_of_ouput_delay = 1:2:10;
%% memory allocation for results
Target = cell(N_mark,1);
Output = cell(N_mark,1);
%% construct NARX network with respect to each marker
% for i_mark = 1 : N_mark
for i_mark = 11
    disp(name_markers(i_mark)); %display curr marker
    if(i_mark==2) % if it is nose marker, skip
        continue;
    end
    %% memory allocation for NARX models
    Networks = cell(length(idx_num_of_hidden_layer)*...
        length(idx_num_of_input_delay)*...
        length(idx_num_of_ouput_delay),1);
    count = 0;
    for N_hidden_layer = idx_num_of_hidden_layer % apply num of hidden layer
    for N_input_delay = idx_num_of_input_delay % apply num of input delay
        delay_input = 2:N_input_delay;
    for N_output_delay = idx_num_of_ouput_delay % apply num of ouput delay
        delay_output = 1:N_output_delay;
        %     for idx_sub_4testing = 1:21
        disp([N_hidden_layer,N_input_delay,N_output_delay]); % display of curr parameters
        count = count + 1;
        %% get marker set
        path_file = fullfile(path_DB_processed,name_folder_analy,...
            sprintf('z_norm_mark_%d',i_mark),'marker_set');
        load(path_file);
        marker_set = cellfun(@(x) x(:,idx_use_mark_type),marker_set,'UniformOutput', false);

        % EMG feat 추출  및 EMG와 시점 맞춤
        path_file = fullfile(path_DB_processed,name_folder_analy,...
            sprintf('z_norm_emg_pair_%d',idx_emg_pair),'feat_set_RMSWL');
        load(path_file);
        feat_set = cellfun(@(x) x(:,idx_use_emg_feat),feat_set,'UniformOutput', false); % 1:4번 채널만
        %% ignore the last windows which can not be divided by seq size
        for i=1:numel(feat_set)
            temp = floor(length(marker_set{i})/len_seq);
            marker_set{i} = marker_set{i}(1:temp*len_seq,:);
            feat_set{i} = feat_set{i}(1:temp*len_seq,:);
        end
        %% Divide Train/Test
        switch id_val_type
            case 'sjit' % subject independnet
                % (val_subject_indepe=1 --> subject indep)
                %     if val_subject_indepe==1
                Input_train = feat_set(idx_sub4train,:);
                Target_train = marker_set(idx_sub4train,:);
                idx_sub4test = find(countmember(idx_sub,idx_sub4train)==0);
                Input_test = feat_set(idx_sub4test,:);
                Target_test = marker_set(idx_sub4test,:);
                %     else
            case  'sjdt' % subject dependent
                Input_train = feat_set(idx_sub2use_sjdt,idx_trl4train);
                Target_train = marker_set(idx_sub2use_sjdt,idx_trl4train);
                idx_trl4test = find(countmember(idx_trl,idx_trl4train)==0);
                Input_test = feat_set(idx_sub2use_sjdt,idx_trl4test);
                Target_test = marker_set(idx_sub2use_sjdt,idx_trl4test);
        end        
        %% Train DB perperation (the mat--> cell --> sequential vector)
        % input of train
        for i= 1:numel(Input_train)
            Input_train{i} = mat2cell(Input_train{i},repmat(len_seq,...
                [length(Input_train{i})/len_seq,1]),length(idx_use_emg_feat));
        end
        Input_train = cat(1,Input_train{:});
        Input_train = cellfun(@(x) x',Input_train,'UniformOutput', false);
        Input_train = cellfun(@con2seq ,Input_train,'UniformOutput', false); % cell 형식으로 바꾸기
        % target of train
        for i= 1:numel(Target_train)
            Target_train{i} = mat2cell(Target_train{i},repmat(len_seq,[length(Target_train{i})/len_seq,1]),3);
        end
        Target_train = cat(1,Target_train{:});
        Target_train = cellfun(@(x) x',Target_train,'UniformOutput', false);
        Target_train = cellfun(@con2seq ,Target_train,'UniformOutput', false); % cell 형식으로 바꾸기
        %% Concatenate data samples, and get seqence formation
        % cell size --> 1 X seq size
        % element of cell --> N_feat X Train Samples
        Input_train_seq = catsamples(Input_train{:});
        Target_train_seq = catsamples(Target_train{:});
        %% Test DB preparation
        % input of Test
        Input_test = cellfun(@(x) x(:,idx_use_emg_feat),Input_test,...
            'UniformOutput', false); % 1:4번 채널만
        % Target of test
        Target_test = cellfun(@(x) x(:,idx_use_mark_type),Target_test,...
            'UniformOutput', false); % 6번채널만 regression
        %% get networks with respect to feature type
        Input_train4net1 = cellfun(@(x) x(idx_emg_feat_for_net1,:),Input_train_seq,...
            'UniformOutput', false);
        %     Xtr_series_net2 = cellfun(@(x) x(EMG_feat_for_net2,:),Xtr_series,...
        %          'UniformOutput', false);
        %% Get Network using NARX 
        % which network can be regarded as system matrix in perspective of Kalman filter
        if id_using_saved_network ~=1
            %% Network creation
            net_NARX = narxnet(delay_input,delay_output,N_hidden_layer);
            net_NARX.divideFcn = '';
            net_NARX.trainParam.min_grad = 1e-10;
            %% data preperation
            [Input_ser_train,Input_del_stat_train,...
                Init_lay_del_train,Target_ser_train] = ...
                preparets(net_NARX,Input_train4net1,{},Target_train_seq);
            %% train in open loop
            net_NARX = train(net_NARX,Input_ser_train,Target_ser_train,Input_del_stat_train);
            view(net_NARX)
            %% close loop
            netc_NARX = closeloop(net_NARX);
            view(netc_NARX)
            %% Network 저장
            if id_save_network
                save('network.mat','net_NARX');
            end
        end
        %% validate NARX network on Test DB
        R.rmse = zeros(numel(Input_test),3);
        for i = 1 : numel(Input_test)
            %% test DB preperation  (an trial data --> seq form)
            Input_test_trl = con2seq(Input_test{i}');
            Target_test_trl = con2seq(Target_test{i}');
            Input_test_trl = cellfun(@(x) x(idx_emg_feat_for_net1),Input_test_trl,...
                'UniformOutput', false);
            %% get initial conditions of the sequence
            [Input_ser_test,Input_del_stat_test,...
                Init_lay_del_test,Target_ser_shift_test] = ...
                preparets(netc_NARX,Input_test_trl,{},Target_test_trl);
            %% classify test DB
            Output_test = netc_NARX(Input_ser_test,Input_del_stat_test,Init_lay_del_test);
            view(netc_NARX)
            %% plot target and outputs of test DB
            TS = size(Target_ser_shift_test,2);
            Target_ser_shift_test = cell2mat(Target_ser_shift_test);
            Output_test = cell2mat(Output_test);
            for i_m_type = 1 : 3
                figure(i_m_type);
                plot(1:TS,Target_ser_shift_test(i_m_type,:),'b',1:TS,Output_test(i_m_type,:),'r')
            end
            %% get RMSE
            R.rmse(i,:) = rms((Target_ser_shift_test-Output_test)');
            %% save target, ouputs
            Target{i_mark} = Target_ser_shift_test;
            Output{i_mark} = Output_test;
            %% get R^2
            R.r_square = compute_r_square(Target_ser_shift_test,Output_test);
        end
        %% saveing resuts
        Networks{count}.result = R;
        Networks{count}.hiddenlayer = N_hidden_layer;
        Networks{count}.xdelay = delay_input;
        Networks{count}.ydelay = delay_output;
        Networks{count}.net = net_NARX;
    end
    end
    end
end 
%     % 결과 정리
%     temp = cell2mat(model);
%     [~,idx_sorted] = sort(mean(cat(1,temp.rmse),2));
%
%     model = model(idx_sorted); % RMSE 평균이 작은 값으로 Sorting
%     temp = cell2mat(model);
%     hidden_layer = cat(1,temp.hiddenlayer);
%     x_delay = cat(1,{temp.xdelay}');
%     y_delay = cat(1,{temp.ydelay}');
%     RMSE =  cat(1,temp.rmse);
%
%     results_arranged = [x_delay,y_delay,num2cell(hidden_layer),...
%         num2cell(RMSE(:,1)),num2cell(RMSE(:,2)),num2cell(RMSE(:,3)),...
%         num2cell(mean(RMSE,2))];

