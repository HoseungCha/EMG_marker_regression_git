% 각 피험자들의 normalized 된 마커와 EMG데이터를 이용해 GRNN으로 regression 하는 코드
clear; clc;close all;

% for tight subplot
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);

% 실험정보
N_sub = 17;
N_trial = 15;
N_Etd_pos = 3;
N_marker = 28;
trg = load(fullfile(cd,'EMG_trigger_ext_code','EMG_trg'));
trg_name = trg.Trg_name(2:end);
name_mark_pos = {'central down lip';'central nose';'central upper lip';'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';'left dimple';'left down eye';'left down lip';'left eyebrow inside';'left eyebrow outside';'left nose';'left upper eye';'left upper lip';'right central lip';'right cheek';'right dimple';'right down eye';'right down lip';'right eyebrow inside';'right eyebrow outside';'right nose';'right upper eye';'right upper lip'};
name_mark_type = {'X','Y','Z','az','el','r'};

% 파라미터
idx2use_etd_pos = 2;
N_sub_train = 10;
idx_train = randperm(17);  idx_train = idx_train(1:N_sub_train);
idx_test = find(countmember(1:15,idx_train)==0);

%데이터 합치기
emg_n = cell(N_trial,N_Etd_pos,N_sub);
mark_n = cell(N_trial,N_marker,N_sub);
for i_sub = 1 : 17
    % 파일 불러오기
    fname = sprintf('sub_%d.mat',i_sub);
    load(fullfile(cd,'DB_norm',fname));
    % 파일 길이가 다르면 조정하기
    for i_trl2check = 1 : N_trial
        len_emg = length(emg.n_set{i_trl2check,1});
        len_DB = length(cam.n_set{i_trl2check,1});
        if len_emg > len_DB
            smp2rejt = len_emg - len_DB;
            for i_etd_pos = 1 : 3
                emg.n_set{i_trl2check,i_etd_pos}(end-smp2rejt+1:end,:) = [];
                emg.d{i_trl2check,i_etd_pos}(end-smp2rejt+1:end,:) = [];
            end
        elseif len_emg < len_DB
            smp2rejt = len_DB - len_emg;
            for i_marker = 1 : N_marker
                cam.n_set{i_trl2check,i_marker}(end-smp2rejt+1,:) = [];
                cam.d{i_trl2check,i_marker}(end-smp2rejt+1,:) = [];
            end
        end
         fprintf('Length of maker : %d Length of EMG : %d\n ',...
                length(emg.n_set{i_trl2check,i_etd_pos}),length(cam.n_set{i_trl2check,i_marker}));
        fprintf('Length of maker : %d Length of EMG : %d\n ',...
            length(emg.d{i_trl2check,i_etd_pos}),length(cam.d{i_trl2check,i_marker}));
    end
    
    emg_n(:,:,i_sub) = emg.n_set;
    mark_n(:,:,i_sub) = cam.n_set;
end


% NN architecture
setdemorandstream(491218382);
net = fitnet([20 5]); % 1layer, 30 Neuron
% view(net);

% input: EMG
% train
temp=permute(emg_n(:,idx2use_etd_pos,idx_train),[1 3 2]);
Xtr = cell2mat(temp(:))';
% test
temp=permute(emg_n(:,idx2use_etd_pos,idx_test),[1 3 2]);
Xte = cell2mat(temp(:))';

for i_m = 1 : N_marker
    for i_mtype = 1 : 6
        % output(Y label): Marker
        % train set
        temp=permute(mark_n(:,i_m,idx_train),[1 3 2]);
        Ytr = cell2mat(temp(:))';
        
        % test set
        temp=permute(mark_n(:,i_m,idx_test),[1 3 2]);
        temp = temp(:);
        
        % test size 기억하기
        for i = 1 : size(temp,1)
            len_test(i,1) = length(temp{i});
        end
        Yte = cell2mat(temp)';
        
        % train
        [net,tr] = train(net,Xtr,Ytr(i_mtype,:));
        % Test
        Ypd = net(Xte);
        
        perf(i_m,i_mtype) = mse(net,Yte(i_mtype,:),Ypd);
        
        %     plotregression(temp_mrk(1,:),testY)
        
        % 그림 그려보기
        % test set trial 별로 다시 나누기
        Yte_cell = mat2cell(Yte(i_mtype,:),1,len_test);
        Ypd_cell = mat2cell(Ypd,1,len_test);
        
        % Trial 별로 그림 그리기
        %             h = figure;
        %             for i_tr_te = 1 : length(Ypd_cell)
        %                 subplot(length(Ypd_cell),1,i_tr_te)
        %                 plot(Yte_cell{i_tr_te});
        %                 hold on;
        %                 plot(Ypd_cell{i_tr_te});
        %                 name_title = sprintf('Position_%s Type_%s',name_mark_pos{i_m},name_mark_type{i_mtype});
        % %                 if i_tr_te==1
        % %                     title(name_title,'Interpreter', 'none');
        % %                 end
        %             end
        %             xlabel(name_title,'Interpreter', 'none');
        %             % 그림 저장
        %             h.Position = [1 41 1920 962];
        %             c = getframe(h);
        %             c = c.cdata;
        %             close(h);
        %             fname = sprintf('sub%d_%s.jpg',i_sub,name_title);
        %             imwrite(c,fullfile(cd,'Result_regression',fname));
        %
    end
end
% regression이 잘된 마커 찾기
name_mark_pos(2) = [];
perf(2,:) = [];
[rmsev,temp] = sort(perf(:));
for i_r = 1 : 10
    fprintf('rmsev : %f ',rmsev(i_r));
    [I_row(i_r), I_col(i_r)] = ind2sub(size(perf),temp(i_r));
    fprintf('Position_%s Type_%s\n',name_mark_pos{I_row(i_r)},name_mark_type{I_col(i_r)});
end


% end