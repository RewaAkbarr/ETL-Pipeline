SET DateStyle = 'MDY';
COPY financial_raw FROM '/data/new/financial_sample_clean.csv' DELIMITER ',' CSV HEADER;

-- table country
INSERT INTO Country (Country_Name)
SELECT DISTINCT Country FROM financial_raw;

-- table Product
INSERT INTO Product (Product_Name, Manufacturing_Price, Sale_Price)
SELECT DISTINCT Product, REPLACE(Manufacturing_Price, '$', '')::double precision, REPLACE(Sale_Price, '$', '')::double precision FROM financial_raw;

-- table Sales
INSERT INTO Sales (Country_ID, Product_ID, Segment, Discount_Band, Units_Sold, Gross_Sales, Discounts, Sales, COGS, Profit, Date, Month_Number, Month_Name, Year)
SELECT Country.Country_ID, Product.Product_ID, Segment, Discount_Band, Units_Sold, Gross_Sales, Discounts, Sales, COGS, Profit, Date, Month_Number, Month_Name, Year
FROM financial_raw
JOIN Country ON financial_raw.Country = Country.Country_Name
JOIN Product ON financial_raw.Product = Product.Product_Name
ORDER BY Date, Month_Number, Month_Name, Year;