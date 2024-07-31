# XML Batch File Generator
## Overview
This project contains a stored procedure that generates XML files in batches from a table of contracts. The procedure splits the data into batches of 10,000 rows and creates temporary tables to manage the file names and batch numbers.

## Author
Thi Thang Pham

## Description
The stored procedure performs the following steps:

1. Splits the table_contract into batches of 10,000 rows.
2. Creates a temporary table ##BATCH_NUMBER with the file name and batch number.
3. Joins the temporary table to the data to export and generates the XML files.

## Getting Started
### Prerequisites
Microsoft SQL Server
### Installation
Create the stored procedure in your SQL Server database by running the provided SQL script.
### Usage
Call the stored procedure sp_generate_xml with the required parameters:
```
EXEC sp_generate_xml @quarter = 'Q1', @generation_date = '2024-07-31', @year = 2024;
```
### Parameters
+ @quarter (VARCHAR(2)): Quarter for which to generate the XML files (e.g., 'Q1', 'Q2', 'Q3', 'Q4').
+ @generation_date (SMALLDATETIME, NULL): Generation date to include in the file names.
+ @year (SMALLINT, NULL): Year to include in the file names.

## Procedure Steps
### Step 1: Create an ID for Each Record
This step creates a temporary table ##TABLE_1 with a batch number and contract ID for each record in table_contract.

### Step 2: Create Batches to Export
This step creates a temporary table ##BATCH_NUMBER with the batch number and file name for each batch.

### Step 3: XML Export
This step generates the XML files for each batch.


### Example
To generate XML files for the first quarter of 2024 with a generation date of July 31, 2024, and the year 2024:
