#1 
SELECT 
    ID_client,
    AVG(Sum_payment) AS avg_check, 
    AVG(Sum_payment) * COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m-01')) / COUNT(ID_check) AS avg_monthly_spent,  
    COUNT(ID_check) AS total_transactions  
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m-01')) = 12;  

#2(1)
WITH monthly_data AS (
    SELECT
        EXTRACT(MONTH FROM date_new) AS month,
        AVG(Sum_payment) AS avg_check,
        COUNT(Id_check) AS total_transactions,
        COUNT(DISTINCT ID_client) AS total_clients,
        SUM(Sum_payment) AS total_spent
    FROM transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY EXTRACT(MONTH FROM date_new)
),
gender_data AS (
    SELECT
        EXTRACT(MONTH FROM t.date_new) AS month,
        c.Gender,
        SUM(t.Sum_payment) AS gender_spent
    FROM transactions t
    JOIN query_for_abt_customerinfo c ON t.ID_client = c.Id_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY EXTRACT(MONTH FROM t.date_new), c.Gender
)
SELECT
    m.month,
    m.avg_check,
    m.total_transactions,
    m.total_clients,
    m.total_spent,
    SUM(CASE WHEN g.Gender = 'M' THEN g.gender_spent ELSE 0 END) / m.total_spent * 100 AS male_percentage,
    SUM(CASE WHEN g.Gender = 'F' THEN g.gender_spent ELSE 0 END) / m.total_spent * 100 AS female_percentage,
    SUM(CASE WHEN g.Gender IS NULL THEN g.gender_spent ELSE 0 END) / m.total_spent * 100 AS unknown_gender_percentage
FROM monthly_data m
LEFT JOIN gender_data g ON m.month = g.month
GROUP BY m.month, m.avg_check, m.total_transactions, m.total_clients, m.total_spent
ORDER BY m.month;

#2(2)
SELECT
    EXTRACT(MONTH FROM t.date_new) AS month,
    AVG(t.Sum_payment) AS avg_check,
    COUNT(t.Id_check) AS total_transactions,
    COUNT(DISTINCT t.ID_client) AS total_clients,
    SUM(t.Sum_payment) AS total_spent,
    SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS male_percentage,
    SUM(CASE WHEN c.Gender = 'F' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS female_percentage,
    SUM(CASE WHEN c.Gender IS NULL THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS unknown_gender_percentage
FROM transactions t
LEFT JOIN query_for_abt_customerinfo c ON t.ID_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY EXTRACT(MONTH FROM t.date_new)
ORDER BY month;

#3(1)
WITH age_groups AS (
    SELECT
        c.Id_client,
        CASE
            WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
            WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
            WHEN c.Age >= 80 THEN '80+'
            ELSE 'Unknown'
        END AS age_group
    FROM query_for_abt_customerinfo c
),
quarterly_data AS (
    SELECT
        t.ID_client,
        CASE
            WHEN EXTRACT(MONTH FROM t.date_new) BETWEEN 1 AND 3 THEN 'Q1'
            WHEN EXTRACT(MONTH FROM t.date_new) BETWEEN 4 AND 6 THEN 'Q2'
            WHEN EXTRACT(MONTH FROM t.date_new) BETWEEN 7 AND 9 THEN 'Q3'
            WHEN EXTRACT(MONTH FROM t.date_new) BETWEEN 10 AND 12 THEN 'Q4'
        END AS quarter,
        SUM(t.Sum_payment) AS total_spent,
        COUNT(t.Id_check) AS total_transactions
    FROM transactions t
    GROUP BY t.ID_client, quarter
)
SELECT
    ag.age_group,
    q.quarter,
    SUM(q.total_spent) AS total_spent,
    SUM(q.total_transactions) AS total_transactions,
    AVG(q.total_spent / q.total_transactions) AS avg_check_per_quarter
FROM age_groups ag
JOIN quarterly_data q ON ag.Id_client = q.ID_client
GROUP BY ag.age_group, q.quarter
ORDER BY ag.age_group, q.quarter;


#3(2)
SELECT
    CASE
        WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
        WHEN c.Age >= 80 THEN '80+'
        ELSE 'Unknown'
    END AS age_group,
    CASE
        WHEN EXTRACT(MONTH FROM t.date_new) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN EXTRACT(MONTH FROM t.date_new) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN EXTRACT(MONTH FROM t.date_new) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN EXTRACT(MONTH FROM t.date_new) BETWEEN 10 AND 12 THEN 'Q4'
    END AS quarter,
    SUM(t.Sum_payment) AS total_spent,
    COUNT(t.Id_check) AS total_transactions,
    AVG(t.Sum_payment) AS avg_check_per_transaction
FROM transactions t
JOIN query_for_abt_customerinfo c ON t.ID_client = c.Id_client
GROUP BY age_group, quarter
ORDER BY age_group, quarter;



