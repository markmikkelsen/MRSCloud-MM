% Inversion frequency profiles for universal editing pulse

clear_all;

%% Load RF waveforms

Tp1 = 12;
rf_sincgauss1 = io_loadRFwaveform_MM('dl_Philips_univ_4_56_1_90.pta', 'inv', Tp1);

Tp2 = 15;
rf_sincgauss2 = io_loadRFwaveform_MM('dl_Philips_univ_4_56_1_90.pta', 'inv', Tp2);

Tp3 = 20;
rf_sincgauss3 = io_loadRFwaveform_MM('dl_Philips_univ_4_56_1_90.pta', 'inv', Tp3);

%% Run Bloch equation simulator

lb = -0.2;
ub = 0.2;
n = 1e5;

rf_sincgauss1.w1max = rf_sincgauss1.tw1/(Tp1/1e3);
rf_sincgauss2.w1max = rf_sincgauss2.tw1/(Tp2/1e3);
rf_sincgauss3.w1max = rf_sincgauss3.tw1/(Tp3/1e3);

[rf_sincgauss1.Mv, rf_sincgauss1.sc] = bes(rf_sincgauss1.waveform(:,2), Tp1, 'f', rf_sincgauss1.w1max/1e3, lb, ub, n);
[rf_sincgauss2.Mv, rf_sincgauss2.sc] = bes(rf_sincgauss2.waveform(:,2), Tp2, 'f', rf_sincgauss2.w1max/1e3, lb, ub, n);
[rf_sincgauss3.Mv, rf_sincgauss3.sc] = bes(rf_sincgauss3.waveform(:,2), Tp3, 'f', rf_sincgauss3.w1max/1e3, lb, ub, n);

%% Find inversion frequency bandwidths

% Sinc-gauss
ind = find(rf_sincgauss1.Mv(3,:) <= 0);
rf_sincgauss1.bw = rf_sincgauss1.sc(ind(end)) - rf_sincgauss1.sc(ind(1));
rf_sincgauss1.bw = rf_sincgauss1.bw * 1e3;

ind = find(rf_sincgauss2.Mv(3,:) <= 0);
rf_sincgauss2.bw = rf_sincgauss2.sc(ind(end)) - rf_sincgauss2.sc(ind(1));
rf_sincgauss2.bw = rf_sincgauss2.bw * 1e3;

ind = find(rf_sincgauss3.Mv(3,:) <= 0);
rf_sincgauss3.bw = rf_sincgauss3.sc(ind(end)) - rf_sincgauss3.sc(ind(1));
rf_sincgauss3.bw = rf_sincgauss3.bw * 1e3;

%% Plot inversion frequency profiles

close all;

w = 0.8;
h = 0.4;
l = (1-w)/2;
b = (1-h)/2;

figure('Color', 'w', 'Units', 'normalized', 'OuterPosition', [l b w h]);

tiledlayout(1,3);
nexttile;

plot(rf_sincgauss1.sc*1e3, rf_sincgauss1.Mv(3,:));
set(gca, 'xlim', [-200 200], 'box', 'off', 'tickdir', 'out');
xlabel('Frequency (Hz)');
ylabel('M_{z}/M_{0}');
title(['{\it{T}} = ' num2str(Tp1) ' ms, \Delta{\it{f}} = ' num2str(rf_sincgauss1.bw, '%.2f') ' Hz']);

nexttile;

plot(rf_sincgauss2.sc*1e3, rf_sincgauss2.Mv(3,:));
set(gca, 'xlim', [-200 200], 'box', 'off', 'tickdir', 'out');
xlabel('Frequency (Hz)');
title(['{\it{T}} = ' num2str(Tp2) ' ms, \Delta{\it{f}} = ' num2str(rf_sincgauss2.bw, '%.2f') ' Hz']);

nexttile;

plot(rf_sincgauss3.sc*1e3, rf_sincgauss3.Mv(3,:));
set(gca, 'xlim', [-200 200], 'box', 'off', 'tickdir', 'out');
xlabel('Frequency (Hz)');
title(['{\it{T}} = ' num2str(Tp3) ' ms, \Delta{\it{f}} = ' num2str(rf_sincgauss3.bw, '%.2f') ' Hz']);

% printfig('Philips_editRF_inv_freq','-eps');









