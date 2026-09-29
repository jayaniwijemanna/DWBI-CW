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