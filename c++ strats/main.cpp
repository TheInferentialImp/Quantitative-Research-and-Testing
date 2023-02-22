// Author: Alexander Yousif (730622857)
// BT V1.0 C++
#include <iostream>
#include <cmath>
#include <fstream>
using namespace std;
// Define function to calculate Bollinger Bands
void calcBollingerBands(double *price, int n, double &upperBand,
double &lowerBand) {
    double sum = 0.0, sumSquared = 0.0, mean = 0.0, sd = 0.0;
    int m = 20;  // number of periods to calculate mean and standard deviation
    for (int i = 0; i < m; i++) {
        sum += price[i];
        sumSquared += pow(price[i], 2);
    }
    mean = sum / m;
    sd = sqrt((sumSquared - pow(sum, 2) / m) / (m - 1));
    upperBand = mean + 2 * sd;
    lowerBand = mean - 2 * sd;
}
// Define function to calculate momentum
double calcMomentum(double *price, int n) {
    double momentum = price[n - 1] - price[0];
    return momentum;
}
// Define function to calculate moving average
double calcMovingAverage(double *price, int n) {
    double sum = 0.0, movingAverage = 0.0;
    int m = 10;  // number of periods to calculate moving average
    for (int i = n - m; i < n; i++) {
        sum += price[i];
    }
    movingAverage = sum / m;
    return movingAverage;
}
// Define function to calculate RSI
double calcRSI(double *price, int n) {
    double sumGain = 0.0, sumLoss = 0.0, RS = 0.0, RSI = 0.0;
    int m = 14;  // number of periods to calculate RSI
    for (int i = 1; i <= m; i++) {
        if (price[i] > price[i-1]) {
            sumGain += price[i] - price[i-1];
        } else {
            sumLoss += price[i-1] - price[i];
 
} }
    for (int i = m + 1; i < n; i++) {
        if (price[i] > price[i-1]) {
            sumGain += price[i] - price[i-1];
        } else {
            sumLoss += price[i-1] - price[i];
        }
        RS = sumGain / sumLoss;
        RSI = 100 - 100 / (1 + RS);
    }
return RSI; }
// Define function to check for gap up or gap down
bool checkGap(double *price, int n) {
    bool gap = false;
    double openPrice = price[0];
    double prevClose = price[1];
    double currOpen = price[2];
    if (currOpen > prevClose) {
gap = true; }
return gap; }
// Define function to calculate FRAMA
double calcFRAMA(double *price, int n) {
    double alpha = 0.01;
    double frama = price[0];
    double framaLong = frama;
    double framaShort = frama;
    double delta = 0.5;
    for (int i = 1; i < n; i++) {
        double diff = abs(price[i] - frama);
        framaLong = alpha * price[i] + (1 - alpha) * framaLong;
        framaShort = delta * (price[I] + (1 - delta) * framaShort
        price[i] - price[i-1]) + (1 - delta) * framaShort;
        if (diff != 0) {
            alpha = pow(delta / diff, 2);
        }
        frama = alpha * price[i] + (1 - alpha) * frama;
    }
    return frama;
}
// Define function to calculate VWAP
double calcVWAP(double *price, double *volume, int n) {
    double sumPV = 0.0, sumV = 0.0, vwap = 0.0;
    for (int i = 0; i < n; i++) {
 
        sumPV += price[i] * volume[i];
        sumV += volume[i];
    }
    vwap = sumPV / sumV;
    return vwap;
}
// Define function to calculate volatility
double calcVolatility(double *price, int n) {
    double sum = 0.0, sumSquared = 0.0, mean = 0.0, sd = 0.0,
volatility = 0.0;
    int m = 20;  // number of periods to calculate mean and standard
deviation
    for (int i = 0; i < m; i++) {
        sum += price[i];
        sumSquared += pow(price[i], 2);
    }
    mean = sum / m;
    sd = sqrt((sumSquared - pow(sum, 2) / m) / (m - 1));
    volatility = sd / mean;
    return volatility;
}
// Define function to calculate stop loss
double calcStopLoss(double *price, int n) {
    double stopLoss = 0.0;
    double atr = 0.0;
    double tr = 0.0;
    double sumTR = 0.0;
    int m = 20;  // number of periods to calculate ATR
    for (int i = 1; i < m; i++) {
        tr = max(max(price[i] - price[i-1], abs(price[i] -
price[i-1])), abs(price[i] - price[i-1]));
sumTR += tr; }
    atr = sumTR / m;
    stopLoss = price[n-1] - 2 * atr;
    return stopLoss;
}
// Define function to calculate portfolio value
double calcPortfolioValue(double *price, double *position, double
cash, int n) {
    double portfolioValue = 0.0;
    for (int i = 0; i < n; i++) {
        portfolioValue += position[i] * price[i];
    }
    portfolioValue += cash;
    return portfolioValue;
}
 
 // Define function to calculate total return
double calcTotalReturn(double *price, double *position, double cash,
int n) {
    double totalReturn = 0.0;
    double portfolioValueStart = calcPortfolioValue(price, position,
cash, 0);
    double portfolioValueEnd = calcPortfolioValue(price, position,
cash, n);
    totalReturn = (portfolioValueEnd - portfolioValueStart) /
portfolioValueStart;
    return totalReturn;
}
// Define function to calculate annualized return
double calcAnnualizedReturn(double *price, double *position, double
cash, int n, int years) {
    double totalReturn = calcTotalReturn(price, position, cash, n);
    double annualizedReturn = pow(1 + totalReturn, 1.0 / years) - 1;
    return annualizedReturn;
}
// Define function to calculate volatility
double calcVolatility(double *price, int n) {
    double sum = 0.0, sumSquared = 0.0, mean = 0.0, sd = 0.0,
volatility = 0.0;
    int m = 20;  // number of periods to calculate mean and standard
deviation
    for (int i = 0; i < m; i++) {
        sum += price[i];
        sumSquared += pow(price[i], 2);
    }
    mean = sum / m;
    sd = sqrt((sumSquared - pow(sum, 2) / m) / (m - 1));
    volatility = sd / mean;
    return volatility;
}
// Define function to calculate stop loss
double calcStopLoss(double *price, int n) {
    double stopLoss = 0.0;
    double atr = 0.0;
    double tr = 0.0;
    double sumTR = 0.0;
    int m = 20;  // number of periods to calculate ATR
    for (int i = 1; i < m; i++) {
        tr = max(max(price[i] - price[i-1], abs(price[i] -
price[i-1])), abs(price[i] - price[i-1]));
sumTR += tr; }

    atr = sumTR / m;
    stopLoss = price[n-1] - 2 * atr;
    return stopLoss;
}
// Define function to calculate portfolio value
double calcPortfolioValue(double *price, double *position, double
cash, int n) {
    double portfolioValue = 0.0;
    for (int i = 0; i < n; i++) {
        portfolioValue += position[i] * price[i];
    }
    portfolioValue += cash;
    return portfolioValue;
}
// Define function to calculate total return
double calcTotalReturn(double *price, double *position, double cash,
int n) {
    double totalReturn = 0.0;
    double portfolioValueStart = calcPortfolioValue(price, position,
cash, 0);
    double portfolioValueEnd = calcPortfolioValue(price, position,
cash, n);
    totalReturn = (portfolioValueEnd - portfolioValueStart) /
portfolioValueStart;
    return totalReturn;
}
// Define function to calculate annualized return
double calcAnnualizedReturn(double *price, double *position, double
cash, int n, int years) {
    double totalReturn = calcTotalReturn(price, position, cash, n);
    double annualizedReturn = pow(1 + totalReturn, 1.0 / years) - 1;
    return annualizedReturn;
}
// Define function to calculate volatility
double calcVolatility(double *price, int n) {
    double sum = 0.0, sumSquared = 0.0, mean = 0.0, sd = 0.0,
volatility = 0.0;
    int m = 20;  // number of periods to calculate mean and standard deviation
    for (int i = 0; i < m; i++) {
        sum += price[i];
        sumSquared += pow(price[i], 2);
    }
    mean = sum / m;
    sd = sqrt((sumSquared - pow(sum, 2) / m) / (m - 1));
    volatility = sd / mean;
 
    return volatility;
}
// Define function to calculate max drawdown
double calcMaxDrawdown(double *price, int n) {
    double maxPrice = price[0], maxDrawdown = 0.0;
    for (int i = 1; i < n; i++) {
        double drawdown = (price[i] - maxPrice) / maxPrice;
        if (drawdown < maxDrawdown) {
            maxDrawdown = drawdown;
        }
        if (price[i] > maxPrice) {
            maxPrice = price[i];
} }
    return maxDrawdown;
}
int main() {
    // Define parameters
    int n = 100;  // number of periods
    double price[n];
    double momentum[n];
    double bollingerBandsUpper[n], bollingerBandsLower[n];
    double volume[n];
    double movingAverage[n];
    double rsi[n];
    double gap[n];
    double framaShort[n], framaLong[n];
    double vwap[n];
    double volatility[n];
    double stopLoss = 0.0;
    double position[n];
    double cash = 10000.0;
    double portfolioValue = 0.0;
    // Define input data
    for (int i = 0; i < n; i++) {
        price[i] = 100.0 + (double)i;
    }
    // Calculate indicators
    calcMomentum(price, momentum, n);
    calcBollingerBands(price, bollingerBandsUpper,
bollingerBandsLower, n);
    calcVolume(price, volume, n);
    calcMovingAverage(price, movingAverage, n);
    calcRSI(price, rsi, n);
    calcGap(price, gap, n);
    calcFRAMA(price, framaShort, framaLong, n);
 
    calcVWAP(price, volume, vwap, n);
    calcVolatility(price, volatility, n);
    // Define trading strategy
    for (int i = 0; i < n; i++) {
        if (price[i] < bollingerBandsLower[i] && momentum[i] > 0 &&
volume[i] > 0) {
            position[i] = cash * 0.25 / price[i];
            cash -= position[i] * price[i];
        } else if (price[i] > bollingerBandsUpper[i] && momentum[i] <
0 && volume[i] > 0) {
            position[i] = -1 * cash * 0.25 / price[i];
            cash += position[i] * price[i];
        } else {
            position[i] = 0.0;
        }
        // Check stop loss
        if (price[i] < stopLoss) {
            position[i] = 0.0;
            cash += price[i] * position[i];
        }
        // Calculate portfolio value
        portfolioValue = calcPortfolioValue(price, position, cash, i);
        // Output results
        printf("Day %d: Price=%.2f, Position=%.2f, Cash=%.2f,
Portfolio Value=%.2f\n", i, price[i], position[i], cash,
portfolioValue);
}
    // Calculate and output performance metrics
    double totalReturn = calcTotalReturn(price, position, cash, n);
    printf("Total return: %.2f%%\n", totalReturn * 100);
    double annualizedReturn = calcAnnualizedReturn(price, position,
cash, n, 1);
    printf("Annualized return: %.2f%%\n", annualizedReturn * 100);
    double volatilityAnnualized = calcVolatility(price, n) *
sqrt(252);
    printf("Volatility: %.2f%%\n", volatilityAnnualized * 100);
    double sharpeRatio = calcSharpeRatio(price, position, cash, n, 1);
    printf("Sharpe ratio: %.2f\n", sharpeRatio);
    double maxDrawdown = calcMaxDrawdown(price, n);
    printf("Max drawdown: %.2f%%\n", maxDrawdown * 100);
 
return 0; }