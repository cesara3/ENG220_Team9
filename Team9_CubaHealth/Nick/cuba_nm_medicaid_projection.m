% Cuba, NM: illustrative Medicaid coverage-loss scenarios
% Population / Medicaid share: Data USA 2024
% https://datausa.io/profile/geo/cuba-nm
% Statewide figures: NM Health Care Authority projections reported Aug 31 2026
% https://dukecityledger.com/news/nm-medicaid-work-requirements/
% Policy starts Jan 1 2027 in NM:
% https://www.hsd.state.nm.us/medicaidchanges/
% NOT a predictive forecast. Scenario rates and replacement-coverage assumptions
% should be revised when local eligibility/enrollment data become available.
clear; clc; close all;
population = 462;
medicaidFraction = 0.398;
baselineUninsuredFraction = 0.0519;
stateMedicaid = 825287;
statePotentiallyAffected = 230000;
stateWorkRuleLosses = 89000;
medicaidCount = round(population*medicaidFraction);
baselineUninsured = round(population*baselineUninsuredFraction);
localAffected = round(medicaidCount * statePotentiallyAffected / stateMedicaid);
scenarioName = ["Low"; "Central (state-rate)"; "High"];
% Fraction of potentially affected Medicaid recipients who lose Medicaid:
lossFraction = [0.20; stateWorkRuleLosses/statePotentiallyAffected; 0.60];
% Fraction of those who lose Medicaid who obtain no replacement insurance:
noReplacementFraction = [0.50; 0.75; 1.00];
medicaidLosses = round(localAffected * lossFraction);
newlyUninsured = round(medicaidLosses .* noReplacementFraction);
totalUninsured = baselineUninsured + newlyUninsured;
uninsuredPct = 100*totalUninsured/population;
results = table(scenarioName, repmat(medicaidCount,3,1), ...
 repmat(localAffected,3,1), lossFraction, noReplacementFraction, ...
 medicaidLosses, newlyUninsured, totalUninsured, uninsuredPct, ...
 'VariableNames', {'Scenario','EstimatedMedicaid2024', ...
 'PotentiallyAffected','LossFraction','NoReplacementFraction', ...
 'MedicaidLosses','NewlyUninsured','TotalUninsured','TotalUninsuredPct'});
disp(results)
writetable(results, 'cuba_nm_medicaid_projection_from_matlab.csv');
figure('Color','w');
b = bar(categorical(scenarioName), [medicaidLosses newlyUninsured], 'grouped');
ylabel('Estimated number of residents');
title('Cuba, NM: Illustrative Medicaid changes after January 2027');
legend({'Potential Medicaid losses','Newly uninsured'},'Location','northwest');
grid on;
% Interpret as sensitivity scenarios, not local predictions; important local exemptions apply.
