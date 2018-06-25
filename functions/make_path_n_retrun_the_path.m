%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------
function path_made = make_path_n_retrun_the_path(path2save,folder_name2make)
    % path2save에 filder_name2make의 이름으로 폴더 생성
    
    % check if folder aleady exists
    if exist(fullfile(path2save,folder_name2make),'file')
        path_made = fullfile(path2save,folder_name2make);
        return;
    end
    mkdir(path2save,folder_name2make);
%     if strcmp(msg,'디렉터리가 이미 존재합니다.')
%         return;
%     end
    % 만든 폴더의 path 받아옴
    path_made = fullfile(path2save,folder_name2make);
end