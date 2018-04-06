%%% demo file for running GMLVQ, GRLVQ, or LGMLVQ
%
% Kerstin Bunte (modified based on the code of Marc Strickert http://www.mloss.org/software/view/323/ and Petra Schneider)
% uses the Fast Limited Memory Optimizer fminlbfgs.m written by Dirk-Jan Kroon available at the MATLAB central
% kerstin.bunte@googlemail.com
% Fri Nov 09 14:22:00 CEST 2012
%
% Conditions of GNU General Public License, version 2 and BSD License apply.
% See file 'license-gpl2.txt' and 'BSD_license.txt' enclosed in this package.
% Programs are not for use in critical applications!
%
addpath(genpath('.'));
% load the data
% actData = 'Iris';
% load data/Iris.csv;
% data = Iris(:,1:end-1);
% label = Iris(:,end);
% nb_samples_per_class = 45;
actData = 'UCIsegmentation';
load data/segment.dat;
data = segment(:,1:end-1);
data(:,std(data)==0) = []; % feature 3 is constant -> exclude it
label= segment(:,end);
nb_samples_per_class = 300;

fprintf('Load the %s data set containing %i samples with %i features.\n',actData,size(data,1),size(data,2));
% draw randomly 100 samples from every class
nb_folds = 1;
indices = nFoldCrossValidation(data,'labels',label,'splits','random','nb_samples',nb_samples_per_class,'nb_folds',nb_folds,'comparable',1);
actSet = 1;
% extract the training set
trainSet = data(indices{actSet},:);
trainLab = label(indices{actSet});
% extract the test set
testIdx = 1:length(label);
testIdx(indices{actSet}) = [];
testSet = data(testIdx,:);
testLab = label(testIdx);

disp('preprocess the data using zscore');
[trainSet, zscore_model] = zscoreTransformation(trainSet);
testSet = zscoreTransformation(testSet, 'parameter', zscore_model);
%% run GMLVQ with in build optimization
GMLVQ_results = struct('GMLVQ_model',{},'GMLVQ_setting',{},'zscore_model',{},'trainError',{},'testError',{});
projectionDimension = size(trainSet,2);
GMLVQparams = struct('PrototypesPerClass',1,'dim',projectionDimension,'regularization',0);

[GMLVQ_model,GMLVQ_settting] = GMLVQ_train(trainSet, trainLab,'dim',GMLVQparams.dim,'PrototypesPerClass',GMLVQparams.PrototypesPerClass,...
    'regularization',GMLVQparams.regularization);
estimatedTrainLabels = GMLVQ_classify(trainSet, GMLVQ_model);
trainError = mean( trainLab ~= estimatedTrainLabels );
fprintf('GMLVQ: error on the train set: %f\n',trainError);
estimatedTestLabels = GMLVQ_classify(testSet, GMLVQ_model);
testError = mean( testLab ~= estimatedTestLabels );
fprintf('GMLVQ: error on the test set: %f\n',testError);

dataprojection = GMLVQ_project([trainSet;testSet], GMLVQ_model, 2);
protprojection = GMLVQ_project(GMLVQ_model.w, GMLVQ_model, 2);

GMLVQ_results{actSet}.zscore_model = zscore_model;
GMLVQ_results{actSet}.GMLVQ_model = GMLVQ_model;
GMLVQ_results{actSet}.GMLVQ_settting = GMLVQ_settting;
GMLVQ_results{actSet}.trainError = trainError;
GMLVQ_results{actSet}.testError = testError;

GMLVQ_model_rank2 = GMLVQ_train(trainSet, trainLab,'dim',2,'PrototypesPerClass',[2,1,2,1,3,2,1],'regularization',0);
fprintf('GMLVQ rank 2: error on the train set: %f\n',mean( trainLab ~= GMLVQ_classify(trainSet, GMLVQ_model_rank2) ));
fprintf('GMLVQ rank 2: error on the test set: %f\n',mean( testLab ~= GMLVQ_classify(testSet, GMLVQ_model_rank2) ));

rank2projection= GMLVQ_project([trainSet;testSet], GMLVQ_model_rank2, 2);
rank2protsproj = GMLVQ_project(GMLVQ_model_rank2.w, GMLVQ_model_rank2, 2);

scrsz = get(0,'ScreenSize');
f = figure(1);set(f,'Position',[scrsz(3)-scrsz(3)/1.8-1 scrsz(4)/2 scrsz(3)/1.8 scrsz(4)/2]);clf(f);set(gcf, 'color', 'none');set(gca, 'color', 'none');
subplot('position',[.03 0.56 0.29 0.4]);
imagesc(GMLVQ_model.omega'*GMLVQ_model.omega);box on;title('GMLVQ: relevance matrix Lambda');colorbar;
subplot('position',[.36 0.56 0.29 0.4]);
bar(svd(GMLVQ_model.omega'*GMLVQ_model.omega));box on;title('GMLVQ: eigenvalues of the matrix');
subplot('position',[.7 0.56 0.29 0.4]);
mins = min(dataprojection);
maxs = max(dataprojection);
gscatter(dataprojection(:,1),dataprojection(:,2),[trainLab;testLab],'','o',4,'off','dim 1','dim 2');box on;title('2 dim projection of the data');
xlim([mins(1) maxs(1)]);ylim([mins(2) maxs(2)]);hold on;
my_voronoi2(protprojection(:,1),protprojection(:,2),GMLVQ_model.c_w,'k');

subplot('position',[.03 0.06 0.29 0.4]);
imagesc(GMLVQ_model_rank2.omega'*GMLVQ_model_rank2.omega);box on;title('GMLVQ (rank 2): relevance matrix Lambda');colorbar;
subplot('position',[.36 0.06 0.29 0.4]);
bar(svd(GMLVQ_model_rank2.omega'*GMLVQ_model_rank2.omega));box on;title('GMLVQ (rank 2): eigenvalues of the matrix');
subplot('position',[.7 0.06 0.29 0.4]);
mins = min(rank2projection);
maxs = max(rank2projection);
gscatter(rank2projection(:,1),rank2projection(:,2),[trainLab;testLab],'','o',4,'off','dim 1','dim 2');box on;title('2 dim projection of the data');
xlim([mins(1) maxs(1)]);ylim([mins(2) maxs(2)]);hold on;
my_voronoi2(rank2protsproj(:,1),rank2protsproj(:,2),GMLVQ_model_rank2.c_w,'k');
% resultpath = ['results/',actData,'/'];
% save([resultpath,'GMLVQ_',num2str(nb_folds),'_foldCV_experiment_',date],'indices','GMLVQ_results');
%% run GRLVQ with in build optimization
GRLVQ_results = struct('GRLVQ_model',{},'GRLVQ_setting',{},'zscore_model',{},'trainError',{},'testError',{});

GRLVQparams = struct('PrototypesPerClass',1,'regularization',0);

[GRLVQ_model,GRLVQ_setting,trainError,testError,costs] = GRLVQ_train(trainSet, trainLab,'PrototypesPerClass',GRLVQparams.PrototypesPerClass,...
	'testSet',[testSet,testLab],'regularization',GRLVQparams.regularization); % ,'optimization','sgd'
% estimatedTrainLabels = GRLVQ_classify(trainSet, GRLVQ_model);
% trainError = sum( trainLab ~= estimatedTrainLabels )/length(estimatedTrainLabels);
fprintf('GRLVQ: error on the train set: %f\n',trainError(end));
% estimatedTestLabels = GRLVQ_classify(testSet, GRLVQ_model);
% testError = sum( testLab ~= estimatedTestLabels )/length(estimatedTestLabels);
fprintf('GRLVQ: error on the test set: %f\n',testError(end));

GRLVQ_results{actSet}.zscore_model = zscore_model;
GRLVQ_results{actSet}.GRLVQ_model = GRLVQ_model;
GRLVQ_results{actSet}.GRLVQ_setting = GRLVQ_setting;
GRLVQ_results{actSet}.trainError = trainError;
GRLVQ_results{actSet}.testError = testError;

scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3)/1.3 scrsz(4)/2]);
bar(GRLVQ_model.lambda);box on;title('GRLVQ: relevances');
%% run LGMLVQ with in build optimization
LGMLVQ_results = struct('GMLVQ_model',{},'GMLVQ_setting',{},'zscore_model',{},'trainError',{},'testError',{});
projectionDimension = size(trainSet,2);
LGMLVQparams = struct('PrototypesPerClass',1,'dim',projectionDimension,'regularization',0);

[LGMLVQ_model,LGMLVQ_setting,trainError,testError] = LGMLVQ_train(trainSet, trainLab,'dim',LGMLVQparams.dim,...
    'PrototypesPerClass',LGMLVQparams.PrototypesPerClass,'testSet',[testSet,testLab],'classwise',0,'regularization',LGMLVQparams.regularization);
% estimatedTrainLabels = LGMLVQ_classify(trainSet, LGMLVQ_model);
% trainError = mean( trainLab ~= estimatedTrainLabels );
fprintf('LGMLVQ: error on the train set: %f\n',trainError(end));
% estimatedTestLabels = LGMLVQ_classify(testSet, LGMLVQ_model);
% testError = mean( testLab ~= estimatedTestLabels );
fprintf('LGMLVQ: error on the test set: %f\n',testError(end));
% plot([trainError;testError]');
