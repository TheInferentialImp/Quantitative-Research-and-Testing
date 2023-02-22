% Author: Alexander Yousif (730622857)
% This is a simple backtesting strategy written using MATLAB that implements 
% max. holding period, stop loss, take profit, and s/f moving average features.
% It will output a graphical representation of our profit and loss for each stock.
% It will only enter trades when a stock x's volume is above an n threshold.

% Load the data
data = csvread('data.csv'); % Replace with actual data for 10 blue-chip stocks
volume = csvread('volume.csv'); % Replace with actual volume data for 10 blue-chip stocks

% Initialize variables
numStocks = size(data, 2); % Number of stocks
position = zeros(1, numStocks); % 0 = flat, 1 = long, -1 = short
pnl = zeros(1, numStocks); % Profit and loss for each stock

% Define the trading strategy
SMA_fast = 50; % Fast moving average
SMA_slow = 200; % Slow moving average
stop_loss = 0.05; % Stop loss threshold
take_profit = 0.1; % Take profit threshold
max_holding_period = 100; % Maximum holding period
min_volume = 1000000; % Minimum volume threshold

% Loop through the data
for i = max(SMA_fast, SMA_slow):size(data, 1)
    % Calculate moving averages
    SMA_fast_data = movmean(data(:, :), SMA_fast);
    SMA_slow_data = movmean(data(:, :), SMA_slow);
    
    % Loop through each stock
    for j = 1:numStocks
        % Check for entry conditions
        if SMA_fast_data(i, j) > SMA_slow_data(i, j) && position(j) <= 0 && volume(i, j) > min_volume
            position(j) = 1;
            buy_price(j) = data(i, j);
            holding_period(j) = 1;
        % Check for exit conditions
        elseif position(j) == 1
            holding_period(j) = holding_period(j) + 1;
            if data(i, j) / buy_price(j) < (1 - stop_loss) || data(i, j) / buy_price(j) > (1 + take_profit) || holding_period(j) >= max_holding_period
                position(j) = 0;
                sell_price(j) = data(i, j);
                pnl(j) = pnl(j) + sell_price(j) - buy_price(j);
            end
        end
    end
end

% Plot the results
figure;
for j = 1:numStocks
    subplot(numStocks, 1, j);
    plot(pnl(j));
    xlabel('Time');
    ylabel(['Profit and Loss for Stock ', num2str(j)]);
    title(['Backtesting Results for Stock ', num2str(j)]);
end