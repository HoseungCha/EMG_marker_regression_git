function Feat = KSM1(S)
% Time-domain power spectral moments (TD-PSD)
% Using Fourier relations between time domain and frequency domain to
% extract power spectral moments dircetly from time domain.
%
% Modifications
% 17/11/2013  RK: Spectral moments first created.
% 
% References
% [1] A. Al-Timemy, R. N. Khushaba, G. Bugmann, and J. Escudero, "Improving the Performance Against Force Variation of EMG Controlled Multifunctional Upper-Limb Prostheses for Transradial Amputees", 
%     IEEE Transactions on Neural Systems and Rehabilitation Engineering, DOI: 10.1109/TNSRE.2015.2445634, 2015.
% [2] R. N. Khushaba, Maen Takruri, Jaime Valls Miro, and Sarath Kodagoda, "Towards limb position invariant myoelectric pattern recognition using time-dependent spectral features", 
%     Neural Networks, vol. 55, pp. 42-58, 2014. 


%% Get the size of the input signal
[samples,channels]=size(S);

% if channels>samples
%     S  = S';
%     [samples,channels]=size(S);
% end

%% RMS Value
r0 = rms(S);

%% Root squared zero order moment normalized
m0     = sqrt(sum(S.^2));
m0     = m0.^.1/.1;

% Prepare derivatives for higher order moments
d1     = diff([zeros(1,channels);diff(S)],1,1);
d2     = diff([zeros(1,channels);diff(d1)],1,1);

% Root squared 2nd and 4th order moments normalized
m2     = sqrt(sum(d1.^2)./(samples-1));
m2     = m2.^.1/.1;

m4     = sqrt(sum(d2.^2)./(samples-1));
m4     = m4.^.1/.1;

%% Sparseness
sparsi = (sqrt(abs((m0-m2).*(m0-m4))).\m0);

%% Irregularity Factor
IRF    = m2./sqrt(m0.*m4);

%% Waveform length ratio
WLR    = sum(abs(d1))./sum(abs(d2));

%% All features together
% Feat   = log(abs([(m0) (m0-m2) (m0-m4) sparsi IRF WLR]));
Feat = [log(abs(m0)) log(abs(m0-m2)) log(abs(m0-m4)) log(abs(sparsi)) log(abs(IRF)) log(abs(WLR)) ];