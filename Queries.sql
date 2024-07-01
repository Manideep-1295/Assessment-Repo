CREATE DATABASE FinalTest
USE FinalTest


CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);

-- Checking purpose
INSERT INTO sales VALUES
(5, 3, '2024-05-25', 2, 6000000.00);

INSERT INTO artworks VALUES
(6, 'Oopiri', 2,'Abstract', 2500000.00);

INSERT INTO sales VALUES
(6, 6, '2024-02-08', 1, 2500000.00)

-- INSERT INTO artists VALUES
-- (6, 'XYZ', 'Spain', 1904)


SELECT * FROM artists
SELECT * FROM artworks
SELECT * FROM sales

-- ### Section 1: 1 mark each

-- 1. Write a query to display the artist names in uppercase.
SELECT UPPER(Name) AS Artist_Name FROM artists

-- 2. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
SELECT SUM(s.total_amount) AS TotalSales
FROM sales s
JOIN artworks a
ON s.artwork_id = a.artwork_id
WHERE a.title = 'Mona Lisa'

-- 3. Write a query to calculate the price of 'Starry Night' plus 10% tax.
SELECT (Price * 1.1) AS PriceWithTax FROM artworks
WHERE title = 'Starry Night'

-- 4. Write a query to extract the year from the sale date of 'Guernica'.
SELECT YEAR(s.sale_date) AS Year
FROM sales s
JOIN artworks a
ON a.artwork_id = s.artwork_id
WHERE a.title = 'Guernica'

-- ### Section 2: 2 marks each

-- 5. Write a query to display artists who have artworks in multiple genres.

SELECT  a.Name,
        COUNT(b.genre) AS No_Of_Arts_in_Genres
FROM artists a
JOIN artworks b
ON a.artist_id = b.artist_id
Group By a.name
HAVING COUNT(b.genre) > 1
Order By a.name


-- 6. Write a query to find the artworks that have the highest sale total for each genre.
GO
SELECT  a.Title,
        a.Genre,
        s.total_amount,
        RANK() OVER (Partition By a.genre ORDER BY s.total_amount DESC) AS Rank
FROM artworks a
JOIN sales s 
ON s.artwork_id = a.artwork_id

-- 7. Write a query to find the average price of artworks for each artist.
SELECT  artist_id,
        AVG(a.price) OVER(Partition By artist_id ORDER BY Price DESC) AS AvgPrice 
FROM artworks a

-- 8. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.

GO
WITH TopArts_CTE
AS(
SELECT  a.artwork_id,
        ar.name,
        SUM(s.quantity) AS TotalQuantity,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS Rank
FROM artworks a
JOIN sales s
ON s.artwork_id = a.artwork_id
JOIN artists ar
ON ar.artist_id = a.artist_id
GROUP BY a.artwork_id, ar.name
)
SELECT * FROM TopArts_CTE
WHERE RANK < 3

-- 9. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.
WITH AvgQuantitySold_CTE
AS(
SELECT  ar.name,
        s.quantity,
        AVG(s.quantity) OVER (PARTITION BY a.artist_id ORDER BY s.quantity) AS Avg
FROM artists ar
JOIN artworks a
ON a.artist_id = ar.artist_id
JOIN sales s
ON s.artwork_id = a.artwork_id
GROUP BY a.artist_id,ar.name,s.quantity
)
SELECT * FROM AvgQuantitySold_CTE
WHERE quantity > AVG
ORDER BY quantity DESC


-- 10. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.
GO
SELECT  i.Country,
        AVG(i.birth_year) OVER (Partition BY i.Country ORDER BY i.artist_id)AS AvgAge 
FROM artists i
GROUP BY i.country,i.artist_id

GO

-- 11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
SELECT * FROM artworks
WHERE Genre = 'Cubism'
INTERSECT(
SELECT * FROM artworks
WHERE Genre = 'Surrealism'
)

-- 12. Write a query to find the artworks that have been sold in both January and February 2024.
SELECT artwork_id
FROM sales
WHERE YEAR(sale_date) = 2024 AND Month(sale_date) = 'January'
INTERSECT(
SELECT artwork_id
FROM sales
WHERE YEAR(sale_date) = 2024 AND Month(sale_date) = 'February'
)
-- 13. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.

WITH AvgArtPrice_CTE
AS(
SELECT  ar.artist_id,
        ar.name,
        AVG(a.price) OVER(Partition By a.artist_id ORDER BY a.Price DESC) AS AvgPrice 
FROM artworks a
JOIN artists ar
ON ar.artist_id = a.artist_id
)
SELECT * FROM AvgArtPrice_CTE 
WHERE AvgPrice > ALL(SELECT price from artworks
                        WHERE genre = 'Renaissance')

-- 14. Write a query to rank artists by their total sales amount and display the top 3 artists.
WITH TopArtists_CTE
AS(
SELECT  ar.artist_id,
        ar.name,
        SUM(s.total_amount) AS TotalSales,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS Rank
FROM artworks a
JOIN sales s
ON s.artwork_id = a.artwork_id
JOIN artists ar
ON ar.artist_id = a.artist_id
GROUP BY ar.artist_id, ar.name
)
SELECT * FROM TopArtists_CTE
WHERE RANK < 4
-- 15. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.
CREATE NONCLUSTERED INDEX NCI_ArtworkId ON sales(artwork_id)

EXEC sp_helpindex sales
-- ### Section 3: 3 Marks Questions

-- 16.  Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.
WITH AvgPriceOfArtworks_CTE
AS(
SELECT  ar.artist_id,
        ar.name,
        AVG(a.price) OVER(Partition By a.artist_id ORDER BY a.Price DESC) AS AvgPrice 
FROM artworks a
JOIN artists ar
ON ar.artist_id = a.artist_id
)
SELECT * FROM AvgPriceOfArtworks_CTE 
WHERE AvgPrice > (SELECT AVG(price) FROM artworks)
ORDER BY AvgPrice DESC


-- 17.  Write a query to create a view that shows artists who have created artworks in multiple genres.

GO
CREATE VIEW vWArtistsWithMultipleGenre
AS
SELECT  a.Name,
        COUNT(b.genre) AS No_Of_Arts_in_Genres
FROM artists a
JOIN artworks b
ON a.artist_id = b.artist_id
Group By a.name
HAVING COUNT(b.genre) > 1
GO

SELECT * FROM vWArtistsWithMultipleGenre
Order By Name


-- 18.  Write a query to find artworks that have a higher price than the average price of artworks by the same artist.

WITH AvgPriceOfArtworks_CTE
AS(
SELECT  ar.artist_id,
        ar.name,
        AVG(a.price) OVER(Partition By a.artist_id ORDER BY a.Price DESC) AS AvgPrice 
FROM artworks a
JOIN artists ar
ON ar.artist_id = a.artist_id
)
SELECT  b.artwork_id,
        b.title,
        b.genre,
        b.price,
        a.AvgPrice
FROM AvgPriceOfArtworks_CTE a
JOIN artworks b
ON a.artist_id = b.artist_id
WHERE b.price > a.AvgPrice

-- ### Section 4: 4 Marks Questions

-- 19.  Write a query to convert the artists and their artworks into JSON format.

SELECT  Artist.name 'Artist',
        ArtWork.title 'Title'
FROM artists Artist
JOIN artworks ArtWork
ON Artist.artist_id = ArtWork.artist_id
GROUP BY Artist.name,ArtWork.title
FOR JSON AUTO

-- 20.  Write a query to export the artists and their artworks into XML format.
SELECT  a.name [Name],
        b.title AS [Name/Title]
FROM artists a
JOIN artworks b
ON a.artist_id = b.artist_id
GROUP BY a.name,b.title
FOR XML PATH('Art'), ROOT('Arts')

-- #### Section 5: 5 Marks Questions

-- 21. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.

Go
CREATE PROC sp_UpdateSales
AS 
BEGIN
    CREATE TRANSACTION CheckNeg
    BEGIN TRY
        IF (SELECT quantity FROM inserted) < 0
            THROW 20001, 'Quantity cant be Negative',1;
        UPDATE 
    END TRY
    CREATE CATCH
    PRINT(Error_Message())
    END CATCH

END

-- 22. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.

GO
ALTER FUNCTION TotalQuantitySold(@genre VARCHAR(20))
RETURNS @TQS TABLE(Genre VARCHAR(20), TotalQuantity INT, Rank INT)
AS
BEGIN 
    INSERT @TQS
    SELECT  a.genre,
            SUM(s.quantity) AS TotalQuantity,
            DENSE_RANK() OVER(ORDER BY SUM(s.quantity) DESC) AS Rank
    FROM artworks a
    JOIN sales s
    ON s.artwork_id = a.artwork_id
    JOIN artists ar
    ON ar.artist_id = a.artist_id
    GROUP BY a.artwork_id, a.genre
    HAVING a.genre = @Genre
    RETURN;
END 
GO

SELECT Genre,TotalQuantity FROM TotalQuantitySold('cubism')
GO

-- 23. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.

CREATE FUNCTION CalcAvgSalesAmount(@Genre VARCHAR(20))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN(
        SELECT AVG(s.total_amount) FROM sales s
        JOIN artworks a
        ON a.artwork_id = s.artwork_id
        WHERE a.genre = @Genre
    )
END
GO

SELECT dbo.CalcAvgSalesAmount('Cubism') AS AvgSalesAmount

-- 24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.
CREATE TABLE artworks_log(artwork_id INT,title VARCHAR(50),change_desc VARCHAR(100))

GO
CREATE TRIGGER TGR_LogChanges
ON artworks
AFTER UPDATE
AS
BEGIN
    INSERT INTO artworks_log
    SELECT artwork_id,title,'' FROM inserted
END
GO

-- 25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.

SELECT  NTILE(4) OVER(ORDER BY SUM(s.total_amount) DESC) AS NTILE,
        a.name,
        SUM(s.total_amount) AS TotalSales
FROM artists a
JOIN artworks art
ON art.artist_id = a.artist_id
JOIN sales s
ON s.artwork_id = art.artwork_id
GROUP BY a.name


-- ### Normalization (5 Marks)

-- 26. **Question:**
--     Given the denormalized table `ecommerce_data` with sample data:

-- | id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
-- | --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
-- | 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
-- | 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
-- | 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
-- | 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

-- Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.



-- ### ER Diagram (5 Marks)

-- 27. Using the normalized tables from Question 27, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.
CREATE TABLE customer(
    cust_id INT,
    cust_name Varchar(20),
    cust_email Varchar(20),
    CONSTRAINT PK_custid PRIMARY KEY(cust_id)
)
CREATE TABLE Products(
    prod_id INT,
    prod_name VARCHAR(20),
    prod_category VARCHAR(20),
    price DECIMAL(10,2),
    CONSTRAINT PK_prodid PRIMARY KEY(prod_id)
)
CREATE TABLE orders(
    ord_id INT,
    prod_id INT,
    ord_date DATE,
    ord_quantity INT,
    CONSTRAINT PK_ordid PRIMARY KEY(ord_id),
    CONSTRAINT FK_prodid FOREIGN KEY(prod_id) REFERENCES Products(prod_id)
)
CREATE TABLE Injunction(
    cust_id INT,
    ord_id INT,
    CONSTRAINT FK_custid FOREIGN KEY(cust_id) REFERENCES customer(cust_id),
    CONSTRAINT FK_ordid2 FOREIGN KEY(ord_id) REFERENCES orders(ord_id)
)