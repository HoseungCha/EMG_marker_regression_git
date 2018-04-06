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
Idx_trl4test = find(countmember(Idx_trl,Idx_trl4train)==0);
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

% 마커DB 불러오기 
i_mark = 12;
MarkerPath = fullfile(cd,'DB_v2','DB_markset_10Hz_basecorr_znorm');
load(fullfile(MarkerPath,sprintf('mark_%d',i_mark)));
marker_set = marker_set';
win_sizes = cellfun('length',marker_set);

Marker = cell2mat(marker_set(:));

% DB를 마구 조작하려면 (이미지는 sub->trl->win 순서대로 정해져 있기
% 떄문에 그 순서대로 sub, trl, win index를 정해주는 것이 좋다.
idx_sub = []; idx_trl = [];
for i_sub = 1 : 21
for i_trl = 1 : 15
    idx_sub = [idx_sub; ...
        i_sub*ones(win_sizes(i_trl,i_sub),1)];
    idx_trl = [idx_trl; ...
        i_trl*ones(win_sizes(i_trl,i_sub),1)];
end
end
   
idx_train  = idx_sub==1 .* ...
    logical(countmember(idx_trl,Idx_trl4train));
idx_train = find(idx_train==1);

idx_test  = idx_sub==1 .* ...
    logical(countmember(idx_trl,Idx_trl4test));
idx_test = find(idx_test==1);


% Prepare DB of whole Images
EMGDatasetPath = fullfile(cd,'DB_v2','emg_raw_img');
EMGData = imageDatastore(EMGDatasetPath);

% train DB
Num_train = length(idx_train);
TrainImg = zeros(227,227,3,Num_train);
Trainlab = zeros(Num_train,1);
count = 0;
while(1)
    count = count + 1;
    i= idx_train(count);
    
    [temp_data,temp_info] = imresize(readimage(EMGData,i),[227 227]);
    TrainImg(:,:,:,count) = temp_data;
    Trainlab(count) = Marker(i,1);
    if count == Num_train
        break;
    end
end

% get google net
net = alexnet;
layersTransfer = net.Layers(1:end-3);

% get network 
layers = [ ...
    layersTransfer
    fullyConnectedLayer(1)
    regressionLayer];

% training option
options = trainingOptions('sgdm', ...
    'Plots','training-progress');

% train Network
rng('default') % For reproducibility
net = trainNetwork(TrainImg,Trainlab,layers,options);

