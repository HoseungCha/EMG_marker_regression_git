% CNN transfer learning�� �̿��� ��Ŀ ��ġ �з� �ڵ�
% made by Ho-Seung Cha, from Cone Lab. in Hanyang Univ.
clc; close all; clear all;
% �� ����
load('Label_DB_Marker_Position');

% ���� ����
N_subject = 21;
N_trial = 15;
load(fullfile(cd,'MarkerPosition_ext_code','marker_set.mat'),'Labels');
Name_mark = Labels; clear Labels;

i_marker = 14;
% Train/Test DB  setting
for i_sub= 1 : N_subject
     for i_trl = 1 : N_trial
         % DB �̸�
         name_dat = sprintf('sub_%d_trl_%d_ver2.mat',i_sub, i_trl);    
         % Label �̸�
         temp_label = Label{i_sub,i_trl}(:,i_marker);
         load(fullfile(cd,'DB_spec',name_dat));
    
     end
end

% % NN setting( ������ 3  layer �����
% % fully network�� softmax layer, classification layer ����
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
