SELECT TOP (1000) [date]
      ,[symbol]
      ,[open]
      ,[close]
      ,[low]
      ,[high]
      ,[volume]
  FROM [stockproject].[dbo].[StockPrices]

SELECT TOP (1000) [Ticker_symbol]
      ,[Security]
      ,[Sector]
      ,[Sub_Industry]
      ,[Headquarter]
  FROM [stockproject].[dbo].[Stockcompanies]
--Checking for null values
 SELECT COUNT(*) FROM stockproject..StockPrices WHERE date IS NULL

 SELECT COUNT(*) FROM stockproject..Stockcompanies WHERE Security IS NULL
 --Checking for Missing Values 
SELECT 
    COUNT(*) - COUNT([symbol]) AS missing_symbol,
    COUNT(*) - COUNT([date]) AS missing_date,
    COUNT(*) - COUNT([open]) AS missing_open,
    COUNT(*) - COUNT([close]) AS missing_close,
    COUNT(*) - COUNT([low]) AS missing_low,
    COUNT(*) - COUNT([high]) AS missing_high,
    COUNT(*) - COUNT([volume]) AS missing_volume
FROM stockproject..StockPrices;


 --Checking for Missing Values
  SELECT 
    COUNT(*) - COUNT(Ticker_symbol) AS missing_Ticker_symbol,
    COUNT(*) - COUNT(Security) AS missing_Security,
    COUNT(*) - COUNT(Sector) AS missing_Sector,
    COUNT(*) - COUNT(Sub_Industry) AS missing_Sub_Industry,
    COUNT(*) - COUNT(Headquarter) AS missing_Headquarter
FROM stockproject..Stockcompanies;


--Checking for Duplicates 
SELECT symbol, date, COUNT(*) 
FROM stockproject..StockPrices
GROUP BY symbol, date
HAVING COUNT(*) > 1;

SELECT Ticker_symbol, COUNT(*) 
FROM stockproject..Stockcompanies
GROUP BY Ticker_symbol 
HAVING COUNT(*) > 1;

 SELECT
   [Ticker_symbol] AS Ticket_symbols
FROM stockproject..Stockcompanies


--Checking for data format
SELECT COUNT(*) 
FROM stockproject..StockPrices 
WHERE ISNUMERIC(volume) = 0;

--Calculate Medium
SELECT DISTINCT 
    sc.Sector, 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sp.[close]) 
        OVER (PARTITION BY sc.Sector) AS Median_Close
FROM stockproject..StockPrices sp
JOIN stockproject..Stockcompanies sc ON sp.symbol = sc.Ticker_symbol;

--Standard Deviation and Variance of Stock Prices
SELECT 
    sc.Sector,
    STDEV(sp.[close]) AS stddev_close,
    VAR(sp.[close]) AS variance_close
FROM stockproject..StockPrices sp
JOIN stockproject..Stockcompanies sc ON sp.symbol = sc.Ticker_symbol
GROUP BY sc.Sector;

--Percentile-Based Analysis
SELECT DISTINCT 
    sc.Sector, 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sp.[close]) 
        OVER (PARTITION BY sc.Sector) AS P25_Close,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sp.[close]) 
        OVER (PARTITION BY sc.Sector) AS P75_Close
FROM stockproject..StockPrices sp
JOIN stockproject..Stockcompanies sc ON sp.symbol = sc.Ticker_symbol;

--Checking for outliers
SELECT COUNT(*) 
FROM stockproject..StockPrices 
WHERE [open] < 0 OR [close] < 0 OR [low] < 0 OR [high] < 0;

--Showing the highest and lowest stock price
SELECT sc.Sector, 
       MAX(sp.[close]) AS Max_Close, 
       MIN(sp.[close]) AS Min_Close
FROM stockproject..StockPrices sp
JOIN stockproject..Stockcompanies sc
ON sp.symbol = sc.Ticker_symbol
GROUP BY sc.Sector;

--Calculates cumulative volume
SELECT symbol, 
       date, 
       volume, 
       SUM(volume) OVER (PARTITION BY symbol ORDER BY date) AS Cumulative_Volume
FROM stockproject..StockPrices;

--Time-Based Analysis
SELECT YEAR(date) AS Year, MONTH(date) AS Month, AVG([close]) AS Avg_Close
FROM stockproject..StockPrices
GROUP BY YEAR(date), MONTH(date)
ORDER BY Year, Month;

 --Average closing price and total volume
SELECT sc.Sector, 
       YEAR(sp.date) AS Year, 
       AVG(sp.[close]) AS Avg_Close, 
       SUM(sp.volume) AS Total_Volume
FROM stockproject..StockPrices sp
JOIN stockproject..Stockcompanies sc ON sp.symbol = sc.Ticker_symbol
GROUP BY sc.Sector, YEAR(sp.date)
ORDER BY sc.Sector, Year;

--Creating view 
CREATE VIEW SectorPerformance AS
SELECT sc.Sector, 
       AVG(sp.[close]) AS Avg_Close, 
       SUM(sp.volume) AS Total_Volume
FROM stockproject..StockPrices sp
JOIN stockproject..Stockcompanies sc ON sp.symbol = sc.Ticker_symbol
GROUP BY sc.Sector;