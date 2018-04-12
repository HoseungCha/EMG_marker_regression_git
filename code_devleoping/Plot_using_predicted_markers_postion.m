%  Ho-Seung Cha, cone lab. Hanyang univ.
%  predicted 된 마커위치를 가지고 그리는 코드
clear; clc;
% 실험정보
N_sub = 21;
N_mark = 28;
Idx_sub = 1 : N_sub;
Idx_sub4train = 1 : 15;
Idx_sub4test = find(countmember(Idx_sub,Idx_sub4train)==0);

% 결과 불러오기
load(fullfile(cd,'results','20180224'))

Label_mark = {'CDL';'CN';'CUL';'H1';'H2';'H3';'H4';'J';'LCL';'LC';'LD';...
    'LDE';'LDL';'LEI';'LEO';'LN';'LUE';'LUL';'RCL';'RC';'RD';'RDE';...
    'RDL';'REI';'REO';'RN';'RUE';'RUL'};


% 마커 코 부분 추출
fpath = fullfile(cd,'DB_v2','DB_markset','mark_nose');
load(fpath);

% nose marker
temp = marker_set_nose(Idx_sub4test,:);
marker_nose = cell2mat(temp(:));
marker_nose(1,:) = [];

% RMSE 가 작은 값만 추출
temp = permute(struct2cell(R),[1 3 2]);
RMSE = temp(2,:);
RMSE{2} = NaN(6,1);
temp = cell2mat(RMSE);
[r,c] = find(temp(1:3,:)<1E-03);
idx_mark_usefull = [2;unique(c)];
idx_mark_usefull(2) = []; % head 제거
idx_mark = 1 : N_mark;
idx_mark_notusefull = find(countmember(idx_mark,idx_mark_usefull)==0);



temp = permute(struct2cell(R),[1 3 2]);
TPred = temp(3,:);
TPred{2} = marker_nose';
% x,y,z 좌표만 뽑아냄
TPred = cellfun(@(x) x(1:3,:), TPred, 'UniformOutput', false);
% 원래 좌표로 바꾸기
TPred = cellfun(@minus, repmat({marker_nose'},[1,28]),TPred,...
    'UniformOutput', false);
TPred{2} = marker_nose';
TPred = permute(cat(3,TPred{:}),[2 3 1]);

% TPred(:,idx_mark_notusefull,:) = NaN;
% plot3dmtx(TPred,1,5,'yes',[],[],Label_mark);

temp = permute(struct2cell(R),[1 3 2]);
T = temp(4,:);
T{2} = marker_nose';
% x,y,z 좌표만 뽑아냄
T = cellfun(@(x) x(1:3,:), T, 'UniformOutput', false);
% 원래 좌표로 바꾸기
T = cellfun(@minus, repmat({marker_nose'},[1,28]),T,...
    'UniformOutput', false);
T{2} = marker_nose';
T = permute(cat(3,T{:}),[2 3 1]);
% T(:,idx_mark_notusefull,:) = NaN;
plot3dmtx(T,1,5,'yes',[],[],Label_mark);

% regression 그림

TPred = permute(cat(3,TPred{:}),[2 3 1]);
T = permute(cat(3,T{:}),[2 3 1]);
plot(1:len2plot,T(1:len2plot,9,6),1:len2plot,TPred(1:len2plot,9,6))

len2plot = 500;
mark2plot = 23
for i = 1 : 3
    subplot(3,1,i)
    plot(1:len2plot,T(1:len2plot,9,i),1:len2plot,TPred(1:len2plot,9,i))
end