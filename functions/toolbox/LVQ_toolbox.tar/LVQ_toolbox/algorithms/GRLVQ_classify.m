function estimatedLabels = GRLVQ_classify(Data, model)
%GRLVQ_classify.m - classifies the given data with the given model
%  example for usage:
%  trainSet = [1,2,3;4,5,6;7,8,9];
%  trainLab = [1;1;2];
%  GRLVQ_model=GRLVQ_train(trainSet,trainLab); % minimal parameters required
%  estimatedTrainLabels = GRLVQ_classify(trainSet, GRLVQ_model);
%  trainError = mean( trainLab ~= estimatedTrainLabels );
%
% input: 
%  trainSet : matrix with training samples in its rows
%  model    : GRLVQ model with prototypes w their labels c_w and the relevances lambda
% 
% output    : the estimated labels
%  
% Kerstin Bunte
% kerstin.bunte@googlemail.com
% Mon Nov 05 09:05:52 CEST 2012
%
% Conditions of GNU General Public License, version 2 apply.
% See file 'license-gpl2.txt' enclosed in this package.
% Programs are not for use in critical applications!
%
dist = computeDistance(Data, model.w, model);
[~, index] = min(dist,[],2);

estimatedLabels = model.c_w(index);