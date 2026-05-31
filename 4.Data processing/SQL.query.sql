select * from `workspace`.`default`.`car_sales_data` limit 100;

SELECT 
    make,
    model,
    SUM(sellingprice) AS total_revenue,
    COUNT(*) AS volume
FROM `workspace`.`default`.`car_sales_data`
GROUP BY make, model
ORDER BY total_revenue DESC
LIMIT 10;

SELECT 
    year,
    AVG(odometer) AS avg_mileage,
    AVG(sellingprice) AS avg_price
FROM `workspace`.`default`.`car_sales_data`
GROUP BY year
ORDER BY year;

SELECT 
    year,
    CASE 
        WHEN odometer < 20000 THEN 'Low'
        WHEN odometer < 80000 THEN 'Medium'
        ELSE 'High'
    END AS mileage_band,
    AVG(sellingprice) AS avg_price
FROM `workspace`.`default`.`car_sales_data`
GROUP BY year, mileage_band;

SELECT 
    state,
    COUNT(*) AS sales_volume,
    AVG(sellingprice) AS avg_price
FROM `workspace`.`default`.`car_sales_data`
GROUP BY state
ORDER BY sales_volume DESC;

SELECT 
    make,
    body,
    COUNT(*) AS sales_count,
    AVG(sellingprice) AS avg_price
FROM `workspace`.`default`.`car_sales_data`
GROUP BY make, body
ORDER BY sales_count DESC;
Time trend
SELECT 
    year,
    COUNT(*) AS sales,
    AVG(sellingprice) AS avg_price
FROM `workspace`.`default`.`car_sales_data`
GROUP BY year
ORDER BY year;


SELECT 
    make,
    AVG((sellingprice - mmr)/mmr) AS avg_margin
FROM `workspace`.`default`.`car_sales_data`
GROUP BY make
ORDER BY avg_margin DESC;

SELECT *
FROM `workspace`.`default`.`car_sales_data`
WHERE sellingprice < mmr
ORDER BY (mmr - sellingprice) DESC;

SELECT 
    seller,
    AVG(sellingprice - mmr) AS profitability
FROM `workspace`.`default`.`car_sales_data`
GROUP BY seller
ORDER BY profitability DESC;


SELECT vin, COUNT(*)
FROM `workspace`.`default`.`car_sales_data`
GROUP BY vin
HAVING COUNT(*) > 1;

SELECT *
FROM (
    SELECT 
        vin,
        make,
        model,
        year,
        sellingprice,

        COUNT(*) OVER (PARTITION BY vin) AS vin_duplicate_count,
        COUNT(*) OVER (PARTITION BY make, model, year, sellingprice) AS similar_duplicate_count,

        CASE 
       WHEN COUNT(*) OVER (PARTITION BY vin) > 1 THEN 'Precise Duplicate (VIN)'
       WHEN COUNT(*) OVER (PARTITION BY make, model, year, sellingprice) > 1 THEN 'Potential Duplicate (Similar Car)'
       ELSE 'Unique'
       END AS duplicate_type

    FROM `workspace`.`default`.`car_sales_data`
) t
WHERE vin_duplicate_count > 1
OR similar_duplicate_count > 1
ORDER BY vin_duplicate_count DESC, similar_duplicate_count DESC;

--- checking make ,model year, selling price and count 

SELECT make, model, year, sellingprice, COUNT(*)
FROM  `workspace`.`default`.`car_sales_data`
GROUP BY make, model, year, sellingprice
HAVING COUNT(*) > 1;


--- Ranking of the car makes 
 SELECT *
FROM (
SELECT 
 make,
model,
COUNT(*) AS sales_count,
AVG(sellingprice) AS avg_price, RANK() OVER (PARTITION BY make ORDER BY COUNT(*) DESC) AS rank_within_make
FROM `workspace`.`default`.`car_sales_data`
 GROUP BY make, model
) t
WHERE rank_within_make <= 3;


---- Checking for market spitting profitability
SELECT 
  make,
  CASE 
 WHEN sellingprice > mmr THEN 'Above Market'  WHEN sellingprice = mmr THEN 'Along Market'
 ELSE 'Below Market'
 END AS price_position,
 COUNT(*) AS volume,
 AVG(sellingprice - mmr) AS avg_diff
FROM `workspace`.`default`.`car_sales_data`
GROUP BY make, price_position;


--- Checking for mileage behaviour in market splits 
SELECT 
  CASE 
   WHEN odometer < 20000 THEN 'Low Mileage'
WHEN odometer < 80000 THEN 'Average Mileage'
ELSE 'High Mileage'
END AS mileage_band,
AVG(sellingprice) AS avg_price,
COUNT(*) AS volume
FROM `workspace`.`default`.`car_sales_data`
GROUP BY mileage_band;


---Ranking to see whom are the best Sellers 
SELECT *
FROM (
    SELECT 
    seller,
    COUNT(*) AS total_sales,
    AVG(sellingprice) AS avg_price,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS Seller_rank
    FROM `workspace`.`default`.`car_sales_data`
    GROUP BY seller
) t
WHERE seller_rank <= 10;

--- Checking  sales day , sales  trends and price trends
SELECT 
CAST(
   CONCAT(
   regexp_extract(saledate, ' (\\d{4}) ', 1), '-',
CASE regexp_extract(saledate, ' (\\w+) ', 1)
WHEN 'Jan' THEN '01'WHEN 'Feb' THEN '02'WHEN 'Mar' THEN '03'
WHEN 'Apr' THEN '04'  WHEN 'May' THEN '05' WHEN 'Jun' THEN '06'
WHEN 'Jul' THEN '07'WHEN 'Aug' THEN '08'WHEN 'Sep' THEN '09'
WHEN 'Oct' THEN '10' WHEN 'Nov' THEN '11'WHEN 'Dec' THEN '12'
END, '-',
LPAD(regexp_extract(saledate, ' (\\d+) \\d{4}', 1), 2, '0')
) AS DATE ) AS sale_day,COUNT(*) AS sales, AVG(sellingprice) AS avg_price
FROM `workspace`.`default`.`car_sales_data`
GROUP BY sale_day
ORDER BY sale_day;

---- how well a vehicle justifies its purchase price through low running costs, depreciation, and longevity and its price %
SELECT  *,
(sellingprice - mmr) / mmr AS price_efficiency,
 PERCENT_RANK() OVER (ORDER BY sellingprice) AS price_percentile
FROM `workspace`.`default`.`car_sales_data`;




