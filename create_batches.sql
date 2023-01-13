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


---- STEP 1: Create an id for each record 
IF OBJECT_ID('tempdb..##TABLE_1') IS NOT NULL --vue par associate
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

-------------------------------------XML Export --------------------------------------------------------
SELECT batch_number,
		filename,
		(
		SELECT
			 @code_version																					AS 'xml/version'
			,@generation_date																				AS 'xml/generation_date'
			,LOWER(NEWID())																					AS 'xml/id'
			,@year																							AS 'general/parameters/year'

			FOR XML PATH(''),TYPE)																			AS associate																					
			----- end associate
		FROM ##TABLE_1 a
		WHERE 
			(@sample_auto = 1 AND EXISTS (SELECT 1 FROM ##SAMPLE_TEST st WHERE st.associateId = a.associateId))
			OR @sample_auto = 0 
			AND a.batch_number = b.batch_number
		FOR XML PATH('associates'),TYPE
		)																									AS [nealan/data]
	FOR XML PATH(''),TYPE, ROOT('root')
	)																					AS xml_file
	FROM ##BATCH_NUMBER b
OPTION(RECOMPILE)
END


FLOOR(((ROW_NUMBER() OVER (ORDER BY c.associateId))-1)/10000)+1								AS batch_number,