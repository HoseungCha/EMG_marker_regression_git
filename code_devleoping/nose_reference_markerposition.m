clear;
% N_trial = 15; %% ½ÇÇè È½¼ö

addpath(genpath(fullfile(cd,'functions')));
% read file path of data
[Sname,Spath] = read_names_of_file_in_folder(fullfile(cd,'DB'));
N_subject = length(Sname);

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
              
                
        for i_frame= 1:NFrames
            %% rigid body
            rigid.right_eyebrow(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,24,:), 1,3,1)-reshape(Marker_Data(i_frame,25,:), 1,3,1) );
            rigid.right_eye(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,27,:), 1,3,1)-reshape(Marker_Data(i_frame,22,:), 1,3,1) );
            rigid.right_cheek(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,20,:), 1,3,1)-reshape(Marker_Data(i_frame,26,:), 1,3,1) );
            rigid.right_dimple(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,21,:), 1,3,1)-reshape(Marker_Data(i_frame,19,:), 1,3,1) );
            rigid.right_upper_lip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,28,:), 1,3,1)-reshape(Marker_Data(i_frame,3,:), 1,3,1) );
            rigid.right_down_lip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,23,:), 1,3,1)-reshape(Marker_Data(i_frame,1,:), 1,3,1) );
            
            rigid.left_eyebrow(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,14,:), 1,3,1)-reshape(Marker_Data(i_frame,15,:), 1,3,1) );
            rigid.left_eye(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,12,:), 1,3,1)-reshape(Marker_Data(i_frame,17,:), 1,3,1) );
            rigid.left_cheek(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,10,:), 1,3,1)-reshape(Marker_Data(i_frame,16,:), 1,3,1) );
            rigid.left_dimple(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,11,:), 1,3,1)-reshape(Marker_Data(i_frame,9,:), 1,3,1) );
            rigid.left_upper_lip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,3,:), 1,3,1)-reshape(Marker_Data(i_frame,18,:), 1,3,1) );
            rigid.left_down_lip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,1,:), 1,3,1)-reshape(Marker_Data(i_frame,13,:), 1,3,1) );
            
             %% distance from nose
             disn.right_eyebrow_out(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,25,:), 1,3,1) );
             disn.right_eyebrow_in(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,24,:), 1,3,1) );           
             disn.right_upeye(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,27,:), 1,3,1) );
             disn.right_downeye(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,22,:), 1,3,1) );             
             disn.right_cheek(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,20,:), 1,3,1) );
             disn.right_nose(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,26,:), 1,3,1) );             
             disn.right_dimple(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,21,:), 1,3,1) );
             disn.right_centlip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,19,:), 1,3,1) );             
             disn.right_uplip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,28,:), 1,3,1) );
             disn.right_downlip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,23,:), 1,3,1) );
             
             disn.left_eyebrow_out(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,15,:), 1,3,1) );
             disn.left_eyebrow_in(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,14,:), 1,3,1) );             
             disn.left_upeye(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,17,:), 1,3,1) );
             disn.left_downeye(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,12,:), 1,3,1) );             
             disn.left_cheek(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,10,:), 1,3,1) );
             disn.left_nose(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,16,:), 1,3,1) );             
             disn.left_dimple(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,11,:), 1,3,1) );
             disn.left_centlip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,9,:), 1,3,1) );             
             disn.left_uplip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,18,:), 1,3,1) );
             disn.left_downlip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,13,:), 1,3,1) );
             
             disn.uplip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,3,:), 1,3,1) );
             disn.downlip(i_frame,i_data,i_sub) = norm( reshape(Marker_Data(i_frame,2,:), 1,3,1)-reshape(Marker_Data(i_frame,1,:), 1,3,1) );
        end
        
    sprintf('%d trial complete',i_data)    
    end  
    sprintf('%dst people complete',i_sub)
end
save('marker.mat','rigid','disn');



