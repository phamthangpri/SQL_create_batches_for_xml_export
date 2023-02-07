Explaination:
1. I'm gonna split the table_contract to batches of 10 000 rows
2. Then I'll create a temporary table ##BATCH_NUMBER with the file name and the number of the batch (for ex: filename_batch_1_8.xml ~ that means the file 1 on 8 total)
3. In the code to export XML, I need to join this temporary table to the data to export.