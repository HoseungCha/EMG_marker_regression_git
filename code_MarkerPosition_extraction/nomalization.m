clear
addpath(genpath(fullfile(cd,'functions')));

make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end

load(fullfile(cd,'EMG_trigger_ext_code','EMG_trg'));
load(fullfile(cd,'MarkerPosition_ext_code','marker_set'));

[N_sub,N_data,N_marker] = size(marker_set);
FS = 2048;
FR = 120;
% dr = round(FS/FR);
movfilter_size = 12; % 이전 12 샘플수씩 무빙 에버러지 평균 계산
% mov_b = (1/movfilter_size)*ones(1,movfilter_size);
% mov_a = 1;
wininc = movfilter_size;
winsize = movfilter_size;

FR2use = 10;
dr = (FS/FR);

trg_name =Trg_name(2:end);
% for i_sub= 1: N_sub


for i_sub= 1: N_sub
    mark_norm = cell(N_data,N_marker);
    for i_data = 1: N_data
        temp_trg =Trg_all{i_sub,i_data}(2:end)- Trg_all{i_sub,i_data}(1);
        temp_trg = round(temp_trg/dr);
%         figure;
        for i_marker= 1 : N_marker
%             disp(Labels{i_marker});
            % marker position 구하기
            temp = marker_set{i_sub,i_data,i_marker};
            m.az = temp(:,1);
            m.el = temp(:,2);
            m.r = temp(:,3);
            [m.x,m.y,m.z] = sph2cart(m.az,m.el,m.r);
            mark = cell2mat(struct2cell(m)');
            
            % Moving average filtering
            [mark_f,trg] = getmovfilter(mark,winsize,wininc,[],[],temp_trg);
            
            % 표정 부분만 추출
            mark_f(trg(27):end,:) = [];
            
            % Calibration session에서 Nomalization
            Max = max(mark_f(1 : trg(6),:));
            Min = min(mark_f(1 : trg(6),:));
            mark_n = (mark_f-Min)./(Max-Min);
            mark_norm{i_data,i_marker} = mark_n;
            
            %그려서 확인
            
%             subplot(N_marker,1,i_marker);
%             plot(mark_n);ylim([0 1]);xlim([0 length(mark_n)+300])
%             a = gca;
%             hold on;
%             stem(trg,repmat(a.YLim(2),[length(trg),1]),'k');
%             stem(trg,repmat(a.YLim(1),[length(trg),1]),'k')
%             for i_text = 1 : 26
%                 text(trg(i_text),...
%                     a.YLim(2)-((a.YLim(2)-a.YLim(1))/length(trg))*i_text,...
%                     trg_name(i_text))
%             end
%             title(Labels{i_marker});
%             legend(fieldnames(m));
        end
%         g = gcf;
%         g.Position = [1921 41 1920 962];
%         c = getframe(g);
%         close(g)
        name_img = sprintf('sub_%d_dat_%d.jpg',i_sub,i_data)
%         imwrite(c.cdata,fullfile(cd,'DB_mark_norm',name_img));
    end
    
    % 저장
    s_name = sprintf('sub_%d',i_sub);
    save(fullfile(cd,'DB_mark_norm',s_name),'mark_norm');
end

% for i = 3
%     data_temp = temp(:,i);
%     data_temp = data_temp- data_temp(temp_trg(1))
%     figure(i_data);plot(data_temp); hold on;
%     y_min = min(data_temp);
%     y_max = max(data_temp);
%     y_mean = mean(data_temp);
%     ha = gca;
%     hold on;
%     ylim([y_min,y_max]);
%     title(Labels{i_marker});

%     for i_text = 1 : length(temp_trg)
%         text(temp_trg(i_text),...
%             repmat(ha.YLim(2)-((ha.YLim(2)-ha.YLim(1))/length(temp_trg))*i_text,...
%             [length(temp_trg(i_text)),1]),trg_name(i_text))
%     end
% 
% 
% end