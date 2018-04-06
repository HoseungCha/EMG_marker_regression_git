% CNN transfer learning을 이용한 마커 위치 분류 코드
% made by Ho-Seung Cha, from Cone Lab. in Hanyang Univ.
clc; close all; clear all;
% 라벨 정보
load('Label_DB_Marker_Position');

% 실험 정보
N_subject = 21;
N_trial = 15;
load(fullfile(cd,'MarkerPosition_ext_code','marker_set.mat'),'Labels');
Name_mark = Labels; clear Labels;

i_marker = 14;
% Train/Test DB  setting
for i_sub= 1 : N_subject
     for i_trl = 1 : N_trial
         % DB 이름
         name_dat = sprintf('sub_%d_trl_%d_ver2.mat',i_sub, i_trl);    
         % Label 이름
         temp_label = Label{i_sub,i_trl}(:,i_marker);
         load(fullfile(cd,'DB_spec',name_dat));
    
     end
end

% % NN setting( 마지막 3  layer 지우고
% % fully network와 softmax layer, classification layer 넣음
% net = googlenet;
% lgraph = layerGraph(net);
% % removeLayers
% lgraph = removeLayers(lgraph, {'loss3-classifier','prob','output'});
% numClasses = 3;
% % numClasses = numel(categories(trainImages.Labels));
% 
% newLayers = [
%     fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',20,'BiasLearnRateFactor', 20)
%     softmaxLayer('Name','softmax')
%     classificationLayer('Name','classoutput')];
% lgraph = addLayers(lgraph,newLayers);
% 
% % Connect the last of the transferred layers remaining in the network ('pool5-drop_7x7_s1') to the new layers.
% lgraph = connectLayers(lgraph,'pool5-drop_7x7_s1','fc');
% 
% figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
% plot(lgraph)
% ylim([0,10])
