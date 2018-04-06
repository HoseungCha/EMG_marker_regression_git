% made by Ho-Seung Cha, from Cone Lab. in Hanyang Univ.
clc; close all; clear all;
% ���� ����
N_subject = 21;
N_trial = 15;
idx2use_mark = 14;

% �� ����
load('Label_DB_Marker_Position');
load(fullfile(cd,'MarkerPosition_ext_code','marker_set.mat'),'Labels');
Name_mark = Labels; clear Labels;


% ���ÿ� �з��� �������� (�󺧸��� ���������� �������� Ȯ���غ��� �ڵ�
% Ȯ���غ� ��� ��Ŀ �Ѱ��� Train�ؾ��ҵ�..

% indexing, subject, trial
idx_cell_ = (1:numel(Label))';
[idx_sub, idx_trl] = ind2sub(size(Label),idx_cell_);
ind_sub_trl = [idx_sub; idx_trl]';

% idx2use_mark = [1,3,8,9,11,14,15,19,21,24,25];
% idx2use_mark = [8,11,14,15,21,24,25];

Name_mark2use = Name_mark(idx2use_mark);
cellsz = cellfun(@size,Label(:),'uni',false);
sz_cell = cell2mat(cellsz);
sz_cell = sz_cell(:,1);

% get original index of cell
cum_sz_cell = cumsum(sz_cell);
ind_org_cell = zeros(sum(sz_cell,1),2);
for i = 1 : length(sz_cell)
    if i==1
        ind_org_cell(1:cum_sz_cell(1),1) = 1:sz_cell(1);
        ind_org_cell(1:cum_sz_cell(1),2) = 1*ones(sz_cell(1),1);
    else
        ind_org_cell(cum_sz_cell(i-1)+1:cum_sz_cell(i),1)= 1:sz_cell(i);
        ind_org_cell(cum_sz_cell(i-1)+1:cum_sz_cell(i),2)= i*ones(sz_cell(i),1);
    end
end

% ��� ������ �������� �󺧸� �̱�
% ��Ŀ �Ѱ��� labeling data ��ġ��
temp = cell2mat(Label(:));
temp = temp(:,idx2use_mark);

% �󺧸� �̱�
label_1 = find(temp==1);
label_2 = find(temp==2);
label_3 = find(temp==3);

%subject independent ������� ������ �̱�
idx_sub4train = 1 : 15;

% subject 1:15 ���� �����͸� ��� �����쿡�� �̱�.  
temp = idx_cell_(countmember(ind_sub_trl(:,1),idx_sub4train)==1);
countmember(ind_org_cell(:,2),temp);




% Train/Test DB  setting
for i_sub= 1 : N_subject
     for i_trl = 1 : N_trial
         % DB �̸�
         name_dat = sprintf('sub_%d_trl_%d_ver2.mat',i_sub, i_trl);    
         % Label �̸�
         load(fullfile(cd,'DB_spec',name_dat));
         emg.img{2}  
         
         
     end
end



% unique�� �����͸� �߰�.

% myData = randi([0 1], [10 2]); %make up some data
% [C,ia,ic] = unique(temp,'rows');
% [nOccurances IX] = sort(histc(ic, 1:length(ic)), 'descend');
% idY = (nOccurances==0);
% nOccurances(idY) = [];
% IX(idY) = [];
% myDataSorted = [nOccurances C(IX,:)];  





% [C,ia,ic] = unique(temp,'rows');
% x =[
% 22 23 24 23
% 24 23 24 22
% 22 23 23 23];
% a = unique(x);
% out = [a,histc(x(:),C)];
% 
% Label = cell2mat(Label(:));
% disp(i_mark);
% 
% 
% for i=1:length(Num_label)
%     l_(i,1) =  Num_label{i}.l1;
%     l_(i,2) = Num_label{i}.l2;
%     l_(i,3) = Num_label{i}.l3;
% end
%


% save('marker_set.mat','marker_set','Label{i_sub,i_trl,i_mark}s','Sname','-v7.3');


