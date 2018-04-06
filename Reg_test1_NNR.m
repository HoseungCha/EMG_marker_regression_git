% �� �����ڵ��� normalized �� ��Ŀ�� EMG�����͸� �̿��� GRNN���� regression �ϴ� �ڵ�
clear; clc;close all;

% for tight subplot
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);

% ��������
N_trial = 15;
N_Etd_pos = 3;
N_marker = 28;
trg = load(fullfile(cd,'EMG_trigger_ext_code','EMG_trg'));
trg_name = trg.Trg_name(2:end);
name_mark_pos = {'central down lip';'central nose';'central upper lip';'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';'left dimple';'left down eye';'left down lip';'left eyebrow inside';'left eyebrow outside';'left nose';'left upper eye';'left upper lip';'right central lip';'right cheek';'right dimple';'right down eye';'right down lip';'right eyebrow inside';'right eyebrow outside';'right nose';'right upper eye';'right upper lip'};
name_mark_type = {'X','Y','Z','az','el','r'};

% �Ķ����
idx2use_etd_pos = 2;
N_trn_trl = 5;
idx_train = randperm(15);  idx_train = idx_train(1:N_trn_trl);
idx_test = find(countmember(1:15,idx_train)==0);
for i_sub = 1
    % ���� �ҷ�����
    fname = sprintf('sub_%d.mat',i_sub);
    load(fullfile(cd,'DB_norm',fname));
    
    % NN architecture 
    setdemorandstream(491218382);
    net = fitnet([20 5]); % 1layer, 30 Neuron
%     view(net);
    
    % input: EMG
    % train
    Xtr = cell2mat(emg.d(idx_train,idx2use_etd_pos))';
    % test
    Xte = cell2mat(emg.d(idx_test,idx2use_etd_pos))';
    
    
    for i_m = 1 : N_marker
        for i_mtype = 1 : 6
            % output(Y label): Marker
            % train set
            temp_Ytr = cam.d(idx_train,i_m);
            Ytr = cell2mat(temp_Ytr)';
            % test set
            temp_Ytr = cam.d(idx_test,i_m);
            % test size ����ϱ�
            for i = 1 : size(temp_Ytr,1)
                len_test(i,1) = length(temp_Ytr{i});
            end
            Yte = cell2mat(temp_Ytr)';
            
            % train �� �� Ȯ��
            % train
            [net,tr] = train(net,Xtr,Ytr(i_mtype,:));
            
            % Test
            Ypd = net(Xte);
            
            perf(i_m,i_mtype) = mse(net,Yte(i_mtype,:),Ypd);
            
            %     plotregression(temp_mrk(1,:),testY)
            
            % �׸� �׷�����
            % test set trial ���� �ٽ� ������
            Yte_cell = mat2cell(Yte(i_mtype,:),1,len_test);
            Ypd_cell = mat2cell(Ypd,1,len_test);
            
            % Trial ���� �׸� �׸���
            h = figure;
            for i_tr_te = 1 : length(Ypd_cell)
                subplot(length(Ypd_cell),1,i_tr_te)
                plot(Yte_cell{i_tr_te});
                hold on;
                plot(Ypd_cell{i_tr_te});
                name_title = sprintf('Position_%s Type_%s',name_mark_pos{i_m},name_mark_type{i_mtype});
%                 if i_tr_te==1
%                     title(name_title,'Interpreter', 'none');
%                 end
            end
            xlabel(name_title,'Interpreter', 'none');
            % �׸� ����
            h.Position = [1 41 1920 962];
            c = getframe(h);
            c = c.cdata;
            close(h);
            fname = sprintf('sub%d_%s.jpg',i_sub,name_title);
            imwrite(c,fullfile(cd,'Result_regression',fname));
            
        end
    end
    % regression�� �ߵ� ��Ŀ ã��
    name_mark_pos(2) = [];
    perf(2,:) = [];
    [rmsev,temp] = sort(perf(:));
    for i_r = 1 : 10
        fprintf('rmsev : %f ',rmsev(i_r));
    [I_row(i_r), I_col(i_r)] = ind2sub(size(perf),temp(i_r));
    fprintf('Position_%s Type_%s\n',name_mark_pos{I_row(i_r)},name_mark_type{I_col(i_r)});
    end
    
   
end