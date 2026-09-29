-- ============================================================
-- Lotus Care Data Warehouse
-- Task 4 - Load Script
-- ============================================================

-- Load dimension tables first

\copy dim_patient FROM 'C:/DW/warehouse_csv/dim_patient.csv' CSV HEADER;

\copy dim_doctor FROM 'C:/DW/warehouse_csv/dim_doctor.csv' CSV HEADER;

\copy dim_clinic FROM 'C:/DW/warehouse_csv/dim_clinic.csv' CSV HEADER;

\copy dim_date FROM 'C:/DW/warehouse_csv/dim_date.csv' CSV HEADER;


-- Load fact table last

\copy fact_appointment FROM 'C:/DW/warehouse_csv/fact_appointment.csv' CSV HEADER;