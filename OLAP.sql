
-- =========================================================
-- Task 5.1: SLICE
-- Average waiting time for Lotus Care Colombo
-- =========================================================

SELECT
    c.clinic_name,
    ROUND(AVG(f.wait_minutes), 2) AS avg_wait_minutes
FROM fact_appointment f
JOIN dim_clinic c
    ON f.clinic_key = c.clinic_key
WHERE c.clinic_name = 'Lotus Care Colombo'
GROUP BY c.clinic_name;


-- =========================================================
-- Task 5.2: DICE
-- Fee income for Colombo clinic during Q1 2025
-- =========================================================

SELECT
    c.clinic_name,
    d.year,
    d.quarter,
    SUM(f.fee) AS total_fee
FROM fact_appointment f
JOIN dim_clinic c
    ON f.clinic_key = c.clinic_key
JOIN dim_date d
    ON f.date_key = d.date_key
WHERE c.clinic_name = 'Lotus Care Colombo'
  AND d.year = 2025
  AND d.quarter = 1
GROUP BY
    c.clinic_name,
    d.year,
    d.quarter;


-- =========================================================
-- Task 5.3: ROLL UP
-- Doctor workload -> Specialty -> Grand Total
-- =========================================================

SELECT
    CASE
        WHEN GROUPING(d.specialty) = 1
            THEN 'GRAND TOTAL'
        ELSE d.specialty
    END AS specialty,

    CASE
        WHEN GROUPING(d.specialty) = 0
             AND GROUPING(d.doctor_name) = 1
            THEN 'SPECIALTY TOTAL'
        WHEN GROUPING(d.doctor_name) = 0
            THEN d.doctor_name
        ELSE ''
    END AS doctor,

    SUM(f.consultation_minutes) AS total_consultation_minutes

FROM fact_appointment f

JOIN dim_doctor d
    ON f.doctor_key = d.doctor_key

GROUP BY ROLLUP(
    d.specialty,
    d.doctor_name
)

ORDER BY
    GROUPING(d.specialty),
    d.specialty,
    GROUPING(d.doctor_name),
    d.doctor_name;



-- =========================================================
-- Task 5.4: DRILL DOWN
-- Level 1: Quarterly fee totals
-- =========================================================

SELECT
    d.year,
    d.quarter,
    SUM(f.fee) AS total_fee
FROM fact_appointment f
JOIN dim_date d
    ON f.date_key = d.date_key
WHERE d.year = 2025
GROUP BY
    d.year,
    d.quarter
ORDER BY
    d.year,
    d.quarter;


-- =========================================================
-- Task 5.4: DRILL DOWN
-- Level 2: Monthly fee totals inside Q1
-- =========================================================

SELECT
    d.year,
    d.quarter,
    d.month,
    d.month_name,
    SUM(f.fee) AS total_fee
FROM fact_appointment f
JOIN dim_date d
    ON f.date_key = d.date_key
WHERE d.year = 2025
  AND d.quarter = 1
GROUP BY
    d.year,
    d.quarter,
    d.month,
    d.month_name
ORDER BY
    d.month;


-- =========================================================
-- Task 5.5: PIVOT
-- Quarterly fee income by clinic
-- =========================================================

SELECT
    c.clinic_name,

    SUM(CASE
        WHEN d.quarter = 1 THEN f.fee
        ELSE 0
    END) AS q1_fee,

    SUM(CASE
        WHEN d.quarter = 2 THEN f.fee
        ELSE 0
    END) AS q2_fee,

    SUM(CASE
        WHEN d.quarter = 3 THEN f.fee
        ELSE 0
    END) AS q3_fee,

    SUM(CASE
        WHEN d.quarter = 4 THEN f.fee
        ELSE 0
    END) AS q4_fee

FROM fact_appointment f

JOIN dim_clinic c
    ON f.clinic_key = c.clinic_key

JOIN dim_date d
    ON f.date_key = d.date_key

WHERE d.year = 2025

GROUP BY c.clinic_name

ORDER BY c.clinic_name;

