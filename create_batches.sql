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



DECLARE	@filename VARCHAR(200)
		;
SET @filename = 'prefix_file_name' + CAST(@year AS VARCHAR(4)) + '.' + @quarter
				+ '.' CONVERT(VARCHAR,@generation_date,20)


---- STEP 1: Create an id for each record 
IF OBJECT_ID('tempdb..##TABLE_1') IS NOT NULL 
        DROP TABLE ##TABLE_1
	SELECT  
		FLOOR(((ROW_NUMBER() OVER (ORDER BY c.contract_id))-1)/10000)+1								AS batch_number,
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
					 FROM ##TABLE_1) AS VARCHAR(20))			AS filename
INTO ##BATCH_NUMBER
FROM ##TABLE_1
GROUP BY batch_number
ORDER BY batch_number

-------STEP 3 : XML Export --------------------------------------------------------
SELECT batch_number,
		filename,
		(SELECT
			 @generation_date																				AS 'xml/generation_date'
			,@quarter																						AS 'xml/quarter' 
			,contract_id																					AS 'xml/id'
			,@year																							AS 'general/parameters/year'
		FROM ##TABLE_1 a
		WHERE a.batch_number = b.batch_number
	FOR XML PATH(''),TYPE, ROOT('root')	)																				AS xml_file
	FROM ##BATCH_NUMBER b




END
GO
