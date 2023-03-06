# Alexander Yousif
# University of North Carolina at Chapel Hill
# PID: 730622857
# see README for info
library(dplyr)
library(readxl)
library(lubridate)

claims_data <- read_excel("data.xlsx") # replace with actual claims data

# convert column names to snake_case if they have spaces!
names(claims_data) <- gsub(" ", "_", names(claims_data))

# calculate reporting_lag in days
claims_data <- claims_data %>% 
  mutate(reporting_lag = as.Date(Reported_Date, format = "%m/%d/%Y") - as.Date(Loss_Date, format = "%m/%d/%Y"))

# select relevant columns
claims_data <- claims_data %>% 
  select(Claim_Number, CAT_Event, MGA, TPA, Cause_of_Loss, Loss_Date, Reported_Date, Closed_Date, Transaction_Period, Total_Paid, Total_Reserve, Total_Incurred, Total_Outstanding, Loss_State)

# Distribution of claims by CAT Event
cat_event_dist <- claims_data %>%
  group_by(CAT_Event) %>%
  summarise(count_claims = n(),
            total_incurred = sum(Total_Incurred)) %>%
  arrange(desc(count_claims))

# Percentage of claims with no close date
percent_unclosed_claims <- claims_data %>%
  summarise(percent_unclosed = sum(is.na(Closed_Date)) / n() * 100)

value_of_unclosed_claims <- claims_data %>%
  filter(is.na(Closed_Date)) %>%
  summarise(value_unclosed = sum(Total_Incurred))
              
# Time to Close Claims
time_to_close <- claims_data %>%
  mutate(time_to_close = as.Date(Closed_Date, format = "%m/%d/%Y") - as.Date(Reported_Date, format = "%m/%d/%Y")) %>%
  group_by(TPA) %>%
  summarise(avg_time_to_close = mean(time_to_close, na.rm = TRUE)) %>%
  arrange(avg_time_to_close)

# Total Incurred by MGA and TPA
total_incurred_by_mga_tpa <- claims_data %>%
  group_by(MGA, TPA) %>%
  summarise(total_incurred = sum(Total_Incurred)) %>%
  arrange(desc(total_incurred))

# Causes of Loss
causes_of_loss <- claims_data %>%
  group_by(Cause_of_Loss) %>%
  summarise(count_claims = n(),
            total_incurred = sum(Total_Incurred)) %>%
  arrange(desc(count_claims))

# Outstanding Reserves
outstanding_reserves <- claims_data %>%
  summarise(total_outstanding_reserves = sum(Total_Outstanding, na.rm = TRUE))

# Distribution of claims by Loss State
loss_state_dist <- claims_data %>%
  group_by(Loss_State) %>%
  summarise(count_claims = n(),
            total_incurred = sum(Total_Incurred)) %>%
  arrange(desc(count_claims))

# Total Incurred by Transaction Period
total_by_period <- claims_data %>%
  group_by(Transaction_Period) %>%
  summarise(total_incurred = sum(Total_Incurred)) %>%
  arrange(Transaction_Period)

# Total Paid vs. Total Reserve
total_paid_vs_total_reserve <- claims_data %>%
  summarise(total_paid = sum(Total_Paid),
            total_reserve = sum(Total_Reserve))

# Top Claims by Total Incurred
top_claims_by_total_incurred <- claims_data %>%
  arrange(desc(Total_Incurred)) %>%
  select(Claim_Number, MGA, TPA, Total_Incurred) %>%
  head(10)

# Print all the results
cat("Distribution of Claims by CAT Event:\n")
print(cat_event_dist)
cat("\nTime to Close Claims:\n")
print(time_to_close)
cat("\nTotal Incurred by MGA and TPA:\n")
print(total_incurred_by_mga_tpa)
cat("\nCauses of Loss:\n")
print(causes_of_loss)
cat("\nOutstanding Reserves:\n")
print(outstanding_reserves)
cat("\nDistribution of Claims by Loss State:\n")
print(loss_state_dist)
cat("\nTotal Incurred by Transaction Period:\n")
print(total_by_period)
cat("\nTotal Paid vs Total Reserve:\n")
print(total_paid_vs_total_reserve)
cat("\nTop Claims by Total Incurred:\n")
print(top_claims_by_total_incurred)
cat("\nPercentage of claims with no close date:\n")
print(percent_unclosed_claims)
cat("\nValue of claims with no close date:\n")
print(value_of_unclosed_claims)