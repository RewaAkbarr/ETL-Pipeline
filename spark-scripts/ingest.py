from pyspark.sql import SparkSession
from pyspark.sql.functions import to_date, col, regexp_replace, round, when, concat, lit

spark = SparkSession.builder.getOrCreate()

spark.conf.set("spark.sql.legacy.timeParserPolicy", "LEGACY")
df = spark.read.format("csv").option("header", "true").load("/data/financial_sample.csv")

df = df.withColumn("Date", to_date(col("Date"), "MM/dd/yyyy"))
for column in ['Units Sold', 'Manufacturing Price', 'Sale Price', 'Gross Sales', 'Discounts', ' Sales', 'COGS', 'Profit']:
    df = df.withColumn(column, regexp_replace(col(column), "[\$,]", "").cast("float"))

df = df.withColumn("Gross Sales", when(round(col("Sale Price") * col("Units Sold"), 2) != col("Gross Sales"), round(col("Sale Price") * col("Units Sold"), 2)).otherwise(col("Gross Sales")))

df = df.withColumn("Profit", when(round(col(" Sales") - col("COGS"), 2) != col("Profit"), round(col(" Sales") - col("COGS"), 2)).otherwise(col("Profit")))

df = df.withColumn(" Sales", when(round(col("Gross Sales") - col("Discounts"), 2) != col(" Sales"), round(col("Gross Sales") - col("Discounts"), 2)).otherwise(col(" Sales")))

for column in ['Manufacturing Price', ,'Sale Price', 'Gross Sales', 'Discounts', ' Sales', 'COGS', 'Profit']:
    df = df.withColumn(column, concat(lit("$"), col(column)))
sortedDf = df.sort("Date", "Year", "Month Number", "Month Name")

sortedDf.write.format("csv").option("header", "true").mode('overwrite').save("/data/financial_sample_clean.csv")
sortedDf.show()