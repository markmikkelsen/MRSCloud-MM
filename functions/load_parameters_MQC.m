function MRS_opt = load_parameters_MQC(MRS_opt)

spinSys      = MRS_opt.metab;
vendor       = MRS_opt.vendor;
localization = MRS_opt.localization;

% Define spatial resolution of simulation grid
fovX  = 4.5;      % size of the full simulation Field of View in the x-direction [cm]
fovY  = 4.5;      % size of the full simulation Field of View in the y-direction [cm]
fovZ  = 4.5;      % size of the full simulation Field of View in the y-direction [cm]
thkX  = 3;        % slice thickness of x refocusing pulse [cm]
thkY  = 3;        % slice thickness of y refocusing pulse [cm]
thkZ  = 3;        % slice thickness of z excitation pulse [cm]
Npts  = 8192;     % 2048 / 8192;     % number of spectral points
sw    = 4000;     % spectral width [Hz]
lw    = 1;        % linewidth of the output spectrum [Hz]
gamma = 42577000; % gyromagnetic ratio (1H = 42.58 MHz/T)

if any(strcmp(vendor, {'Siemens', 'Universal_Siemens'}))
    Bfield = 2.89; % Siemens magnetic field strength [Tesla]
else
    Bfield = 3.0;  % Philips magnetic field strength [Tesla]
end

if strcmp(localization, 'STEAM_7T')
    if strcmp(vendor, 'Siemens')
        Bfield = 6.98; % [Tesla]
    else
        Bfield = 7.0;  % [Tesla]
    end
end

MRS_opt.fovX   = fovX;   % size of the full simulation Field of View in the x-direction [cm]
MRS_opt.fovY   = fovY;   % size of the full simulation Field of View in the y-direction [cm]
MRS_opt.fovZ   = fovZ;   % size of the full simulation Field of View in the y-direction [cm]
MRS_opt.thkX   = thkX;   % slice thickness of x refocusing pulse [cm]
MRS_opt.thkY   = thkY;   % slice thickness of y refocusing pulse [cm]
MRS_opt.thkZ   = thkZ;   % slice thickness of z excitation pulse [cm]
MRS_opt.Npts   = Npts;   % number of spectral points
MRS_opt.sw     = sw;     % spectral width [Hz]
MRS_opt.lw     = lw;     % linewidth of the output spectrum [Hz]
MRS_opt.gamma  = gamma;  % gyromagnetic ratio
MRS_opt.Bfield = Bfield; % magnetic field strength [Tesla]

% Define the pulse waveforms here
switch vendor{1}

    case 'Philips'

        if strcmp(MRS_opt.localization, 'PRESS')
            excWaveform   = 'Philips_spredrex.pta';
            refocWaveform = 'gtst1203_sp.pta'; % name of refocusing pulse waveform.
        else % sLASER GOIA pulse
            refocWaveform = 'GOIA';            % name of refocusing pulse waveform.
        end

        if ~any(strcmp(MRS_opt.seq, {'UnEdited', 'UnEdited_se_MRSI'}))
            if strcmp(MRS_opt.seq, 'HERCULES')
                editWaveform1     = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [4.58ppm]
                editWaveform2     = 'sg100_100_0_14ms_88hz.pta'; % name of 2nd single editing pulse waveform. [4.18ppm]
                editWaveform3     = 'dl_Philips_4_58_1_90.pta';  % name of 1st dual editing pulse waveform. [4.58ppm 1.90ppm]
                editWaveform4     = 'dl_Philips_4_18_1_90.pta';  % name of 2nd dual editing pulse waveform. [4.18ppm 1.90ppm]
            elseif strcmp(MRS_opt.seq, 'HERMES')
                editWaveform1     = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [4.56ppm]
                editWaveform2     = 'sg100_100_0_14ms_88hz.pta'; % name of 2nd single editing pulse waveform. [1.9ppm]
                editWaveform3     = 'dl_Philips_4_56_1_90.pta';  % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                editWaveform4     = 'sg100_100_0_14ms_88hz.pta'; % name of non-editing pulse waveform. [non-editing]
            elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                editWaveform1     = 'dl_Philips_4_56_1_90.pta';
                editWaveform2     = 'dl_Philips_3_67_1_90_20ms.pta';
                editWaveform3     = 'dl_Philips_3_67_4_56_20ms.pta';
                editWaveform4     = 'sg100_100_0_14ms_88hz.pta';
            else % MEGA-PRESS
                if strcmp(MRS_opt.seq, 'Edited_se_MRSI')
                    editWaveform1 = 'am_sg_150_100.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                    editWaveform2 = 'am_sg_150_100.pta'; % name of 1st single editing pulse waveform. [7.5ppm]
                else
                    editWaveform1 = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                    editWaveform2 = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [7.5ppm]
                end
            end
        end

    case 'Siemens'

        if strcmp(MRS_opt.localization, 'PRESS')
            refocWaveform = 'orig_refoc_mao_100_4.pta'; % name of refocusing pulse waveform.
        else % sLASER GOIA pulse
            refocWaveform = 'GOIA';                     % name of refocusing pulse waveform.
        end

        if ~strcmp(MRS_opt.seq, 'UnEdited')
            if strcmp(MRS_opt.seq, 'HERCULES')
                editWaveform1 = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [4.58ppm]
                editWaveform2 = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [4.18ppm]
                editWaveform3 = 'dl_Siemens_4_58_1_90.pta';      % name of 1st single editing pulse waveform. [4.58ppm 1.90ppm]
                editWaveform4 = 'dl_Siemens_4_18_1_90.pta';      % name of 1st single editing pulse waveform. [4.18ppm 1.90ppm]
            elseif strcmp(MRS_opt.seq, 'HERMES')
                editWaveform1 = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [4.56ppm]
                editWaveform2 = 'Siemens_filtered_editing.pta';  % name of 2nd single editing pulse waveform. [1.90ppm]
                editWaveform3 = 'dl_Siemens_4_56_1_90.pta';      % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                editWaveform4 = 'Siemens_filtered_editing.pta';  % name of non-editing pulse waveform. [non-editing]
            elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                editWaveform1 = 'dl_Siemens_4_56_1_90.pta';
                editWaveform2 = 'dl_Siemens_3_67_1_90_20ms.pta';
                editWaveform3 = 'dl_Siemens_3_67_4_56_20ms.pta';
                editWaveform4 = 'Siemens_filtered_editing.pta';
            else % MEGA PRESS
                editWaveform1 = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [1.9ppm]
                editWaveform2 = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [7.5ppm]
            end
        end

    case 'GE'

        if strcmp(MRS_opt.localization, 'PRESS')
            refocWaveform = 'GE_rfa_3.9ms.pta'; % name of refocusing pulse waveform.
        else % sLASER GOIA pulse
            % refocWaveform = 'GE_GOIA_WURST.mat';    % name of refocusing pulse waveform.
            % refocWaveform = 'WURST_GOIA';    % name of refocusing pulse waveform.
            % refocWaveform = 'HS16R45s.pta';    % name of refocusing pulse waveform.
            refocWaveform = 'HS16R45s.txt';    % name of refocusing pulse waveform.
            if strcmp(MRS_opt.seq, 'MQC')
                refocWaveform2 = 'S-BREBOP-7500.pta';
            end
        end

        if ~strcmp(MRS_opt.seq, 'UnEdited')
            if strcmp(MRS_opt.seq, 'HERCULES')
                editWaveform1 = 'sg100_100_0_14ms_88hz.pta'; %'sg100_100_0_14ms_88hz.pta';  % name of 1st single editing pulse waveform. [4.58ppm]
                editWaveform2 = 'sg100_100_0_14ms_88hz.pta'; %'sg100_100_0_14ms_88hz.pta';  % name of 2nd single editing pulse waveform. [4.18ppm]
                editWaveform3 = 'dl_Philips_4_58_1_90.pta';  % name of 1st dual editing pulse waveform. [4.58ppm 1.90ppm]
                editWaveform4 = 'dl_Philips_4_18_1_90.pta';  % name of 2nd dual editing pulse waveform. [4.18ppm 1.90ppm]
            elseif strcmp(MRS_opt.seq, 'HERMES')
            %     editWaveform1 = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [4.56ppm]
            %     editWaveform2 = 'sg100_100_0_14ms_88hz.pta'; % name of 2nd single editing pulse waveform. [1.9ppm]
            %     editWaveform3 = 'dl_Philips_4_56_1_90.pta';  % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
            %     editWaveform4 = 'sg100_100_0_14ms_88hz.pta'; % name of non-editing pulse waveform. [non-editing]
            % elseif strcmp(MRS_opt.seq, 'HERMES_UHP')
                editWaveform1 = 'SGeddit.txt'; % name of 1st single editing pulse waveform. [4.56ppm]
                editWaveform2 = 'SGeddit.txt'; % name of 2nd single editing pulse waveform. [1.9ppm]
                editWaveform3 = 'dl_Philips_4_56_1_90.pta';  % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                editWaveform4 = 'SGeddit.txt'; % name of non-editing pulse waveform. [non-editing]
            elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                editWaveform1 = 'dl_Philips_4_56_1_90.pta';
                editWaveform2 = 'dl_Philips_3_67_1_90_20ms.pta';
                editWaveform3 = 'dl_Philips_3_67_4_56_20ms.pta';
                editWaveform4 = 'sg100_100_0_14ms_88hz.pta';
            elseif strcmp(MRS_opt.seq, 'MQC')
                editWaveform1 = 'gauss10s.pta';
            else % MEGA-PRESS
                editWaveform1 = 'gauss1s.pta'; %'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                editWaveform2 = 'gauss1s.pta'; %'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [7.5ppm]
            end
        end

    case 'Universal_Philips'

        if strcmp(MRS_opt.localization, 'PRESS')
            refocWaveform = 'univ_eddenrefo.pta'; % name of refocusing pulse waveform.
        else % sLASER GOIA pulse
            refocWaveform = 'GOIA'; % name of refocusing pulse waveform.
        end

        if ~strcmp(MRS_opt.seq, 'UnEdited')
            if strcmp(MRS_opt.seq, 'HERCULES')
                editWaveform1 = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.58ppm]
                editWaveform2 = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.18ppm]
                editWaveform3 = 'dl_Philips_4_58_1_90.pta';  % name of 1st single editing pulse waveform. [4.58ppm 1.90ppm]
                editWaveform4 = 'dl_Philips_4_18_1_90.pta';  % name of 1st single editing pulse waveform. [4.18ppm 1.90ppm]
            elseif strcmp(MRS_opt.seq, 'HERMES')
                editWaveform1 = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [4.56ppm]
                editWaveform2 = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [1.90ppm]
                editWaveform3 = 'dl_Philips_univ_4_56_1_90.pta'; % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                editWaveform4 = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [non-editing]
            elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                editWaveform1 = 'dl_Philips_univ_4_56_1_9_20ms.pta';
                editWaveform2 = 'dl_Philips_univ_3_67_1_9_20ms.pta';
                editWaveform3 = 'dl_Philips_univ_3_67_4_56_20ms.pta';
                editWaveform4 = 'sl_univ_pulse.pta';
            else % MEGA PRESS
                editWaveform1 = 'sl_univ_pulse.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                editWaveform2 = 'sl_univ_pulse.pta'; % name of 1st single editing pulse waveform. [7.5ppm]
            end
        end

    case 'Universal_Siemens'

        if strcmp(MRS_opt.localization, 'PRESS')
            refocWaveform           = 'univ_eddenrefo.pta';        % name of refocusing pulse waveform.
        else % sLASER GOIA pulse
            refocWaveform           = 'GOIA';                      % name of refocusing pulse waveform.
        end

        if ~strcmp(MRS_opt.seq, 'UnEdited')
            if strcmp(MRS_opt.seq, 'HERCULES')
                editWaveform1       = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.58ppm]
                editWaveform2       = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.18ppm]
                editWaveform3       = 'dl_Siemens_4_58_1_90.pta';     % name of 1st single editing pulse waveform. [4.58ppm 1.90ppm]
                editWaveform4       = 'dl_Siemens_4_18_1_90.pta';  % name of 1st single editing pulse waveform. [4.18ppm 1.90ppm]
            elseif strcmp(MRS_opt.seq, 'HERMES')
                editWaveform1       = 'sl_univ_pulse.pta';                % name of 1st single editing pulse waveform. [4.56ppm]
                editWaveform2       = 'sl_univ_pulse.pta';               % name of 1st single editing pulse waveform. [1.90ppm]
                editWaveform3       = 'dl_Siemens_4_56_1_90.pta';       % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                editWaveform4       = 'sl_univ_pulse.pta';              % name of 1st single editing pulse waveform. [non-editing]
            elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                editWaveform1       = 'dl_Siemens_univ_4_56_1_9_20ms.pta';
                editWaveform2       = 'dl_Siemens_univ_3_67_1_9_20ms.pta';
                editWaveform3       = 'dl_Siemens_univ_3_67_4_56_20ms.pta';
                editWaveform4       = 'sl_univ_pulse.pta';
            else                                                       % MEGA PRESS
                editWaveform1       = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [1.9ppm]
                editWaveform2       = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [7.5ppm]
            end
        end

    case 'Universal_GE'

        if strcmp(MRS_opt.localization, 'PRESS')
            refocWaveform = 'univ_eddenrefo.pta'; % name of refocusing pulse waveform.
        else % sLASER GOIA pulse
            refocWaveform = 'GE_GOIA_WURST.mat'; % name of refocusing pulse waveform.
        end

        if ~strcmp(MRS_opt.seq, 'UnEdited')
            if strcmp(MRS_opt.seq, 'HERCULES')
                editWaveform1 = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.58ppm]
                editWaveform2 = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.18ppm]
                editWaveform3 = 'dl_Philips_4_58_1_90.pta';  % name of 1st single editing pulse waveform. [4.58ppm 1.90ppm]
                editWaveform4 = 'dl_Philips_4_18_1_90.pta';  % name of 1st single editing pulse waveform. [4.18ppm 1.90ppm]
            elseif strcmp(MRS_opt.seq, 'HERMES')
                editWaveform1 = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [4.56ppm]
                editWaveform2 = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [1.90ppm]
                editWaveform3 = 'dl_Philips_univ_4_56_1_90.pta'; % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                editWaveform4 = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [non-editing]
            elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                editWaveform1 = 'dl_Philips_4_56_1_90.pta';
                editWaveform2 = 'dl_Philips_3_67_1_90_20ms.pta';
                editWaveform3 = 'dl_Philips_3_67_4_56_20ms.pta';
                editWaveform4 = 'sg100_100_0_14ms_88hz.pta';
            else % MEGA PRESS
                editWaveform1 = 'sl_univ_pulse.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                editWaveform2 = 'sl_univ_pulse.pta'; % name of 2nd single editing pulse waveform. [7.5ppm]
            end
        end

end

% Define frequency parameters for editing targets
if strcmp(MRS_opt.seq, 'MQC')
    MRS_opt.editOnFreq1 = MRS_opt.editON{1}; % Center frequency of 1st editing experiment [ppm]
elseif ~any(strcmp(MRS_opt.seq, {'UnEdited', 'UnEdited_se_MRSI'}))
    MRS_opt.editOnFreq1     = MRS_opt.editON{1}; % Center frequency of 1st editing experiment [ppm]
    MRS_opt.editOnFreq2     = MRS_opt.editON{2}; % Center frequency of 2nd editing experiment [ppm]
    if ~any(strcmp(MRS_opt.seq, {'MEGA', 'Edited_se_MRSI', 'MQC'}))
        MRS_opt.editOnFreq3 = MRS_opt.editON{3}; % Center frequency of 3rd HERMES/HERCULES experiment [ppm]
        MRS_opt.editOnFreq4 = MRS_opt.editON{4}; % Center frequency of 4th HERMES/HERCULES experiment [ppm]
    end
end

if ~any(strcmp(MRS_opt.seq, {'UnEdited', 'UnEdited_se_MRSI'}))
    switch vendor{1}
        case 'Philips'
            TE1         = 7.0*2;            % TE1 [ms]
            MRS_opt.TE1 = TE1;              % TE1 [ms]
        case 'Siemens'
            TE1         = 7.75*2;           % TE1 [ms]
            MRS_opt.TE1 = TE1;              % TE1 [ms]
        case 'GE'
            TE1         = 7.35*2;           % TE1 [ms]
            MRS_opt.TE1 = TE1;              % TE1 [ms]
        case {'Universal_Philips', 'Universal_Siemens'}
            TE1         = 6.55*2;           % TE1 [ms]
            MRS_opt.TE1 = TE1;              % TE1 [ms]
        case 'Universal_GE'
            TE1         = 6.56*2;           % TE1 [ms]
            % TE1         = 5.72*2;           % TE1 [ms] % MM (240416)
            MRS_opt.TE1 = TE1;              % TE1 [ms]
    end
else
    if strcmp(MRS_opt.seq, 'UnEdited')
        switch vendor{1}
            case 'Philips'
                TE1                 = 8.15*2; %7.41*2;           % TE1 [ms]
                MRS_opt.TE1         = TE1;              % TE1 [ms]
                MRS_opt.TE2         = MRS_opt.TEs{1} - TE1; % scnh setup TE2
            case 'Siemens'
                TE1                 = 8.2*2;           % TE1 [ms]
                MRS_opt.TE1         = TE1;              % TE1 [ms]
                MRS_opt.TE2         = MRS_opt.TEs{1} - TE1; % scnh setup TE2
            case 'GE'
                TE1                 = 7.35*2;           % TE1 [ms]
                MRS_opt.TE1         = TE1;              % TE1 [ms]
                MRS_opt.TE2         = MRS_opt.TEs{1} - TE1; % scnh setup TE2
            case {'Universal_Philips', 'Universal_Siemens', 'Universal_GE'}
                TE1                 = 7.0*2;           % TE1 [ms]
                MRS_opt.TE1         = TE1;              % TE1 [ms]
                MRS_opt.TE2         = MRS_opt.TEs{1} - TE1; % scnh setup TE2
        end
    end
end

if strcmp(MRS_opt.seq, 'MQC')
    editTp1 = 7; % duration of 1st editing pulse [ms]
    MRS_opt.editTp1 = editTp1;
elseif ~any(strcmp(MRS_opt.seq, {'UnEdited', 'UnEdited_se_MRSI'}))
    if any(strcmp(MRS_opt.seq, {'MEGA', 'Edited_se_MRSI'}))
        editTp1 = MRS_opt.editTp; % duration of 1st editing pulse [ms]
        editTp2 = MRS_opt.editTp; % duration of 2nd editing pulse [ms]
    else
        editTp1 = 20; % duration of 1st editing pulse [ms]
        editTp2 = 20; % duration of 2nd editing pulse [ms]
        editTp3 = 20; % duration of 2nd editing pulse [ms]
        editTp4 = 20; % duration of 2nd editing pulse [ms]
    end
    MRS_opt.editTp  = editTp1;
    MRS_opt.editTp1 = editTp1; % duration of 1st editing pulse [ms]
    MRS_opt.editTp2 = editTp2; % duration of 2nd editing pulse [ms]
    if ~any(strcmp(MRS_opt.seq, {'MEGA', 'Edited_se_MRSI'}))
        MRS_opt.editTp3 = editTp3; % duration of 2nd editing pulse [ms]
        MRS_opt.editTp4 = editTp4; % duration of 2nd editing pulse [ms]
    end
end

if MRS_opt.nX > 1
    MRS_opt.x = linspace(-MRS_opt.fovX/2, MRS_opt.fovX/2, MRS_opt.nX); %X positions to simulate [cm]
else
    MRS_opt.x = 0;
end
if MRS_opt.nY > 1
    MRS_opt.y = linspace(-MRS_opt.fovY/2, MRS_opt.fovY/2, MRS_opt.nY); %X positions to simulate [cm]
else
    MRS_opt.y = 0;
end
if MRS_opt.nZ > 1
    MRS_opt.z = linspace(-MRS_opt.fovZ/2, MRS_opt.fovZ/2, MRS_opt.nZ); %Z positions to simulate [cm]
else
    MRS_opt.z = 0;
end

if any(strcmp(MRS_opt.seq, {'UnEdited_se_MRSI', 'Edited_se_MRSI'}))
    switch excWaveform
        case 'Philips_spredrex.pta'
            excRF     = io_loadRFwaveform(excWaveform,'exc',0);
            excTp     = 7.13; % Check duration
            excRF.tbw = 2.277 * excTp; %BW99 (kHz) * dur (ms)%1.354
            excRF     = rf_resample(excRF,100);
    end
end

switch refocWaveform
    case 'gtst1203_sp.pta'
        refRF     = io_loadRFwaveform(refocWaveform,'ref',0);
        refTp     = 6.89;
        refRF.tbw = 1.354 * refTp; %BW50 (kHz) * dur (ms)%1.354 %1.412
        refRF     = rf_resample(refRF,100);
    case 'orig_refoc_mao_100_4.pta'
        refRF     = io_loadRFwaveform(refocWaveform,'ref',0);
        refTp     = 4.4;
        %refRF.tbw = 1.31*refTp;  %BW50 (kHz) * dur (ms)
    case 'GE_rfa_3.9ms.pta'
        refRF     = io_loadRFwaveform(refocWaveform,'ref',0);
        refTp     = 5.2;
        %refRF.tbw = 1.11*refTp;  %BW50 (kHz) * dur (ms)
        refRF     = rf_resample(refRF,100);
    case 'univ_eddenrefo.pta'
        refRF     = io_loadRFwaveform(refocWaveform,'ref',0);
        refTp     = 7.0;
        %refRF.tbw = 1.342*refTp; %BW50 (kHz) * dur (ms)
    case 'GOIA'
        load('Philips_GOIA_WURST_100pts.mat','Sweep2');
        refRF      = Sweep2;
        refTp      = 4.5; % (ms)
        BW         = 8; % (kHz)
        refRF.tbw  = refTp * BW; % dur (ms) * BW50 (kHz)
        refRF.f0   = 0;
        %refRF.isGM = 1; %is the pulse gradient mdoulated? - 02262020 SH
        refRF.tthk = MRS_opt.thkX * (refTp/1e3); %This is the time x sliceThickness product for gradient modulated pulses.  It is in units [cm.s]
    case 'GE_GOIA_WURST.mat'
        load('GE_GOIA_WURST.mat','Sweep_GE_100');
        refRF      = Sweep_GE_100;
        refTp      = 4.5; % (ms)
        BW         = 10; % (kHz)
        refRF.tbw  = refTp * BW; % dur (ms) * BW50 (kHz)
        refRF.f0   = 0;
        % refRF.isGM = 1;
        refRF.tthk = MRS_opt.thkX * (refTp/1e3); %This is the time x sliceThickness product for gradient modulated pulses.  It is in units [cm.s]
    case 'WURST_GOIA'
        load('WURST_GOIA.mat','rf');
        refRF      = rf;
        refTp      = 4.5; % (ms)
        BW         = 10; % (kHz)
        refRF.tbw  = refTp * BW; % dur (ms) * BW50 (kHz)
        refRF.f0   = 0;
        % refRF.isGM = 1;
        refRF.tthk = MRS_opt.thkX * (refTp/1e3); %This is the time x sliceThickness product for gradient modulated pulses.  It is in units [cm.s]
    case 'HS16R45s.pta'
        refRF     = io_loadRFwaveform(refocWaveform,'ref',0);
        refTp     = 4.504;
        %refRF.tbw = 1.11*refTp;  %BW50 (kHz) * dur (ms)
        refRF     = rf_resample(refRF,100);
        refRF.tthk = MRS_opt.thkX * (refTp/1e3); %This is the time x sliceThickness product for gradient modulated pulses.  It is in units [cm.s]
    case 'HS16R45s.txt'
        refRF      = io_loadRFwaveform(refocWaveform,'ref');
        refTp      = 4.504;
        % refRF.tbw  = 1.11*refTp;  %BW50 (kHz) * dur (ms)
        refRF      = rf_resample(refRF,100);
        refRF.tthk = MRS_opt.thkX * (refTp/1e3); %This is the time x sliceThickness product for gradient modulated pulses.  It is in units [cm.s]
        if strcmp(MRS_opt.seq, 'MQC')
            refRF = rf_freqshift(refRF, refTp, 128);
        end
end

if strcmp(MRS_opt.seq, 'MQC')
    refRF2      = io_loadRFwaveform(refocWaveform2,'ref');
    refTp2      = 7.504;
    %refRF2.tbw  = 1.11*refTp2;  %BW50 (kHz) * dur (ms)
    refRF2      = rf_resample(refRF2,100);
    refRF2.tthk = MRS_opt.thkZ * (refTp2/1e3); %This is the time x sliceThickness product for gradient modulated pulses.  It is in units [cm.s]
    refRF2      = rf_freqshift(refRF2, refTp2, 128);
end

if any(strcmp(MRS_opt.seq, {'UnEdited_se_MRSI', 'Edited_se_MRSI'}))
    MRS_opt.excRF = excRF;
    MRS_opt.excTp = excTp;
end

MRS_opt.refRF = refRF;
MRS_opt.refTp = refTp;
if strcmp(MRS_opt.seq, 'MQC')
    MRS_opt.refRF2 = refRF2;
    MRS_opt.refTp2 = refTp2;
end

% Load RF waveforms for editing pulses, defined above
if strcmp(MRS_opt.seq, 'HERCULES')
    editRF1         = io_loadRFwaveform(editWaveform1,'inv',0);
    editRF2         = io_loadRFwaveform(editWaveform2,'inv',0);
    editRF3         = io_loadRFwaveform(editWaveform3,'inv',0);
    editRF4         = io_loadRFwaveform(editWaveform4,'inv',0);
    editRF3.tw1     = editRF2.tw1 * 2; %1.8107;
    editRF4.tw1     = editRF2.tw1 * 2; %1.8107;
    MRS_opt.editRF1 = editRF1;
    MRS_opt.editRF2 = editRF2;
    MRS_opt.editRF3 = editRF3;
    MRS_opt.editRF4 = editRF4;
elseif strcmp(MRS_opt.seq, 'HERMES')
    editRF1         = io_loadRFwaveform(editWaveform1,'inv',0);
    editRF2         = io_loadRFwaveform(editWaveform2,'inv',0);
    editRF3         = io_loadRFwaveform(editWaveform3,'inv',0);
    editRF3.tw1     = editRF2.tw1 * 2;
    editRF4         = io_loadRFwaveform(editWaveform4,'inv',0);
    MRS_opt.editRF1 = editRF1;
    MRS_opt.editRF2 = editRF2;
    MRS_opt.editRF3 = editRF3;
    MRS_opt.editRF4 = editRF4;
elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
    editRF1         = io_loadRFwaveform(editWaveform1,'inv',0);
    editRF2         = io_loadRFwaveform(editWaveform2,'inv',0);
    editRF3         = io_loadRFwaveform(editWaveform3,'inv',0);
    editRF4         = io_loadRFwaveform(editWaveform4,'inv',0);
    editRF1.tw1     = 1.8115; %editRF4.tw1*2;
    editRF2.tw1     = 1.8354;
    editRF3.tw1     = 1.9165;
    editRF4.tw1     = editRF4.tw1;
    MRS_opt.editRF1 = editRF1;
    MRS_opt.editRF2 = editRF2;
    MRS_opt.editRF3 = editRF3;
    MRS_opt.editRF4 = editRF4;
elseif any(strcmp(MRS_opt.seq, {'MEGA', 'Edited_se_MRSI'}))
    editRF1         = io_loadRFwaveform(editWaveform1,'inv',0);
    editRF2         = io_loadRFwaveform(editWaveform2,'inv',0);
    MRS_opt.editRF1 = editRF1;
    MRS_opt.editRF2 = editRF2;
elseif strcmp(MRS_opt.seq, 'MQC')
    editRF1         = io_loadRFwaveform(editWaveform1,90,0);
    MRS_opt.editRF1 = editRF1;
end

% % Construct the editing pulses from the waveforms and defined frequencies
% if strcmp(MRS_opt.seq, 'MQC')
%     MRS_opt.editRFonA     = rf_freqshift(editRF1, editTp1, (MRS_opt.centreFreq - MRS_opt.editOnFreq1) * Bfield * gamma/1e6);
% elseif ~any(strcmp(MRS_opt.seq, {'UnEdited', 'UnEdited_se_MRSI'}))
%     MRS_opt.editRFonA     = rf_freqshift(editRF1, editTp1, (MRS_opt.centreFreq - MRS_opt.editOnFreq1) * Bfield * gamma/1e6); %1.90 = GABA ON
%     MRS_opt.editRFonB     = rf_freqshift(editRF2, editTp2, (MRS_opt.centreFreq - MRS_opt.editOnFreq2) * Bfield * gamma/1e6); %7.5 = GABA OFF or MM supp
%     if ~any(strcmp(MRS_opt.seq, {'MEGA', 'Edited_se_MRSI'}))
%         MRS_opt.editRFonC = rf_freqshift(editRF3, editTp3, (MRS_opt.centreFreq - MRS_opt.editOnFreq3) * Bfield * gamma/1e6); %7.5 = GABA OFF or MM supp
%         MRS_opt.editRFonD = rf_freqshift(editRF4, editTp4, (MRS_opt.centreFreq - MRS_opt.editOnFreq4) * Bfield * gamma/1e6); %7.5 = GABA OFF or MM supp
%     end
%     % HERCULES has the same editing pulse duration and timing for all sub-experiments. Valid for Mega-press as well:
%     MRS_opt.editTp = editTp1;
% end

% Load the spin system definitions and pick the spin system of choice
load('spinSystems.mat', ['sys' spinSys]);
sys = eval(['sys' spinSys]);

% Set up gradients
if strcmp(MRS_opt.seq, 'UnEdited_se_MRSI')
    MRS_opt.Gx     = (refRF.tbw / (refTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm] %this is for refoc
    MRS_opt.Gx_exc = (excRF.tbw / (excTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm] %this is for excitation
elseif strcmp(MRS_opt.seq, 'Edited_se_MRSI')
    MRS_opt.Gx     = (refRF.tbw / (refTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm] %this is for refoc
    MRS_opt.Gx_exc = -(excRF.tbw / (excTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm] %this is for excitation
else % MM (250905)
    MRS_opt.Gx     = (refRF.tbw / (refTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm]
    MRS_opt.Gy     = (refRF.tbw / (refTp/1e3)) / (gamma * MRS_opt.thkY / 1e4); %[G/cm]
    MRS_opt.Gz     = (refRF2.tbw / (refTp2/1e3)) / (gamma * MRS_opt.thkZ / 1e4); %[G/cm]
end

for k = 1:length(sys)
    sys(k).shifts = sys(k).shifts - MRS_opt.centreFreq;
end
MRS_opt.sys = sys;

%Calculate new delays by subtracting the pulse durations from the taus
%vector;
if ~strcmp(MRS_opt.seq, 'UnEdited_se_MRSI')
    taus           = TE1/2;               %middle 2nd EDITING to the start of readout
    % taus           = tausA;
    delays         = zeros(size(taus));
    % delays(1)      = taus(1)-(refTp/2);
    % delays(2)      = 0; %taus(2)-((refTp+editTp)/2);
    % delays(3)      = 0; %taus(3)-((editTp+refTp)/2);
    % delays(4)      = 0; %taus(4)-((refTp+editTp)/2);
    % delays(5)      = 0; %taus(5)-(editTp/2);

    MRS_opt.taus   = taus;
    MRS_opt.delays = delays;
end

%Calculate Hamiltonian matrices and starting density matrix.
[H,d] = sim_Hamiltonian_mgs(sys, Bfield);
MRS_opt.H = H;
MRS_opt.d = d;

%Creating propagators for editing pulse
% if ~strcmp(MRS_opt.seq, 'UnEdited')
%     [MRS_opt.QoutONA]  = calc_shapedRF_propagator_edit(MRS_opt.H,MRS_opt.editRFonA,MRS_opt.editTp,MRS_opt.edit_flipAngle,0);
%     [MRS_opt.QoutONB]  = calc_shapedRF_propagator_edit(MRS_opt.H,MRS_opt.editRFonB,MRS_opt.editTp,MRS_opt.edit_flipAngle,0);
%     if ~strcmp(MRS_opt.seq, 'MEGA')
%         [MRS_opt.QoutONC]  = calc_shapedRF_propagator_edit(MRS_opt.H,MRS_opt.editRFonC,MRS_opt.editTp,MRS_opt.edit_flipAngle,0);
%         [MRS_opt.QoutOND]  = calc_shapedRF_propagator_edit(MRS_opt.H,MRS_opt.editRFonD,MRS_opt.editTp,MRS_opt.edit_flipAngle,0);
%     end
% end

%Creating propagators for Refoc pulse ONLY in the X direction With an assumption x=y, i.e., the voxel is isotropic
%(H,RF,Tp,flipAngle,phase,dfdx,grad)

% Load excitation pulse
if any(strcmp(MRS_opt.seq, {'UnEdited_se_MRSI', 'Edited_se_MRSI'}))
    excWaveform   = 'univ_spreddenrex.pta';
    % excWaveform   = 'Philips_spredrex.pta';
    RF_struct     = io_loadRFwaveform(excWaveform,'exc',0);
    MRS_opt.excRF = RF_struct;
    parfor (X = 1:length(MRS_opt.x), MRS_opt.parallelize.workers)
        Q_exc{X} = calc_shapedRF_propagator_exc(MRS_opt.H, MRS_opt.excRF, MRS_opt.excTp, MRS_opt.excflipAngle, 0, MRS_opt.y(X), MRS_opt.Gx_exc);
    end
    MRS_opt.Qexc = Q_exc;
end

% Load refocusing pulse(s)
if any(strcmp(MRS_opt.seq, {'UnEdited', 'MEGA', 'HERMES', 'HERCULES', 'HERMES_GABA_GSH_EtOH'}))
    parfor (X = 1:length(MRS_opt.x), MRS_opt.parallelize.workers)
        Q_refoc{X} = calc_shapedRF_propagator_refoc(MRS_opt.H, MRS_opt.refRF, MRS_opt.refTp, MRS_opt.flipAngle, 0, MRS_opt.y(X), MRS_opt.Gx); %#ok<*PFBNS>
    end
    MRS_opt.Q_refoc = Q_refoc;
elseif strcmp(MRS_opt.seq, 'MQC')
    parfor (X = 1:length(MRS_opt.x), MRS_opt.parallelize.workers)
        Q_refoc{X}  = calc_shapedRF_propagator_refoc(MRS_opt.H, MRS_opt.refRF, MRS_opt.refTp, MRS_opt.flipAngle, 90, MRS_opt.x(X), MRS_opt.Gx);
        Q_refoc2{X} = calc_shapedRF_propagator_refoc(MRS_opt.H, MRS_opt.refRF2, MRS_opt.refTp2, MRS_opt.flipAngle, 0, MRS_opt.z(X), MRS_opt.Gz);
    end
    MRS_opt.Q_refoc  = Q_refoc;
    MRS_opt.Q_refoc2 = Q_refoc2;
end
