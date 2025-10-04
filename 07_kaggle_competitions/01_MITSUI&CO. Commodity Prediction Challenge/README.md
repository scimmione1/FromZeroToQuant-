# MITSUI & CO. Commodity Prediction Challenge - EDA and First Analysis

## 📊 **Executive Summary**
This notebook presents a comprehensive analysis and machine learning solution for the Mitsui & Co. Commodity Prediction Challenge on Kaggle. The challenge involves predicting commodity price movements using multi-market financial data spanning Japanese (JPX) and US markets.

---

## 🎯 **Challenge Overview**

### **Competition Objective**
Predict commodity price targets based on financial market data from multiple sources, including:
- **JPX Market Data**: Japanese futures, stocks, and commodity contracts
- **US Market Data**: US stocks, ETFs, and financial instruments
- **Target Variables**: 424 different commodity price prediction targets

### **Business Context**
- **Company**: MITSUI & CO., LTD - Japanese multinational trading and investment corporation
- **Industry**: Commodity trading, natural resources, energy
- **Challenge Type**: Time series regression with multiple targets
- **Evaluation Metric**: Spearman Rank Correlation (Kaggle competition metric)

---

## 📈 **Dataset Specifications**

### **Data Structure**
- **Training Data**: 1,961 samples × 558 features
- **Test Data**: 134 samples × 559 features  
- **Training Labels**: 1,961 samples × 425 targets
- **Target Pairs**: 424 commodity prediction targets with associated market pairs

### **Feature Categories**
1. **JPX Features**: Japanese market data (futures, stocks)
2. **US Features**: US market data (stocks, ETFs, indices)
3. **Temporal Features**: Date identifiers and lag information
4. **Multi-Index Structure**: Hierarchical organization by market category

### **Data Characteristics**
- **Missing Values**: ~10.49% in training labels
- **Feature Types**: Numerical (float64, int64)
- **Time Period**: Sequential daily market data
- **Market Coverage**: Cross-market Japanese-US financial instruments

---

## 🔍 **Analytical Framework**

### **1. Exploratory Data Analysis (EDA)**
- **Data Quality Assessment**: Missing value analysis, data type validation
- **Feature Distribution Analysis**: Statistical summaries, outlier detection
- **Multi-Index Structure**: Proper handling of hierarchical column organization
- **Target Analysis**: Distribution and correlation of prediction targets

### **2. Advanced Feature Engineering**
- **Technical Indicators**: 20+ advanced features per base feature
- **Rolling Statistics**: Moving averages, volatility measures
- **Regime Features**: Market state indicators
- **Cross-Market Features**: JPX-US market relationships
- **Lag Features**: Temporal dependencies and momentum indicators

### **3. Machine Learning Pipeline**
- **Base Models**: Linear Regression, LightGBM, Bayesian Ridge
- **Ensemble Methods**: Blending and Stacking approaches
- **Meta-Learning**: Linear Regression as meta-learner
- **Cross-Validation**: Time series split validation

---

## 🚀 **Model Development**

### **Feature Engineering Pipeline**
```python
def create_advanced_features():
    - Rolling statistics (5, 10, 20 periods)
    - Volatility measures (standard deviation, range)
    - Momentum indicators (RSI-style features)
    - Regime detection (market state features)
    - Cross-sectional features (rank, percentile)
    - Lag features (1, 2, 3 period lags)
```

### **Ensemble Architecture**
```
Base Models: LinearRegression + LightGBM
    ↓
Ensemble Methods:
    ├── Blending (VotingRegressor)
    └── Stacking (StackingRegressor + LinearRegression meta-learner)
```

### **Model Configuration**
- **LightGBM Parameters**: Windows-safe, CPU-optimized
- **Cross-Validation**: 3-fold time series split
- **Feature Selection**: Correlation-based selection (max 500 features)
- **Preprocessing**: Robust handling of missing values

---

## 🏆 **Key Results & Performance**

### **Model Performance Summary**
| Method | Avg Kaggle Metric | Avg R² Score | Avg RMSE | Avg Features |
|--------|-------------------|--------------|-----------|--------------|
| **Stacking** | **0.7364** | **0.6506** | **0.0247** | **332** |
| Blending | 0.7171 | 0.6210 | 0.0255 | 332 |
| Baseline | 0.4460 | 0.3200 | 0.0350 | 25 |

### **Top Performing Models**
1. **STACKING - target_364**: Kaggle Metric = 0.9095, R² = 0.8392
2. **STACKING - target_116**: Kaggle Metric = 0.8947, R² = 0.8299  
3. **BLENDING - target_364**: Kaggle Metric = 0.8901, R² = 0.7909

### **Performance Improvements**
- **+62.9% improvement** over baseline Linear Regression
- **Feature explosion solved**: 332 average features vs 400-600 previous
- **Ensemble advantage**: Stacking outperforms blending by 2.7%

---

## 💡 **Key Technical Insights**

### **Feature Engineering Impact**
✅ **Advanced feature engineering significantly enhances performance**
- Rolling statistics provide trend and momentum signals
- Volatility features capture market regime changes
- Cross-market features leverage JPX-US relationships

### **Ensemble Learning Benefits**
✅ **Stacking methodology proves most effective**
- Linear Regression + LightGBM base model combination
- Linear Regression meta-learner for final predictions
- 3-fold cross-validation prevents overfitting

### **Data Processing Discoveries**
✅ **Multi-Index structure requires careful handling**
- Proper alignment of features and targets
- Temporal lag incorporation for prediction realism
- Missing value imputation preserves data integrity

---

## 🔧 **Technical Implementation**

### **Libraries & Dependencies**
```python
# Core Data Science
import pandas as pd, numpy as np
import matplotlib.pyplot as plt, seaborn as sns

# Machine Learning
from sklearn.ensemble import VotingRegressor, StackingRegressor
from sklearn.linear_model import LinearRegression, BayesianRidge
from sklearn.metrics import r2_score, mean_squared_error
import lightgbm as lgb

# Statistics & Evaluation
from scipy.stats import spearmanr
```

### **Code Architecture**
1. **Data Loading & Validation**: Robust CSV processing with dtype specifications
2. **Feature Engineering**: Modular `create_advanced_features()` function
3. **Model Training**: Ensemble pipeline with error handling
4. **Evaluation**: Kaggle metric implementation with Spearman correlation
5. **Submission**: Production-ready prediction pipeline

### **Performance Optimization**
- **Windows-Compatible LightGBM**: CPU-only, row-wise processing
- **Memory Management**: Efficient MultiIndex handling
- **Feature Selection**: Correlation-based dimensionality reduction
- **Parallel Processing**: Multi-model ensemble training

---

## 📊 **Business Implications**

### **Trading Strategy Applications**
- **Commodity Price Forecasting**: Multi-horizon predictions
- **Risk Management**: Volatility and regime detection
- **Portfolio Optimization**: Cross-market correlation insights
- **Market Timing**: Momentum and trend indicators

### **Technical Infrastructure**
- **Real-Time Prediction**: Production-ready ensemble models
- **Feature Pipeline**: Automated technical indicator calculation
- **Model Monitoring**: Performance tracking and validation
- **Scalability**: Multi-target prediction framework

---

## 📋 **Files & Structure**

### **Core Analysis Files**
- `01_Mitsui Commodity Prediction Challenge_EDA_and_first_analysis.ipynb`: Main analysis
- `ensemble_results_advanced.csv`: Comprehensive model performance results
- `ensemble_config_advanced.json`: Optimal model configuration
- `submission.ipynb`: Production submission pipeline

### **Data Files**
- `train.csv`: Historical market data (1,961 samples × 558 features)
- `test.csv`: Prediction data (134 samples × 559 features)
- `train_labels.csv`: Target variables (1,961 samples × 425 targets)
- `target_pairs.csv`: Target-market pair mappings (424 pairs)

---

## 🎯 **Methodology Highlights**

### **Advanced Feature Engineering**
- **20+ Technical Indicators** per base feature
- **Rolling Windows**: 5, 10, 20-period statistics
- **Volatility Measures**: Standard deviation, range, regime detection
- **Cross-Market Features**: JPX-US correlation and momentum
- **Temporal Lags**: 1-3 period historical dependencies

### **Ensemble Strategy**
- **Base Model Diversity**: Linear Regression (interpretable) + LightGBM (non-linear)
- **Meta-Learning**: Linear Regression combiner for final predictions
- **Cross-Validation**: Time series split respecting temporal structure
- **Feature Selection**: Correlation-based reduction to prevent overfitting

### **Evaluation Framework**
- **Primary Metric**: Spearman Rank Correlation (Kaggle competition standard)
- **Secondary Metrics**: R² Score, RMSE, MAE for comprehensive assessment
- **Baseline Comparison**: Simple Linear Regression for improvement validation
- **Performance Monitoring**: Per-target analysis with statistical significance

---

## 🚀 **Future Enhancements**

### **Model Improvements**
- **Deep Learning**: LSTM/Transformer architectures for temporal patterns
- **Feature Selection**: Advanced mutual information and SHAP-based selection
- **Hyperparameter Tuning**: Bayesian optimization for ensemble parameters
- **Cross-Market Modeling**: Explicit JPX-US relationship modeling

### **Data Augmentation**
- **External Data**: Economic indicators, commodity fundamentals
- **Alternative Features**: Sentiment analysis, news-based features
- **Frequency Enhancement**: Intraday data for higher resolution
- **Regime Modeling**: Market state classification and adaptation

---

*This analysis demonstrates a comprehensive approach to commodity price prediction using ensemble machine learning, achieving significant performance improvements through advanced feature engineering and robust model architecture.*