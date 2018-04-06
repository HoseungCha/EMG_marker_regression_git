function cost = LGMLVQ_costfun(trainSet, trainLab, model, regularization)
%LGMLVQ_costfun.m - computes the costs for a given training set and LGMLVQ
%model with or without regularization
%  example for usage:
%  trainSet = [1,2,3;4,5,6;7,8,9];
%  trainLab = [1;1;2];
%  LGMLVQ_model=LGMLVQ_train(trainSet,trainLab); % minimal parameters required
%  costs = LGMLVQ_costfun(trainSet, trainLab, LGMLVQ_model, zeros(1,length(LGMLVQ_model.psis)));
%
% input: 
%  trainSet : matrix with training samples in its rows
%  trainLab : a vector of training labels
%  model    : LGMLVQ model with prototypes w their labels c_w and the matrices psis
%  regularization: the factor>=0 for the regularization
% 
% output    : cost function value
%  
% Kerstin Bunte
% kerstin.bunte@googlemail.com
% Mon Nov 05 09:05:52 CEST 2012
%
% Conditions of GNU General Public License, version 2 apply.
% See file 'license-gpl2.txt' enclosed in this package.
% Programs are not for use in critical applications!
%
nb_samples = length(trainLab);
% labels should be a row vector
if size(trainLab,1)~=nb_samples, trainLab = trainLab';end

LabelEqPrototype = trainLab*ones(1,numel(model.c_w)) == (model.c_w*ones(1,nb_samples))';
dists = computeDistance(trainSet, model.w, model);
Dwrong = dists;
Dwrong(LabelEqPrototype) = realmax(class(Dwrong));   % set correct labels impossible
[distwrong pidxwrong] = min(Dwrong.'); % closest wrong
clear Dwrong;
Dcorrect = dists;
Dcorrect(~LabelEqPrototype) = realmax(class(Dcorrect)); % set wrong labels impossible
[distcorrect pidxcorrect] = min(Dcorrect.'); % closest correct
clear Dcorrect;
distcorrectpluswrong = distcorrect + distwrong;
distcorrectminuswrong = distcorrect - distwrong;
mu = distcorrectminuswrong ./ distcorrectpluswrong;
if sum(regularization)>0,
    regTerm = regularization .* cellfun(@(matrix) log(det(matrix*matrix')),model.psis);
    cost = sum(mu-regTerm(pidxcorrect)-regTerm(pidxwrong));
else
    cost = sum(mu);
end
clear dists;