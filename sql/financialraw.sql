CREATE TABLE financial_raw (
    Segment VARCHAR(255),
    Country VARCHAR(255),
    Product VARCHAR(255),
    Discount_Band VARCHAR(255),
    Units_Sold FLOAT,
    Manufacturing_Price VARCHAR(255),
    Gross_Sales VARCHAR(255),
    Discounts VARCHAR(255),
    Sales VARCHAR(255),
    COGS VARCHAR(255),  
    Profit VARCHAR(255),
    Date DATE,
    Month_Number INT,
    Month_Name VARCHAR(255),
    Year VARCHAR(50)
);

CREATE TABLE Country (
    Country_ID SERIAL PRIMARY KEY,
    Country_Name VARCHAR(255)
);

CREATE TABLE Product (
    Product_ID SERIAL PRIMARY KEY,
    Product_Name VARCHAR(255),
    Manufacturing_Price FLOAT,
    Sale_Price FLOAT
);

CREATE TABLE Sales (
    Sales_ID SERIAL PRIMARY KEY,
    Country_ID INT,
    Product_ID INT,
    Segment VARCHAR(255),
    Discount_Band VARCHAR(255),
    Units_Sold FLOAT,
    Gross_Sales VARCHAR(255),
    Discounts VARCHAR(255),
    Sales VARCHAR(255),
    COGS VARCHAR(255),
    Profit VARCHAR(255),
    Date DATE,
    Month_Number INT,
    Month_Name VARCHAR(255),
    Year VARCHAR(50),
    FOREIGN KEY (Country_ID) REFERENCES Country(Country_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);