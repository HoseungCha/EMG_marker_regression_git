%----------------------------------------------------------------------
% filepath that you want to read
% extenstion that you want to read format of file (ex: *mat, *png etc..)
%----------------------------------------------------------------------
% by Ho-Seung Cha,
% Ph.D Student @  Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%---------------------------------------------------------------------


function [name,FilepathFolder] = read_names_of_file_in_folder(filepath,extension)
path=pwd;
cd(filepath)
if nargin==1
    list = dir;
    id_read_only_folder =1;
else
    list=dir(extension);
    id_read_only_file =1;
end
count=1;
for i=1:length(list)
    % skip unnecessary files
    if ( strcmp(list(i).name,'.')==1 || strcmp(list(i).name,'..')==1)
        continue;
    end
    % if you read only folder, skip files
    if exist('id_read_only_folder') %#ok<EXIST>
        if list(i).bytes~=0
            continue;
        end
    end
    % if you read only files, skip folder
    if exist('id_read_only_file') %#ok<EXIST>
        if list(i).bytes==0
            continue;
        end
    end
    % name which has been read
    name{count,1} = list(i).name;
    FilepathFolder{count,1} = fullfile(filepath,list(i).name);
    count = count +1;
end
cd(path);
end