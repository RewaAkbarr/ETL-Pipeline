import datetime
import pyspark
import os
from dotenv import load_dotenv
from pathlib import Path
import psycopg2
import pandas as pd

# Load environment variables
dotenv_path = Path('/app/.env')
load_dotenv(dotenv_path=dotenv_path)

# Get environment variables
postgres_host = 'dataeng-postgres'
postgres_db = 'postgres_db'
postgres_user = 'user'
postgres_password = 'password'
postgres_port = '5432'

# Create SparkContext
sparkcontext = pyspark.SparkContext.getOrCreate(
    conf=(pyspark.SparkConf().setAppName("Dibimbing"))
)
sparkcontext.setLogLevel("WARN")

spark = pyspark.sql.SparkSession(sparkcontext.getOrCreate())

# Create a connection to the database
conn = psycopg2.connect(
    host=postgres_host,
    port=postgres_port,
    dbname=postgres_db,
    user=postgres_user,
    password=postgres_password
)

# Create a cursor object
cur = conn.cursor()

# Execute a query
cur.execute("SELECT * FROM coffee_shop_sales")

# Fetch the results
rows = cur.fetchall()

# Convert the results to a pandas DataFrame
df_pd = pd.DataFrame(rows, columns=[desc[0] for desc in cur.description])

# Fix for iteritems issue
df_pd.iteritems = df_pd.items

# Convert datetime.time columns to string manually
for col in df_pd.columns:
    if df_pd[col].dtype == 'object' and isinstance(df_pd[col].iloc[0], datetime.time):
        df_pd[col] = df_pd[col].astype(str)

# Convert the pandas DataFrame to a Spark DataFrame
df = spark.createDataFrame(df_pd)

# Create temporary view for SQL queries
df.createOrReplaceTempView("sales")

# Remove missing and duplicate data, add 'total_price' column
df_cleaned = spark.sql("""
    SELECT DISTINCT *, concat('$', format_number((transaction_qty * unit_price), 2)) as total_price
    FROM sales
    WHERE transaction_id IS NOT NULL 
    AND transaction_date IS NOT NULL 
    AND transaction_time IS NOT NULL 
    AND transaction_qty IS NOT NULL 
    AND store_id IS NOT NULL 
    AND product_id IS NOT NULL 
    AND unit_price IS NOT NULL 
    AND product_category IS NOT NULL 
    AND product_type IS NOT NULL 
    AND product_detail IS NOT NULL
""")

# Send back to database
df_cleaned.write \
    .format("jdbc") \
    .option("url", f"jdbc:postgresql://{postgres_host}:{postgres_port}/{postgres_db}") \
    .option("dbtable", "coffee_shop_sales_cleaned") \
    .option("user", postgres_user) \
    .option("password", postgres_password) \
    .option("driver", "org.postgresql.Driver") \
    .mode("overwrite") \
    .save()

# Close the cursor and connection
cur.close()
conn.close()