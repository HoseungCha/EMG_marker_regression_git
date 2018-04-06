% NARX�� �̿��� regression �ϴ� �Լ�
% NARX�� �Է� �Ӹ� �ƴ϶� ����� feedback �Ͽ�, �̷��� data�� ���� �ϴ� �Լ���
clc; close all; clear ;

% ���� ����
N_mark = 28;
N_sub = 21;
Idx_sub = 1 : N_sub;
Idx_trl = 1 : 15;
Idx_sub4train = 1 : 19;
% Idx_sub4train(10) = [];
Idx_trl4train = 1 : 5;
Label_mark = {'central down lip';'central nose';'central upper lip';'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';'left dimple';'left down eye';'left down lip';'left eyebrow inside';'left eyebrow outside';'left nose';'left upper eye';'left upper lip';'right central lip';'right cheek';'right dimple';'right down eye';'right down lip';'right eyebrow inside';'right eyebrow outside';'right nose';'right upper eye';'right upper lip'};
delay = 1;
Idx_sub_4testing = 1;
% neuronsHiddenLayer = [30 30];
% % ��Ŀ �� �κ� ����
% fpath = fullfile(cd,'DB_v2','DB_markset','mark_nose');
% load(fpath);
    
% EMG/marker delay ����
N_delay = 5;

Idx_use_mark_type = 1:3;
Idx_use_emg_feat = 1:8;

EMG_feat_for_net1 = 1:4;

% validation ����
val_subject_indepe = 0;
use_saved_network = 0;
% seq size
seq_size = 100;
target = cell(N_mark,1);
output = cell(N_mark,1);
% for i_mark = 1 : N_mark
for i_mark = 11
    Label_mark(i_mark)
    if(i_mark==2)
        continue;
    end
    model = cell(length(40:20:100)*length(0:2:10)*length(1:2:10),1);
    count_model = 0;
    % network1
    
    for hiddenLayer = 30
    for i_xdelay = 5
        xdelay = 0:i_xdelay;
        
    for i_ydelay = 5
        ydelay = 1:i_ydelay;

%     for Idx_sub_4testing = 1:21
    [hiddenLayer,i_xdelay,i_ydelay]

    fpath = fullfile(cd,'DB_v2','DB_markset_10Hz_basecorr_norm_0-1',sprintf('mark_%d',i_mark));
    load(fpath);
    marker_set = cellfun(@(x) x(:,Idx_use_mark_type),marker_set,'UniformOutput', false); 
%     marker_set = cellfun(@(x) x(N_delay:end,Idx_use_mark_type),marker_set,'UniformOutput', false); % 6��ä�θ� regression
    
    % EMG feat ����  �� EMG�� ���� ����
    fpath = fullfile(cd,'DB_v2','emg_feat_set_10Hz','EMG_feat_normalized');
    load(fpath);
    feat = cellfun(@(x) x(:,Idx_use_emg_feat),feat,'UniformOutput', false); % 1:4�� ä�θ�
    
    % 10������ Train/Test �ϱ� ����, 10�� ����� ������ ����
    for i=1:numel(feat)
        temp_div = length(marker_set{i})/seq_size;
        temp_z = floor(temp_div);
        if (temp_div -temp_z) ==0
           continue; 
        else
            marker_set{i} = marker_set{i}(1:temp_z*seq_size,:);
            feat{i} = feat{i}(1:temp_z*seq_size,:);
        end
    end
    
    %% Train/Test DB ���� 
    % (val_subject_indepe=1 --> subject indep)
    if val_subject_indepe==1
        Xtr_ = feat(Idx_sub4train,:);
        Ttr_ = marker_set(Idx_sub4train,:);
        Idx_sub4test = find(countmember(Idx_sub,Idx_sub4train)==0);
        Xte_ = feat(Idx_sub4test,:);
        Tte_ = marker_set(Idx_sub4test,:);
    else
        Xtr_ = feat(Idx_sub_4testing,Idx_trl4train);
        Ttr_ = marker_set(Idx_sub_4testing,Idx_trl4train);
        Idx_trl4test = find(countmember(Idx_trl,Idx_trl4train)==0);
        Xte_ = feat(Idx_sub_4testing,Idx_trl4test);
        Tte_ = marker_set(Idx_sub_4testing,Idx_trl4test);
    end
    
    %% DB �ļ� ó��(ä�� ����, delay ���� ���)
    
    % input of Train
%     Xtr = cellfun(@(x) x(1:end-N_delay+1,Idx_use_emg_feat),Xtr_,'UniformOutput', false); % 1:4�� ä�θ�
%     Xtr = cellfun(@(x) x',Xtr_,'UniformOutput', false); % transe pose
%     Xtr = cellfun(@con2seq ,Xtr,'UniformOutput', false); % cell �������� �ٲٱ�
%     Xtr = Xtr(:);
    Xtr = Xtr_;
    for i= 1:numel(Xtr)
        Xtr{i} = mat2cell(Xtr_{i},repmat(seq_size,[length(Xtr{i})/seq_size,1]),length(Idx_use_emg_feat));  
    end
    Xtr = cat(1,Xtr{:});
    Xtr = cellfun(@(x) x',Xtr,'UniformOutput', false);
    Xtr = cellfun(@con2seq ,Xtr,'UniformOutput', false); % cell �������� �ٲٱ�
%     Xtr = Xtr(:);

    % Target of train
%     Ttr = cellfun(@(x) x(N_delay:end,Idx_use_mark_type),Ttr_,'UniformOutput', false); % 6��ä�θ� regression
%     Ttr = cellfun(@(x) x',Ttr,'UniformOutput', false); % transe pose
%     Ttr = cellfun(@con2seq ,Ttr,'UniformOutput', false); % cell �������� �ٲٱ�
%     Ttr = Ttr(:);
    Ttr = Ttr_;
    for i= 1:numel(Ttr)
        Ttr{i} = mat2cell(Ttr{i},repmat(seq_size,[length(Ttr{i})/seq_size,1]),3);  
    end
    Ttr = cat(1,Ttr{:});
    Ttr = cellfun(@(x) x',Ttr,'UniformOutput', false);
    Ttr = cellfun(@con2seq ,Ttr,'UniformOutput', false); % cell �������� �ٲٱ�

    % soring of input by length of sequence
%     numObservations = numel(Xtr);
%     for i=1:numObservations
%         sequence = Xtr{i};
%         sequenceLengths(i) = size(sequence,2);
%     end
%     
%     %sort
%     [sequenceLengths,idx] = sort(sequenceLengths);
%     Xtr = Xtr(idx);
%     Ttr = Ttr(idx);
    
    % padding
%     temp_cat_Xtr = catsamples(Xtr{1},'pad');
%     temp_cat_Ttr = catsamples(Ttr{1},'pad');
%     for i=2:numObservations
%         temp_cat_Xtr = catsamples(temp_cat_Xtr,Xtr{i},'pad');
%         temp_cat_Ttr = catsamples(temp_cat_Ttr,Ttr{i},'pad');
%     end
%     Xtr_series = temp_cat_Xtr; 
%     Ttr_series = temp_cat_Ttr; 
    Xtr_series = catsamples(Xtr{:});
    Ttr_series = catsamples(Ttr{:});

    % input of Test
    Xte = cellfun(@(x) x(:,Idx_use_emg_feat),Xte_,'UniformOutput', false); % 1:4�� ä�θ�
%     Xte = cellfun(@(x) x,Xte','UniformOutput', false); % transe pose

    % Target of test
    Tte = cellfun(@(x) x(:,Idx_use_mark_type),Tte_,'UniformOutput', false); % 6��ä�θ� regression
%     Tte = cellfun(@(x) x,Tte','UniformOutput', false); % transe pose

    %% network ���� �н��ϱ� ���� ������(EMG Ư¡)
    Xtr_series_net1 = cellfun(@(x) x(EMG_feat_for_net1,:),Xtr_series,...
         'UniformOutput', false);
%     Xtr_series_net2 = cellfun(@(x) x(EMG_feat_for_net2,:),Xtr_series,...
%          'UniformOutput', false);
    clear Xtr_series temp_cat_Xtr temp_cat_Ttr sequence numObservations idx;
 
    
    if use_saved_network ~=1
    %% get sytem matrix from training set usin NARX
    % Network creation
    net = narxnet(xdelay,ydelay,hiddenLayer);
    net.divideFcn = '';
    net.trainParam.min_grad = 1e-10;
    
    % data prep
    [Xs,Xi,Ai,Ts] = preparets(net,Xtr_series_net1,{},Ttr_series); 
%     [Xs,Xi,Ai,Ts] = preparets(net,Xtr_series,{},Ttr_series); 
    % train in open loop
    net = train(net,Xs,Ts,Xi);

    % open loop performance evaluation (only one-stemp afead prediction
    % error)
    yp = sim(net,Xs,Xi);
    e = cell2mat(yp)-cell2mat(Ts);
    plot(e')
    clear yp e
    
    % close loop
    netc = closeloop(net);
    
%     % close loop performance eval
%     % Training data���� ���غ�
%     T1 = con2seq(Ttr_{2}');
% %     Xtr1 = con2seq(Xtr_{2}');
% %     Xtr1_net1 = cellfun(@(x) x(EMG_feat_for_net1,:),Xtr1,...
% %          'UniformOutput', false);
%     Xtr1_net1 = con2seq(Xtr_{2}(:,EMG_feat_for_net1)');
%     % data prep and get initial conditions
%     [Xs1,Xi1,Ai1,Ts1] = preparets(netc,Xtr1_net1,{},T1);
% %     [Xs1,Xi1,Ai1,Ts1] = preparets(netc,Xtr1,{},T1);
%     % classify
%     yp1 = netc(Xs1,Xi1,Ai1);
%     % for plot
%     TS = size(Ts1,2);
%     Ts1_mat = cell2mat(Ts1);
%     yp1_mat = cell2mat(yp1);
% %     for i_m_type = 1 : 3
% %         figure(i_m_type);
% %         plot(1:TS,Ts1_mat(i_m_type,:),'b',1:TS,yp1_mat(i_m_type,:),'r')
% %     end
%     clear T1 Xtr1 Xs1 Xi1 Ai1 Ts1 yp1 Ts1
    

%     %% Network ����
%     save('network.mat','net', 'net2');   
    end
    %% NARX TEST
    rmse = zeros(numel(Xte),3);
    for i = 1 : numel(Xte)
 
        
        
        X_test = con2seq(Xte{i}');
        T_test = con2seq(Tte{i}');
        X_test = cellfun(@(x) x(EMG_feat_for_net1),X_test,...
         'UniformOutput', false);
        % data prep and get initial conditions
        [Xs1,Xi1,Ai1,Ts1] = preparets(netc,X_test,{},T_test);
        
        % classify
        yp1 = netc(Xs1,Xi1,Ai1);
        
        % for plot
        TS = size(Ts1,2);
        Ts1_mat = cell2mat(Ts1);
        yp1_mat = cell2mat(yp1);
        for i_m_type = 1 : 3
            figure(i_m_type);
            plot(1:TS,Ts1_mat(i_m_type,:),'b',1:TS,yp1_mat(i_m_type,:),'r')
        end
        rmse(i,:) = rms((Ts1_mat-yp1_mat)');
        
        % for saving
        target{i_mark} = Ts1_mat;
        output{i_mark} = yp1_mat;
        
        %  SST & SSE ���
        Ts1_mat = Ts1_mat';
        yp1_mat = yp1_mat';
        test_target_mean = mean(Ts1_mat,1);
%         test_target_mean = mean(Ts1_mat,2);
%         
%         test_target_mean = zeros(1,3)
%         for i = 1: 3
%             test_target_mean(1,i) = mean(testY(:,i))
%         end

    
        
        sst = zeros(length(Ts1_mat),1);
        sse = zeros(length(Ts1_mat),1);
        temp1 = zeros(1,3);
        temp2 = zeros(1,3);
        for ii= 1: length(Ts1_mat)
            for j=1: 3
                temp1(1,j) = pow2(Ts1_mat(ii,j)-test_target_mean(1,j));
                temp2(1,j) = pow2(yp1_mat(ii,j) - Ts1_mat(ii,j));
            end
            sst(ii) = sum(temp1);
            sse(ii) = sum(temp2);
        end
        sst = sum(sst);    
        sse = sum(sse);    
        r_square = 1 - (sse / sst);

    end
    count_model = count_model + 1
    model{count_model}.rmse = mean(rmse)
    model{count_model}.hiddenlayer = hiddenLayer;
    model{count_model}.xdelay = xdelay;
    model{count_model}.ydelay = ydelay;
    model{count_model}.net = net;

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
end
