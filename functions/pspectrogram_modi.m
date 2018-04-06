function [S,f,t,P,fcorr,tcorr] = pspectrogram_modi(x,spectype,varargin)
%PSPECTROGRAM Spectrogram and cross spectrogram
%   S = PSPECTROGRAM(X,'spect',WINDOW,NOVERLAP,NFFT,Fs,...)
%   S = PSPECTROGRAM({X,Y},'xspect',WINDOW,NOVERLAP,NFFT,Fs,...)
%   [S,F,T,P,fcorr,tcorr] = PSPECTROGRAM(...)
%
%   Inputs:
%      see "help spectrogram" for complete description of all input
%      arguments. SPECTTYPE is a string specifying the type of estimate to
%      return, the choices are: 'spect' and 'xspect'.
%
%   Outputs:
%      see "help spectrogram" and "help xspectrogram" for complete 
%      description of all output arguments.
%      The output definition depends on the input string ESTTYPE:
%      S - complex STFT ('spect') or power cross spectrogram ('xspect')
%      F - frequencies for S
%      T - times for S
%      P - power spectrogram ('spect') or complex cpsd ('xspect')
%      fcorr - matrix of corrected (reassigned) frequencies 
%      tcorr - matrix of corrected (reassigned) times

%   Copyright 2016 The MathWorks, Inc.

% Parse arguments specific to PSPECTROGRAM and remove from argument list.
[reassign,varargin] = getReassignmentOption(varargin{:});
[faxisloc, varargin] = getFreqAxisOption(varargin{:});
[threshold,varargin] = getMinThreshold(varargin{:});

% Look for psd and power flags
[esttype, varargin] = psdesttype({'psd','power'},'psd',varargin); 

% Parse input arguments (using the PWELCH parser since it shares the same API).
[x,nx,~,y,ny,win,~,~,noverlap,~,~,options] = welchparse(x,esttype,varargin{:});

% Check for valid input signals
chkinput(x,'X');

% cast to enforce precision rules
noverlap = signal.internal.sigcasttofloat(noverlap,'double',...
  'spectrogram','NOVERLAP','allownumeric');

% Process frequency-specific arguments
[Fs,nfft,isnormfreq,options] = processFrequencyOptions(options,reassign);

% Make x and win into columns
x = x(:);
y = y(:);
win = win(:);
nwin = length(win);
fcorr = [];
tcorr = [];
  
% Place x into columns and return the corresponding central time estimates.
[xin,t] = getSTFTColumns(x,nx,nwin,noverlap,Fs);

if strcmpi(spectype,'spect') % Spectrogram
  % There is no second input signal, so no need to compute STFT columns.
  yin = [];
  
  % Compute the raw STFT
  % Apply the window to the array of offset signal segments.
  [y,f] = computeDFT(bsxfun(@times,win,xin),nfft,Fs);

  % Compute reassignment matrices.
  [fcorr,tcorr] = computeReassign(xin,win,Fs,nfft,y,f,t,reassign,nargout);

  % Truncate output and adjust any time-frequency corrections based on
  % FREQRANGE spectrum format ('centered', 'onesided', 'twosided')
  [S,f,fcorr,tcorr] = formatSpectrogram(y,f,fcorr,tcorr,Fs,nfft,options);

  % Compute PSD when required.
  if nargout==0 || nargout>3
    [P,f] = compute_PSD(win,S,nfft,f,t,options,Fs,esttype,threshold,reassign,fcorr,tcorr);
  else
    P = [];
  end

  % Shift the outputs when 'centered' is specified.
  if options.centerdc && length(options.nfft)==1
    [S,f,P,fcorr,tcorr] = centerOutputs(nargout,S,f,P,fcorr,tcorr);
  end
  
  if nargout==0
    % plot when no output arguments are specified
    displayspectrogram(t,f,P,isnormfreq,faxisloc,esttype,threshold);
  end

else % Cross Spectrogram
  % Validate second input argument
  chkinput(y,'Y');
    
  % Place y into columns.
  yin = getSTFTColumns(y,ny,nwin,noverlap,Fs);
  
  if options.centerdc
    freqrange = 'centered';
  else
    freqrange = options.range;
  end
  
  % Compute cross STFT using CPSD.
  [S,f] = cpsd(xin,yin,win,0,nfft,Fs,freqrange);
  
  % Scale the cross spectrogram to power using the effective noise
  % bandwidth of the window, if requested.
  if strcmp(esttype,'power')
    S = S*enbw(win,Fs); 
  end
  
  % Compute time-varying cross spectrum when requested.
  if nargout>3
    P = S;
  else
    P = [];
  end
  
  % Return the cross spectrogram (magnitude) as the first argument.
  S = abs(S);
  
  % Apply threshold
  if threshold>0
    S(S<threshold) = 0;
  end

  if nargout==0
    % plot when no output arguments are specified
    displayspectrogram(t,f,S,isnormfreq,faxisloc,esttype,threshold);
  end

end

% cast to enforce precision rules
if (isa(xin,'single') || isa(yin,'single') || isa(win,'single')) 
  [S,f,t,P,fcorr,tcorr] = castToSingle(nargout,S,f,t,P,fcorr,tcorr);
end


%--------------------------------------------------------------------------
function chkinput(x,X)
% Check for valid input signal

if isempty(x) || issparse(x) || ~isfloat(x)
  error(message('signal:spectrogram:MustBeFloat', X));
end

if min(size(x))~=1
  error(message('signal:spectrogram:MustBeVector', X));
end

%--------------------------------------------------------------------------
function displayspectrogram(t,f,Pxx,isFsnormalized,faxisloc,esttype, threshold)
% Cell array of the standard frequency units strings

if isFsnormalized
  f = f/pi; % Normalize the freq axis
  t = 2*pi*t; % Convert time axis to samples
  frequnitstrs = getfrequnitstrs;
  freqlbl = frequnitstrs{1};
  timelbl = getString(message('signal:spectrogram:Samples'));
else
  % Use engineering units
  [f,~,uf] = engunits(f,'unicode');
  freqlbl = getfreqlbl([uf 'Hz']);
  [t,~,ut] = engunits(t,'unicode','time');
  timelbl = [getString(message('signal:spectrogram:Time')) ' (' ut ')'];
end

h = newplot;
if strcmpi(faxisloc,'yaxis')
  xlbl = timelbl;
  ylbl = freqlbl;
else
  xlbl = freqlbl;
  ylbl = timelbl;
end

hRotate = uigettool(ancestor(h,'Figure'),'Exploration.Rotate');
if isempty(hRotate) || strcmp(hRotate.State,'off')
  if strcmp(faxisloc,'yaxis')
    hndl = imagesc(t, f, 10*log10(abs(Pxx)+eps));
  else
    hndl = imagesc(f, t, 10*log10(abs(Pxx)'+eps));
  end
  hndl.Parent.YDir = 'normal';

  setupListeners(hndl);
else
  if strcmp(faxisloc,'yaxis')
    hndl = surf(t, f, 10*log10(abs(Pxx)+eps),'EdgeColor','none');
  else
    hndl = surf(f, t, 10*log10(abs(Pxx)'+eps),'EdgeColor','none');
  end
  axis xy
  axis tight
  view(0,90);
end  

if threshold>0
  Pmax = max(Pxx(:));
  if threshold < Pmax
    set(ancestor(hndl,'axes'),'CLim',10*log10([threshold Pmax]))
  end
end

if strcmpi(esttype,'power')
  cblabel = getString(message('signal:dspdata:dspdata:PowerdB'));
else
  if isFsnormalized
    cblabel = getString(message('signal:dspdata:dspdata:PowerfrequencydBradsample'));
  else
    cblabel = getString(message('signal:dspdata:dspdata:PowerfrequencydBHz'));
  end
end
%sigutils.internal.colorbari('titlelong',cblabel);
h = colorbar;
h.Label.String = cblabel;

ylabel(ylbl);
xlabel(xlbl);

% -------------------------------------------------------------------------
function [Pxx,f,fcorr,tcorr] = compute_PSD(win,y,nfft,f,t,options,Fs,esttype,threshold,reassign,fcorr,tcorr)

% Evaluate the window normalization constant.
if strcmpi(esttype,'power')
  if reassign
    % compensate for the power of the window including a
    % 1/N scaling factor omitted by FFT/DFT computation.
    if isscalar(nfft)
      U = nfft*(win'*win);
    else
      U = numel(win)*(win'*win);
    end
  else
    % The window is convolved with every power spectrum peak, therefore
    % compensate for the DC value squared to obtain correct peak heights.
    % The 1/N factor has been omitted since it will cancel below.
    U = sum(win)^2;
  end
else
  % compensates for the power of the window.
  % The 1/N factor has been omitted since it will cancel below.
  U = win'*win;
end

Sxx = y.*conj(y)/U; % Auto spectrum.

% reassign in-place when requested.
if reassign
  Sxx = reassignSpectrum(Sxx, f, t, fcorr, tcorr, options);
end

% Compute the one-sided or two-sided PSD [Power/freq]. Also compute
% the corresponding half or whole power spectrum [Power].
[Pxx,f] = computepsd(Sxx, f, options.range, nfft, Fs, esttype);

% remove low-power estimates if requested
if threshold>0
  Pxx(Pxx<threshold) = 0;
end

% -------------------------------------------------------------------------
function [y,f,Pxx,fcorr,tcorr] = centerOutputs(nOut,y,f,Pxx,fcorr,tcorr)
% center y,fcorr,tcorr only if specified in the output list
% center f,Pxx if specified in the output list or when plotting
% nOut contains the number of output arguments of SPECTROGRAM
if nOut>0
  y = centerest(y);
end

if nOut==0 || nOut>1
  f = centerfreq(f);
end

if nOut==0 || nOut>3
  Pxx = centerest(Pxx);
end

if nOut>4
  fcorr = centerest(fcorr);
end

if nOut>5
  tcorr = centerest(tcorr);
end

% -------------------------------------------------------------------------
function [y,f,t,Pxx,fcorr,tcorr] = castToSingle(nOut,y,f,t,Pxx,fcorr,tcorr)
% convert outputs to single precision when specified in output list
% nOut contains the number of output arguments of SPECTROGRAM

if nOut>0
  y = single(y);
end

if nOut>1
  f = single(f);
end

if nOut>2
  t = single(t);
end

if nOut>3
  Pxx = single(Pxx);
end

if nOut>4
  fcorr = single(fcorr);
end

if nOut>5
  tcorr = single(tcorr);
end

% -------------------------------------------------------------------------
function [threshold,varargin] = getMinThreshold(varargin)
threshold = 0;

i = 1;
while i<numel(varargin)
  if ischar(varargin{i}) && strncmpi(varargin{i},'MinThreshold',2)...
      && isnumeric(varargin{i+1}) && isscalar(varargin{i+1})
    threshold = 10^(varargin{i+1}/10);
    varargin([i i+1]) = [];
  else
    i = i+1;
  end
end

% -------------------------------------------------------------------------
function [faxisloc,varargin] = getFreqAxisOption(varargin)
faxisloc = 'xaxis';
i = 1;
while i <= numel(varargin)
  if ischar(varargin{i}) && strncmpi(varargin{i},'xaxis',2)
    faxisloc = 'xaxis';
    varargin(i)=[];
  elseif ischar(varargin{i}) && strncmpi(varargin{i},'yaxis',2)
    faxisloc = 'yaxis';
    varargin(i)=[];
  else
    i = i+1;
  end
end

% -------------------------------------------------------------------------
function [reassign,varargin] = getReassignmentOption(varargin)
reassign = false;

i = 1;
while i <= numel(varargin)
  if ischar(varargin{i}) && strncmpi(varargin{i},'reassigned',2)
    reassign = true;
    varargin(i)=[];
  else
    i = i+1;
  end
end

%--------------------------------------------------------------------------
function [Fs,nfft,isnormfreq,options] = processFrequencyOptions(options,reassign)
% Determine whether an empty was specified for Fs (i.e., Fs=1Hz) or
% returned by welchparse which means normalized Fs is used.

% Cast to enforce Precision rules
Fs = double(options.Fs);
nfft = double(options.nfft);

% when Fs is specified as [], welchparse() returns 1 Hz.
% welchparse() returns [] only when Fs is omitted
isnormfreq = isempty(Fs);
if isnormfreq
  Fs = 2*pi;
end

if length(nfft) > 1
  % Frequency vector was specified, return and plot two-sided PSD
  if strcmpi(options.range,'onesided')
    warning(message('signal:welch:InconsistentRangeOption'));
  end
  options.range = 'twosided';
end

% prevent unneeded temporary conversion to one-sided spectrum
if options.centerdc
  options.range = 'twosided';
end

% ensure frequency vector is linearly spaced when performing reassignment
if reassign && ~isscalar(options.nfft)
  f = options.nfft(:);
  
  % see if we can get a uniform spacing of the freq vector
  [~, ~, ~, maxerr] = getUniformApprox(f);
  
  % see if the ratio of the maximum absolute deviation relative to the
  % largest absolute in the frequency vector is less than a few eps
  isuniform = maxerr < 3*eps(class(f));
  
  if ~isuniform
    error(message('signal:spectrogram:ReassignFreqMustBeUniform'));
  end
end

% -------------------------------------------------------------------------
function [y,f,fcorr,tcorr]  = formatSpectrogram(y,f,fcorr,tcorr,Fs,nfft,options)
% truncate output and adjust any time-frequency corrections based on
% FREQRANGE spectrum format ('centered', 'onesided', 'twosided')

% if nfft is a scalar, it is the length of the fft, otherwise it contains
% the output frequency vector
freqvecspecified = length(nfft)>1;

% truncate output when using one-sided spectrum
if ~freqvecspecified && strcmpi(options.range,'onesided')
  f = psdfreqvec('npts',nfft,'Fs',Fs,'Range','half');
  y = y(1:length(f),:);
  if ~isempty(fcorr)
    fcorr = fcorr(1:length(f),:);
  end
  if ~isempty(tcorr)
    tcorr = tcorr(1:length(f),:);
  end
end

if ~isempty(fcorr)
  if options.centerdc || freqvecspecified && any(nfft < 0)
    % map to [-Fs/2,Fs/2) when using negative frequencies
    fcorr = mod(fcorr+Fs/2,Fs)-Fs/2;
  else
    % map to [0,Fs) when using positive frequencies
    fcorr = mod(fcorr,Fs);
  end
end

%--------------------------------------------------------------------------
function [fcorr,tcorr] = computeReassign(xin,win,Fs,nfft,y,f,t,reassign,narg)
% Compute the reassignment time and frequency matrices fcorr and tcorr
  if reassign || narg>4
    % Apply frequency correction from time derivative window
    yc = computeDFT(bsxfun(@times,dtwin(win,Fs),xin),nfft,Fs);
    fcorr = -imag(yc ./ y);
    fcorr(~isfinite(fcorr)) = 0;
    fcorr = bsxfun(@plus,f,fcorr);
  else
    fcorr = [];
  end

  if reassign || narg>5
    % Apply time correction from frequency derivative window
    yc = computeDFT(bsxfun(@times,dfwin(win,Fs),xin),nfft,Fs);
    tcorr = real(yc ./ y);
    tcorr(~isfinite(tcorr)) = 0;
    tcorr = bsxfun(@plus,t,tcorr);
  else
    tcorr = [];
  end

% -------------------------------------------------------------------------
function setupListeners(hndl)
hAxes = ancestor(hndl,'Axes');
hRotate = uigettool(ancestor(hndl,'Figure'),'Exploration.Rotate');
eYScale = addlistener(hAxes,'YScale','PreSet',@(src,evt) image2surf(hndl));
eView = addlistener(hAxes,'View','PostSet',@(src,evt) image2surf(hndl));
if ~isempty(hRotate)
    eRotate = addlistener(hRotate,'State','PostSet',@(src,evt) image2surf(hndl));
else
    eRotate = [];
end

if ~isprop(hndl,'TransientUserDataListener')
    pi = addprop(hndl,'TransientUserDataListener');
    pi.Transient = true;
end

set(hndl,'TransientUserDataListener',{eYScale,eView,eRotate});

% -------------------------------------------------------------------------
function image2surf(h)
if ishghandle(h)
  ud = h.UserData;
  if ~isempty(ud)
    delete(ud{1});
    delete(ud{2});
    delete(ud{3});
  end
  
  C = h.CData;
  if size(C,1)<2 || size(C,2)<2
    % don't draw a surface for 1-cell high/wide images
    return
  end
  
  X = h.XData;
  Y = h.YData;
  hAxes = h.Parent;
  v = hAxes.View;
  CLim = hAxes.CLim;
  xLabel = hAxes.XLabel.String;
  yLabel = hAxes.YLabel.String;

  hcb = findobj(ancestor(hAxes,'figure'),'type','colorbar');
  for i=1:numel(hcb)
    if isequal(handle(hAxes),handle(hcb(i).Axes))
      cblabel = hcb(i).Label.String;
    end
  end
      
  delete(h);
  
  surf(hAxes,X,Y,C,'EdgeColor','none','LineStyle','none','LineWidth',5);
  set(hAxes, ...
    'XLim', X([1 end]), ...
    'YLim', Y([1 end]), ...
    'ZLim', [min(C(:)) max(C(:))], ...
    'CLim', CLim, ...
    'View', v);
  xlabel(hAxes,xLabel);
  ylabel(hAxes,yLabel);
  
  hcb = colorbar('peer',hAxes);
  hcb.Label.String = cblabel;  
end