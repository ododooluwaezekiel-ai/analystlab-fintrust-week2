SELECT * FROM transactions WHERE Amount_NGN IS NULL
SELECT COUNT(*) FROM transactions WHERE Amount_NGN IS NULL
USE FinTrust;
DROP TABLE transactions;
USE FinTrust;
SELECT COUNT(*) FROM transactions;
ALTER TABLE transactions ADD Amount_NGN_Fixed FLOAT;
GO
UPDATE transactions
SET Amount_NGN_Fixed = TRY_CONVERT(FLOAT, REPLACE(Amount_NGN, ',', ''));
GO
SELECT COUNT(*) FROM transactions WHERE Amount_NGN_Fixed IS NULL;
ALTER TABLE transactions DROP COLUMN Amount_NGN;
GO

EXEC sp_rename 'transactions.Amount_NGN_Fixed', 'Amount_NGN', 'COLUMN';
GO
SELECT COUNT(*) FROM transactions;
SELECT MIN(Amount_NGN), MAX(Amount_NGN), AVG(Amount_NGN) FROM transactions;
SELECT COUNT(*) FROM customers;

SELECT COUNT(*) 
FROM transactions t
LEFT JOIN customers c ON t.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

USE FinTrust;
GO

/* ============================================================
   Q1. Which customer segment generates the most transactions,
       and how does their average spend compare?
   ============================================================ */
SELECT c.Customer_Segment,
       COUNT(t.Transaction_ID) AS total_transactions,
       ROUND(AVG(t.Amount_NGN), 2) AS avg_amount
FROM transactions t
JOIN customers c ON t.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY total_transactions DESC;
GO

/* ============================================================
   Q2. Which transaction types carry the most total value?
   ============================================================ */
SELECT Transaction_Type,
       COUNT(*) AS txn_count,
       ROUND(SUM(Amount_NGN), 2) AS total_value
FROM transactions
GROUP BY Transaction_Type
ORDER BY total_value DESC;
GO

/* ============================================================
   Q3. Which channel has the highest transaction success rate?
   ============================================================ */
SELECT Channel,
       COUNT(*) AS total_txns,
       SUM(CASE WHEN Transaction_Status = 'Successful' THEN 1 ELSE 0 END) AS successful,
       ROUND(100.0 * SUM(CASE WHEN Transaction_Status = 'Successful' THEN 1 ELSE 0 END) / COUNT(*), 1) AS success_rate_pct
FROM transactions
GROUP BY Channel
ORDER BY success_rate_pct DESC;
GO

/* ============================================================
   Q4. Which customer segment has the highest risk-review rate?
   ============================================================ */
SELECT c.Customer_Segment,
       COUNT(*) AS total_txns,
       SUM(CASE WHEN t.Risk_Review_Flag = 1 THEN 1 ELSE 0 END) AS flagged,
       ROUND(100.0 * SUM(CASE WHEN t.Risk_Review_Flag = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS risk_rate_pct
FROM transactions t
JOIN customers c ON t.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY risk_rate_pct DESC;
GO

/* ============================================================
   Q5. Who are the top 10 customers by total transaction value?
   (SQLite used LIMIT 10 -- SQL Server uses TOP 10 instead,
   placed right after SELECT)
   ============================================================ */
SELECT TOP 10
       c.Customer_ID, c.Customer_Name, c.Customer_Segment,
       COUNT(t.Transaction_ID) AS txn_count,
       ROUND(SUM(t.Amount_NGN), 2) AS total_spent
FROM transactions t
JOIN customers c ON t.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.Customer_Segment
ORDER BY total_spent DESC;
GO

/* ============================================================
   Q6. Do international transactions carry more risk?
   ============================================================ */
SELECT International_Transaction,
       COUNT(*) AS txn_count,
       ROUND(AVG(Amount_NGN), 2) AS avg_amount,
       ROUND(100.0 * SUM(CASE WHEN Risk_Review_Flag = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS risk_rate_pct
FROM transactions
GROUP BY International_Transaction;
GO

/* ============================================================
   Q7. Are dormant/restricted accounts still transacting?
   ============================================================ */
SELECT c.Account_Status,
       COUNT(t.Transaction_ID) AS txn_count,
       ROUND(AVG(t.Amount_NGN), 2) AS avg_amount
FROM transactions t
JOIN customers c ON t.Customer_ID = c.Customer_ID
GROUP BY c.Account_Status
ORDER BY txn_count DESC;
GO

/* ============================================================
   Q8. Does income band relate to digital engagement?
   ============================================================ */
SELECT Monthly_Income_Band,
       COUNT(*) AS customers,
       ROUND(AVG(Digital_Engagement_Score), 1) AS avg_engagement_score,
       ROUND(AVG(CAST(Tenure_Months AS FLOAT)), 1) AS avg_tenure_months
FROM customers
GROUP BY Monthly_Income_Band
ORDER BY avg_engagement_score DESC;
GO



