CREATE DATABASE IF NOT EXISTS upi_project;
USE upi_project;

CREATE TABLE IF NOT EXISTS monthly_upi (
    month DATE,
    banks_live INT,
    volume_mn DECIMAL(12,2),
    value_cr DECIMAL(14,2),
    days_in_month INT,
    avg_daily_volume_mn DECIMAL(10,2),
    avg_ticket_rs DECIMAL(10,2)
);
USE upi_project;