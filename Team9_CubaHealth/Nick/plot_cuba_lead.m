% plot_cuba_lead.m
% Plot reported lead in drinking water at consumer taps in Cuba, New Mexico.
% Both CSV files must be in the same directory as this MATLAB script.
% 90th-percentile data are NOT mean household exposure or blood-lead values.
% Each time-series marker is placed at the END of its sampling period.
% For Jan-Jun and Jul-Dec 2025, these are period ends, NOT exact collection dates.
% The neighboring community values have different sample years.  See the CSV.

clear; clc; close all;
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end

T = readtable(fullfile(scriptDir,'cuba_nm_lead_chronological.csv'), 'TextType','string');
C = readtable(fullfile(scriptDir,'nm_nearby_lead_comparison.csv'), 'TextType','string');

% Parse dates robustly even if readtable has already inferred datetime.
if isdatetime(T.period_end)
    dates = T.period_end;
else
    dates = datetime(string(T.period_end),'InputFormat','yyyy-MM-dd');
end
[dates,idx] = sort(dates);
T = T(idx,:);

% Reference thresholds, in micrograms per liter (approximately ppb).
currentAL = 15;  % EPA action level for the periods in these reports
futureAL  = 10;  % Revised action level, beginning Nov 1, 2027 (not 2025)

figure('Color','w','Position',[120 100 1180 780]);
tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

% Figure 1: Cuba historical observations.
nexttile;
plot(dates,T.lead_90th_ppb,'-o','LineWidth',2,'MarkerSize',9); hold on;
plot(dates,T.lead_max_ppb,'--^','LineWidth',1.5,'MarkerSize',8);
yline(currentAL,':','15 ppb action level (in force for samples)',...
    'LineWidth',1.8,'LabelHorizontalAlignment','left');
yline(futureAL,':','10 ppb revised action level (2027)',...
    'LineWidth',1.5,'LabelHorizontalAlignment','left');
for k = 1:height(T)
    text(dates(k),T.lead_90th_ppb(k)+0.6,...
        sprintf('%.1f',T.lead_90th_ppb(k)),...
        'HorizontalAlignment','center','FontSize',10);
end
xlabel('End date of sampling period (not necessarily date sample was collected)');
ylabel('Lead concentration (ppb)');
title('Cuba, NM: lead at consumer taps (oldest to newest)');
legend({'90th percentile','Highest reported sample','15-ppb AL','10-ppb future AL'},...
    'Location','northwest');
grid on;
ylim([0 max(24,1.1*max(T.lead_max_ppb))]);

% Figure 2: Selected surrounding utilities; sample years not identical.
nexttile;
x = 1:height(C);
bar(x,C.lead_90th_ppb,0.62); hold on;
xticks(x);
xticklabels(cellstr(C.community));
yline(currentAL,':','15 ppb (2025 action level)','LineWidth',1.8);
yline(futureAL,':','10 ppb (2027 revised level)','LineWidth',1.5);
for k = 1:height(C)
    text(x(k),C.lead_90th_ppb(k)+0.35,...
        sprintf('%.1f ppb (%s)',C.lead_90th_ppb(k),C.sampling_period(k)),...
        'HorizontalAlignment','center','FontSize',9);
end
ylim([0 17.5]);
ylabel('90th-percentile lead (ppb)');
title('Selected NM utility comparison (different sampling years; not a matched study)');
grid on;

% Print a precise text summary and expose inconsistencies in the source.
fprintf('\nCUBA, NM: LEAD (90th percentile)\n');
for k=1:height(T)
    fprintf('  %-14s : %5.1f ppb (highest sample %5.1f ppb)\n',...
        char(T.sampling_period(k)),T.lead_90th_ppb(k),T.lead_max_ppb(k));
end
fprintf('\nWARNING: Uploaded Cuba reports mark lead rows as "Exceeds AL: Yes"\n');
fprintf('even when the 90th percentile is below 15 ppb and report 0 samples\n');
fprintf('above AL. In Jul-Dec 2025 the high is 21 ppb, adding a conflict.\n');
fprintf('Ask NMED or Cuba Water System to reconcile the reported columns.\n');

% Save a shareable PNG (optional: uncomment the line below).
% exportgraphics(gcf,fullfile(scriptDir,'cuba_nm_lead_plot.png'),'Resolution',200);
