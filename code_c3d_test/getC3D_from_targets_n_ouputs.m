%----------------------------------------------------------------------
% c3d --> mat --> c3d
% mat(random) --> c3d
%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------
clear;clc;close all;

%% load C3D sample 
acq = btkReadAcquisition('01.c3d');
markers = btkGetMarkers(acq);
temp = struct2cell(markers);
% markers_value = cat(2,temp{:});

%% prepare marker_valus from EMG-marker classifier
load('target_output');
output = cellfun(@(x) x',output,'UniformOutput',false); % trans pose
output{2} = zeros(size(output{1})); % fill in zeros in nose marker
target = cellfun(@(x) x',target,'UniformOutput',false); % trans pose
target{2} = zeros(size(target{1})); % fill in zeros in nose marker
marker_v_output = cat(2,output{:});
marker_v_target = cat(2,target{:});

%% get parameters of CSV data ( 가정: changes of number of frame )
N_marker = 28;
N_frame = size(marker_v_target,1);

acq4output =  btkCloneAcquisition(acq); % c3d의 나머지 parameters들을 가져옴
acq4target =  btkCloneAcquisition(acq); % c3d의 나머지 parameters들을 가져옴

btkSetFrameNumber(acq4output, N_frame) % set number of frame
btkSetFrameNumber(acq4target, N_frame) % set number of frame

%% new marker values (we need to get those values from csv file)
btkSetMarkersValues(acq4output, marker_v_output);  % set marker values
btkSetMarkersValues(acq4target, marker_v_target);  % set marker values

%% write
btkWriteAcquisition(acq4output, 'output.c3d');
btkWriteAcquisition(acq4target, 'target.c3d');

%% check saved file
acq4check = btkReadAcquisition('output.c3d');
markers4check = btkGetMarkers(acq4check);
