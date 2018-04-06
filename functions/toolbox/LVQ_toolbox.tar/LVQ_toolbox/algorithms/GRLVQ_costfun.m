function cost = GRLVQ_costfun(trainSet, trainLab, model, regularization)
%GMLVQ_costfun.m - computes the costs for a given training set and GMLVQ
%model with or without regularization
%  example for usage:
%  trainSet = [1,2,3;4,5,6;7,8,9];
%  trainLab = [1;1;2];
%  GMLVQ_model=GMLVQ_train(trainSet,trainLab); % minimal parameters required
%  costs = GMLVQ_costfun(trainSet, trainLab, GMLVQ_model, 0);
%
% input: 
%  trainSet : matrix with training samples in its rows
%  trainLab : a vector of training labels
%  model    : GMLVQ model with prototypes w their labels c_w and the matrix omega
%  regularization: the factor>=0 for the regularization
% 
% output    : cost function value
%  
% Kerstin Bunte (based on the code from Marc Strickert)
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

% LabelEqPrototype = trainLab*ones(1,numel(model.c_w)) == (model.c_w*ones(1,nb_samples))';
LabelEqPrototype = bsxfun(@eq,trainLab,model.c_w');
dists = computeDistance(trainSet, model.w, model);
if regularization,
    regTerm = regularization * log(prod(model.lambda));
% if strcmp(p.Results.optimization,'sgd')       
else
    regTerm = 0;
end
Dwrong = dists;
Dwrong(LabelEqPrototype) = realmax(class(Dwrong));   % set correct labels impossible
distwrong = min(Dwrong.'); % closest wrong
clear Dwrong;

Dcorrect = dists;
Dcorrect(~LabelEqPrototype) = realmax(class(Dcorrect)); % set wrong labels impossible
distcorrect = min(Dcorrect.'); % closest correct
clear Dcorrect;
clear dists;
distcorrectpluswrong = distcorrect + distwrong;
distcorrectminuswrong = distcorrect - distwrong;
mu = distcorrectminuswrong ./ distcorrectpluswrong;
if regularization,
    regTerm = regularization * log(prod(model.lambda));
else
    regTerm = 0;
end
cost = sum(mu)-regTerm;