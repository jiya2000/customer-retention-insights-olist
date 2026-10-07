# Olist Ecommerce Churn Analysis

**End-to-end customer analytics pipeline for the Olist Brazilian E-Commerce dataset.**

## Overview

This project provides a comprehensive analysis of the Olist E-Commerce dataset, focusing on customer retention and churn prediction. It includes a full pipeline from raw data to machine learning ready features, and implements predictive modeling using algorithms like Random Forest and XGBoost.

## Project Structure

```text
├── data/
│   ├── raw/             # Original Olist data (downloaded via pipeline)
│   ├── processed/       # Cleaned data ready for modeling
├── notebooks/           
│   └── 01_End_to_End_Pipeline.ipynb # The main notebook with the analysis
├── src/                 # Source code (for future modularization)
├── models/              # Saved trained models
├── requirements.txt     # Python dependencies
└── README.md
```

## Key Features

-   **Data Cleaning & Preprocessing**: robust handling of missing values and data type conversions.
-   **Synthetic Data Augmentation**: Techniques to expand the dataset for better model training (Phase 3).
-   **Advanced Feature Engineering**:
    -   **RFM Analysis**: Recency, Frequency, Monetary value calculation.
    -   **Delivery Metrics**: Analysis of delivery times, lateness, and approval times.
-   **Churn Prediction**: Labeling and preparation for churn modeling (Phase 4).
-   **Predictive Modeling**: Using XGBoost, Logistic Regression, Random Forest, and Stacking.
-   **Forecasting**: Time series forecasting using Prophet.

## Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/jiya2000/customer-retention-insights-olist.git
   cd customer-retention-insights-olist
   ```

2. **Install Dependencies**:
   It is recommended to use a virtual environment.
   ```bash
   pip install -r requirements.txt
   ```

## Usage

Navigate to the `notebooks/` directory and open `01_End_to_End_Pipeline.ipynb` in a Jupyter environment or Google Colab to run the analysis. The notebook will automatically download the required datasets using `kagglehub`.
