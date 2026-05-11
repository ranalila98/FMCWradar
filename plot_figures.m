%% plot_paper_figures.m
%
% Run AFTER auto_phase_array.m.
%
% Required workspace variables:
%   resp, r, sp, Z, nfft_r, nfft_d
%   detects_raw, detects
%   detected_targets
%   truth_targets, target_dist, target_az
%   radar_speed, dr, lambda, Nrx_virt
%
% Produces 6 figures:
%   Fig 1 — Range profiles: single channel vs virtual-channel superposition
%   Fig 2 — Single-channel RDM
%   Fig 3 — Fused RDM Z(kv,kr)
%   Fig 4 — Raw CFAR detections
%   Fig 5 — Final grouped CFAR detections
%   Fig 6 — Point Cloud Map (PCM)
%
% Saves each figure as vector PDF only.

set(groot, ...
    'defaultAxesFontName',   'Times New Roman', ...
    'defaultAxesFontSize',   9, ...
    'defaultTextFontName',   'Times New Roman', ...
    'defaultTextFontSize',   9, ...
    'defaultLineLineWidth',  0.75, ...
    'defaultAxesLineWidth',  0.5, ...
    'defaultAxesBox',        'on', ...
    'defaultFigureColor',    'white', ...
    'defaultAxesColor',      'white', ...
    'defaultAxesTickDir',    'out', ...
    'defaultAxesTickLength', [0.015 0.015]);

W1 = 3.5;    % IEEE single-column width, inches
W2 = 7.16;   % IEEE double-column width, inches
H  = 2.6;    % standard height, inches

out_folder = "paper_figures";
if ~exist(out_folder, 'dir')
    mkdir(out_folder);
end

%% =========================================================
%  Derived quantities
%% =========================================================

resp_pos = resp(nfft_r/2+1:end, :, :);

[~, v0_idx] = min(abs(sp));

% Single-channel range profile: receiver channel 1, max over Doppler
rp_single = squeeze(max(abs(resp_pos(:, 1, :)), [], 3));
rp_single_dB = 20*log10(rp_single ./ max(rp_single) + eps);

% All virtual-channel range profiles: max over Doppler for each channel
rp_all = squeeze(max(abs(resp_pos), [], 3));   % [range_bins x virtual_channels]

% Normalize each virtual channel separately
rp_all_dB = 20*log10(rp_all ./ max(rp_all, [], 1) + eps);

% Fused profile for marker placement
rp_fused = sqrt(mean(rp_all.^2, 2));
rp_fused_dB = 20*log10(rp_fused ./ max(rp_fused) + eps);

% ---------------------------------------------------------
% RDM plots
% Keep these as range-Doppler maps.
% ---------------------------------------------------------

% Single-channel RDM
Z_single = reshape(abs(resp_pos(:,1,:)).^2, size(resp_pos,1), size(resp_pos,3));
Z_single_dB = 10*log10(Z_single ./ max(Z_single(:)) + eps);

% Fused RDM
Z_fused_dB = 10*log10(Z ./ max(Z(:)) + eps);

num_truths = size(truth_targets, 1);
num_dets   = size(detected_targets, 1);

%% =========================================================
%  FIG 1 — Range Profiles, paper-style
%% =========================================================

f1 = figure('Units','inches','Position',[0.5 5 W2 H], ...
            'PaperUnits','inches','PaperSize',[W2 H], ...
            'PaperPosition',[0 0 W2 H], ...
            'Color','w');

ax1a = subplot(1,2,1);

plot(ax1a, r, rp_single_dB, 'k-', 'LineWidth', 0.75);
xlabel(ax1a, 'Range (m)');
ylabel(ax1a, 'Normalized magnitude (dB)');
title(ax1a, '(a) Single receiver channel', 'FontWeight','normal');
xlim(ax1a, [0 80]);
ylim(ax1a, [-60 3]);
grid(ax1a,'on');
ax1a.GridLineStyle = ':';
ax1a.GridAlpha = 0.4;

ax1b = subplot(1,2,2);

plot(ax1b, r, rp_all_dB, 'LineWidth', 0.45);
hold(ax1b,'on');

for k = 1:num_dets
    [~,ri] = min(abs(r - detected_targets(k,1)));
    plot(ax1b, r(ri), rp_fused_dB(ri), 'kv', ...
         'MarkerSize',5,'MarkerFaceColor','k');
end

hold(ax1b,'off');
xlabel(ax1b, 'Range (m)');
ylabel(ax1b, 'Normalized magnitude (dB)');
title(ax1b, sprintf('(b) %d-channel superposition', Nrx_virt), ...
      'FontWeight','normal');
xlim(ax1b, [0 80]);
ylim(ax1b, [-80 3]);
grid(ax1b,'on');
ax1b.GridLineStyle = ':';
ax1b.GridAlpha = 0.4;

%% =========================================================
%  FIG 2 — Single-Channel RDM
%% =========================================================

f2 = figure('Units','inches','Position',[0.5 2 W1 H+0.4], ...
            'PaperUnits','inches','PaperSize',[W1 H+0.4], ...
            'PaperPosition',[0 0 W1 H+0.4], ...
            'Color','w');

ax2 = axes(f2,'Position',[0.14 0.16 0.72 0.72]);
imagesc(ax2, sp, r, Z_single_dB);
colormap(ax2, gray(256));
cb2 = colorbar(ax2,'eastoutside');
cb2.Label.String   = 'Normalized power (dB)';
cb2.Label.FontSize = 8;
cb2.FontSize       = 8;
caxis(ax2, [-50 0]);
set(ax2,'YDir','normal');
xlabel(ax2,'Relative velocity (m/s)');
ylabel(ax2,'Range (m)');
title(ax2,'(a) Single virtual receiver channel','FontWeight','normal');
ylim(ax2,[0 max(r)*0.8]);

%% =========================================================
%  FIG 3 — Fused RDM
%% =========================================================

f3 = figure('Units','inches','Position',[4.5 2 W1 H+0.4], ...
            'PaperUnits','inches','PaperSize',[W1 H+0.4], ...
            'PaperPosition',[0 0 W1 H+0.4], ...
            'Color','w');

ax3 = axes(f3,'Position',[0.14 0.16 0.72 0.72]);
imagesc(ax3, sp, r, Z_fused_dB);
colormap(ax3, gray(256));
cb3 = colorbar(ax3,'eastoutside');
cb3.Label.String   = 'Normalized power (dB)';
cb3.Label.FontSize = 8;
cb3.FontSize       = 8;
caxis(ax3, [-50 0]);
set(ax3,'YDir','normal');
xlabel(ax3,'Relative velocity (m/s)');
ylabel(ax3,'Range (m)');
title(ax3, sprintf('(b) Fused RDM, %d virtual channels', Nrx_virt), ...
      'FontWeight','normal');
ylim(ax3,[0 max(r)*0.8]);

noise_single = mean(Z_single_dB(:));
noise_fused  = mean(Z_fused_dB(:));
fprintf('Noise floor difference, single minus fused: %.2f dB\n', ...
        noise_single - noise_fused);

%% =========================================================
%  FIG 4 — Raw CFAR Detections
%% =========================================================

f4 = figure('Units','inches','Position',[0.5 -1 W1 H+0.4], ...
            'PaperUnits','inches','PaperSize',[W1 H+0.4], ...
            'PaperPosition',[0 0 W1 H+0.4], ...
            'Color','w');

ax4 = axes(f4,'Position',[0.14 0.16 0.72 0.72]);
imagesc(ax4, sp, r, Z_fused_dB);
colormap(ax4, gray(256));
cb4 = colorbar(ax4,'eastoutside');
cb4.Label.String   = 'Normalized power (dB)';
cb4.Label.FontSize = 8;
cb4.FontSize       = 8;
caxis(ax4, [-50 0]);
set(ax4,'YDir','normal');
hold(ax4,'on');

if exist('detects_raw','var') && ~isempty(detects_raw)
    hRaw = plot(ax4, sp(detects_raw(:,2)), r(detects_raw(:,1)), 'wo', ...
         'MarkerSize', 5.5, 'LineWidth', 1.2);
    lg4 = legend(ax4, hRaw, 'Raw CFAR detections', 'Location','northeast');
    lg4.FontSize = 8;
    lg4.Box = 'off';
    lg4.TextColor = 'w';
end

hold(ax4,'off');
xlabel(ax4,'Relative velocity (m/s)');
ylabel(ax4,'Range (m)');
title(ax4,'Raw improved 2D CFAR detections','FontWeight','normal');
ylim(ax4,[0 max(r)*0.8]);

%% =========================================================
%  FIG 5 — Final Grouped CFAR Detections
%% =========================================================

f5 = figure('Units','inches','Position',[4.5 -1 W1 H+0.4], ...
            'PaperUnits','inches','PaperSize',[W1 H+0.4], ...
            'PaperPosition',[0 0 W1 H+0.4], ...
            'Color','w');

ax5 = axes(f5,'Position',[0.14 0.16 0.72 0.72]);
imagesc(ax5, sp, r, Z_fused_dB);
colormap(ax5, gray(256));
cb5 = colorbar(ax5,'eastoutside');
cb5.Label.String   = 'Normalized power (dB)';
cb5.Label.FontSize = 8;
cb5.FontSize       = 8;
caxis(ax5, [-50 0]);
set(ax5,'YDir','normal');
hold(ax5,'on');

if ~isempty(detects)
    hFinal = plot(ax5, sp(detects(:,2)), r(detects(:,1)), 'wo', ...
         'MarkerSize', 7, 'LineWidth', 1.5);
    lg5 = legend(ax5, hFinal, 'Final grouped detections', 'Location','northeast');
    lg5.FontSize = 8;
    lg5.Box = 'off';
    lg5.TextColor = 'w';
end

hold(ax5,'off');
xlabel(ax5,'Relative velocity (m/s)');
ylabel(ax5,'Range (m)');
title(ax5,'Final detections after post-CFAR grouping','FontWeight','normal');
ylim(ax5,[0 max(r)*0.8]);

%% =========================================================
%  FIG 6 — Clean Point Cloud Map
%% =========================================================

f6 = figure('Units','inches','Position',[0.5 -4.5 W1 W1], ...
            'PaperUnits','inches','PaperSize',[W1 W1], ...
            'PaperPosition',[0 0 W1 W1], ...
            'Color','w');

ax6 = axes(f6,'Position',[0.16 0.15 0.78 0.76]);
hold(ax6,'on');

% Truth coordinates
x_truth = truth_targets(:,1) .* sind(truth_targets(:,3));
y_truth = truth_targets(:,1) .* cosd(truth_targets(:,3));

% Detected coordinates
x_det = detected_targets(:,1) .* sind(detected_targets(:,3));
y_det = detected_targets(:,1) .* cosd(detected_targets(:,3));

% Plot detected first, then truth on top
h_det = plot(ax6, x_det, y_det, 'd', ...
    'MarkerSize', 8, ...
    'MarkerFaceColor', [0.85 0 0], ...
    'MarkerEdgeColor', 'k', ...
    'LineWidth', 1.0, ...
    'LineStyle', 'none');

h_truth = plot(ax6, x_truth, y_truth, 'o', ...
    'MarkerSize', 7, ...
    'MarkerFaceColor', [0 0.4470 0.7410], ...
    'MarkerEdgeColor', 'k', ...
    'LineWidth', 0.9, ...
    'LineStyle', 'none');

% Label offsets
truth_offsets = [
     0.55, -0.10;
     0.55,  0.25;
     0.45,  0.35;
     0.45,  0.35
];

det_offsets = [
    -0.95, -0.85;
    -0.95, -0.85;
    -0.85, -1.00;
    -0.85, -0.90;
     0.65, -1.10;
     0.65,  0.75;
    -1.10,  0.70;
     0.75,  1.00
];

% Truth labels
for k = 1:num_truths
    idx = mod(k-1, size(truth_offsets,1)) + 1;
    text(ax6, x_truth(k)+truth_offsets(idx,1), ...
              y_truth(k)+truth_offsets(idx,2), ...
         sprintf('T%d', k), ...
         'FontSize', 8, ...
         'FontWeight', 'bold', ...
         'Color', [0 0.4470 0.7410]);
end

% Detected labels
for k = 1:num_dets
    idx = mod(k-1, size(det_offsets,1)) + 1;
    text(ax6, x_det(k)+det_offsets(idx,1), ...
              y_det(k)+det_offsets(idx,2), ...
         sprintf('D%d', k), ...
         'FontSize', 8, ...
         'FontWeight', 'bold', ...
         'Color', [0.85 0 0]);
end

hold(ax6,'off');

xlabel(ax6,'Cross-range (m)', 'FontWeight','bold');
ylabel(ax6,'Range (m)', 'FontWeight','bold');
title(ax6,'Point Cloud Map: Truth vs Detected Targets', ...
    'FontWeight','bold');

legend(ax6, [h_truth, h_det], {'Truth','Detected'}, ...
       'Location','northwest', ...
       'FontSize',8);

axis(ax6,'equal');
grid(ax6,'on');
ax6.GridLineStyle = '-';
ax6.GridAlpha = 0.25;
set(ax6, 'FontSize', 9, 'LineWidth', 0.8);

% Add margin around points
x_all = [x_truth; x_det];
y_all = [y_truth; y_det];

xlim(ax6, [min(x_all)-5, max(x_all)+5]);
ylim(ax6, [min(y_all)-5, max(y_all)+5]);

%% =========================================================
%  Print detection summary
%% =========================================================

fprintf('\n=== Detection Summary ===\n');
fprintf('%-6s %-12s %-12s %-12s %-14s %-14s %-10s %-10s\n', ...
        'Det#','R_det','R_true','R_err','az_DFT','az_truth','V_det','V_true');

for k = 1:num_dets
    [~,ti] = min(abs(target_dist - detected_targets(k,1)));

    r_det = detected_targets(k,1);
    r_true = target_dist(ti);
    r_err = r_det - r_true;

    az_det = detected_targets(k,3);
    az_true = target_az(ti);

    v_det = detected_targets(k,2);
    v_true = truth_targets(ti,2);

    fprintf('%-6d %-12.3f %-12.3f %-12.3f %-14.3f %-14.3f %-10.3f %-10.3f\n', ...
            k, r_det, r_true, r_err, az_det, az_true, v_det, v_true);
end

%% =========================================================
%  Save all figures — PDF only
%% =========================================================

figs  = {f1, f2, f3, f4, f5, f6};

names = {'fig1_range_profiles', ...
         'fig2_RDM_single', ...
         'fig3_RDM_fused', ...
         'fig4_raw_CFAR_detections', ...
         'fig5_grouped_CFAR_detections', ...
         'fig6_PCM'};

fprintf('\nSaving PDF figures to folder: %s\n', out_folder);

for k = 1:length(figs)

    pdf_path = fullfile(out_folder, [names{k} '.pdf']);

    exportgraphics(figs{k}, pdf_path, ...
        'ContentType', 'vector', ...
        'BackgroundColor', 'white');

    fprintf('  Saved: %s.pdf\n', names{k});
end

fprintf('\nDone. 6 PDF figures saved in: %s\n', out_folder);
fprintf('For LaTeX example: \\includegraphics[width=\\columnwidth]{%s/%s.pdf}\n', ...
        out_folder, names{1});

%% =========================================================
%  Restore default figure settings
%% =========================================================

set(groot, ...
    'defaultAxesFontName',   'Helvetica', ...
    'defaultAxesFontSize',   10, ...
    'defaultTextFontName',   'Helvetica', ...
    'defaultLineLineWidth',  0.5, ...
    'defaultAxesLineWidth',  0.5, ...
    'defaultAxesBox',        'on', ...
    'defaultAxesTickDir',    'in', ...
    'defaultAxesTickLength', [0.01 0.025]);