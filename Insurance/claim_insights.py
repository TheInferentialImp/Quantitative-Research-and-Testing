"""README."""
# Alexander Yousif
# University of North Carolina at Chapel Hill
# PID: 730622857
"""
Calculates:
Reporting_lag in days by subtracting the Loss_Date from the Reported_Date using pandas' to_datetime and dt.days functions.
Distribution of claims by CAT_Event and sorts the data frame in descending order based on the count of claims.
Percentage and value of unclosed claims.
Average time to close claims by TPA.
Total incurred by MGA and TPA and sorts the data frame in descending order based on the total incurred.
Count and total incurred by cause of loss and sorts the data frame in descending order based on the count of claims.
Count and total incurred by loss state and sorts the data frame in descending order based on the count of claims.
Total incurred by transaction period and sorts the data frame in ascending order based on the transaction period.
Total paid and total reserve.
Top 10 claims by total incurred and sorts the data frame in descending order based on the total incurred.
Creates a pivot table of the total incurred by loss state and creates a heatmap using seaborn's heatmap function.
Visualizes:
Distribution of claims by CAT Event using pandas' plot function.
Causes of loss using seaborn's barplot function.
Top claims by total incurred using pandas' plot function.
Writes all data to a text file called insights.txt created in the directory in which the script is executed.
The libraries used in this code are pandas, numpy, matplotlib, and seaborn. Pandas is used for data manipulation and analysis, numpy is used for numerical operations, matplotlib is used for data visualization, and seaborn is used for creating more sophisticated visualizations.
""",

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import geopandas as gpd
plt.rcParams['figure.figsize'] = [30, 7.5]
# read in data from Excel file
claims_data = pd.read_excel("/Users/onyx/Documents/Quantitative-Research-and-Testing/data.xlsx") # replace with actual claims data

# convert column names to snake_case
claims_data.columns = claims_data.columns.str.replace(" ", "_")

# calculate reporting_lag in days
claims_data["reporting_lag"] = (pd.to_datetime(claims_data["Reported_Date"], format="%m/%d/%Y") 
                                - pd.to_datetime(claims_data["Loss_Date"], format="%m/%d/%Y")).dt.days

# select relevant columns
claims_data = claims_data[["Claim_Number", "CAT_Event", "MGA", "TPA", "Cause_of_Loss", "Loss_Date", "Reported_Date", 
                           "Closed_Date", "Transaction_Period", "Total_Paid", "Total_Reserve", "Total_Incurred", 
                           "Total_Outstanding", "Loss_State"]]

# Distribution of claims by CAT Event
cat_event_dist = claims_data.groupby("CAT_Event").agg(count_claims=("Claim_Number", "count"),
                                                      total_incurred=("Total_Incurred", "sum")).sort_values(
    "count_claims", ascending=False).reset_index()

# Percentage of claims with no close date
percent_unclosed_claims = claims_data['Closed_Date'].isna().sum() / len(claims_data) * 100

# Value of unclosed claims
value_unclosed_claims = claims_data.loc[claims_data['Closed_Date'].isna(), 'Total_Outstanding'].sum()

# Time to close claims
claims_data['Closed_Date'] = pd.to_datetime(claims_data['Closed_Date'], format='%m/%d/%Y')
claims_data['Reported_Date'] = pd.to_datetime(claims_data['Reported_Date'], format='%m/%d/%Y')
claims_data['Loss_Date'] = pd.to_datetime(claims_data['Loss_Date'], format='%m/%d/%Y')
claims_data['time_to_close'] = claims_data['Closed_Date'] - claims_data['Reported_Date']
time_to_close = claims_data.groupby('TPA').agg(avg_time_to_close=('time_to_close', 'mean')).reset_index().sort_values('avg_time_to_close')

# Total Incurred by MGA and TPA
total_incurred_by_mga_tpa = claims_data.groupby(['MGA', 'TPA']).agg(total_incurred=('Total_Incurred', 'sum')).reset_index().sort_values('total_incurred', ascending=False)

# Causes of Loss
causes_of_loss = claims_data.groupby('Cause_of_Loss').agg(count_claims=('Claim_Number', 'count'), total_incurred=('Total_Incurred', 'sum')).reset_index().sort_values('count_claims', ascending=False)

# Distribution of claims by Loss State
loss_state_dist = claims_data.groupby('Loss_State').agg(count_claims=('Claim_Number', 'count'), total_incurred=('Total_Incurred', 'sum')).reset_index().sort_values('count_claims', ascending=False)

# Total Incurred by Transaction Period
total_incurred_by_transaction_period = claims_data.groupby('Transaction_Period').agg(total_incurred=('Total_Incurred', 'sum')).reset_index().sort_values('Transaction_Period')

# Total Paid vs Total Reserve
total_paid_vs_total_reserve = claims_data.agg(total_paid=('Total_Paid', 'sum'), total_reserve=('Total_Reserve', 'sum'))

# Top Claims by Total Incurred
top_claims_by_total_incurred = claims_data.sort_values('Total_Incurred', ascending=False).loc[:, ['Claim_Number', 'MGA', 'TPA', 'Total_Incurred']].head(10)

# Create a heatmap
total_incurred_by_state = pd.pivot_table(data=claims_data, values='Total_Incurred', index='Loss_State', aggfunc='sum')
total_incurred_by_state = total_incurred_by_state.sort_values('Total_Incurred', ascending=False)
sns.heatmap(data=total_incurred_by_state, cmap='YlOrRd', annot=True, fmt='.2f', linewidths=.5)
plt.title('Total Incurred by State')
plt.ylabel('Loss State')
plt.show()

# Create a heat geo-map(USA) with total incurred by state
usa = '/Users/onyx/Downloads/cb_2018_us_state_500k/cb_2018_us_state_500k.shp'
usa_map = gpd.read_file(usa)
total_incurred_by_state_rounded = total_incurred_by_state
total_incurred_by_state_rounded['Total_Incurred'] = total_incurred_by_state['Total_Incurred'].astype(int)

# # Merge total_incurred_by_state with usa_map
merged = usa_map.merge(total_incurred_by_state_rounded, how='left', left_on='STUSPS', right_index=True)
merged['Total_Incurred'] = merged['Total_Incurred'].fillna(0)
merged.plot(column='Total_Incurred', cmap='OrRd', legend=True, figsize=[30, 7.5])

print(merged)

# Visualize distribution of claims by CAT Event
cat_event_dist.plot(kind='bar', x='CAT_Event', y='count_claims', rot=0, legend=False, facecolor='green', color= 'lightgrey', edgecolor= 'red', hatch= '///' , label = 'Missing values')
plt.title('Distribution of Claims by CAT Event')
plt.xlabel('CAT Event')
plt.ylabel('Number of Claims')
plt.show()

# Visualize causes of loss
sns.barplot(x='count_claims', y='Cause_of_Loss', data=causes_of_loss, color='b')
plt.title('Causes of Loss')
plt.xlabel('Number of Claims')
plt.ylabel('Cause of Loss')
plt.show()

# Visualize top claims by total incurred
top_claims_by_total_incurred.plot(kind='bar', x='Claim_Number', y='Total_Incurred', rot=0, legend=False)
plt.title('Top Claims by Total Incurred')
plt.xlabel('Claim Number')
plt.ylabel('Total Incurred')
plt.show()

# Write insights onto a txt file
with open("insights.txt", "w") as f:
    f.write("Reporting lag in days: \n")
    f.write("Distribution of claims by CAT Event: \n")
    f.write(str(cat_event_dist) + "\n\n")
    f.write("Percentage of claims with no close date: {:.2f}% \n".format(percent_unclosed_claims) + "\n\n")
    f.write("Value of unclosed claims: ${:,.2f} \n\n".format(value_unclosed_claims) + "\n\n")
    f.write("Average time to close claims by TPA: \n")
    f.write(str(time_to_close) + "\n\n")
    f.write("Total Incurred by MGA and TPA: \n")
    f.write(str(total_incurred_by_mga_tpa) + "\n\n")
    f.write("Causes of Loss: \n")
    f.write(str(causes_of_loss) + "\n\n")
    f.write("Distribution of claims by Loss State: \n")
    f.write(str(loss_state_dist) + "\n\n")
    f.write("Total Incurred by Transaction Period: \n")
    f.write(str(total_incurred_by_transaction_period) + "\n\n")
    f.write("Total Paid vs Total Reserve: \n")
    f.write(str(total_paid_vs_total_reserve) + "\n\n")
    f.write("Top Claims by Total Incurred: \n")
    f.write(str(top_claims_by_total_incurred) + "\n\n")