# FinTrust Digital Bank — Data Analytics (Week 2)
**AnalystLab Africa | Experience Lab Internship Programme**
**Track:** Data Analytics | **Intern:** Ogundeji Ezekiel

Week 2 of a 4-week project transforming FinTrust's synthetic customer and transaction data into
business intelligence — data quality assessment, SQL analysis, exploratory data analysis, and an
initial Power BI dashboard.

> **Note:** `Risk_Review_Flag` is a synthetic, educational label throughout this project. It is not
> a real fraud determination and is not used to make any real banking decision.

---

## Project Structure

```
├── data/
│   ├── FinTrust_Customer_Data_clean.csv        # 1,500 customer records
│   └── FinTrust_Transaction_Data_clean.csv     # 12,000 transaction records
├── data-quality/
│   └── FinTrust_Week2_Data_Quality_Workbook.xlsx   # Part A: full quality assessment (Excel, live formulas)
├── sql/
│   └── FinTrust_Week2_SQL_Analysis.sql          # Part B: 8 business questions (SQL Server / T-SQL)
├── notebooks/
│   └── FinTrust_Week2_Data_Analysis.ipynb       # Part C: Python EDA, 6 visualizations
├── dashboard/
│   └── FinTrust_Week2_PowerBI_Build_Spec.md     # Part D: Power BI build spec + DAX measures
├── docs/
│   ├── FinTrust_Week2_Business_Findings.docx    # Part E: 5 findings (Finding → Evidence → Meaning)
│   ├── FinTrust_Week2_Documentation.docx        # Decisions, resources, testing log, limitations
│   └── FinTrust_Week2_Project_Summary.docx      # 11-point Week 2 summary
└── README.md
```

---

## Data Sources

| Dataset | Records | Columns | Notes |
|---|---|---|---|
| `FinTrust_Customer_Data` | 1,500 | 12 | No missing values, no duplicates |
| `FinTrust_Transaction_Data` | 12,000 | 11 | 96 missing `Device_Type`, 96 missing `Location` (confirmed intentional per data dictionary) |

Joined on `Customer_ID` (one-to-many). Join integrity confirmed: 0 orphan transactions, every
customer has ≥1 transaction.

---

## Part A — Data Quality & Cleaning (Excel)

Full 10-item quality assessment built with live Excel formulas (`COUNTIF`, `COUNTBLANK`,
`QUARTILE`, `SUMPRODUCT`, `INDEX/MATCH`) rather than pasted-in values, so every number recalculates
if the source data changes.

**Key results:**
- 0 missing values (Customer) / 192 missing values (Transaction — confirmed intentional)
- 0 duplicate records in either table
- 1,090 transactions from Dormant/Restricted-status accounts (a real data-consistency issue between the two tables)
- `Amount_NGN` outlier check (IQR method): upper fence ₦117,922.86, 1,474 transactions (12.3%) above it
- Mean (₦46,706) vs median (₦10,306) confirms strong right-skew

## Part B — SQL Analysis

8 business questions covering customer behavior, transaction value/type/channel, segments, and
risk-review patterns. Originally developed and validated in SQLite, then ported to SQL Server
(T-SQL) for the live database build — see **Challenges Solved** below for the real issues hit during
that migration.

**Standout finding:** international transactions are flagged for risk review at **36.9%**, vs
**18.9%** for domestic — nearly double, despite being only 4% of total volume. Customer segment, by
contrast, barely moves the needle (19.3%–20.3% across all four segments).

## Part C — Python EDA

6 visualizations (Matplotlib/Seaborn) covering transaction volume by segment, value by type, amount
distribution, risk by channel, risk by international status, and daily volume trend — each annotated
with what it shows, why it matters, and the business insight.

## Part D — Power BI Dashboard

KPI cards (Total Customers, Total Transactions, Total Value, Avg Value, Success Rate, Risk Rate) +
6 visuals + slicers. Built from a documented spec with exact expected values for self-checking the
build.

## Part E — Business Findings

5 findings in *Finding → Evidence → Business Meaning* format, the strongest being the international
risk pattern above and a segment-mislabeling finding (6 of the top 10 customers by spend are labeled
"Everyday," not "Premium").

---

## Challenges Solved

Real problems hit while building this out — documented because the troubleshooting was as much a
part of the deliverable as the analysis itself:

- **Source files were PDF table exports, not native CSVs.** Naive whitespace-based text extraction
  produced inconsistent column counts across rows due to variable PDF spacing. Fixed with a
  fixed-vocabulary regex parser, validated against zero parse failures across 13,500 combined
  records. A hidden page-break character was also found silently corrupting 166 transaction rows —
  identified by checking for gaps in the sequential Transaction_ID range.
- **SQL Server's Import Flat File wizard auto-typed `Amount_NGN` as `float`,** which silently
  dropped ~128 rows to `NULL` on values it couldn't parse — even though Part A had already confirmed
  zero missing values in the source data. Fixed by re-importing the column as `nvarchar`, then
  converting to `FLOAT` under explicit control in SQL (`TRY_CONVERT` + `REPLACE`), verifying 0 failed
  conversions before finalizing the column.
- **`Risk_Review_Flag` and `International_Transaction` were auto-typed as `bit`** (0/1) instead of
  text, since the wizard only saw two distinct values. This broke every query written against the
  string values `'Yes'`/`'No'`. Fixed by re-running affected queries against `1`/`0` instead, with a
  `CASE` wrapper to relabel results back to readable text for reporting.
- **SQLite → SQL Server syntax differences:** `LIMIT 10` → `TOP 10` (and moved to right after
  `SELECT`); integer division in `AVG()` required an explicit `CAST(... AS FLOAT)` to avoid silently
  truncated averages.

---

## Tools Used

Python (pandas, NumPy, Matplotlib, Seaborn) · Microsoft Excel · Microsoft SQL Server / SSMS ·
Power BI (spec-based build) · Git/GitHub

---

## Limitations

- `Risk_Review_Flag` is synthetic and educational — not a real fraud signal.
- Daily transaction volume is artificially flat (std ≈ 0.47/day across the 90-day window), a
  synthetic-data generation artifact — this dataset cannot support real seasonality analysis.
- The Dormant/Restricted-account activity (1,090 transactions) is documented but not root-caused.

---

## Author

Ogundeji Ezekiel — AnalystLab Africa Data Analytics Track, FinTrust Digital Bank Experience Lab Project
