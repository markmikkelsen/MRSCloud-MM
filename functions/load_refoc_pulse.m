function MRS_opt = load_refoc_pulse(MRS_opt, refocWaveform)

switch refocWaveform
    case 'gtst1203_sp.pta'
        refRF = io_loadRFwaveform(refocWaveform,'ref',0);
    case 'orig_refoc_mao_100_4.pta'
        refRF = io_loadRFwaveform(refocWaveform,'ref',0);
    case 'GE_rfa_3.9ms.pta'
        refRF = io_loadRFwaveform(refocWaveform,'ref',0);
    case 'univ_eddenrefo.pta'
        refRF = io_loadRFwaveform(refocWaveform,'ref',0);
    case 'Philips_GOIA_WURST_GOIA.mat'
        load('Philips_GOIA_WURST_100pts.mat', 'Sweep2');
        refRF = Sweep2;
    case 'GE_GOIA_WURST.mat'
        load('GE_GOIA_WURST.mat', 'Sweep_GE_100');
        refRF = Sweep_GE_100;
    case 'WURST_GOIA.mat'
        load('WURST_GOIA.mat','rf');
        refRF = rf;
    case 'HS16R45s.pta'
        refRF = io_loadRFwaveform(refocWaveform,'ref',0);
    otherwise
        error('"%s" is not a valid refocusing pulse name.', refocWaveform);
end

if all(isfield(MRS_opt, {'refTp', 'refBW'}))
    refTp = MRS_opt.refTp; % (ms)
    bw    = MRS_opt.refBW; % (kHz)    
else
    switch refocWaveform
        case 'gtst1203_sp.pta'
            refTp     = 6.89;
            bw        = 1.354;
        case 'orig_refoc_mao_100_4.pta'
            refTp     = 4.4;
            bw        = 1.31;
        case 'GE_rfa_3.9ms.pta'
            refTp     = 5.2;
            bw        = 1.11;
        case 'univ_eddenrefo.pta'
            refTp     = 7.0;
            bw        = 1.342;
        case 'Philips_GOIA_WURST_GOIA.mat'
            refTp      = 4.5;
            bw         = 8;
        case 'GE_GOIA_WURST.mat'
            refTp      = MRS_opt.refTp;
            bw         = MRS_opt.refBW;
        case 'WURST_GOIA.mat'
            refRF      = rf;
            refTp      = 4.5;
            bw         = 10;
        case 'HS16R45s.pta'
            refTp     = 4.504;
            bw        = 1.11;
    end
end

refRF.tbw  = refTp * bw;
if any(strcmp(refocWaveform, {'Philips_GOIA_WURST_GOIA.mat', 'GE_GOIA_WURST.mat', ...
        'WURST_GOIA.mat', 'HS16R45s.pta'}))
    refRF.f0   = 0;
    % refRF.isGM = 1;
    % Set the time x slice thickness product for gradient modulated pulses.
    % It is in units [cm * s]
    refRF.tthk = MRS_opt.thkX * (refTp/1e3); 
end
refRF = rf_resample(refRF, 100); % downsample RF pulse

MRS_opt.refRF = refRF;
MRS_opt.refTp = refTp;
