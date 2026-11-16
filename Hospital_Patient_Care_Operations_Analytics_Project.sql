CREATE DATABASE hospital_analytics;
USE hospital_analytics;


/* Business Problem:
CarePlus Hospital wants to analyze patient appointments, treatment activity, 
doctor performance, room utilization, waiting times, and operational problems. 
The objective is to use SQL-based analysis to identify patterns and provide 
data-driven recommendations.*/


-- Step 1 : patients table
CREATE TABLE patients (
   patient_id VARCHAR(20) PRIMARY KEY,
   patient_name VARCHAR(100) NOT NULL,
   age INT,
   gender VARCHAR(20),
   city VARCHAR(50),
   patient_type VARCHAR(20),
   preferred_time_slot VARCHAR(20),
   registration_date DATE);

SELECT * FROM patients;
   
-- step 2 : doctors table
CREATE TABLE doctors (
     doctor_id VARCHAR(10) PRIMARY KEY,
     doctor_name VARCHAR(100) NOT NULL,
     specialty VARCHAR(50),
     hire_date DATE,
     rating DECIMAL(3,2),
     employment_type VARCHAR(20),
     is_active VARCHAR(5));
SELECT * FROM doctors;
     
-- step 3 : rooms table
CREATE TABLE rooms (
    room_id VARCHAR(10) PRIMARY KEY,
    room_type VARCHAR(30),
    floor INT,
    equipment_type VARCHAR(50),
    capacity INT,
    last_maintenance_date DATE,
    is_available VARCHAR(5));
    
SELECT * FROM rooms;

-- step 4 : appointments table
CREATE TABLE appointments (
	appointment_id VARCHAR(20) PRIMARY KEY,
    patient_id VARCHAR(20) NOT NULL,
    appointment_date DATE,
    doctor_id VARCHAR(10),
    service_type VARCHAR(30),
    priority VARCHAR(20),
    estimated_cost DECIMAL(10,2),
    booking_channel VARCHAR(20),
    FOREIGN KEY (patient_id)
         REFERENCES patients(patient_id),
	FOREIGN KEY (doctor_id)
         REFERENCES doctors(doctor_id));
		
SELECT * FROM appointments;

-- step 5 : treatments table
CREATE TABLE treatments (
    treatment_id VARCHAR(20) PRIMARY KEY,
    appointment_id VARCHAR(20) NOT NULL,
    doctor_id VARCHAR(10),
    room_id VARCHAR(10),
    actual_treatment_date DATE,
    status VARCHAR(20),
    treatment_attempt INT,
    treatment_duration_min INT,
    waiting_time_min INT,
    treatment_cost DECIMAL(10,2),
    FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id),
    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),
    FOREIGN KEY (room_id)
        REFERENCES rooms(room_id));
SELECT * FROM treatments;

SELECT * FROM patients LIMIT 10;
SELECT * FROM doctors LIMIT 10;
SELECT * FROM rooms LIMIT 10;
SELECT * FROM appointments LIMIT 10;
SELECT * FROM treatments LIMIT 10;






SHOW TABLES;

-- =============================================
-- Sprint 3: Basic Analysis / Data Exploration
-- =============================================
-- Q1. Total number of patients
SELECT COUNT(*) AS total_patients
FROM patients;

-- Q2. Total appointments
SELECT COUNT(*) AS total_appointments
FROM appointments;

-- Q3. Total treatment records
SELECT COUNT(*) AS total_treatment
FROM treatments;

-- Q4. Different medical service types
SELECT service_type, COUNT(*) AS appointment_count
From appointments
GROUP BY service_type
ORDER BY appointment_count DESC;

-- Q5. Active doctors
SELECT COUNT(*) AS active_doctors
FROM doctors
WHERE is_active = 'Yes';

-- Q6. Different room types
SELECT
    room_type,
    COUNT(*) AS room_count
FROM rooms
GROUP BY room_type
ORDER BY room_count DESC;

-- Q7. Total estimated appointment value
SELECT
    SUM(estimated_cost) AS total_estimated_value
FROM appointments;

-- Q8. Average treatment duration
SELECT
    AVG(treatment_duration_min) AS avg_treatment_duration
FROM treatments;

-- Sprint 4: Objective-Based Analysis
-- OBJECTIVE 1 — Patient & Appointment Demand
-- Q1. Compare appointment volume across cities.
SELECT
    p.city,
    COUNT(a.appointment_id) AS total_appointments
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.city
ORDER BY total_appointments DESC;

-- Q2. Compare appointments across service types and priorities.?
SELECT
    service_type,
    priority,
    COUNT(*) AS appointment_count
FROM appointments
GROUP BY
    service_type,
    priority
ORDER BY
    service_type,
    appointment_count DESC;

-- Q3. Examine appointment volume over time
SELECT
    YEAR(appointment_date) AS year,
    MONTH(appointment_date) AS month_number,
    MONTHNAME(appointment_date) AS month,
    COUNT(*) AS appointment_count
FROM appointments
GROUP BY
    YEAR(appointment_date),
    MONTH(appointment_date),
    MONTHNAME(appointment_date)
ORDER BY
    year,
    month_number;

-- Q4. Compare estimated appointment value across patient types.
SELECT
    p.patient_type,
    COUNT(a.appointment_id) AS appointments,
    SUM(a.estimated_cost) AS estimated_value
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_type
ORDER BY estimated_value DESC;

-- Q5. Examine booking channels and their contribution to demand.
SELECT
    booking_channel,
    COUNT(*) AS appointments,
    SUM(estimated_cost) AS estimated_value
FROM appointments
GROUP BY booking_channel
ORDER BY appointments DESC;

-- OBJECTIVE 2 — Patient Appointment Behaviour
-- Q6. Compare patients by number of appointments.
SELECT
    p.patient_id,
    p.patient_name,
    COUNT(a.appointment_id) AS appointment_count
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY
    p.patient_id,
    p.patient_name
HAVING COUNT(a.appointment_id) > 1
ORDER BY appointment_count DESC;

-- Q7. Identify patients with higher cumulative estimated appointment value.
SELECT
    p.patient_id,
    p.patient_name,
    SUM(a.estimated_cost) AS total_estimated_value
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY
    p.patient_id,
    p.patient_name
ORDER BY total_estimated_value DESC
LIMIT 10;

-- Q8. Compare patient activity across cities.
SELECT
    p.city,
    COUNT(DISTINCT p.patient_id) AS patients,
    COUNT(a.appointment_id) AS appointments
FROM patients p
LEFT JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.city
ORDER BY appointments DESC;


-- Q9. Compare General, Corporate, and Insurance patients.
SELECT
    p.patient_type,
    COUNT(DISTINCT p.patient_id) AS patients,
    COUNT(a.appointment_id) AS appointments,
    SUM(a.estimated_cost) AS estimated_value
FROM patients p
LEFT JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_type;

-- 10. Examine patient booking patterns over time.
SELECT
    YEAR(a.appointment_date) AS year,
    MONTH(a.appointment_date) AS month_number,
    MONTHNAME(a.appointment_date) AS month,
    COUNT(DISTINCT a.patient_id) AS active_patients,
    COUNT(a.appointment_id) AS total_bookings
FROM appointments a
GROUP BY
    YEAR(a.appointment_date),
    MONTH(a.appointment_date),
    MONTHNAME(a.appointment_date)
ORDER BY
    year,
    month_number;
    
-- new Query
----- * Which patients have never booked more than one appointment? ------
SELECT
    p.patient_id,
    p.patient_name,
    COUNT(a.appointment_id) AS appointment_count
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.patient_name
HAVING COUNT(a.appointment_id) = 1;

-- OBJECTIVE 3 — Treatment Performance
-- Q11. Compare treatment outcomes across cities.
SELECT
    p.city,
    t.status,
    COUNT(t.treatment_id) AS treatment_count
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY
    p.city,
    t.status
ORDER BY
    p.city,
    treatment_count DESC;

-- Q12. Examine treatment duration and waiting time.
SELECT
    ROUND(AVG(treatment_duration_min), 2) AS avg_treatment_duration,
    ROUND(AVG(waiting_time_min), 2) AS avg_waiting_time,
    MIN(treatment_duration_min) AS min_treatment_duration,
    MAX(treatment_duration_min) AS max_treatment_duration,
    MIN(waiting_time_min) AS min_waiting_time,
    MAX(waiting_time_min) AS max_waiting_time
FROM treatments;

-- Q13. Compare Completed, Cancelled, No-Show, Rescheduled, and In Progress outcomes.
SELECT
    status,
    COUNT(*) AS treatment_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM treatments),
        2
    ) AS percentage
FROM treatments
GROUP BY status
ORDER BY treatment_count DESC;

-- Q14. Identify areas with higher treatment activity or poorer outcomes.
SELECT
    p.city,
    COUNT(t.treatment_id) AS total_treatments,
    SUM(
        CASE
            WHEN t.status IN ('Cancelled', 'No-Show', 'Rescheduled')
            THEN 1
            ELSE 0
        END
    ) AS non_completed_treatments,
    ROUND(
        SUM(
            CASE
                WHEN t.status IN ('Cancelled', 'No-Show', 'Rescheduled')
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(t.treatment_id),
        2
    ) AS non_completed_percentage
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY p.city
ORDER BY total_treatments DESC;

-- Q15. Compare treatment performance over time.
SELECT
    YEAR(actual_treatment_date) AS year,
    MONTH(actual_treatment_date) AS month_number,
    MONTHNAME(actual_treatment_date) AS month,
    COUNT(*) AS total_treatments,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN status = 'No-Show' THEN 1 ELSE 0 END) AS no_show,
    SUM(CASE WHEN status = 'Rescheduled' THEN 1 ELSE 0 END) AS rescheduled,
    SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) AS in_progress
FROM treatments
GROUP BY
    YEAR(actual_treatment_date),
    MONTH(actual_treatment_date),
    MONTHNAME(actual_treatment_date)
ORDER BY year, month_number;
    
-- New Query --
----- Q. 6. Which room types are used most frequently for treatments? -----
SELECT
    r.room_type,
    COUNT(t.treatment_id) AS treatment_count
FROM rooms r
JOIN treatments t
    ON r.room_id = t.room_id
GROUP BY r.room_type
ORDER BY treatment_count DESC;


-- OBJECTIVE 4 — Doctor & Room Performance
-- Q16. Compare the number of treatments handled by doctors.
SELECT
    d.doctor_id,
    d.doctor_name,
    COUNT(t.treatment_id) AS treatments_handled
FROM doctors d
LEFT JOIN treatments t
    ON d.doctor_id = t.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name
ORDER BY treatments_handled DESC;

-- Q17. Compare doctor performance across treatment outcomes.
SELECT
    d.doctor_id,
    d.doctor_name,
    d.specialty,
    d.rating,
    COUNT(t.treatment_id) AS treatment_count
FROM doctors d
LEFT JOIN treatments t
    ON d.doctor_id = t.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name,
    d.specialty,
    d.rating
ORDER BY treatment_count DESC;

-- Q18. Examine treatment duration across doctors.
SELECT
    d.doctor_name,
    AVG(t.treatment_duration_min) AS avg_duration
FROM doctors d
JOIN treatments t
    ON d.doctor_id = t.doctor_id
GROUP BY d.doctor_name
ORDER BY avg_duration DESC;

-- Q19. Compare room usage across room types and equipment types.
SELECT
    r.room_type,
    r.equipment_type,
    COUNT(t.treatment_id) AS treatment_count
FROM rooms r
JOIN treatments t
    ON r.room_id = t.room_id
GROUP BY
    r.room_type,
    r.equipment_type
ORDER BY treatment_count DESC;

-- Q20. Evaluate treatment performance across rooms.
SELECT
    r.room_id,
    r.room_type,
    COUNT(t.treatment_id) AS treatment_count,
    ROUND(AVG(t.treatment_duration_min), 2) AS avg_treatment_duration,
    ROUND(AVG(t.waiting_time_min), 2) AS avg_waiting_time
FROM rooms r
JOIN treatments t
    ON r.room_id = t.room_id
GROUP BY
    r.room_id,
    r.room_type
ORDER BY treatment_count DESC;

-- New Query --
----- Q. Which medical specialties handle the highest number of treatments? -----
SELECT
    d.specialty,
    COUNT(t.treatment_id) AS treatment_count,
    COUNT(DISTINCT d.doctor_id) AS doctor_count,
    ROUND(
        COUNT(t.treatment_id) * 1.0 /
        COUNT(DISTINCT d.doctor_id),
        2
    ) AS avg_treatments_per_doctor
FROM doctors d
JOIN treatments t
    ON d.doctor_id = t.doctor_id
GROUP BY d.specialty
ORDER BY treatment_count DESC;

-- OBJECTIVE 5 — Identify Treatment & Appointment Problems
-- Q22. Identify appointments requiring multiple treatment attempts.
SELECT
    appointment_id,
    COUNT(*) AS treatment_attempts
FROM treatments
GROUP BY appointment_id
HAVING COUNT(*) > 1
ORDER BY treatment_attempts DESC;

-- Q23. Find common problem statuses and patterns.
SELECT
    status,
    COUNT(*) AS count_status
FROM treatments
WHERE status IN ('Cancelled', 'No-Show', 'Rescheduled')
GROUP BY status
ORDER BY count_status DESC;


-- Q24. Compare waiting time for appointments with multiple attempts.
SELECT
    t.appointment_id,
    COUNT(*) AS attempts,
    AVG(t.waiting_time_min) AS avg_waiting_time
FROM treatments t
GROUP BY t.appointment_id
HAVING COUNT(*) > 1
ORDER BY avg_waiting_time DESC;

-- Q25. Identify cities or service types with more cancellations, no-shows, or rescheduling.
SELECT
    p.city,
    t.status,
    COUNT(*) AS treatment_count
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN treatments t
    ON a.appointment_id = t.appointment_id
WHERE t.status IN ('Cancelled', 'No-Show', 'Rescheduled')
GROUP BY
    p.city,
    t.status
ORDER BY
    p.city,
    treatment_count DESC;
    
-- Q26. Investigate whether priority level is associated with waiting time or treatment outcomes.
SELECT
    a.priority,
    COUNT(t.treatment_id) AS treatments,
    AVG(t.waiting_time_min) AS avg_waiting_time
FROM appointments a
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY a.priority
ORDER BY avg_waiting_time DESC;

-- Q27. Priority vs treatment outcome
SELECT
    a.priority,
    t.status,
    COUNT(*) AS treatment_count
FROM appointments a
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY
    a.priority,
    t.status
ORDER BY
    a.priority,
    treatment_count DESC;

-- New Query --
----- Q. Which doctors have the most cancelled appointments? -----
SELECT
    t.doctor_id,
    COUNT(*) AS cancelled_treatments
FROM treatments t
WHERE t.status = 'Cancelled'
GROUP BY t.doctor_id
ORDER BY cancelled_treatments DESC;