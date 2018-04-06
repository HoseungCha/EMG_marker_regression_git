function indices = nFoldCrossValidation( data, varargin )
% nFoldCrossValidation.m - n-fold crossvalidation
% Performs an n-fold cross validation on a labeled or unlabeled set and
% returns the n index lists for the folds as cell array of size (1,n).
% NOTE: minimal requirement version 7.4.0.336 (R2007a) 
%  example for usage:
%  load segment.dat;
%  data = segment(:,1:end-1);
%  disjunctIdx = nFoldCrossValidation(data);
%  disjunctIdx5Folds = nFoldCrossValidation(data,'nb_folds',5);
%  disjunctIdx5FoldsEqualClassDistribution = nFoldCrossValidation(data,'labels',segment(:,end),'nb_folds',5);
%  randomIndicesEqualclassDistribution = nFoldCrossValidation(segment(:,1:end-1),'labels',segment(:,end),'splits','random','nb_samples',300,'nb_folds',10);
%  nb_folds = 5;
%  actTestSet = 2;
%  actTrainSet = [1:actTestSet-1,actTestSet+1:nb_folds];
%  testset  = data(disjunctIdx5Folds{actTestSet},:);
%  testlab  = labels(disjunctIdx5Folds{actTestSet});
%  trainset = data(cat(2,disjunctIdx5Folds{actTrainSet}),:);
%  trainlab = labels(cat(2,disjunctIdx5Folds{actTrainSet}));
%
%  input: 
%  data         : matrix with training samples in its rows and the columns contains the features
% 
%  optional input parameters:
%  'nb_folds'   : (default 10) the number of folds created
%  'labels'     : a label vector for the data used to include label information in the splits 
%                 (equal nb of samples from every class in every fold or
%                 keeping the class distributions in disjunct sets).
%  'splits'     : (default 'disjunct') possible values are
%                 'disjunct' -> split the data into disjunct subsets.  
%                               If 'labels' is given the classes are distributed equally in the sets.
%                 'random'   -> extracts 'nb_samples' random samples from the data set in every fold. 
%  'nb_samples' : (default 1000) nb_samples used if 'splits' = 'random'.
%                  If 'labels' is given the nb_samples are extracted from
%                  every class -> fold size = nb_samples*nb_classes. 
%                  Otherwise the nb_samples equals the fold size.
%  'comparable' : (default false) set this to true to produce the same splits
% 
%  output: 
%  indices      : a cell array containing the indices of the samples for the splits
% 
%  Copyright 2012 Kerstin Bunte
%  $Revision: 0 $  $Date: 2012/10/26 10:00 $
%  
p = inputParser;   % Create an instance of the class.
p.addRequired('data', @isfloat);

p.addOptional('nb_folds', 10, @(x)(~(x-floor(x))));
p.addOptional('labels', [], @(x)(length(x)==size(data,1)));
p.addOptional('splits', 'disjunct', @(x)any(strcmpi(x,{'disjunct','random'})));
p.addOptional('nb_samples', 1000, @(x)(~(x-floor(x))));
p.addOptional('comparable', 0, @(x)(~(x-floor(x))));

p.CaseSensitive = true;
p.FunctionName = 'nFoldCrossValidation';
% Parse and validate all input arguments.
p.parse(data, varargin{:});
% Display all arguments.
disp 'Perform n-fold cross validation with following settings:'
disp(p.Results);

nb_samples = size(data,1);
nb_folds = p.Results.nb_folds;
labels = p.Results.labels;
if p.Results.comparable,
    rng('default');
end

indices = cell(1,nb_folds);
switch(p.Results.splits)
    case{'disjunct'}
        if isempty(labels)
            randomizedIdx = randperm(nb_samples);
            nb_samples_pf = ceil(nb_samples/nb_folds);
            for j=1:nb_folds-1
                indices{j} = cat(1,indices{j},data(randomizedIdx((j-1)*nb_samples_pf+1:j*nb_samples_pf)));
            end
            indices{nb_folds} = cat(1,indices{nb_folds},data(randomizedIdx((nb_folds-1)*nb_samples_pf+1:end)));
        else
            classes = unique(labels);
            nb_classes = length(classes);    

            classIdx = cell(1,nb_classes);

            for i=1:nb_classes
                classIdx{i} = find(labels==classes(i));
                randomizedIdx = randperm(length(classIdx{i}));
                nb_samples_pc = ceil(length(classIdx{i})/nb_folds);
                for j=1:nb_folds-1
                    indices{j} = cat(1,indices{j},classIdx{i}(randomizedIdx((j-1)*nb_samples_pc+1:j*nb_samples_pc)));
                end
                indices{nb_folds} = cat(1,indices{nb_folds},classIdx{i}(randomizedIdx((nb_folds-1)*nb_samples_pc+1:end)));
            end      
        end
    otherwise
        if isempty(labels)
            nb_samples_inFold = p.Results.nb_samples;
            for j=1:nb_folds
                randomizedIdx = randperm(nb_samples);
                indices{j} = cat(1,indices{j},data(randomizedIdx((j-1)*nb_samples_inFold+1:j*nb_samples_inFold)));
            end
        else
            classes = unique(labels);
            nb_classes = length(classes);
            classIdx = cell(1,nb_classes);
            for i=1:nb_classes
                nb_samples_perClass = p.Results.nb_samples;
                classIdx{i} = find(labels==classes(i));
                if length(classIdx{i})<nb_samples_perClass
                    nb_samples_perClass = ceil(90/100*length(classIdx{i}));
                    disp(['number of samples in class ',num2str(classes(i)),' is smaller than requested and we will use ~90% = ',num2str(nb_samples_perClass),' samples']);
                end
                randomizedIdx = randperm(length(classIdx{i}));
                for j=1:nb_folds
                    indices{j} = cat(1,indices{j},classIdx{i}(randomizedIdx(1:nb_samples_perClass)));
                end
            end                
        end
end