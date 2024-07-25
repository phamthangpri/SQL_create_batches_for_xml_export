/*************************************************************************************************************
 Author:            Thi Thang Pham
 Description:       Generat XML files by batch
					
 Parameter(s):      @quarter : string
					@generation_date : date
					@year : int

Explaination:
1. I'm gonna split the table_contract to batches of 10 000 rows
2. Then I'll create a temporary table ##BATCH_NUMBER with the file name and the number of the batch (for ex: filename_batch_1_8.xml ~ that means the file 1 on 8 total)
3. In the code to export XML, I need to join this temporary table to the data to export.

The parameters are just in case you need to use the generation date into the filename
 *************************************************************************************************************/

 
CREATE OR ALTER PROCEDURE sp_generate_xml
			@quarter VARCHAR(2),
			@generation_date SMALLDATETIME NULL,
			@year SMALLINT = NULL

AS
BEGIN 


DECLARE	@filename VARCHAR(200)
		;
SET @filename = 'prefix_file_name' + CAST(@year AS VARCHAR(4)) + '.' + @quarter
				+ '.' CONVERT(VARCHAR,@generation_date,20)


---- STEP 1: Create an id for each record 
IF OBJECT_ID('tempdb..##TABLE_1') IS NOT NULL 
        DROP TABLE ##TABLE_1
	SELECT  
		FLOOR(((ROW_NUMBER() OVER (ORDER BY c.contract_id))-1)/10000)+1			AS batch_number, --change 10000 to number of rows that you need for a batch
		c.contract_id 
	INTO ##TABLE_1
	FROM table_contract c
END


--- STEP 2: Create different batches to export -------------

IF OBJECT_ID('tempdb..##BATCH_NUMBER') IS NOT NULL 
		DROP TABLE ##BATCH_NUMBER
	SELECT batch_number,
		@filename 
		+ ' '+ CAST(batch_number AS VARCHAR(20)) 
		+ '.' + CAST((SELECT MAX(batch_number) 
						FROM ##TABLE_1) AS VARCHAR(20))							AS filename
	INTO ##BATCH_NUMBER
	FROM ##TABLE_1
	GROUP BY batch_number
	ORDER BY batch_number
END
-------STEP 3 : XML Export --------------------------------------------------------
SELECT batch_number,
		filename,
		(SELECT
			 @generation_date											AS 'xml/generation_date'
			,@quarter												AS 'xml/quarter' 
			,contract_id												AS 'xml/id'
			,@year													AS 'general/parameters/year'
		FROM ##TABLE_1 a
		WHERE a.batch_number = b.batch_number
	FOR XML PATH(''),TYPE, ROOT('root')	)										AS xml_file
	FROM ##BATCH_NUMBER b

END
GO
