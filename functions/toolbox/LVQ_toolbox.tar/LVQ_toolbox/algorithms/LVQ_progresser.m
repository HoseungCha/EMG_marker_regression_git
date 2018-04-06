function earlystoppedreturn = LVQ_progresser(variables, output, where)
%
% control actions during each iteration of the fminlbfgs optimization
%
% Conditions of GNU General Public License, version 2 and BSD License apply.
% See file 'license-gpl2.txt' and 'BSD_license.txt' enclosed in this package.
% Programs are not for use in critical applications!
% Kerstin Bunte based on the code from Marc Strickert
%
global earlystopped threshstop 

if sum(where == 'iter') < 4
    earlystopped = false;
    earlystoppedreturn = earlystopped;
    return
end

earlystopped = exist ('stop','file') > 0;
earlystoppedreturn = earlystopped;

if earlystopped 
    delete('stop');
    return
end

if isempty(threshstop) 
    return
end


if threshstop > 0  % early stopping by simple thresholding: if too good: stop
    earlystopped = output.fval < threshstop;  % close to perfect
    earlystoppedreturn = earlystopped;
    if earlystopped
      return
    end
end

global useEarlyStopping

if isempty(useEarlyStopping)
    return
end

%%% early stopping

global training_data training_label prototypeLabel% n_vec bestvariables
nb_prototypes = numel(prototypeLabel);
model.w = variables(1:nb_prototypes,:);
model.c_w = prototypeLabel;
model.omega = variables(nb_prototypes+1:end,:);
estimatedLabels = GMLVQ_classify(training_data, model);
ref = mean( training_label ~= estimatedLabels );
% fprintf('error: %f',ref);
%   if isempty(n_vec) || n_vec < 1 % GRLVQ
%     lam = variables(1,:); % weights
%     protos = variables(2:end,:); % protos
%     [cls C] = applyprotoseuc(protos, protolabl, lam, datval, labval);
%   else % MRLVQ
%     lam = variables(1:n_vec,:).';
%     protos = variables((n_vec+1):end,:);
%     [cls C] = applyprotosmat(protos, protolabl, lam, datval, labval);
%   end
% ref = trace(C)/sum(C(:))-1; % negative classif error

persistent last penalty
% disp(last);
if isempty(last) 
%     bestvariables = variables;
    penalty = -25;  % penalty counter, skip first 15 iterations (burn-in phase)
%     last = ref * ones(5,1);  % memory of 5 elements
    last = ref;
else
%     [srt idxsrt] = sort([last; ref],'descend');
%     fvalval = srt(1);
%     fpos = find(idxsrt == 6);  % index of added element
%     if fpos == 6  % last position?
      penalty = penalty + 1;
      if penalty > 10  % allow a maximum of 10 times to fail
        earlystopped = true;
        earlystoppedreturn = earlystopped;
        return
      end
%     else
% %       last = srt(1:5);
% %       if fpos == 1  % best position
% %         bestvariables = variables;
% %       end
%       if penalty < 0  % still in burn-in phase
%         penalty = penalty + 1;
%       end
%       if penalty > 0  % do not go below here
%         penalty = penalty - 1;
%       end
%     end
end
earlystoppedreturn = earlystopped;