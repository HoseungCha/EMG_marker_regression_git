% Nose 중심으로  Transform Cartesian coordinates to sphericalcollapse 시행 하는 코드
clear;

addpath(genpath(fullfile(cd,'functions')));
% read file path of data
[Sname,Spath] = read_names_of_file_in_folder(fullfile(cd,'DB'));
N_subject = 13;
N_trial = 15;
N_marker = 28;
% N_subject = length(Sname);
marker_set = cell(N_subject,N_trial,N_marker);
for i_sub= 1: N_subject
    sub_name = Sname{i_sub}(end-2:end);

    [c_fname,c_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*csv');
    N_trial = length(c_fname);
    [b_fname,b_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');

    for i_data=1: N_trial
        %% CSV Read
        file_name_path = [Spath{i_sub},'\',num2str(i_data),'.csv'];
        [Marker_Data ,Labels,Time,NMarkers,NFrames,FrameRate] = csv2mat(file_name_path); 
        %% 1.central_down_lip  ^2.central_nose^  3.central_upper_lip  4.head1  5.head2  6. head3  7.head4  8.jaw
        %% 9.left_central_lip  10.left_cheek  11.left_dimple  12.left_down_eye  13.left_down_lip  14.left_eyebrow_inside
        %% 15. left_eyebrow_outside  16.left_nose  17.left_upper_eye  18.left_upper_lip  19.right_central_lip
        %% 20.right_cheek  21.right_dimple  22.right_down_eye  23.right_down_lip  24.right_eyebrow_inside
        %% 25.right_eyebrow_outside  26.right_nose  27.right_upper_eye  28.right_upper_lip
    nose_marker = permute(Marker_Data(:,2,:),[1 3 2]);
    for i_marker = 1 : N_marker     
        Labels{i_marker}(1:2) = [];
        temp = nose_marker - permute(Marker_Data(:,i_marker,:),[1 3 2]);
        [azimuth,elevation,r] = cart2sph(temp(:,1),temp(:,2),temp(:,3));
        marker_set{i_sub,i_data,i_marker} = [azimuth,elevation,r];
        
        
    end
  
    sprintf('%d trial complete',i_data)    
    end  
    sprintf('%dst people complete',i_sub)
end
save('marker_set.mat','marker_set','Labels','Sname','-v7.3');


