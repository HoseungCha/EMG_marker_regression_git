% Predicting 3D lip shapes using facial surface EMG 코드 구현
% from Ho-Seung Cha, Hanyang University

clear; clc;close all;

% for tight subplot
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);

% 실험정보
N_trial = 15;
N_Etd_pos = 3;
N_marker = 28;
trg = load(fullfile(cd,'EMG_trigger_ext_code','EMG_trg'));
trg_name = trg.Trg_name(2:end);
name_mark_pos = {'central down lip';'central nose';'central upper lip';'head 1';'head 2';'head 3';'head 4';'jaw';'left central lip';'left cheek';'left dimple';'left down eye';'left down lip';'left eyebrow inside';'left eyebrow outside';'left nose';'left upper eye';'left upper lip';'right central lip';'right cheek';'right dimple';'right down eye';'right down lip';'right eyebrow inside';'right eyebrow outside';'right nose';'right upper eye';'right upper lip'};
name_mark_type = {'X','Y','Z','az','el','r'};
N_mark_type = length(name_mark_type);

% 파라미터
idx2use_etd_pos = 2;
N_trn_trl = 5;
idx_train = randperm(15);  idx_train = idx_train(1:N_trn_trl);
idx_test = find(countmember(1:15,idx_train)==0);
dim_pca = 4;
sigma_pca = 0.5;
for i_sub = 1
    % 파일 불러오기
    fname = sprintf('sub_%d.mat',i_sub);
    load(fullfile(cd,'DB_norm',fname));
    
    % input: EMG
    % train
    Xtr = cell2mat(emg.n_set(idx_train,idx2use_etd_pos))';
    % test
    Xte = cell2mat(emg.n_set(idx_test,idx2use_etd_pos))';
    
    
    for i_m = 1 : N_marker
        % nose마커는 넘어가기
        if i_m==2
            continue;
        end
        % output(Y label): Marker
        % train set
        temp_Ytr = cam.n_set(idx_train,i_m);
        Ytr = cell2mat(temp_Ytr)';
        % test set
        temp_Ytr = cam.n_set(idx_test,i_m);
        % test size 기억하기
        for i = 1 : size(temp_Ytr,1)
            len_test(i,1) = length(temp_Ytr{i});
        end
        Yte = cell2mat(temp_Ytr)';
        
        % train
        % 2차항으로 EMG feature agumentation
        idx2agu = permn(1:4,2);
        Xtr_agu = zeros(size(idx2agu,1),length(Xtr));
        for i_aug = 1 : size(idx2agu,1)
            Xtr_agu(i_aug,:) = Xtr(idx2agu(i_aug,1),:).*Xtr(idx2agu(i_aug,2),:);
        end
        
        % cancatinating 한 후 normalization by mean and standard
        % deviation
        Ztr = [Xtr;Xtr_agu;Ytr];
        [Ztr,mu_tr,sigma_tr] = zscore(Ztr,0,2);
        
        % Training using PCA
        [coeff_tr,~,latent_tr] = pca(Ztr');
        %             [V_tr,D_tr] = eig(cov(Ztr'));
        %             % sorting by eigen value
        %             [~,i_sorted] = sort(diag(D_tr),'descend');
        %             V_tr(:,i_sorted(1:dim_pca))
        PCA_model = coeff_tr(:,1:dim_pca); % EMG부분만 모델 사용
        PCA_model_emg = PCA_model(1:size(Xtr,1)+size(Xtr_agu,1),:);
        
        % Test DB 준비
        % 2차항으로 EMG feature agumentation
        idx2agu = permn(1:4,2);
        Xte_agu = zeros(size(idx2agu,1),length(Xte));
        for i_aug = 1 : size(idx2agu,1)
            Xte_agu(i_aug,:) = Xte(idx2agu(i_aug,1),:).*Xte(idx2agu(i_aug,2),:);
        end
        Zte = [Xte;Xte_agu;Yte];
        Zte = (Zte-repmat(mu_tr,[1,length(Zte)]))./repmat(sigma_tr,[1,length(Zte)]);
        
        % Least Square Error (LSE) estimation
%         b_lse = inv(PCA_model_emg'*PCA_model_emg)*PCA_model_emg';
%         Zpd = PCA_model*b_lse*Zte(1:size(Xtr,1)+size(Xtr_agu,1),:);
        
        Cb = diag(latent_tr(1:dim_pca));
        bmmse = inv((PCA_model_emg'*PCA_model_emg)+sigma_pca^2*inv(Cb))...
            *PCA_model_emg'*Zte(1:size(Xtr,1)+size(Xtr_agu,1),:);
        Zpd = PCA_model*bmmse;
        
        % 결과 정리 
        perf(i_m,:) = rms(Zte(21:end,:)-Zpd(21:end,:),2)';
        % 그림 그려보기
        % test set trial 별로 다시 나누기
        Zte_cell = mat2cell(Zte,26,len_test);
        Zpd_cell = mat2cell(Zpd,26,len_test);     
        
        % Trial 별로 그림 그리기
%         for i_mtype = 1 : N_mark_type
%             h = figure;
%         for i_tr_te = 1 : length(Zpd_cell)
%             subplot(length(Zpd_cell),1,i_tr_te)
%             plot(Zte_cell{i_tr_te}(20+i_mtype,:)');
%             hold on;
%             plot(Zpd_cell{i_tr_te}(20+i_mtype,:)');
%             name_title = sprintf('Position_%s Type_%s',name_mark_pos{i_m},name_mark_type{i_mtype});
%             %                 if i_tr_te==1
%             %                     title(name_title,'Interpreter', 'none');
%             %                 end
%         end
%             xlabel(name_title,'Interpreter', 'none');
%             h.Position = [1 41 1920 962];
%             c = getframe(h);
%             cdata{i_mtype,1} = c.cdata;
%             close(h);
%         end
       
        % 그림 저장
%         fname = sprintf('sub%d_%s.jpg',i_sub,name_mark_pos{i_m});
%         imwrite(cell2mat(cdata),fullfile(cd,fname));
        
    end
end

% regression이 잘된 마커 찾기
name_mark_pos(2) = [];
perf(2,:) = [];
% perf = perf(:,21:26);
[rmsev,temp] = sort(perf(:));
for i_r = 1 : 10
    fprintf('rmsev : %f ',rmsev(i_r));
    [I_row(i_r), I_col(i_r)] = ind2sub(size(perf),temp(i_r));
    fprintf('Position_%s Type_%s\n',name_mark_pos{I_row(i_r)},name_mark_type{I_col(i_r)});
end 