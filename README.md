# 📈 Stock Market Analysis Dashboard & SQL Playground

**Built by Fateh Mohammed Sayyed**  
*Python · Streamlit · SQL · DuckDB · Pandas · Plotly*

An interactive stock market analytics application for exploring six Indian companies: **TVS Motors, TCS, Infosys, Hero MotoCorp, Eicher Motors, and Bajaj Auto**.

This project combines Python-based exploratory data analysis (EDA), interactive dashboards, company comparisons, and an executable SQL Playground powered by DuckDB.

> **Data note:** This project uses historical stock data, not live market prices. The bundled dataset's latest record is 31 July 2018. This is an analytics and learning project, not investment advice.

## ✨ Key Features

- Interactive Streamlit dashboard with market KPIs and historical price trends.
- Python EDA for data profiling, missing values, duplicates, outliers, and price consistency.
- Company comparison using returns, volatility, drawdown, turnover, and normalized performance.
- SQL Playground with 28 selectable questions across beginner, intermediate, and advanced levels.
- Executable SQL queries using DuckDB, with editable queries and downloadable results.
- Insights and reporting with CSV exports, SQL scripts, and PDF report generation.
- Dataset management for uploading, cleaning, validating, and exporting stock data.

## 🧰 Tech Stack

| Technology | Purpose |
|---|---|
| Python | Data analysis and application logic |
| Streamlit | Interactive web application |
| Pandas & NumPy | Data cleaning and calculations |
| SQL & DuckDB | Analytical queries and SQL Playground |
| Plotly | Interactive visualizations |
| Matplotlib & Seaborn | Statistical charts |
| ReportLab | PDF report generation |

## 🚀 Installation and Run

### 1. Clone the repository

```bash
git clone https://github.com/fatehSayyed/stock-market-analysis-streamlit-sql.git
cd stock-market-analysis-streamlit-sql
```

Replace the repository URL if you choose a different repository name.

### 2. Create a virtual environment (recommended)

**Windows**

```bash
python -m venv .venv
.venv\Scripts\activate
```

**macOS / Linux**

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Install dependencies

```bash
python -m pip install -r requirements.txt
```

### 4. Run the application

```bash
python -m streamlit run app.py
```

Open the local URL printed in the terminal, usually http://localhost:8501.

**Requirement:** Python 3.10 or newer is recommended.

## 📊 Dashboard Pages

| Page | Features |
|---|---|
| Market Overview | KPIs, price trends, moving averages, volume, turnover, and daily returns |
| Stock Explorer | OHLC/WAP prices, returns, moving averages, delivery metrics, filters, and CSV downloads |
| Exploratory Data Analysis | Descriptive statistics, missing values, outliers, data quality, and correlations |
| Company Comparison | Normalized performance, returns, volatility, drawdown, turnover, and rankings |
| SQL Playground | 28 questions, editable SQL, query execution, results, and CSV downloads |
| Insights & Reports | Analytical findings, CSV summaries, SQL scripts, and PDF reports |
| Dataset Management | CSV uploads, column mapping, quality checks, and combined dataset downloads |

## 📂 Data Setup

Place the six source CSV files in a folder named `data/`:

```text
data/
├── TVS Motors.csv
├── TCS.csv
├── Infosys.csv
├── Hero Motocorp.csv
├── Eicher Motors.csv
└── Bajaj Auto.csv
```

The application standardizes the columns, combines the files vertically using `pandas.concat()`, and adds a `Company` column to identify each stock.

If the original six files are unavailable, the application can use `data/cleaned_data.csv` as a pre-combined fallback. The bundled dataset contains 5,334 rows covering 1 January 2015 to 31 July 2018.

## 🧪 SQL Playground

The combined data is registered as `stock_data` in an in-memory DuckDB database.

The 28 SQL questions cover:

- `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, and `DISTINCT`
- Aggregations using `COUNT`, `MIN`, `MAX`, `AVG`, and `SUM`
- `GROUP BY`, `HAVING`, and common table expressions (CTEs)
- Window functions such as `LAG`, `RANK`, `DENSE_RANK`, and `ROW_NUMBER`
- 30-day and 90-day moving averages
- Monthly returns, cumulative turnover, and volatility

The playground supports editable queries, actual execution against the dataset, results tables, and downloadable CSVs.

The SQL runner is designed to restrict queries to read-only analytical statements, reject destructive or external-access commands, limit returned rows, and enforce a timeout. See `utils/sql_engine.py` for its implementation.

## 📐 Key Metric Definitions

- **Daily return:** Percentage change in a company's closing price from its previous available trading observation.
- **Period return:** `(Last closing price / First closing price) − 1`.
- **Volatility:** Sample standard deviation of daily returns; annualized volatility uses √252 where shown.
- **Maximum drawdown:** Largest decline from a prior running closing-price peak during the selected period.
- **Moving averages:** Displayed only when a full 30- or 90-observation window is available.

## ⚠️ Limitations

- **Historical data only:** The dataset ends on 31 July 2018 and is not connected to a live market feed.
- **Potential corporate-action effects:** Some historical price movements are unusually large and may reflect corporate actions; this has not been independently verified.
- **Missing values:** These are retained where appropriate instead of being automatically replaced with zero.
- **Source-reported findings:** Statements from the project brief should be distinguished from independently recalculated findings.
- **Investment disclaimer:** The application is intended for analytics practice and historical exploration. It does not provide buy or sell recommendations.

## 🗂️ Project Structure

```text
stock-market-analysis-streamlit-sql/
├── app.py
├── requirements.txt
├── README.md
├── stock_analysis.sql
├── data/
│   └── cleaned_data.csv
├── views/
├── utils/
└── tests/
```

Keep this structure consistent with the files actually committed to your repository.

## 👨‍💻 Author

**Fateh Mohammed Sayyed**

GitHub: https://github.com/fatehSayyed

Interested in data analytics and building practical projects using **Python, SQL, Streamlit, and interactive dashboards**.

---

⭐ Explore the code, run the dashboard locally, and practice SQL analysis using the interactive question bank.
