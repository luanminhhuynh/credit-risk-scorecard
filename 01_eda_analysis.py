import pandas as pd
import numpy as np

print("="*60)
print("CREDIT RISK ANALYSIS - EXPLORATORY DATA ANALYSIS")
print("="*60)

# Load data
df = pd.read_csv('data/raw/UCI_Credit_Card.csv')

print(f'\n Dataset loaded: {df.shape[0]:,} rows × {df.shape[1]} columns')

# Get column names
print(f'\nColumn names:')
print(df.columns.tolist())

# Summary statistics
print(f'\n Summary Statistics:')
print(df.describe())

# Default rate
default_col = 'default payment next month'
if default_col in df.columns:
    rate = df[default_col].mean() * 100
    print(f'\n Default Rate: {rate:.2f}%')
    print(f' Non-default: {100-rate:.2f}%')
else:
    print(f'\n  Warning: Column "{default_col}" not found!')
    print('Available columns:', df.columns.tolist())

# Missing values check
print(f'\n Missing Values Check:')
missing = df.isnull().sum()
if missing.sum() > 0:
    print(missing[missing > 0])
else:
    print('No missing values found!')

print("\n" + "="*60)
print("Analysis Complete!")
print("="*60)
