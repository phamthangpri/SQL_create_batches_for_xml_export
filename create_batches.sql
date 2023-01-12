/*************************************************************************************************************
 Author:            Thi Thang Pham
 Description:       Generat XML by batch
					
 Parameter(s):      @quarter
					@generation_date 
					@year

 *************************************************************************************************************/

 
CREATE OR ALTER PROCEDURE sp_generate_xml
			@quarter VARCHAR(2),
			@generation_date SMALLDATETIME NULL,
			@year SMALLINT = NULL

AS
BEGIN 



DECLARE	
		@startdate DATE = NULL, 
		@enddate DATE = NULL,
		@filename VARCHAR(200),
		@t1 DATETIME,
		@t2 DATETIME
		;
SET @filename = 'prefix_file_name' + CAST(@year AS VARCHAR(4)) + '.' + @quarter
				+ '.' CONVERT(VARCHAR,@generation_date,20)
-------------------------------------XML Export --------------------------------------------------------
---Create different batches to export -------------

IF OBJECT_ID('tempdb..##BATCH_NUMBER') IS NOT NULL 
		DROP TABLE ##BATCH_NUMBER
SELECT batch_number,
	   @filename 
	   + ' '+ CAST(batch_number AS VARCHAR(20)) 
	   + '.' + CAST((SELECT MAX(batch_number) 
					 FROM ##TABLE_1) AS VARCHAR(20))			AS filename
INTO ##BATCH_NUMBER
FROM ##TABLE_1
GROUP BY batch_number
ORDER BY batch_number


SELECT batch_number,
		filename,
	(SELECT 
		(------children 1
		SELECT
			 @code_version																					AS 'xml/version'
			,@generation_date																				AS 'xml/generation_date'
			,LOWER(NEWID())																					AS 'xml/id'

FLOOR(((ROW_NUMBER() OVER (ORDER BY c.associateId))-1)/10000)+1								AS batch_number,