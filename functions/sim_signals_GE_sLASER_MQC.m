function [MRS_opt, out] = sim_signals_GE_sLASER_MQC(MRS_opt)

for ii = 1:length(MRS_opt)

    TE          = MRS_opt(ii).TEs{1}; % echo time [ms]
    excTp       = 60;
    excFreq     = 2.95;
    refTp       = MRS_opt(ii).refTp;  % duration of first refocusing pulse [ms]
    refTp2      = MRS_opt(ii).refTp2; % duration of second refocusing pulse [ms]
    metabolite  = MRS_opt(ii).metab;
    editTp1     = MRS_opt(ii).editTp1;    
    editOnFreq1 = MRS_opt(ii).editOnFreq1;

    fprintf('\n%s simulation at TE %d ms\n\n', metabolite, TE);
    out_name = [MRS_opt(ii).vendor{1} '_' MRS_opt(ii).seq{1} '_' MRS_opt(ii).localization{1} '_TE' num2str(TE) '_' metabolite '.mat'];
    save_dir = MRS_opt(ii).save_dir;

    %taus = [5.0688, abs(5.0688 - 24.3619), (38.3882-24.3619), (43.0007-38.3882), (49.6813-43.0007), (64.3619-49.6813), (80.0-64.3619)];
    % taus = [12.8600   14.4940    6.3440    5.5420   14.6320   20.0250    8.1030]; % MM
    % taus = [11.7580   15.5960    6.3440    5.5420   13.5180   21.1390    8.1030]; % MM: Updated taus (240416)
    % taus = [3.8200   12.5440   20.6360   10.0000   10.0000   12.0000    5.5440   19.4560]; % MM: taus for Seung's MQC sequence (240706)
    taus = [41 12 17 8.5 8.5 17 12 41]; % MM: taus for Seung's MQC sequence (250905)

    % ********************SET UP SIMULATION**********************************

    % Calculate new delays by subtracting the pulse durations from the taus
    % vector;
    delays(1) = taus(1) - ((excTp+refTp)/2);
    % delays(1) = taus(1) - (refTp/2);
    delays(2) = taus(2) - ((refTp+refTp)/2);
    delays(3) = taus(3) - ((refTp+editTp1)/2);
    delays(4) = taus(4) - ((editTp1+refTp2)/2);
    delays(5) = taus(5) - ((refTp2+editTp1)/2);
    delays(6) = taus(6) - ((editTp1+refTp)/2);
    delays(7) = taus(7) - ((refTp+refTp)/2);
    delays(8) = taus(8) - (refTp/2);

    MRS_opt(ii).delays = delays;
    MRS_opt(ii).taus   = taus;

    % MRS_opt(ii).excRF    = rf_freqshift(MRS_opt(ii).editRF1, excTp, (MRS_opt(ii).centreFreq - excFreq) * MRS_opt(ii).Bfield * MRS_opt(ii).gamma/1e6);
    % MRS_opt(ii).Q_outexc = calc_shapedRF_propagator_exc(MRS_opt(ii).H, MRS_opt(ii).excRF, excTp, MRS_opt(ii).edit_flipAngle, 0);
    % MRS_opt(ii).Q_outexc = calc_shapedRF_propagator_exc(MRS_opt(ii).H, MRS_opt(ii).editRF1, excTp, MRS_opt(ii).edit_flipAngle, 0, ...
    %     (MRS_opt(ii).centreFreq - excFreq) * MRS_opt(ii).Bfield * MRS_opt(ii).gamma/1e6);

    MRS_opt(ii).editRFonA = rf_freqshift(MRS_opt(ii).editRF1, editTp1, (MRS_opt(ii).centreFreq - editOnFreq1) * MRS_opt(ii).Bfield * MRS_opt(ii).gamma/1e6);
    MRS_opt(ii).Q_outONA  = calc_shapedRF_propagator_edit(MRS_opt(ii).H, MRS_opt(ii).editRFonA, MRS_opt(ii).editTp1, MRS_opt(ii).edit_flipAngle, 0);
    
    %% Run sequence

    % EXCITE
    % d = sim_excite(MRS_opt(ii).d, MRS_opt(ii).H, 'x');
    % d = apply_propagator_exc(MRS_opt(ii).d, MRS_opt(ii).H, MRS_opt(ii).Q_outexc);
    d = sim_shapedRF(MRS_opt(ii).d, MRS_opt(ii).H, MRS_opt(ii).editRF1, excTp, 90, 0, ...
        (MRS_opt(ii).centreFreq - excFreq) * MRS_opt(ii).Bfield * MRS_opt(ii).gamma/1e6);
    d = sim_apply_pfilter(d, MRS_opt(ii).H, +1); % +1
    d = sim_evolve(d, MRS_opt(ii).H, delays(1)/1e3);

    %% AFP pulse x-direction
    % First AFP
    parfor (X = 1:length(MRS_opt(ii).x), MRS_opt.parallelize.workers)
        d_x{X} = apply_propagator_refoc(d, MRS_opt(ii).H, MRS_opt(ii).Q_refoc{X}); %#ok<*PFBNS>
        d_x{X} = sim_apply_pfilter(d_x{X}, MRS_opt(ii).H, -1); % -1
        d_x{X} = sim_evolve(d_x{X}, MRS_opt(ii).H, delays(2)/1e3);
    end

    % Second AFP
    parfor (X = 1:length(MRS_opt(ii).x), MRS_opt.parallelize.workers)
        d_x{X} = apply_propagator_refoc(d_x{X}, MRS_opt(ii).H, MRS_opt(ii).Q_refoc{X});
        d_x{X} = sim_apply_pfilter(d_x{X}, MRS_opt(ii).H, +1); % +1
        d_x{X} = sim_evolve(d_x{X}, MRS_opt(ii).H, delays(3)/1e3);
    end

    % Calculate the average density matrix (doing this inside a separate for
    % loop because I couldn't figure out how to do this inside the parfor loop):
    d_Ax = struct([]);
    for X = 1:length(MRS_opt(ii).x)
        d_Ax = sim_dAdd(d_Ax, d_x{X});
    end

    %% Edit 1 (gauss10s)
    d_edit1 = apply_propagator_edit(d_Ax, MRS_opt(ii).H, MRS_opt(ii).Q_outONA);
    d_edit1 = sim_apply_pfilter(d_edit1, MRS_opt(ii).H, +2); % +2
    d_edit1 = sim_evolve(d_edit1, MRS_opt(ii).H, delays(4)/1e3);

    %% S-BREBOP-7500 pulse z-direction
    parfor (Z = 1:length(MRS_opt(ii).z), MRS_opt.parallelize.workers)
        d_z{Z} = apply_propagator_refoc(d_edit1, MRS_opt(ii).H, MRS_opt(ii).Q_refoc2{Z});
        d_z{Z} = sim_apply_pfilter(d_z{Z}, MRS_opt(ii).H, -2); % -2
        d_z{Z} = sim_evolve(d_z{Z}, MRS_opt(ii).H, delays(5)/1e3);
    end

    % Calculate the average density matrix (doing this inside a separate for
    % loop because I couldn't figure out how to do this inside the parfor loop):
    d_Az = struct([]);
    for Z = 1:length(MRS_opt(ii).z)
        d_Az = sim_dAdd(d_Az, d_z{Z});
    end

    %% Edit 2 (gauss10s)
    d_edit2 = apply_propagator_edit(d_Az, MRS_opt(ii).H, MRS_opt(ii).Q_outONA);
    d_edit2 = sim_apply_pfilter(d_edit2, MRS_opt(ii).H, -1); % -1
    d_edit2 = sim_evolve(d_edit2, MRS_opt(ii).H, delays(6)/1e3);

    %% AFP pulse y-direction
    parfor (Y = 1:length(MRS_opt(ii).y), MRS_opt.parallelize.workers)
        % Third AFP
        d_y{Y} = apply_propagator_refoc(d_edit2, MRS_opt(ii).H, MRS_opt(ii).Q_refoc{Y});
        d_y{Y} = sim_apply_pfilter(d_y{Y}, MRS_opt(ii).H, +1); % +1
        d_y{Y} = sim_evolve(d_y{Y}, MRS_opt(ii).H, delays(7)/1e3);

        % Fourth AFP
        d_y{Y} = apply_propagator_refoc(d_y{Y}, MRS_opt(ii).H, MRS_opt(ii).Q_refoc{Y});
        d_y{Y} = sim_apply_pfilter(d_y{Y}, MRS_opt(ii).H, -1); % -1
        d_y{Y} = sim_evolve(d_y{Y}, MRS_opt(ii).H, delays(8)/1e3);
    end

    % Calculate the average density matrix (doing this inside a separate for
    % loop because I couldn't figure out how to do this inside the parfor loop):
    d_Ay = struct([]);
    for Y = 1:length(MRS_opt(ii).y)
        d_Ay = sim_dAdd(d_Ay, d_y{Y});
    end

    %% Now running the tail end of the sequence

    out = sim_mega_slaser_shaped_ultrafast_readout(MRS_opt(ii), d_Ay);
    numSims = MRS_opt(ii).nX * MRS_opt(ii).nY * MRS_opt(ii).nZ;
    out = op_ampScale(out, 1/numSims);

    % Scale by the total size of the simulated region, relative to the size
    % of the voxel.
    if MRS_opt(ii).fovX > MRS_opt(ii).thkX
        voxRatio = (MRS_opt(ii).thkX * MRS_opt(ii).thkY) / (MRS_opt(ii).fovX * MRS_opt(ii).fovY);
    else
        voxRatio = 1;
    end

    out = op_ampScale(out, 1/voxRatio);

    % Correct residual DC offset
    out = op_dccorr_FID_A(out, 'p');

    out.name = metabolite;
    save(fullfile(save_dir, out_name), 'out');

end

end


function out = sim_mega_slaser_shaped_ultrafast_readout(MRS_opt, d)

% Readout along y (90 degree phase)
% out = sim_readout(d, MRS_opt.H, MRS_opt.Npts, MRS_opt.sw, MRS_opt.lw, 90);
out = sim_readout(d, MRS_opt.H, MRS_opt.Npts, MRS_opt.sw, MRS_opt.lw, 105);

% Correct the ppm scale:
out.ppm = out.ppm - (4.68 - MRS_opt.centreFreq);

% Fill in structure header fields:
out.seq = MRS_opt.seq;
out.te  = sum(MRS_opt.taus);
out.sim = 'shaped';

% Additional fields for compatibility with FID-A processing tools.
out.sz=size(out.specs);
out.date=datetime("today");
out.dims.t=1;
out.dims.coils=0;
out.dims.averages=0;
out.dims.subSpecs=0;
out.dims.extras=0;
out.averages=1;
out.rawAverages=1;
out.subspecs=1;
out.rawSubspecs=1;
out.flags.writtentostruct=1;
out.flags.gotparams=1;
out.flags.leftshifted=0;
out.flags.filtered=0;
out.flags.zeropadded=0;
out.flags.freqcorrected=0;
out.flags.phasecorrected=0;
out.flags.averaged=1;
out.flags.addedrcvrs=1;
out.flags.subtracted=1;
out.flags.writtentotext=0;
out.flags.downsampled=0;
out.flags.isISIS=0;
out.seq=char(MRS_opt.seq); % scnh

end
