SET DateStyle = 'MDY';
COPY coffee_shop_sales FROM '/data/Coffee_Shop_Sales.csv' DELIMITER ',' CSV HEADER;