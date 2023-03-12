import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.tsa.arima.model import ARIMA

# Load the data
sales_data = pd.read_csv('/Users/onyx/Downloads/cb_2018_us_state_500k/airline-passengers.csv', header=0, index_col=0, squeeze=True, parse_dates=True)
sales_data.index.freq = 'MS'

# Visualize the data
plt.plot(sales_data)
plt.title('Shampoo Sales Time Series')
plt.xlabel('Month')
plt.ylabel('Sales')
plt.show()

# Take the first difference to remove the trend
sales_diff = sales_data.diff().dropna()

# Fit an ARIMA(1,1,1) model to the data
model = ARIMA(sales_diff, order=(1,1,1), enforce_stationarity=False)
results = model.fit()

# Print the model summary
print(results.summary())

# Split the data into training and testing sets
train_size = int(len(sales_diff) * 0.7)
train, test = sales_diff[:train_size], sales_diff[train_size:]

# Fit the ARIMA model to the training data
model = ARIMA(train, order=(1,1,1))
results = model.fit()

# Use the ARIMA model to make predictions on the test data
predictions_diff = results.predict(start=len(train), end=len(train)+50, typ='levels')

# Add the differenced predictions back to the last value of the training set to get the actual predictions
predictions = np.cumsum(predictions_diff) + sales_diff.iloc[-1]

# Plot the original time series, differenced time series, and predicted values
plt.plot(sales_data.index, sales_data.values, label='Original')
plt.plot(predictions.index, predictions.values, label='Predicted')
plt.title('Shampoo Sales Time Series Prediction')
plt.xlabel('Month')
plt.ylabel('Sales')
plt.legend()
plt.show()
