close all;

fspan   = 5;    % [kHz]
f0      = 0;
thkX    = 3;
sweep_width     = 8000; %9998;                     % Hz
sweep_duration  = 0.0045;                   % Second
gamma           = 42.577000;                % MHz/T
B1              = 15.0;                     % uT
sweep_amplitude = B1*gamma;                 %Hz

%%

% read .txt into matlab to obtain the rf
filename = 'GE_GOIA_WURST.txt'
colOrder = [1,2,3,4];
[rf,info]=io_readRFtxt(filename,colOrder)

% save rf to .mat and other parameters
Sweep_GE.waveform = rf;
Sweep_GE.type = 'ref';
Sweep_GE.tw1 = B1*gamma*sweep_duration;
Sweep_GE.tbw = sweep_duration*sweep_width;
Sweep_GE.isGM = 1;
Sweep_GE.tthk = thkX*sweep_duration; %This is the time x sliceThickness product for gradient modulated pulses.  It is in units [cm.s]

% resample waveform to 100 pts
Sweep_GE_100=rf_resample(Sweep_GE,100);

% bloch simulation
[mv,sc]=rf_blochSim(Sweep_GE_100,sweep_duration*1000,fspan,f0,sweep_amplitude/1000),title('15.0 uT,8 kHz,4.5 ms');
[mv,sc]=rf_blochSim(Sweep2,sweep_duration*1000,fspan,f0,sweep_amplitude/1000),title('15.0 uT,8 kHz,4.5 ms');
