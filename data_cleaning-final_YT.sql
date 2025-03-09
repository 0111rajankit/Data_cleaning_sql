SELECT * FROM sales
---------------------------------------------------------
--Step 1 :- To check for duplicates
--Step 2 :- Check For Null Values
--Step 3 :- Treating Null values
--Step 4 :- Handling Negative values
--Step 5 :- Fixing Inconsistent Date Formats & Invalid Dates
--Step 6 :- Fixing Invalid Email Addresses
--Step 7 :- Checking the datatype
--------------------------------------------------------------------------------------------
--Step 1 :- To check for duplicates

WITH CTE AS (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY transaction_id) row_num
FROM sales
)
DELETE FROM CTE 
WHERE row_num >1

SELECT *
FROM CTE 
where transaction_id IN (1001,1004,1030,1074)


--------------------------------------------------------------------------------------------
--Step 2 :- Check For Null Values

SELECT * FROM sales 
WHERE transaction_id is null
OR 
customer_id IS NULL
OR 
customer_name IS NULL
--------------------------------------------------------------------------------------------
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;
--------------------------------------------------------------------------------------------

--Step 3 :- Treating Null values

SELECT DISTINCT category from sales

-----------------category
UPDATE sales 
SET category='Unknown'
WHERE category IS NULL

-----------------customer_address
UPDATE sales 
SET customer_address='Not Available'
WHERE customer_address IS NULL

-----------------payment_method

SELECT DISTINCT payment_method from sales

UPDATE sales 
SET payment_method='Credit Card'
WHERE payment_method IN ('creditcard','CC','credit')

UPDATE sales 
SET payment_method='Cash'
WHERE payment_method IS NULL

-----------------delivery_status

SELECT DISTINCT delivery_status from sales

UPDATE sales 
SET delivery_status='Not Delivered'
WHERE delivery_status IS NULL


-----------------price
----MEAN
---2510.76

SELECT AVG(price) from sales

----MODE

SELECT price,count(*) as max_count
from sales
group by price
order by max_count desc

----Median
--2530.75

SELECT DISTINCT 
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) OVER() AS median
FROM sales;

------------------------------------------
select category, avg(price) as avg_price
from sales
group by category 

--Unknown	         2511.416405
--Books	             2574.457346
--Home & Kitchen	 2507.058378
--Toys	             2235.471689
--Electronics	     2663.927840
--Clothing	         2539.278187

--Unknown
UPDATE sales
SET price=2511.41
WHERE price is NULL and category='Unknown'

--Books
UPDATE sales
SET price=2574.45
WHERE price is NULL and category='Books'

--Home & Kitchen	 2507.05
UPDATE sales
SET price=2507.05
WHERE price is NULL and category='Home & Kitchen'

--Toys	             2235.47
UPDATE sales
SET price=2235.47
WHERE price is NULL and category='Toys'

--Electronics	     2663.92
UPDATE sales
SET price=2663.92
WHERE price is NULL and category='Electronics'

---Clothing	         2539.27
UPDATE sales
SET price=2539.27
WHERE price is NULL and category='Clothing'

select * from sales
--------------------------------------------------------------------------------------------
--Step 4 :- Handling Negative values

SELECT * FROM SALES
where quantity <0

UPDATE sales
SET quantity = ABS(quantity)
WHERE quantity <0

UPDATE sales 
SET total_amount= price*quantity
WHERE total_amount IS NULL OR total_amount <> price*quantity


SELECT * FROM SALES 
WHERE customer_id iS NULL

SELECT * FROM SALES 
WHERE customer_name iS NULL

update sales
set customer_name='User'
where customer_name is NULL

--------------------------------------------------------------------------------------------

--Step 5 :- Fixing Inconsistent Date Formats & Invalid Dates

select * from sales
WHERE purchase_date ='2024-02-30'

UPDATE sales 
SET purchase_date =
	CASE 
		WHEN TRY_CONVERT(DATE,purchase_date, 103) IS NOT NULL
		THEN TRY_CONVERT(DATE,purchase_date, 103)
	ELSE NULL
END;

--------------------------------------------------------------------------------------------
--Step 6 :- Fixing Invalid Email Addresses

SELECT * FROM SALES
WHERE email NOT LIKE '%@%'

UPDATE sales
SET email= NULL 
WHERE email NOT LIKE '%@%'

--------------------------------------------------------------------------------------------
--Step 7 :- Checking the datatype

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='sales'

ALTER TABLE sales
ALTER COLUMN purchase_date DATE;