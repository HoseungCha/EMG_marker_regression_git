% NARX를 이용해 regression 하는 함수
% NARX는 입력 뿐만 아니라 출력은 feedback 하여, 미래의 data를 예측 하는 함수임
clc; close all; clear ;

% 실험 정보
N_mark = 28;
N_sub = 21;
Idx_sub = 1 : N_sub;
Idx_trl = 1 : 15;
Idx_sub4train = 1 : 15;
Idx_trl4train = 1 : 10;
Label_mark = {'central down lip';'central nose';'central upper lip';'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';'left dimple';'left down eye';'left down lip';'left eyebrow inside';'left eyebrow outside';'left nose';'left upper eye';'left upper lip';'right central lip';'right cheek';'right dimple';'right down eye';'right down lip';'right eyebrow inside';'right eyebrow outside';'right nose';'right upper eye';'right upper lip'};

% EMG 카메라 마커 delay 조정

% 마커 코 부분 추출
% fpath = fullfile(cd,'DB_v2','DB_markset','mark_nose');
% load(fpath);
    
% EMG/marker delay 조절
N_delay = 5;

% epoch 20번만 학습하기

for i_mark = 12
    if(i_mark==2)
        continue;
    end
%     % NARX
%     d1 = 1:delay;
%     d2 = 1:delay;
%     narx_net = narxnet(d1,d2,N_neuron_hidden_layer);
%     narx_net.divideFcn = '';
%     narx_net.trainParam.epochs = 20;

    
    % 마커 추출
    fpath = fullfile(cd,'DB_v2','DB_markset_10Hz_basecorr_norm_0-1',sprintf('mark_%d',i_mark));
    load(fpath);
    
    % EMG feat 추출
    fpath = fullfile(cd,'DB_v2','emg_feat_set_10Hz','EMG_feat_normalized');
    load(fpath);
    
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
    %Xtrain
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
    

    %test DB 추출
    Idx_sub4test = find(countmember(Idx_sub,Idx_sub4train)==0);
%     Idx_trl4test = find(countmember(Idx_trl,Idx_trl4train)==0);
    %Xtest
    Xte_ = marker_set(Idx_sub4test,:);
%     Xte_ = feat_rms(1,Idx_trl4test);
    Xte = cellfun(@(x) x(:,:),Xte_,'UniformOutput', false); % 1:4번 채널만
    Xte = cellfun(@(x) x',Xte,'UniformOutput', false); % transe pose
%     Xte = cellfun(@con2seq ,Xte,'UniformOutput', false); % cell 형식으로 바꾸기
    Xte = Xte(:);
    
    %Target of test
    Tte_ = marker_set(Idx_sub4test,:);
%     Tte_ = marker_set(1,Idx_trl4test);
    Tte = cellfun(@(x) x(:,:),Tte_,'UniformOutput', false); % 6번채널만 regression
    Tte = cellfun(@(x) x',Tte,'UniformOutput', false); % transe pose
%     Tte = cellfun(@con2seq ,Tte,'UniformOutput', false); % cell 형식으로 바꾸기
    Tte = Tte(:);

    
    % Network Creation
%     net = narxnet(0,1:delay,neuronsHiddenLayer);
%     net.divideFcn = '';
    
    
    % 4. Training the network
    spread = 0.7;
    temp = cell2mat(Ttr');
    net = newgrnn(cell2mat(Xtr'),temp(1:3,:));
%     A = net(Xtr_series);
    view(net)
    
    % Test
    test_data = Xte{7};
    tic
    Ypd = sim(net,test_data);
    toc
    for i=1:3
        figure(i)
        plot((Tte{1}(i,:)))
        hold on;
        plot((Ypd(i,:)))
    end
end


