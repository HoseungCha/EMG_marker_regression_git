% NARX를 이용해 regression 하는 함수
% NARX는 입력 뿐만 아니라 출력은 feedback 하여, 미래의 data를 예측 하는 함수임
clc; close all; clear ;

% 실험 정보
N_mark = 28;
N_sub = 21;
Idx_sub = 1 : N_sub;
Idx_trl = 1 : 15;
Idx_sub4train = 1 : 19;
% Idx_sub4train(10) = [];
Idx_trl4train = 1 : 5;
Label_mark = {'central down lip';'central nose';'central upper lip';'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';'left dimple';'left down eye';'left down lip';'left eyebrow inside';'left eyebrow outside';'left nose';'left upper eye';'left upper lip';'right central lip';'right cheek';'right dimple';'right down eye';'right down lip';'right eyebrow inside';'right eyebrow outside';'right nose';'right upper eye';'right upper lip'};
delay = 1;
% neuronsHiddenLayer = [30 30];
% % 마커 코 부분 추출
% fpath = fullfile(cd,'DB_v2','DB_markset','mark_nose');
% load(fpath);
    
% EMG/marker delay 조절
N_delay = 5;
Idx_sub_4testing = 3;
Idx_use_mark_type = 1:3;
Idx_use_emg_feat = 1:8;

EMG_feat_for_net1 = 1:4;

% validation 조정
val_subject_indepe = 0;
use_saved_network = 0;
% seq size
seq_size = 20;
for i_mark = 10 : N_mark
    if(i_mark==2)
        continue;
    end
%     model = cell(length(10:2:30)*length(0:5)*length(1:5),1);
%     count_model = 0;
%     % network1
%     for hiddenLayer = 10:2:30
%     for i_xdelay = 0:5
%         xdelay = 0:i_xdelay;
%         
%     for i_ydelay = 1:5
%         ydelay = 1:i_ydelay;inputSize = 12;
    % design LSTM network
    outputSize = 100;
%     outputMode = 'last';
    numClasses = 9;

    layers = [ ...
        sequenceInputLayer(length(EMG_feat_for_net1))
        lstmLayer(outputSize,'OutputMode',outputMode)
        fullyConnectedLayer(1)
        regressionLayer];


    
    % 마커 추출 및 emg와 시점 맞춤

    fpath = fullfile(cd,'DB_v2','DB_markset_10Hz_basecorr_znorm',sprintf('mark_%d',i_mark));
    load(fpath);
    marker_set = cellfun(@(x) x(N_delay:end,Idx_use_mark_type),marker_set,'UniformOutput', false); % 6번채널만 regression
    
    % EMG feat 추출  및 EMG와 시점 맞춤
    fpath = fullfile(cd,'DB_v2','emg_feat_set_10Hz','EMG_feat_znormalized');
    load(fpath);
    % emg marker 시간 맞춤
    feat = cellfun(@(x) x(1:end-N_delay+1,Idx_use_emg_feat),feat,'UniformOutput', false); % 1:4번 채널만
    
    % 10단위로 Train/Test 하기 위해, 10의 배수로 데이터 맞춤
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
    
    %% Train/Test DB 추출 
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
    
    %% DB 후속 처리(채널 변경, delay 변경 등등)
    
    % input of Train
%     Xtr = cellfun(@(x) x(1:end-N_delay+1,Idx_use_emg_feat),Xtr_,'UniformOutput', false); % 1:4번 채널만
%     Xtr = cellfun(@(x) x',Xtr_,'UniformOutput', false); % transe pose
%     Xtr = cellfun(@con2seq ,Xtr,'UniformOutput', false); % cell 형식으로 바꾸기
%     Xtr = Xtr(:);
    Xtr = Xtr_;
    for i= 1:numel(Xtr)
        Xtr{i} = mat2cell(Xtr_{i},repmat(seq_size,[length(Xtr{i})/seq_size,1]),length(Idx_use_emg_feat));  
    end
    Xtr = cat(1,Xtr{:});
    Xtr = cellfun(@(x) x',Xtr,'UniformOutput', false);
    Xtr = cellfun(@con2seq ,Xtr,'UniformOutput', false); % cell 형식으로 바꾸기
%     Xtr = Xtr(:);

    % Target of train
%     Ttr = cellfun(@(x) x(N_delay:end,Idx_use_mark_type),Ttr_,'UniformOutput', false); % 6번채널만 regression
%     Ttr = cellfun(@(x) x',Ttr,'UniformOutput', false); % transe pose
%     Ttr = cellfun(@con2seq ,Ttr,'UniformOutput', false); % cell 형식으로 바꾸기
%     Ttr = Ttr(:);
    Ttr = Ttr_;
    for i= 1:numel(Ttr)
        Ttr{i} = mat2cell(Ttr{i},repmat(seq_size,[length(Ttr{i})/seq_size,1]),3);  
    end
    Ttr = cat(1,Ttr{:});
    Ttr = cellfun(@(x) x',Ttr,'UniformOutput', false);
    Ttr = cellfun(@con2seq ,Ttr,'UniformOutput', false); % cell 형식으로 바꾸기

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
    Xte = cellfun(@(x) x(:,Idx_use_emg_feat),Xte_,'UniformOutput', false); % 1:4번 채널만
%     Xte = cellfun(@(x) x,Xte','UniformOutput', false); % transe pose

    % Target of test
    Tte = cellfun(@(x) x(:,Idx_use_mark_type),Tte_,'UniformOutput', false); % 6번채널만 regression
%     Tte = cellfun(@(x) x,Tte','UniformOutput', false); % transe pose

    %% network 별로 학습하기 위해 나누기(EMG 특징)
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
%     % Training data에서 평가해봄
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
    

%     %% Network 저장
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
%         for i_m_type = 1 : 3
%             figure(i_m_type);
%             plot(1:TS,Ts1_mat(i_m_type,:),'b',1:TS,yp1_mat(i_m_type,:),'r')
%         end
        rmse(i,:) = rms((Ts1_mat-yp1_mat)');
    end
%     count_model = count_model + 1
%     model{count_model}.rmse = mean(rmse);
%     model{count_model}.hiddenlayer = hiddenLayer;
%     model{count_model}.xdelay = xdelay;
%     model{count_model}.ydelay = ydelay;
%     model{count_model}.net = net;

%     end
%     end
%     end
end
