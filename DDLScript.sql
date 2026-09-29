-- =========================================================
-- Task 2.1: Dimension Table DDL
-- Lotus Care Data Warehouse
-- =========================================================

CREATE TABLE dim_patient (
    patient_key INTEGER PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    gender VARCHAR(10),
    date_of_birth DATE,
    district VARCHAR(50)
);

CREATE TABLE dim_doctor (
    doctor_key INTEGER PRIMARY KEY,
    doctor_id VARCHAR(10) NOT NULL,
    doctor_name VARCHAR(100),
    specialty VARCHAR(100)
);

CREATE TABLE dim_clinic (
    clinic_key INTEGER PRIMARY KEY,
    clinic_id VARCHAR(10) NOT NULL,
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    province VARCHAR(50)
);


-- =========================================================
-- Task 2.2: Date Dimension DDL
-- =========================================================

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day INTEGER NOT NULL,
    day_name VARCHAR(20) NOT NULL
);



-- =========================================================
-- Task 2.3: Fact Appointment Table DDL
-- =========================================================

CREATE TABLE fact_appointment (
    patient_key INTEGER NOT NULL,
    doctor_key INTEGER NOT NULL,
    clinic_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    wait_minutes INTEGER,
    consultation_minutes INTEGER,
    fee NUMERIC(10,2),

    CONSTRAINT fk_patient
        FOREIGN KEY (patient_key)
        REFERENCES dim_patient(patient_key),

    CONSTRAINT fk_doctor
        FOREIGN KEY (doctor_key)
        REFERENCES dim_doctor(doctor_key),

    CONSTRAINT fk_clinic
        FOREIGN KEY (clinic_key)
        REFERENCES dim_clinic(clinic_key),

    CONSTRAINT fk_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key)
);



SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
      'dim_patient',
      'dim_doctor',
      'dim_clinic',
      'dim_date',
      'fact_appointment'
  )
ORDER BY table_name;


SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.constraint_schema = kcu.constraint_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.constraint_schema = tc.constraint_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'fact_appointment'
ORDER BY kcu.column_name;


SELECT 'dim_patient' AS table_name, COUNT(*) AS row_count FROM dim_patient
UNION ALL
SELECT 'dim_doctor', COUNT(*) FROM dim_doctor
UNION ALL
SELECT 'dim_clinic', COUNT(*) FROM dim_clinic
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'fact_appointment', COUNT(*) FROM fact_appointment;


-- =========================================================
-- Task 4.4: Verify Warehouse Row Counts
-- =========================================================

SELECT 'dim_patient' AS table_name, COUNT(*) AS row_count
FROM dim_patient

UNION ALL

SELECT 'dim_doctor', COUNT(*)
FROM dim_doctor

UNION ALL

SELECT 'dim_clinic', COUNT(*)
FROM dim_clinic

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dim_date

UNION ALL

SELECT 'fact_appointment', COUNT(*)
FROM fact_appointment;

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

