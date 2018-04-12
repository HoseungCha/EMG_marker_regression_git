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

% network1
xdelay = 0;
ydelay = 1;
EMG_feat_for_net1 = 1:4;
EMG_feat_for_net2 = 5:8;
% validation 조정
val_subject_indepe = 0;
use_saved_network = 0;
% seq size
seq_size = 20;
for i_mark = 12 : N_mark
    if(i_mark==2)
        continue;
    end
    
    % 필요한 feature(채널)만 사용!
    fpath = fullfile(cd,'DB_v2','DB_markset_10Hz_basecorr_norm_0-1',sprintf('mark_%d',i_mark));
    load(fpath);
    marker_set = cellfun(@(x) x(N_delay:end,Idx_use_mark_type),marker_set,'UniformOutput', false); % 6번채널만 regression
    
    fpath = fullfile(cd,'DB_v2','emg_feat_set_10Hz','EMG_feat_normalized');
    load(fpath);
    feat = cellfun(@(x) x(1:end-N_delay+1,Idx_use_emg_feat),feat,'UniformOutput', false);  % 1:4번 채널만
    
    % 10단위로 Train/Test 하기 위해, seq_size 의 배수로 데이터 맞춤
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
    Xtr = Xtr_;
    for i= 1:numel(Xtr)
        Xtr{i} = mat2cell(Xtr_{i},repmat(seq_size,[length(Xtr{i})/seq_size,1]),length(Idx_use_emg_feat));  
    end
    Xtr = cat(1,Xtr{:});
    Xtr = cellfun(@(x) x',Xtr,'UniformOutput', false);
    Xtr = cellfun(@con2seq ,Xtr,'UniformOutput', false); % cell 형식으로 바꾸기

    % Target of train
    Ttr = Ttr_;
    for i= 1:numel(Ttr)
        Ttr{i} = mat2cell(Ttr{i},repmat(seq_size,[length(Ttr{i})/seq_size,1]),3);  
    end
    Ttr = cat(1,Ttr{:});
    Ttr = cellfun(@(x) x',Ttr,'UniformOutput', false);
    Ttr = cellfun(@con2seq ,Ttr,'UniformOutput', false); % cell 형식으로 바꾸기


    Xtr_series = catsamples(Xtr{:});
    Ttr_series = catsamples(Ttr{:});

%     % input of Test
%     Xte = cellfun(@(x) x(:,Idx_use_emg_feat),Xte_,'UniformOutput', false); % 1:4번 채널만
% %     Xte = cellfun(@(x) x,Xte','UniformOutput', false); % transe pose
% 
%     % Target of test
%     Tte = cellfun(@(x) x(:,Idx_use_mark_type),Tte_,'UniformOutput', false); % 6번채널만 regression
% %     Tte = cellfun(@(x) x,Tte','UniformOutput', false); % transe pose

    %% network 별로 학습하기 위해 나누기(EMG 특징)
    Xtr_series_net1 = cellfun(@(x) x(EMG_feat_for_net1,:),Xtr_series,...
         'UniformOutput', false);
    Xtr_series_net2 = cellfun(@(x) x(EMG_feat_for_net2,:),Xtr_series,...
         'UniformOutput', false);
    clear Xtr_series temp_cat_Xtr temp_cat_Ttr sequence numObservations idx;
 
    
    if use_saved_network ~=1
    %% get sytem matrix from training set usin NARX
    % Network creation
    net = narxnet(0:1,1:2,14);
    net.divideFcn = '';
    net.trainParam.min_grad = 1e-10;
    
    % data prep
    [Xs,Xi,Ai,Ts] = preparets(net,Xtr_series_net1,{},Ttr_series); 
%     [Xs,Xi,Ai,Ts] = preparets(net,Xtr_series,{},Ttr_series); 
    % train in open loop
    net = train(net,Xs,Ts,Xi);
    
    % close loop
    netc = closeloop(net);

    %% get measurement matrix using NARX
    % Network creation
    net2 = narxnet(0:1,1:2,14);
%     net2 = timedelaynet(0,30);
    net2.divideFcn = '';
    net2.trainParam.min_grad = 1e-10;
%     net2.dimensions.numInput = 3;
    
    % data prep
    [Xs,Xi,Ai,Ts] = preparets(net2,Ttr_series,{},Xtr_series_net2); 
%     [Xs,Xi,Ai,Ts] = preparets(net2,Ttr_series,Xtr_series_net2); 
    % train in open loop
    net2 = train(net2,Xs,Ts,Xi,Ai);

    % close loop
    netc2 = closeloop(net2);
 
    %% Network 저장
    save('network.mat','net', 'netc2');   
    end
    %% TEST(kalmann filter estimation_
    for i = 1 : numel(Xte_)
        % UKF 설정
        ukf.MeasurementNoise = 0.1
        
        % Test data of EMG
        X_test = con2seq(Xte_{i}'); 
        X_test_net1 = cellfun(@(x) x(EMG_feat_for_net1,:),X_test,...
         'UniformOutput', false);
        X_test_net2 = cellfun(@(x) x(EMG_feat_for_net2,:),X_test,...
         'UniformOutput', false);
        clear X_test;
     
        %% Kalman filter (UKF)
        % Your initial state guess at time k, utilizing measurements up to time k-1: xhat[k|k-1]
        initialStateGuess = [0;0;0]; % xhat[k|k-1]

        % Construct the filter
        ukf = unscentedKalmanFilter(@state_fnc,... % State transition function
        @meas_fnc,... % Measurement function
        initialStateGuess);

        

        N_step = size(X_test,2);
%         % data prep
%         [Xs,Xi,Ai,Ts] = preparets(net,Xtr_series,{},Ttr_series);
        xCorrectedUKF = zeros(N_step,3);
        PCorrected = zeros(N_step,3,3);
        for k = 1 : N_step
%             e(k) = yMeas(k) - vdpMeasurementFcn(ukf.State);
            [xCorrectedUKF(k,:), PCorrected(k,:,:)] ...
                = correct(ukf,X_test_net2{k});
%             correct(ukf,X_test{k});
            predict(ukf,X_test_net1{k});
        end
        
        % for display of predicted results
        
        % test target
        XTrue = Xte_{i};
        TTrue = Tte_{i};
        timeVector = 1 : N_step;
        for i_m = 1 : 3
        figure(i_m);
        plot(timeVector,XTrue(:,i_m), timeVector,TTrue(:,i_m),...
            timeVector,xCorrectedUKF(:,i_m));
        legend('Input','Target','UKF estimate')
        end
        
        % NARX 단독 결과
        X_test = con2seq(Xte_{i}');
        T_test = con2seq(Tte_{i}');
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
        
        
 
    end
end


function xk = state_fnc(xk,uk)
    persistent firstRun;
    persistent net;
    if isempty(firstRun)
        firstRun = 1;
        load('network.mat');
    end
    input = {uk;xk};
    out = net(input);
    xk = out{1};
end

function yk = meas_fnc(xk)
    persistent firstRun netc2;
    if isempty(firstRun)
        firstRun = 1;
        load('network.mat');
    end
    input = {xk};
    out = netc2(input);
    yk = out{1};
end