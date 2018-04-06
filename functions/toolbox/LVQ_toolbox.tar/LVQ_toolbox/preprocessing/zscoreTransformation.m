function [normData, varargout] = zscoreTransformation(dataSet, varargin)
% zscoreTransformation.m - z score transformation
% normalize the data to have zero mean and unit variance
%
%  input: 
%  data         : matrix with training samples in its rows and the columns contains the features
% 
%  optional input parameters:
%  'model'      : applies the transformation given in model (usually coming from a previous run). 
%                 Required fields are 'mean' and 'std'.
% 
nout = max(nargout,1)-1;
p = inputParser;   % Create an instance of the class.
p.addRequired('dataSet', @isfloat);

p.addParamValue('parameter', [], @(x)(isstruct(x) && isfield(x,'mean') && isfield(x,'std')));
p.CaseSensitive = true;
p.FunctionName = 'zscoreTransformation';
% Parse and validate all input arguments.
p.parse(dataSet, varargin{:});

if isempty(p.Results.parameter),
    mnval = mean(dataSet);
    stdval= std(dataSet);
else
    mnval = p.Results.parameter.mean;
    stdval= p.Results.parameter.std;
end

normData = bsxfun(@rdivide,bsxfun(@minus,dataSet,mnval),stdval);

%%% output of the preprocessing
varargout = cell(nout);
for k=1:nout
	switch(k)
		case(1)
            transformationPars = struct('mean',mnval,'std',stdval);
			varargout(k) = {transformationPars};
	end
end