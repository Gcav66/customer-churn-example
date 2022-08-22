#!/bin/bash  

fname="snowsql_staging.sql"

split -l 5000000 user_logs.csv user_logs_small.csv

# Update database name if different from "KKBOX" example
echo "
USE database KKBOX;

CREATE STAGE IF NOT EXISTS customer_churn;

" > $fname

echo "
PUT file://"${PWD}"/transactions.csv @customer_churn;
PUT file://"${PWD}"/transactions_v2.csv @customer_churn;
PUT file://"${PWD}"/members_v3.csv @customer_churn;
PUT file://"${PWD}"/user_logs_v2.csv @customer_churn;
" >> $fname

for i in $(find . -name 'user_logs_sm*')
do
 	echo "PUT file://"${PWD}${i:1}" @customer_churn;" >> $fname
done

for i in $(find . -name 'user_logs_sm*')
do
    fileArray+=("'"${i:2}".gz'")
	fileArray+=(", ")
done

# Update the database, schema, and table names for the COPY statements below if different from default used in example
echo "
COPY INTO KKBOX.CHURN.TRANSACTIONS FROM @customer_churn files = ('transactions.csv.gz', 'transactions_v2.csv.gz') file_format = (type = CSV skip_header = 1);
COPY INTO KKBOX.CHURN.MEMBERS FROM @customer_churn files = ('members_v3.csv.gz') file_format = (type = CSV skip_header = 1);

COPY INTO KKBOX.CHURN.USER_LOGS FROM @customer_churn files = ('user_logs_v2.csv.gz') file_format = (type = CSV skip_header = 1);

COPY INTO KKBOX.CHURN.USER_LOGS FROM @customer_churn files = ("${fileArray[@]:0:19}") file_format = (type = CSV skip_header = 1);
COPY INTO KKBOX.CHURN.USER_LOGS FROM @customer_churn files = ("${fileArray[@]:20:19}") file_format = (type = CSV skip_header = 1);
COPY INTO KKBOX.CHURN.USER_LOGS FROM @customer_churn files = ("${fileArray[@]:40:19}") file_format = (type = CSV skip_header = 1);
COPY INTO KKBOX.CHURN.USER_LOGS FROM @customer_churn files = ("${fileArray[@]:60:19}") file_format = (type = CSV skip_header = 1);
COPY INTO KKBOX.CHURN.USER_LOGS FROM @customer_churn files = ("${fileArray[@]:80:19}") file_format = (type = CSV skip_header = 1);
COPY INTO KKBOX.CHURN.USER_LOGS FROM @customer_churn files = ("${fileArray[@]:100:19}") file_format = (type = CSV skip_header = 1);
COPY INTO KKBOX.CHURN.USER_LOGS FROM @customer_churn files = ("${fileArray[@]:120:19}") file_format = (type = CSV skip_header = 1);
COPY INTO KKBOX.CHURN.USER_LOGS FROM @customer_churn files = ("${fileArray[@]:140:17}") file_format = (type = CSV skip_header = 1);

" >> $fname

echo "
SELECT * FROM KKBOX.CHURN.TRANSACTIONS LIMIT 10;
SELECT * FROM KKBOX.CHURN.USER_LOGS LIMIT 10;
SELECT * FROM KKBOX.CHURN.MEMBERS LIMIT 10;

DROP STAGE IF EXISTS customer_churn; 
" >> $fname
echo "The file snowsql_staging.sql has been created in the local directory"

# The following command can be used to find all the split user_logs_small files and remove them.
# However, these files will be needed by SnowSQL first to copy the data into the USER_LOGS table. 
# After uploading the user logs data into Snowflake, you can delete these small files manually or by using the below command. 

# find . -type f -name user_logs_small\* -exec rm -f {} \;

echo "The script is complete"