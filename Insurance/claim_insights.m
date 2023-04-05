% This script performs data analysis and visualization on claims data.
% The libraries used in this code are pandas, numpy, matplotlib, seaborn, and geopandas.
% Pandas is used for data manipulation and analysis, numpy is used for numerical operations, matplotlib is used for data visualization, seaborn is used for creating more sophisticated visualizations, and geopandas is used for creating maps.

% Set figure size for visualizations
figure('Position', [0 0 1200 300]);

% read in data from Excel file
claims_data = readtable('data.xlsx');

% convert column names to snake_case
claims_data.Properties.VariableNames = lower(string(claims_data.Properties.VariableNames));

% calculate reporting_lag in days
claims_data.reporting_lag = daysact(datetime(claims_data.loss_date), datetime(claims_data.reported_date));

% select relevant columns
claims_data = claims_data(:, {'claim_number', 'cat_event', 'mga', 'tpa', 'cause_of_loss', 'loss_date', 'reported_date', ...
'closed_date', 'transaction_period', 'total_paid', 'total_reserve', 'total_incurred', ...
'total_outstanding', 'loss_state'});

% Distribution of claims by CAT Event
cat_event_dist = sortrows(groupsummary(claims_data, 'cat_event', {'count', 'sum'}, 'total_incurred'), -2);

% Percentage of claims with no close date
percent_unclosed_claims = sum(isnat(claims_data.closed_date)) / height(claims_data) * 100;

% Value of unclosed claims
value_unclosed_claims = sum(claims_data.total_outstanding(isnat(claims_data.closed_date)));

% Time to close claims
claims_data.closed_date = datetime(claims_data.closed_date, 'InputFormat', 'MM/dd/yyyy');
claims_data.reported_date = datetime(claims_data.reported_date, 'InputFormat', 'MM/dd/yyyy');
claims_data.loss_date = datetime(claims_data.loss_date, 'InputFormat', 'MM/dd/yyyy');
claims_data.time_to_close = claims_data.closed_date - claims_data.reported_date;
time_to_close = sortrows(groupsummary(claims_data, 'tpa', 'mean', 'time_to_close'));

% Total Incurred by MGA and TPA
total_incurred_by_mga_tpa = sortrows(groupsummary(claims_data, {'mga', 'tpa'}, 'sum', 'total_incurred'), -3);

% Causes of Loss
causes_of_loss = sortrows(groupsummary(claims_data, 'cause_of_loss', {'count', 'sum'}, 'total_incurred'), -2);

% Distribution of claims by Loss State
loss_state_dist = sortrows(groupsummary(claims_data, 'loss_state', {'count', 'sum'}, 'total_incurred'), -2);

% Total Incurred by Transaction Period
total_incurred_by_transaction_period = sortrows(groupsummary(claims_data, 'transaction_period', 'sum', 'total_incurred'));

% Total Paid vs Total Reserve
total_paid_vs_total_reserve = table(sum(claims_data.total_paid), sum(claims_data.total_reserve), 'VariableNames', {'total_paid', 'total_reserve'});

% Top Claims by Total Incurred
top_claims_by_total_incurred = sortrows(claims_data(:, {'claim_number', 'mga', 'tpa', 'total_incurred'}), -4);
top_claims_by_total_incurred = top_claims_by_total_incurred(1:10, :);

% Create a heatmap
total_incurred_by_state = groupsummary(claims_data, 'loss_state', 'sum', 'total_incurred');
states = geoshape(shaperead('usastatehi', 'UseGeoCoords', true));
heatmap_fig = figure('Position', [0 0 800 600]);
heatmap_ax = axes(heatmap_fig);
heatmap_ax.NextPlot = 'add';
heatmap_ax.XLim = [-128 -65];
heatmap_ax.YLim = [24 50];
heatmap_ax.Box = 'on';
title(heatmap_ax, 'Total Incurred by State', 'FontSize', 14);
heatmap(heatmap_ax, states, 'Colormap', parula, 'ColorLimits', [min(total_incurred_by_state.sum_total_incurred), max(total_incurred_by_state.sum_total_incurred)], 'UseLogColorMap', false, 'GridVisible', 'off', 'NaNColor', [0.7 0.7 0.7], 'Data', total_incurred_by_state.sum_total_incurred);
colorbar('southoutside');
xlabel(heatmap_ax, 'Longitude', 'FontSize', 12);
ylabel(heatmap_ax, 'Latitude', 'FontSize', 12);

% Save the heatmap as a PNG file
saveas(heatmap_fig, 'heatmap.png');

% Create a bar chart showing the distribution of claims by CAT Event
cat_event_fig = figure('Position', [0 0 800 600]);
cat_event_ax = axes(cat_event_fig);
cat_event_ax.NextPlot = 'add';
bar(cat_event_ax, cat_event_dist.cat_event, cat_event_dist.sum_total_incurred, 'FaceColor', [0.2 0.2 0.2], 'EdgeColor', 'none');
title(cat_event_ax, 'Distribution of Claims by CAT Event', 'FontSize', 14);
xlabel(cat_event_ax, 'CAT Event', 'FontSize', 12);
ylabel(cat_event_ax, 'Total Incurred ($)', 'FontSize', 12);
cat_event_ax.XTickLabelRotation = 45;

% Save the bar chart as a PNG file
saveas(cat_event_fig, 'cat_event_distribution.png');

% Create a pie chart showing the percentage of claims with no close date
unclosed_claims_fig = figure('Position', [0 0 800 600]);
unclosed_claims_ax = axes(unclosed_claims_fig);
unclosed_claims_ax.NextPlot = 'add';
pie(unclosed_claims_ax, [percent_unclosed_claims, 100 - percent_unclosed_claims], {'Unclosed Claims', 'Closed Claims'}, [0.2 0.2 0.2; 0.7 0.7 0.7]);
title(unclosed_claims_ax, 'Percentage of Claims with No Close Date', 'FontSize', 14);

% Save the pie chart as a PNG file
saveas(unclosed_claims_fig, 'unclosed_claims.png');

% Create a bar chart showing the average time to close claims by TPA
time_to_close_fig = figure('Position', [0 0 800 600]);
time_to_close_ax = axes(time_to_close_fig);
time_to_close_ax.NextPlot = 'add';
bar(time_to_close_ax, time_to_close.tpa, days(time_to_close.mean_time_to_close), 'FaceColor', [0.2 0.2 0.2], 'EdgeColor', 'none');
title(time_to_close_ax, 'Average Time to Close Claims by TPA', 'FontSize', 14);
xlabel(time_to_close_ax, 'TPA', 'FontSize', 12);
ylabel(time_to_close_ax, 'Time to Close (Days)', 'FontSize', 12);

% Create a bar plot of total incurred by MGA and TPA
figure('Position', [0 0 800 300]);
bplot = bar(total_incurred_by_mga_tpa.total_incurred);
bplot.FaceColor = 'flat';
bplot.CData(1, :) = [0.2 0.2 1]; % MGA color
bplot.CData(2, :) = [1 0.2 0.2]; % TPA color
xticklabels(strrep(string(total_incurred_by_mga_tpa.mga_tpa), '_', ' '));
xlabel('MGA/TPA', 'FontSize', 12);
ylabel('Total Incurred', 'FontSize', 12);
title('Total Incurred by MGA and TPA', 'FontSize', 14);

% Create a bar plot of total incurred by transaction period
figure('Position', [0 0 800 300]);
bplot = bar(total_incurred_by_transaction_period.total_incurred);
bplot.FaceColor = 'flat';
bplot.CData(1, :) = [0.2 0.2 1]; % Jan-Mar 2021 color
bplot.CData(2, :) = [0.2 1 0.2]; % Apr-Jun 2021 color
bplot.CData(3, :) = [1 0.2 0.2]; % Jul-Sep 2021 color
xticklabels(string(total_incurred_by_transaction_period.transaction_period));
xlabel('Transaction Period', 'FontSize', 12);
ylabel('Total Incurred', 'FontSize', 12);
title('Total Incurred by Transaction Period', 'FontSize', 14);

% Create a bar plot of top claims by total incurred
figure('Position', [0 0 800 300]);
bplot = bar(top_claims_by_total_incurred.total_incurred);
xticklabels(string(top_claims_by_total_incurred.claim_number));
xlabel('Claim Number', 'FontSize', 12);
ylabel('Total Incurred', 'FontSize', 12);
title('Top Claims by Total Incurred', 'FontSize', 14);

% Create a scatter plot of total incurred vs total paid
figure('Position', [0 0 800 400]);
scatter(claims_data.total_paid, claims_data.total_incurred);
xlabel('Total Paid', 'FontSize', 12);
ylabel('Total Incurred', 'FontSize', 12);
title('Total Paid vs Total Incurred', 'FontSize', 14);

% Create a scatter plot of total incurred vs total reserve
figure('Position', [0 0 800 400]);
scatter(claims_data.total_reserve, claims_data.total_incurred);
xlabel('Total Reserve', 'FontSize', 12);
ylabel('Total Incurred', 'FontSize', 12);
title('Total Reserve vs Total Incurred', 'FontSize', 14);

% Create a donut chart of causes of loss
figure('Position', [0 0 800 400]);
pie(causes_of_loss.total_incurred, causes_of_loss.cause_of_loss);
title('Causes of Loss', 'FontSize', 14);


disp('Data analysis and visualization completed successfully.');