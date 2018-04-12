% Predicting 3D lip shapes using facial surface EMG 코드 구현
% from Ho-Seung Cha, Hanyang University

clear; clc;close all;

% for tight subplot
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);

% 실험정보
N_sub=17;
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
N_sub_train = 10;
idx_train = randperm(N_sub);  idx_train = idx_train(1:N_sub_train);
idx_test = find(countmember(1:N_sub,idx_train)==0);
dim_pca = 10;
sigma_pca = 0.95;

%데이터 합치기
emg_ = cell(N_trial,N_Etd_pos,N_sub);
mark_ = cell(N_trial,N_marker,N_sub);
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
    end
    emg_(:,:,i_sub) = emg.n_set;
    mark_(:,:,i_sub) = cam.n_set;
end
% central nose marker 는 제거
mark_(:,2,:) = []; name_mark_pos(2) = [];
N_marker = length(name_mark_pos);

% input: EMG
% train
temp=permute(emg_(:,idx2use_etd_pos,idx_train),[1 3 2]);
Xtr = cell2mat(temp(:))';
% test
temp=permute(emg_(:,idx2use_etd_pos,idx_test),[1 3 2]);
Xte = cell2mat(temp(:))';

% output(Y label): Marker
% train set
temp=reshape(permute(mark_(:,:,idx_train),[1 3 2]),[N_trial*N_sub_train,N_marker]);
Ytr = cell2mat(temp)';

% test set
temp=reshape(permute(mark_(:,:,idx_test),[1 3 2]),[N_trial*(N_sub-N_sub_train),N_marker]);

% test size 기억하기
len_test = zeros(size(temp,1),1);
for i = 1 : size(temp,1)
    len_test(i) = length(temp{i,1});
end
Yte = cell2mat(temp)';

% train
% 2차항으로 EMG feature agumentation
idx2agu = combinator(4,2,'c','r') ;

Xtr_agu = zeros(size(idx2agu,1),length(Xtr));
for i_aug = 1 : size(idx2agu,1)
    Xtr_agu(i_aug,:) = Xtr(idx2agu(i_aug,1),:).*Xtr(idx2agu(i_aug,2),:);
end

% cancatinating 한 후 normalization by mean and standard
% deviation
Ztr = [Xtr;Xtr_agu;Ytr];
% [Ztr,mu_tr,sigma_tr] = zscore(Ztr,0,2);

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
%     idx2agu = permn(1:4,2);
Xte_agu = zeros(size(idx2agu,1),length(Xte));
for i_aug = 1 : size(idx2agu,1)
    Xte_agu(i_aug,:) = Xte(idx2agu(i_aug,1),:).*Xte(idx2agu(i_aug,2),:);
end
Zte = [Xte;Xte_agu;Yte];
% Zte = (Zte-repmat(mu_tr,[1,length(Zte)]))./repmat(sigma_tr,[1,length(Zte)]);

% Least Square Error (LSE) estimation
%     b_lse = inv(PCA_model_emg'*PCA_model_emg)*PCA_model_emg';
%     Zpd = PCA_model*b_lse*Zte(1:size(Xtr,1)+size(Xtr_agu,1),:);

Cb = diag(latent_tr(1:dim_pca));
bmmse = inv((PCA_model_emg'*PCA_model_emg)+sigma_pca^2*inv(Cb))...
    *PCA_model_emg'*Zte(1:size(Xtr,1)+size(Xtr_agu,1),:);
Zpd = PCA_model*bmmse;

% 결과 정리
perf = rms(Zte(size(Xtr,1)+size(Xtr_agu,1)+1:end,:)...
    -Zpd(size(Xtr,1)+size(Xtr_agu,1)+1:end,:),2)';
% 그림 그려보기
% test set trial 별로 다시 나누기
Zte_cell = mat2cell(Zte,size(Zte,1),len_test);
Zpd_cell = mat2cell(Zpd,size(Zte,1),len_test);

% Trial 별로 그림 그리기

for i_tr_te = 1 : length(Zpd_cell)
    h = figure;
%     subplot(length(Zpd_cell),1,i_tr_te)
    plot(Zte_cell{i_tr_te}(:,:)');
    hold on;
    figure;
    plot(Zpd_cell{i_tr_te}(:,:)');
%     name_title = sprintf('Position_%s Type_%s',name_mark_pos{i_m},name_mark_type{i_mtype});
    xlabel(name_title,'Interpreter', 'none');
    h.Position = [1 41 1920 962];
    c = getframe(h);
    cdata{i_tr_te,1} = c.cdata;
    close(h);
end


% 그림 저장
%         fname = sprintf('sub%d_%s.jpg',i_sub,name_mark_pos{i_m});
%         imwrite(cell2mat(cdata),fullfile(cd,fname));
% end

% regression이 잘된 마커 찾기
% name_mark_pos(2) = [];
% perf(2,:) = [];
% perf = perf(:,21:26);
[rmsev,temp] = sort(perf(:));
for i_r = 1 : 10
    fprintf('rmsev : %f ',rmsev(i_r));
    [I_row(i_r), I_col(i_r)] = ind2sub(size(perf),temp(i_r));
    name_title = sprintf('Position_%s Type_%s\n',name_mark_pos{I_row(i_r)},name_mark_type{I_col(i_r)});
    disp(name_title);
    plot(Zte_cell{i_tr_te}(20+i_mtype,:)');
end

% regression이 잘된 마커 그리기
% Trial 별로 그림 그리기
% for i_mtype = 1 : N_mark_type
%     h = figure;
% for i_tr_te = 1 : length(Zpd_cell)
%     subplot(length(Zpd_cell),1,i_tr_te)
%     plot(Zte_cell{i_tr_te}(20+i_mtype,:)');
%     hold on;
%     plot(Zpd_cell{i_tr_te}(20+i_mtype,:)');
%     name_title = sprintf('Position_%s Type_%s',name_mark_pos{i_m},name_mark_type{i_mtype});
%     %                 if i_tr_te==1
%     %                     title(name_title,'Interpreter', 'none');
%     %                 end
% end
%     xlabel(name_title,'Interpreter', 'none');
%     h.Position = [1 41 1920 962];
%     c = getframe(h);
%     cdata{i_mtype,1} = c.cdata;
%     close(h);
% end

% 그림 저장
%         fname = sprintf('sub%d_%s.jpg',i_sub,name_mark_pos{i_m});
%         imwrite(cell2mat(cdata),fullfile(cd,fname));
