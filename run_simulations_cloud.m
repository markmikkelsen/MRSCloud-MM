function basis = run_simulations_cloud(json_input)

% Load JSON file containing simulation parameters
sim_params_json = loadjson(json_input);

metablist      = horzcat(sim_params_json.private.metab_default, sim_params_json.userInput.metablist);
vendor         = sim_params_json.userInput.vendor;          % OPTIONS: "GE", "Philips", "Siemens", "Universal_GE", "Universal_Philips", "Universal_Siemens"
B0             = sim_params_json.userInput.B0;
mega_or_hadam  = sim_params_json.userInput.mega_or_hadam;   % OPTIONS: "MEGA", "HERMES", "HERCULES"
localization   = sim_params_json.userInput.localization;    % OPTIONS: "PRESS", "sLASER", "STEAM 7T"
editTarget     = sim_params_json.userInput.editTarget;
if isempty(editTarget)
    editTarget = {''};
end
TE             = sim_params_json.userInput.TE;              % TE and the sum of taus must be equal
taus           = sim_params_json.userInput.taus;
RFpulses       = sim_params_json.userInput.pulses;          % A structure containing the RF pulse parameters
spatial_points = sim_params_json.userInput.spatial_points;
TM             = sim_params_json.userInput.tm;
flipAngle      = sim_params_json.private.flipAngle;
centreFreq     = sim_params_json.private.centreFreq;
edit_flipAngle = sim_params_json.private.edit_flipAngle;
exc_flipAngle  = sim_params_json.private.exc_flipAngle;
save_dir       = sim_params_json.DIRECTORY.save_dir;

if ~exist(save_dir,'dir')
    mkdir(save_dir);
end
delete([save_dir,'/*']); % Empty save_dir

% Check if Parallel Computing Toolbox is installed so that calculations can
% be accelerated
MRS_opt.parallelize.flag    = toolbox_check;
MRS_opt.parallelize.workers = MRS_opt.parallelize.flag * maxNumCompThreads;  % 0 = serial, N = parallel

% Check timings
assert(TE == sum(taus), 'TE (%g ms) does not equal sum of taus (%g ms).', TE, sum(taus));

for ii = 1:length(metablist)

    if exist('RFpulses', 'var') && ~isempty(RFpulses)

        if isfield(RFpulses, 'exc') && ~isempty(RFpulses.exc.name)
            MRS_opt.excName = RFpulses.exc.name;
            MRS_opt.excTp   = RFpulses.exc.duration;
            MRS_opt.excBW   = RFpulses.exc.bandwidth;
        end

        if isfield(RFpulses, 'ref') && ~isempty(RFpulses.ref.name)
            MRS_opt.refName = RFpulses.ref.name;
            MRS_opt.refTp   = RFpulses.ref.duration;
            MRS_opt.refBW   = RFpulses.ref.bandwidth;
        end

        if isfield(RFpulses, 'edit') && ~isempty(RFpulses.edit.duration)
            fields = fieldnames(RFpulses.edit);
            fields = fields(contains(fields, 'edit'));
            for jj = 1:numel(fields)
                MRS_opt.editName{jj} = RFpulses.edit.(fields{jj}).name;
                MRS_opt.editON{jj}   = RFpulses.edit.(fields{jj}).offset;
            end
            MRS_opt.editTp = RFpulses.edit.duration;
        end

    else

        fprintf(['\n"RFpulses" not found in the input .json file or it is empty. ' ...
                 'Using default pulse parameters.\n\n']);

        switch mega_or_hadam{1}

            case {'MEGA', 'Edited_se_MRSI'}
                A              = editOn;       %single-lobe pulse
                B              = editOff;      %single-lobe pulse
                MRS_opt.editTp = editTp;       %for MEGA only
                MRS_opt.editON = num2cell([A B]);

            case 'HERMES'
                % TE              = 80;
                A               = 4.56;           %single-lobe pulse
                B               = 1.90;           %single-lobe pulse
                C               = (4.56 + 1.9)/2; %dual-lobe pulse
                D               = 7.50;           %single-lobe pulse
                MRS_opt.editTp = editTp;
                MRS_opt.editON = num2cell([A B C D]);

            case 'HERMES_GABA_GSH_EtOH'
                % TE              = 80;
                A               = (4.56 + 1.9)/2;  %dual-lobe pulse
                B               = (3.67 + 1.9)/2;  %dual-lobe pulse
                C               = (3.67 + 4.56)/2; %dual-lobe pulse
                D               = 7.50;            %single-lobe pulse
                MRS_opt.editTp = editTp;
                MRS_opt.editON = num2cell([A B C D]);

            case 'HERCULES'
                % TE              = 80;
                A               = 4.58;           %single-lobe pulse
                B               = 4.18;           %single-lobe pulse
                C               = (4.58 + 1.9)/2; %dual-lobe pulse
                D               = (4.18 + 1.9)/2; %dual-lobe pulse
                MRS_opt.editTp = editTp;
                MRS_opt.editON = num2cell([A B C D]);

            case 'MQC'
                A               = 4.56;
                MRS_opt.editON = num2cell(A);

            otherwise
                error('''%s'' is invalid.', mega_or_hadam);

        end

    end

    MRS_opt.flipAngle      = flipAngle;        % Flip angle degrees
    MRS_opt.centreFreq     = centreFreq;       % Center frequency of MR spectrum [ppm]
    MRS_opt.edit_flipAngle = edit_flipAngle;   % Edited flip angle
    MRS_opt.exc_flipAngle  = exc_flipAngle;     % Excitation flip angle
    MRS_opt.TM             = TM;
    MRS_opt.nX             = spatial_points;   % number of spatial points to simulate in x direction
    MRS_opt.nY             = spatial_points;   % number of spatial points to simulate in y direction
    MRS_opt.nZ             = spatial_points;   % number of spatial points to simulate in z direction
    MRS_opt.localization   = localization;
    MRS_opt.B0             = B0;
    MRS_opt.vendor         = vendor;
    MRS_opt.seq            = mega_or_hadam;
    metab                  = metablist(ii);
    Nmetab                 = length(metab);
    MRS_opt.metab          = metab{Nmetab};
    MRS_opt.Nmetab         = Nmetab;
    MRS_opt.TEs            = num2cell(TE);
    MRS_opt.taus           = taus;
    % MRS_opt.tm             = tm; % mixing time [ms]
    MRS_opt.save_dir       = save_dir;
    if strcmp(mega_or_hadam{1}, 'MQC')
        MRS_opt            = load_parameters_MQC(MRS_opt);
    else
        MRS_opt            = load_parameters(MRS_opt); % This is the function you need to edit to change the simulation parameters
    end

    % Simulate
    switch localization{1}

        case 'PRESS'

            if any(strcmp(mega_or_hadam, {'HERMES', 'HERCULES', 'HERMES_GABA_GSH_EtOH'}))
                [MRS_opt, outA, outB, outC, outD] = sim_signals(MRS_opt); %#ok<*ASGLU>
            elseif strcmp(mega_or_hadam, 'MEGA')
                [MRS_opt, outA, outB] = sim_signals(MRS_opt);
            elseif strcmp(mega_or_hadam, 'Edited_se_MRSI')
                [MRS_opt, outA, outB] = sim_signals_MRSI(MRS_opt);
            elseif strcmp(mega_or_hadam, 'UnEdited_se_MRSI')
                [MRS_opt, outA] = sim_signals_MRSI(MRS_opt);
            else
                [MRS_opt, outA] = sim_signals(MRS_opt);
            end

        case 'sLASER'

            if any(strcmp(mega_or_hadam, {'HERMES', 'HERCULES', 'HERMES_GABA_GSH_EtOH'}))
                switch vendor{1}
                    case 'GE'
                        [MRS_opt, outA, outB, outC, outD] = sim_signals_GE_sLASER_HERMES(MRS_opt);
                    case {'Philips', 'Siemens'}
                        [MRS_opt, outA, outB, outC, outD] = sim_signals_sLASER(MRS_opt);
                end
            elseif strcmp(mega_or_hadam, 'MEGA') && strcmp(vendor,'GE')
                [MRS_opt, outA, outB] = sim_signals_GE_sLASER_MEGA(MRS_opt);
            elseif strcmp(mega_or_hadam, 'MQC')
                [MRS_opt, outA] = sim_signals_GE_sLASER_MQC(MRS_opt);
            else
                [MRS_opt, outA] = sim_signals_sLASER(MRS_opt);
            end

        case 'STEAM 7T'

            if strcmp(mega_or_hadam, 'UnEdited')
                [MRS_opt, out] = sim_signals_STEAM(MRS_opt);
            end

    end

end

% Create a basis set in .BASIS format for LCModel
addMMFlag          = 0;
basis              = fit_makeBasis_MRSCloud(save_dir, addMMFlag, mega_or_hadam{1}, editTarget{1}, TE, localization{1}, vendor{1});
basis.vendor       = sim_params_json.userInput.vendor;
basis.seq          = sim_params_json.userInput.mega_or_hadam;
basis.localization = sim_params_json.userInput.localization;

switch mega_or_hadam{1}
    case {'UnEdited', 'MQC'}
        subspec = 1;
        subspecName = {''};
        editTarget = {''}; % ARC 20230621
    case 'MEGA'
        subspec = 1:4;
        subspecName = {'off','on','diff1','sum'};
    case 'HERMES'
        subspec = 1:7;
        subspecName = {'a','b','c','d','diff1','diff2','sum'};
    case 'HERMES_GABA_GSH_EtOH'
        subspec = 1:8;
        subspecName = {'a','b','c','d','diff1','diff2','sum','diff3'}; %diff3 is EtOH
    case 'HERCULES'
        subspec = 1:7;
        subspecName = {'a','b','c','d','diff1','diff2','sum'};
    case 'UnEdited_se_MRSI'
        subspec = 1;
        subspecName = {''};
    case 'Edited_se_MRSI'
        subspec = 1:4;
        subspecName = {'off','on','diff1','sum'};
end

for ss = 1:length(subspec)

    out_name_parts = {'LCModel', vendor{1}, mega_or_hadam{1}, localization{1}, editTarget{1}}; % ARC 20230621
    last_ix = find(strlength(out_name_parts) > 0, 1, 'last'); % ARC 20230621
    out_name_parts{last_ix} = [out_name_parts{last_ix} '_TE' num2str(TE)]; % ARC 20230621 % scnh added '_TE'
    out_name_parts{end+1} = subspecName{ss}; %#ok<*AGROW> % ARC 20230621
    outfile = fullfile(save_dir, [strjoin(out_name_parts(strlength(out_name_parts) > 0), '_') '.BASIS']); % ARC 20230621

    io_writelcmBASIS(basis, outfile, vendor{1}, mega_or_hadam{1}, metablist, subspec(ss));
    out = fit_plotBasis(basis, ss, 1);
    set(gcf, 'Color', 'w');
    if any(strcmp(mega_or_hadam, {'UnEdited','MQC'}))
        exportgraphics(out, fullfile(save_dir, 'basis-set.pdf'), 'ContentType', 'vector');
    else
        exportgraphics(out, fullfile(save_dir, ['basis-set' '_' subspecName{ss} '.pdf']), 'ContentType', 'vector');
    end
    close;

end

% create a basis set in .mat for Osprey
addMMFlag = 0;
delete([save_dir,'/BASIS_*']); % Remove the previous BASIS with MMFlag off
basis = fit_makeBasis_MRSCloud(save_dir, addMMFlag, mega_or_hadam{1}, editTarget{1}, TE, localization{1}, vendor{1});

end
