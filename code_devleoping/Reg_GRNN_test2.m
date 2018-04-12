% NARX를 이용해 regression 하는 함수
% NARX는 입력 뿐만 아니라 출력은 feedback 하여, 미래의 data를 예측 하는 함수임
clc; close all; clear ;

% 실험 정보
N_mark = 28;
N_sub = 21;
Idx_sub = 1 : N_sub;
Idx_sub4train = 1 : 15;
Label_mark = {'central down lip';'central nose';'central upper lip';'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';'left dimple';'left down eye';'left down lip';'left eyebrow inside';'left eyebrow outside';'left nose';'left upper eye';'left upper lip';'right central lip';'right cheek';'right dimple';'right down eye';'right down lip';'right eyebrow inside';'right eyebrow outside';'right nose';'right upper eye';'right upper lip'};

% 마커 코 부분 추출
fpath = fullfile(cd,'DB_v2','DB_markset','mark_nose');
load(fpath);
    
% epoch 20번만 학습하기

for i_mark = 1 : N_mark
    if(i_mark==2)
        continue;
    end
%     % NARX
%     d1 = [];
%     d2 = [1];
%     narx_net = narxnet(d1,d2,19);
%     narx_net.divideFcn = '';
%     narx_net.trainParam.epochs = 20;

    
    % 마커 추출
    fpath = fullfile(cd,'DB_v2','DB_markset',sprintf('mark_%d',i_mark));
    load(fpath);
    
    % EMG feat 추출
    fpath = fullfile(cd,'DB_v2','emg_feat_set','RMS');
    load(fpath);
    
    %train DB 추출
    %Xtrain
    temp = feat_rms(Idx_sub4train,:);
    temp = temp(:); %  Trial(2) --> 1차원으로 합치기
    Xtrain = cell2mat(temp);
    Xtrain = Xtrain(:,1:4);
    %Ttrain
    temp = marker_set(Idx_sub4train,:);
    temp = temp(:); %  Trial(2) --> 1차원으로 합치기
    Ttrain = cell2mat(temp);
    
    %test DB 추출
    Idx_sub4test = find(countmember(Idx_sub,Idx_sub4train)==0);
    % Xtest
    temp = feat_rms(Idx_sub4test,:);
    temp = temp(:); %  Trial(2) --> 1차원으로 합치기
    Xtest = cell2mat(temp);
    Xtest = Xtest(:,1:4);
    % Ttest
    temp = marker_set(Idx_sub4test,:);
    temp = temp(:); %  Trial(2) --> 1차원으로 합치기
    Ttest = cell2mat(temp);
    
    % Train
    % prepare train DB
    net = newgrnn(Xtrain,Ttrain);
    Ttrain = con2seq(Ttrain');
    Xtrain = con2seq(Xtrain');
    [p,Pi,Ai,t] = preparets(narx_net,Xtrain,{},Ttrain);
    narx_net = train(narx_net,p,t,Pi);

    % Test
    % multil ahead detection을 위한 closed loop 형성
%     narx_net_closed = closeloop(narx_net);
    % prepare test DB
    Ttest = con2seq(Ttest');
    Xtest = con2seq(Xtest');
    [p,Pi,Ai,t] = preparets(narx_net,Xtest,{},Ttest);
    TPred = narx_net(p,Pi,Ai);
   
    % error plor
    TPred = cell2mat(TPred);
    t = cell2mat(t);
    e = TPred-t;
    plot(e')
    
    % 결과 저장
    R(i_mark).narx_net = narx_net;
    R(i_mark).rmse = rms(e,2);
    R(i_mark).TPred = TPred;
    R(i_mark).T = t;
    
    % test plot
%     TS = size(t,2);
%     e = YTestPred-t;
%     rms(e,2)
%     for i = 1 : 6
%         figure(i);plot(1:TS,t(i,:),'b',1:TS,YTestPred(i,:),'r')
%     end

end


% marker 3d plot
% temp = marker_set_nose(Idx_sub4test,:);
% marker_nose = cell2mat(temp(:));
% marker_nose(1) = [];% 1 ahead y label 예측
% YTestMarker = repmat(marker_nose,[1,3])' - t(1:3,:);
% 
% plot3dmtx(Marker_Data)