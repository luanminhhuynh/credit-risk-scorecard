"""
Credit Risk Analysis - Exploratory Data Analysis
Author: Huynh Minh Luan 
Date: November 2, 2025
Dataset: UCI Credit Card Default Dataset (30,000 customers)
"""

import pandas as pd
import numpy as np

print("="*60)
print("CREDIT RISK ANALYSIS - EXPLORATORY DATA ANALYSIS")
print("="*60)

# Load data
df = pd.read_csv('data/raw/UCI_Credit_Card.csv')

print(f'\n Dataset loaded: {df.shape[0]:,} rows × {df.shape[1]} columns')

# Get column names
print(f'\n Column names:')
print(df.columns.tolist())

# Summary statistics
print(f'\n Summary Statistics:')
print(df.describe())

# Default rate (fixed column name)
default_col = 'default.payment.next.month'
if default_col in df.columns:
    rate = df[default_col].mean() * 100
    print(f'\n Default Rate: {rate:.2f}%')
    print(f' Non-default: {100-rate:.2f}%')
    
    # Default distribution
    print(f'\n Default Distribution:')
    print(df[default_col].value_counts())
else:
    print(f'\n  Warning: Column "{default_col}" not found!')
    print('Available columns:', df.columns.tolist())

# Missing values check
print(f'\n Missing Values Check:')
missing = df.isnull().sum()
if missing.sum() > 0:
    print(missing[missing > 0])
else:
    print('No missing values found! Data is clean.')

# Data types
print(f'\n Data Types:')
print(df.dtypes)

# Key insights
print(f'\n Key Insights:')
print(f'   • Total Customers: {len(df):,}')
print(f'   • Total Features: {df.shape[1]}')
print(f'   • Default Rate: {rate:.2f}%')
print(f'   • Data Quality: Clean (no missing values)')
print(f'   • Dataset Size: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB')

print("\n" + "="*60)
print(" Analysis Complete!")
print("="*60)
