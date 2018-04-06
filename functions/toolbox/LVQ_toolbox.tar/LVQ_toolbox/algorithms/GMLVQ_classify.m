function estimatedLabels = GMLVQ_classify(Data, model)
%GMLVQ_classify.m - classifies the given data with the given model
%  example for usage:
%  trainSet = [1,2,3;4,5,6;7,8,9];
%  trainLab = [1;1;2];
%  GMLVQ_model=GMLVQ_train(trainSet,trainLab); % minimal parameters required
%  estimatedTrainLabels = GMLVQ_classify(trainSet, GMLVQ_model);
%  trainError = mean( trainLab ~= estimatedTrainLabels );
%
% input: 
%  trainSet : matrix with training samples in its rows
%  model    : GMLVQ model with prototypes w their labels c_w and the matrix omega
% 
% output    : the estimated labels
%  
% Kerstin Bunte
% kerstin.bunte@googlemail.com
% Mon Nov 05 09:05:52 CEST 2012
%
% Conditions of GNU General Public License, version 2 and BSD License apply.
% See file 'license-gpl2.txt' and 'BSD_license.txt' enclosed in this package.
% Programs are not for use in critical applications!
%
dist = computeDistance(Data, model.w, model);
[~, index] = min(dist,[],2);

estimatedLabels = model.c_w(index);