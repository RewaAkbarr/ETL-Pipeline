SET DateStyle = 'MDY';
COPY Ecommerce FROM '/data/ecommerce-session-bigquery.csv' DELIMITER ',' CSV HEADER;
