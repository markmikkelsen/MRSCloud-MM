function MRS_opt = load_parameters(MRS_opt)

spinSys      = MRS_opt.metab;
vendor       = MRS_opt.vendor;
% localization = MRS_opt.localization;

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
B0    = MRS_opt.B0;

% if any(strcmp(vendor, {'Siemens', 'Universal_Siemens'}))
%     Bfield = 2.89; % Siemens magnetic field strength [Tesla]
% else
%     Bfield = 3.0;  % Philips magnetic field strength [Tesla]
% end
% 
% if strcmp(localization, 'STEAM_7T')
%     if strcmp(vendor, 'Siemens')
%         B0 = 6.98; % [Tesla]
%     else
%         B0 = 7.0;  % [Tesla]
%     end
% end

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
MRS_opt.Bfield = B0;     % magnetic field strength [T]

% Define the pulse waveforms here
if any(isfield(MRS_opt, {'excName','refName','editName'}))

    if isfield(MRS_opt, 'excName')
        excWaveform   = MRS_opt.excName;
    end
    if isfield(MRS_opt, 'refName')
        refocWaveform = MRS_opt.refName;
    end
    if isfield(MRS_opt, 'editName')
        editWaveform  = MRS_opt.editName;
    end

else

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
                    editWaveform{1}     = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [4.58ppm]
                    editWaveform{2}     = 'sg100_100_0_14ms_88hz.pta'; % name of 2nd single editing pulse waveform. [4.18ppm]
                    editWaveform{3}     = 'dl_Philips_4_58_1_90.pta';  % name of 1st dual editing pulse waveform. [4.58ppm 1.90ppm]
                    editWaveform{4}     = 'dl_Philips_4_18_1_90.pta';  % name of 2nd dual editing pulse waveform. [4.18ppm 1.90ppm]
                elseif strcmp(MRS_opt.seq, 'HERMES')
                    editWaveform{1}     = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [4.56ppm]
                    editWaveform{2}     = 'sg100_100_0_14ms_88hz.pta'; % name of 2nd single editing pulse waveform. [1.9ppm]
                    editWaveform{3}     = 'dl_Philips_4_56_1_90.pta';  % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                    editWaveform{4}     = 'sg100_100_0_14ms_88hz.pta'; % name of non-editing pulse waveform. [non-editing]
                elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                    editWaveform{1}     = 'dl_Philips_4_56_1_90.pta';
                    editWaveform{2}     = 'dl_Philips_3_67_1_90_20ms.pta';
                    editWaveform{3}     = 'dl_Philips_3_67_4_56_20ms.pta';
                    editWaveform{4}     = 'sg100_100_0_14ms_88hz.pta';
                else % MEGA-PRESS
                    if strcmp(MRS_opt.seq, 'Edited_se_MRSI')
                        editWaveform{1} = 'am_sg_150_100.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                        editWaveform{2} = 'am_sg_150_100.pta'; % name of 1st single editing pulse waveform. [7.5ppm]
                    else
                        editWaveform{1} = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                        editWaveform{2} = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [7.5ppm]
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
                    editWaveform{1} = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [4.58ppm]
                    editWaveform{2} = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [4.18ppm]
                    editWaveform{3} = 'dl_Siemens_4_58_1_90.pta';      % name of 1st single editing pulse waveform. [4.58ppm 1.90ppm]
                    editWaveform{4} = 'dl_Siemens_4_18_1_90.pta';      % name of 1st single editing pulse waveform. [4.18ppm 1.90ppm]
                elseif strcmp(MRS_opt.seq, 'HERMES')
                    editWaveform{1} = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [4.56ppm]
                    editWaveform{2} = 'Siemens_filtered_editing.pta';  % name of 2nd single editing pulse waveform. [1.90ppm]
                    editWaveform{3} = 'dl_Siemens_4_56_1_90.pta';      % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                    editWaveform{4} = 'Siemens_filtered_editing.pta';  % name of non-editing pulse waveform. [non-editing]
                elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                    editWaveform{1} = 'dl_Siemens_4_56_1_90.pta';
                    editWaveform{2} = 'dl_Siemens_3_67_1_90_20ms.pta';
                    editWaveform{3} = 'dl_Siemens_3_67_4_56_20ms.pta';
                    editWaveform{4} = 'Siemens_filtered_editing.pta';
                else % MEGA PRESS
                    editWaveform{1} = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [1.9ppm]
                    editWaveform{2} = 'Siemens_filtered_editing.pta';  % name of 1st single editing pulse waveform. [7.5ppm]
                end
            end

        case 'GE'

            if strcmp(MRS_opt.localization, 'PRESS')
                refocWaveform = 'GE_rfa_3.9ms.pta'; % name of refocusing pulse waveform.
            else % sLASER GOIA pulse
                refocWaveform = 'GE_GOIA_WURST';    % name of refocusing pulse waveform.
                % refocWaveform = 'WURST_GOIA';    % name of refocusing pulse waveform.
                % refocWaveform = 'HS16R45s.pta';    % name of refocusing pulse waveform.
            end

            if ~strcmp(MRS_opt.seq, 'UnEdited')
                if strcmp(MRS_opt.seq, 'HERCULES')
                    editWaveform{1} = 'sg100_100_0_14ms_88hz.pta'; %'sg100_100_0_14ms_88hz.pta';  % name of 1st single editing pulse waveform. [4.58ppm]
                    editWaveform{2} = 'sg100_100_0_14ms_88hz.pta'; %'sg100_100_0_14ms_88hz.pta';  % name of 2nd single editing pulse waveform. [4.18ppm]
                    editWaveform{3} = 'dl_Philips_4_58_1_90.pta';  % name of 1st dual editing pulse waveform. [4.58ppm 1.90ppm]
                    editWaveform{4} = 'dl_Philips_4_18_1_90.pta';  % name of 2nd dual editing pulse waveform. [4.18ppm 1.90ppm]
                elseif strcmp(MRS_opt.seq, 'HERMES')
                    %     editWaveform{1} = 'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [4.56ppm]
                    %     editWaveform{2} = 'sg100_100_0_14ms_88hz.pta'; % name of 2nd single editing pulse waveform. [1.9ppm]
                    %     editWaveform{3} = 'dl_Philips_4_56_1_90.pta';  % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                    %     editWaveform{4} = 'sg100_100_0_14ms_88hz.pta'; % name of non-editing pulse waveform. [non-editing]
                    % elseif strcmp(MRS_opt.seq, 'HERMES_UHP')
                    editWaveform{1} = 'SGeddit.txt'; % name of 1st single editing pulse waveform. [4.56ppm]
                    editWaveform{2} = 'SGeddit.txt'; % name of 2nd single editing pulse waveform. [1.9ppm]
                    editWaveform{3} = 'dl_Philips_4_56_1_90.pta';  % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                    editWaveform{4} = 'SGeddit.txt'; % name of non-editing pulse waveform. [non-editing]
                elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                    editWaveform{1} = 'dl_Philips_4_56_1_90.pta';
                    editWaveform{2} = 'dl_Philips_3_67_1_90_20ms.pta';
                    editWaveform{3} = 'dl_Philips_3_67_4_56_20ms.pta';
                    editWaveform{4} = 'sg100_100_0_14ms_88hz.pta';
                elseif strcmp(MRS_opt.seq, 'MQC')
                    editWaveform{1} = 'gauss10s.pta';
                    editWaveform{2} = 'gauss10s.pta';
                    editWaveform{3} = 'gauss10s.pta';
                else % MEGA-PRESS
                    editWaveform{1} = 'gauss1s.pta'; %'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                    editWaveform{2} = 'gauss1s.pta'; %'sg100_100_0_14ms_88hz.pta'; % name of 1st single editing pulse waveform. [7.5ppm]
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
                    editWaveform{1} = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.58ppm]
                    editWaveform{2} = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.18ppm]
                    editWaveform{3} = 'dl_Philips_4_58_1_90.pta';  % name of 1st single editing pulse waveform. [4.58ppm 1.90ppm]
                    editWaveform{4} = 'dl_Philips_4_18_1_90.pta';  % name of 1st single editing pulse waveform. [4.18ppm 1.90ppm]
                elseif strcmp(MRS_opt.seq, 'HERMES')
                    editWaveform{1} = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [4.56ppm]
                    editWaveform{2} = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [1.90ppm]
                    editWaveform{3} = 'dl_Philips_univ_4_56_1_90.pta'; % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                    editWaveform{4} = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [non-editing]
                elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                    editWaveform{1} = 'dl_Philips_univ_4_56_1_9_20ms.pta';
                    editWaveform{2} = 'dl_Philips_univ_3_67_1_9_20ms.pta';
                    editWaveform{3} = 'dl_Philips_univ_3_67_4_56_20ms.pta';
                    editWaveform{4} = 'sl_univ_pulse.pta';
                else % MEGA PRESS
                    editWaveform{1} = 'sl_univ_pulse.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                    editWaveform{2} = 'sl_univ_pulse.pta'; % name of 1st single editing pulse waveform. [7.5ppm]
                end
            end

        case 'Universal_Siemens'

            if strcmp(MRS_opt.localization, 'PRESS')
                refocWaveform = 'univ_eddenrefo.pta';        % name of refocusing pulse waveform.
            else % sLASER GOIA pulse
                refocWaveform = 'GOIA';                      % name of refocusing pulse waveform.
            end

            if ~strcmp(MRS_opt.seq, 'UnEdited')
                if strcmp(MRS_opt.seq, 'HERCULES')
                    editWaveform{1}       = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.58ppm]
                    editWaveform{2}       = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.18ppm]
                    editWaveform{3}       = 'dl_Siemens_4_58_1_90.pta';     % name of 1st single editing pulse waveform. [4.58ppm 1.90ppm]
                    editWaveform{4}       = 'dl_Siemens_4_18_1_90.pta';  % name of 1st single editing pulse waveform. [4.18ppm 1.90ppm]
                elseif strcmp(MRS_opt.seq, 'HERMES')
                    editWaveform{1}       = 'sl_univ_pulse.pta';                % name of 1st single editing pulse waveform. [4.56ppm]
                    editWaveform{2}       = 'sl_univ_pulse.pta';               % name of 1st single editing pulse waveform. [1.90ppm]
                    editWaveform{3}       = 'dl_Siemens_4_56_1_90.pta';       % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                    editWaveform{4}       = 'sl_univ_pulse.pta';              % name of 1st single editing pulse waveform. [non-editing]
                elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                    editWaveform{1}       = 'dl_Siemens_univ_4_56_1_9_20ms.pta';
                    editWaveform{2}       = 'dl_Siemens_univ_3_67_1_9_20ms.pta';
                    editWaveform{3}       = 'dl_Siemens_univ_3_67_4_56_20ms.pta';
                    editWaveform{4}       = 'sl_univ_pulse.pta';
                else                                                       % MEGA PRESS
                    editWaveform{1}       = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [1.9ppm]
                    editWaveform{2}       = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [7.5ppm]
                end
            end

        case 'Universal_GE'

            if strcmp(MRS_opt.localization, 'PRESS')
                refocWaveform = 'univ_eddenrefo.pta'; % name of refocusing pulse waveform.
            else % sLASER GOIA pulse
                refocWaveform = 'GE_GOIA_WURST'; % name of refocusing pulse waveform.
            end

            if ~strcmp(MRS_opt.seq, 'UnEdited')
                if strcmp(MRS_opt.seq, 'HERCULES')
                    editWaveform{1} = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.58ppm]
                    editWaveform{2} = 'sl_univ_pulse.pta';         % name of 1st single editing pulse waveform. [4.18ppm]
                    editWaveform{3} = 'dl_Philips_4_58_1_90.pta';  % name of 1st single editing pulse waveform. [4.58ppm 1.90ppm]
                    editWaveform{4} = 'dl_Philips_4_18_1_90.pta';  % name of 1st single editing pulse waveform. [4.18ppm 1.90ppm]
                elseif strcmp(MRS_opt.seq, 'HERMES')
                    editWaveform{1} = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [4.56ppm]
                    editWaveform{2} = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [1.90ppm]
                    editWaveform{3} = 'dl_Philips_univ_4_56_1_90.pta'; % name of 1st dual editing pulse waveform. [4.56ppm 1.90ppm]
                    editWaveform{4} = 'sl_univ_pulse.pta';             % name of 1st single editing pulse waveform. [non-editing]
                elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
                    editWaveform{1} = 'dl_Philips_4_56_1_90.pta';
                    editWaveform{2} = 'dl_Philips_3_67_1_90_20ms.pta';
                    editWaveform{3} = 'dl_Philips_3_67_4_56_20ms.pta';
                    editWaveform{4} = 'sg100_100_0_14ms_88hz.pta';
                else % MEGA-PRESS
                    editWaveform{1} = 'sl_univ_pulse.pta'; % name of 1st single editing pulse waveform. [1.9ppm]
                    editWaveform{2} = 'sl_univ_pulse.pta'; % name of 2nd single editing pulse waveform. [7.5ppm]
                end
            end

    end

end

% Define frequency parameters for editing targets
if ~any(strcmp(MRS_opt.seq, {'UnEdited', 'UnEdited_se_MRSI'}))
    MRS_opt.editOnFreq1     = MRS_opt.editON{1}; % Center frequency of 1st editing experiment [ppm]
    MRS_opt.editOnFreq2     = MRS_opt.editON{2}; % Center frequency of 2nd editing experiment [ppm]
    if ~any(strcmp(MRS_opt.seq, {'MEGA', 'Edited_se_MRSI'}))
        MRS_opt.editOnFreq3 = MRS_opt.editON{3}; % Center frequency of 3rd HERMES/HERCULES experiment [ppm]
        MRS_opt.editOnFreq4 = MRS_opt.editON{4}; % Center frequency of 4th HERMES/HERCULES experiment [ppm]
    end
    if strcmp(MRS_opt.seq, 'MQC')
        MRS_opt.editOnFreq3 = MRS_opt.editON{3};
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
    MRS_opt.editTp1 = 10;
    MRS_opt.editTp2 = 8;
    MRS_opt.editTp3 = 10;
elseif ~any(strcmp(MRS_opt.seq, {'UnEdited', 'UnEdited_se_MRSI'}))
    if any(strcmp(MRS_opt.seq, {'MEGA', 'Edited_se_MRSI'}))
        editTp1 = MRS_opt.editTp; % duration of 1st editing pulse [ms]
        editTp2 = MRS_opt.editTp; % duration of 2nd editing pulse [ms]
    else % For HERMES and HERCULES, fix editing pulse duration to 20 ms
        editTp3 = MRS_opt.editTp; % duration of 3rd editing pulse [ms]
        editTp4 = MRS_opt.editTp; % duration of 4th editing pulse [ms]
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
    MRS_opt.z = linspace(-MRS_opt.fovZ/2, MRS_opt.fovZ/2, MRS_opt.nZ); %X positions to simulate [cm]
else
    MRS_opt.z = 0;
end

if any(strcmp(MRS_opt.seq, {'UnEdited_se_MRSI', 'Edited_se_MRSI'}))
    switch excWaveform
        case 'Philips_spredrex.pta'
            excRF = io_loadRFwaveform(excWaveform,'exc',0);
            if ~isempty(MRS_opt.excTp)
                excTp = MRS_opt.excTp;
            else
                excTp = 7.13; % Check duration
            end
            if ~isempty(MRS_opt.excBW)
                excRF.tbw = MRS_opt.excBW * excTp;
            else
                excRF.tbw = 2.277 * excTp;
            end
            excRF = rf_resample(excRF, 100);
        case 'univ_spreddenrex.pta'
            erorr('Code incomplete.');
        otherwise
            error('"%s" is not a valid refocusing pulse name.', excWaveform);
    end
    MRS_opt.excRF = excRF;
    MRS_opt.excTp = excTp;
end

% Load refocusing RF pulse
MRS_opt = load_refoc_pulse(MRS_opt, refocWaveform);

% Load RF waveforms for editing pulses, defined above
if strcmp(MRS_opt.seq, 'HERCULES')
    editRF1         = io_loadRFwaveform(editWaveform{1},'inv',0);
    editRF2         = io_loadRFwaveform(editWaveform{2},'inv',0);
    editRF3         = io_loadRFwaveform(editWaveform{3},'inv',0);
    editRF4         = io_loadRFwaveform(editWaveform{4},'inv',0);
    editRF3.tw1     = editRF2.tw1 * 2; %1.8107;
    editRF4.tw1     = editRF2.tw1 * 2; %1.8107;
    MRS_opt.editRF1 = editRF1;
    MRS_opt.editRF2 = editRF2;
    MRS_opt.editRF3 = editRF3;
    MRS_opt.editRF4 = editRF4;
elseif strcmp(MRS_opt.seq, 'HERMES')
    editRF1         = io_loadRFwaveform(editWaveform{1},'inv',0);
    editRF2         = io_loadRFwaveform(editWaveform{2},'inv',0);
    editRF3         = io_loadRFwaveform(editWaveform{3},'inv',0);
    editRF3.tw1     = editRF2.tw1 * 2;
    editRF4         = io_loadRFwaveform(editWaveform{4},'inv',0);
    MRS_opt.editRF1 = editRF1;
    MRS_opt.editRF2 = editRF2;
    MRS_opt.editRF3 = editRF3;
    MRS_opt.editRF4 = editRF4;
elseif strcmp(MRS_opt.seq, 'HERMES_GABA_GSH_EtOH')
    editRF1         = io_loadRFwaveform(editWaveform{1},'inv',0);
    editRF2         = io_loadRFwaveform(editWaveform{2},'inv',0);
    editRF3         = io_loadRFwaveform(editWaveform{3},'inv',0);
    editRF4         = io_loadRFwaveform(editWaveform{4},'inv',0);
    editRF1.tw1     = 1.8115; %editRF4.tw1*2;
    editRF2.tw1     = 1.8354;
    editRF3.tw1     = 1.9165;
    editRF4.tw1     = editRF4.tw1;
    MRS_opt.editRF1 = editRF1;
    MRS_opt.editRF2 = editRF2;
    MRS_opt.editRF3 = editRF3;
    MRS_opt.editRF4 = editRF4;
elseif any(strcmp(MRS_opt.seq, {'MEGA', 'Edited_se_MRSI'}))
    editRF1         = io_loadRFwaveform(editWaveform{1},'inv',0);
    editRF2         = io_loadRFwaveform(editWaveform{2},'inv',0);
    MRS_opt.editRF1 = editRF1;
    MRS_opt.editRF2 = editRF2;
elseif strcmp(MRS_opt.seq, 'MQC')
    editRF1         = io_loadRFwaveform(editWaveform{1},'90',0);
    editRF2         = io_loadRFwaveform(editWaveform{2},'180',0);
    editRF3         = io_loadRFwaveform(editWaveform{3},'90',0);
    MRS_opt.editRF1 = editRF1;
    MRS_opt.editRF2 = editRF2;
    MRS_opt.editRF3 = editRF3;
end

% Construct the editing pulses from the waveforms and defined frequencies
if strcmp(MRS_opt.seq, 'MQC')
    MRS_opt.editRFonA     = rf_freqshift(editRF1, editTp1, (MRS_opt.centreFreq - MRS_opt.editOnFreq1) * B0 * gamma/1e6);
    MRS_opt.editRFonB     = rf_freqshift(editRF2, editTp2, (MRS_opt.centreFreq - MRS_opt.editOnFreq2) * B0 * gamma/1e6);
    MRS_opt.editRFonC     = rf_freqshift(editRF3, editTp3, (MRS_opt.centreFreq - MRS_opt.editOnFreq3) * B0 * gamma/1e6);
elseif ~any(strcmp(MRS_opt.seq, {'UnEdited', 'UnEdited_se_MRSI'}))
    MRS_opt.editRFonA     = rf_freqshift(editRF1, editTp1, (MRS_opt.centreFreq - MRS_opt.editOnFreq1) * B0 * gamma/1e6);
    MRS_opt.editRFonB     = rf_freqshift(editRF2, editTp2, (MRS_opt.centreFreq - MRS_opt.editOnFreq2) * B0 * gamma/1e6);
    if ~any(strcmp(MRS_opt.seq, {'MEGA', 'Edited_se_MRSI'}))
        MRS_opt.editRFonC = rf_freqshift(editRF3, editTp3, (MRS_opt.centreFreq - MRS_opt.editOnFreq3) * B0 * gamma/1e6);
        MRS_opt.editRFonD = rf_freqshift(editRF4, editTp4, (MRS_opt.centreFreq - MRS_opt.editOnFreq4) * B0 * gamma/1e6);
    end
    % HERCULES has the same editing pulse duration and timing for all
    % sub-experiments. Valid for MEGA-PRESS as well.
    MRS_opt.editTp = editTp1;
end

% Load the spin system definitions and pick the spin system of choice
load('spinSystems.mat', ['sys' spinSys]);
sys = eval(['sys' spinSys]);

% Set up gradients
if strcmp(MRS_opt.seq, 'UnEdited_se_MRSI')
    MRS_opt.Gx     = (MRS_opt.refRF.tbw / (MRS_opt.refTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm] %this is for refoc
    MRS_opt.Gx_exc = (MRS_opt.excRF.tbw / (excTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm] %this is for excitation
elseif strcmp(MRS_opt.seq, 'Edited_se_MRSI')
    MRS_opt.Gx     = (MRS_opt.refRF.tbw / (MRS_opt.refTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm] %this is for refoc
    MRS_opt.Gx_exc = -(MRS_opt.excRF.tbw / (excTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm] %this is for excitation
else
    MRS_opt.Gx     = (MRS_opt.refRF.tbw / (MRS_opt.refTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm]
    MRS_opt.Gy     = (MRS_opt.refRF.tbw / (MRS_opt.refTp/1e3)) / (gamma * MRS_opt.thkY / 1e4); %[G/cm]
    % MRS_opt.Gx_exc = (MRS_opt.excRF.tbw / (excTp/1e3)) / (gamma * MRS_opt.thkX / 1e4); %[G/cm] %this is for excitation
end

for k = 1:length(sys)
    sys(k).shifts = sys(k).shifts - MRS_opt.centreFreq;
end
MRS_opt.sys = sys;

% % Calculate new delays by subtracting the pulse durations from the taus vector
% if ~strcmp(MRS_opt.seq, 'UnEdited_se_MRSI')
%     % taus           = TE1/2;               %middle 2nd EDITING to the start of readout
%     % taus           = tausA;
%     delays         = zeros(size(MRS_opt.taus));
%     % delays(1)      = taus(1)-(refTp/2);
%     % delays(2)      = 0; %taus(2)-((refTp+editTp)/2);
%     % delays(3)      = 0; %taus(3)-((editTp+refTp)/2);
%     % delays(4)      = 0; %taus(4)-((refTp+editTp)/2);
%     % delays(5)      = 0; %taus(5)-(editTp/2);
% 
%     % MRS_opt.taus   = taus;
%     MRS_opt.delays = delays;
% end

% Calculate Hamiltonian matrices and starting density matrix
[H,d] = sim_Hamiltonian_mgs(sys, B0);
MRS_opt.H = H;
MRS_opt.d = d;

% Create propagators for editing pulse
% if ~strcmp(MRS_opt.seq, 'UnEdited')
%     [MRS_opt.QoutONA]  = calc_shapedRF_propagator_edit(MRS_opt.H,MRS_opt.editRFonA,MRS_opt.editTp,MRS_opt.edit_flipAngle,0);
%     [MRS_opt.QoutONB]  = calc_shapedRF_propagator_edit(MRS_opt.H,MRS_opt.editRFonB,MRS_opt.editTp,MRS_opt.edit_flipAngle,0);
%     if ~strcmp(MRS_opt.seq, 'MEGA')
%         [MRS_opt.QoutONC]  = calc_shapedRF_propagator_edit(MRS_opt.H,MRS_opt.editRFonC,MRS_opt.editTp,MRS_opt.edit_flipAngle,0);
%         [MRS_opt.QoutOND]  = calc_shapedRF_propagator_edit(MRS_opt.H,MRS_opt.editRFonD,MRS_opt.editTp,MRS_opt.edit_flipAngle,0);
%     end
% end

% Creating propagators for Refoc pulse ONLY in the X direction With an
% assumption x=y, i.e., the voxel is isotropic
% (H,RF,Tp,flipAngle,phase,dfdx,grad)

% Load excitation pulse and create propagator
if any(strcmp(MRS_opt.seq, {'UnEdited_se_MRSI', 'Edited_se_MRSI'}))
    % excWaveform   = 'univ_spreddenrex.pta'; % 'Philips_spredrex.pta'
    % RF_struct     = io_loadRFwaveform(excWaveform,'exc',0);
    % MRS_opt.excRF = RF_struct;
    if MRS_opt.parallelize
        parfor X = 1:length(MRS_opt.x)
            Qexc{X} = calc_shapedRF_propagator_exc(MRS_opt.H, MRS_opt.excRF, MRS_opt.excTp, MRS_opt.exc_flipAngle, 0, MRS_opt.y(X), MRS_opt.Gx_exc);
        end
    else
        Qexc = cell(1,length(MRS_opt.x));
        for X = 1:length(MRS_opt.x)
            Qexc{X} = calc_shapedRF_propagator_exc(MRS_opt.H, MRS_opt.excRF, MRS_opt.excTp, MRS_opt.exc_flipAngle, 0, MRS_opt.y(X), MRS_opt.Gx_exc);
        end
    end
    MRS_opt.Qexc = Qexc;
end

% Create propagators for refocusing pulse
if any(strcmp(MRS_opt.seq, {'UnEdited', 'MEGA', 'HERMES', 'HERCULES', 'HERMES_GABA_GSH_EtOH', 'MQC'}))
    if MRS_opt.parallelize
        parfor X = 1:length(MRS_opt.x)
            Qrefoc{X} = calc_shapedRF_propagator_refoc(MRS_opt.H, MRS_opt.refRF, MRS_opt.refTp, MRS_opt.flipAngle, 0, MRS_opt.y(X), MRS_opt.Gx); %#ok<*PFBNS>
        end
    else
        Qrefoc = cell(1,length(MRS_opt.x));
        for X = 1:length(MRS_opt.x)
            Qrefoc{X} = calc_shapedRF_propagator_refoc(MRS_opt.H, MRS_opt.refRF, MRS_opt.refTp, MRS_opt.flipAngle, 0, MRS_opt.y(X), MRS_opt.Gx); %#ok<*PFBNS>
        end
    end
    MRS_opt.Qrefoc = Qrefoc;
end
