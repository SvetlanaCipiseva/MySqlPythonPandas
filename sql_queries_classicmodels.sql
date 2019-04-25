-- version: MySQL 8.0.15
USE CLASSICMODELS;
-- 1.Find all the product names for all those products whose price are equal 
-- to or above the average price (54.40)
SELECT productName, buyPrice
FROM products
WHERE buyPrice >= (SELECT avg(buyPrice)
				   FROM products);

-- 2.Find the employee name (first and last) for those employees whose customers 
-- have never made an order before.
SELECT e.firstName, e.lastName
FROM 
	customers c
	INNER JOIN employees e ON c.salesRepEmployeeNumber=e.employeeNumber
	LEFT JOIN orders o ON c.customerNumber=o.customerNumber
WHERE o.orderNumber IS NULL;

-- 3.Add a new column to the payments table called  ordernumber that is the same
-- lenghth and datatype as the order number in the orders table.
ALTER TABLE payments
ADD COLUMN orderNumber INT;

-- 4.Create a link between the orders and payments table with the new ordernumber
-- columns being a foreign key in the payments table.
ALTER TABLE payments
ADD FOREIGN KEY payments_ibfk_2(orderNumber)
REFERENCES orders(orderNumber)
ON DELETE NO ACTION
ON UPDATE CASCADE;

-- 5.Crtate a view called orderskshs. The orderskshs will contain the value of 
-- orders in Kenyan shillings. The current orders are in dolars. We want to know
-- the value in kshs by multiplying the ordervalue by 100. The view should have
-- the ordernumber and the total value of the order in kshs.
DROP VIEW IF EXISTS orderskshs; -- check and delete if view already exists
CREATE VIEW orderskshs AS 
   SELECT orderNumber, SUM(quantityOrdered*priceEach*100)  AS 'total value of the order in kshs'
   FROM orderdetails
   GROUP BY orderNumber;

-- 6.Find the total number of customers each employee has under their care broken
-- down by the country they come from e.g. an employees may have two customers
-- in france, 5 in the US. Etc.
SELECT CONCAT(e.firstName,' ',e.lastName) employee, 
		COUNT(c.customerNumber) 'count of customers', c.country
FROM customers c
JOIN employees e ON c.salesRepEmployeeNumber=e.employeeNumber
GROUP BY c.salesRepEmployeeNumber, c.country
ORDER BY employee, c.country;

-- 7.Change the value for ‘Shipped’ status on orders table to ‘Dispatched’
UPDATE orders 
SET status = 'Dispatched'
WHERE status = 'Shipped';

-- 8.What is the average number of days 
SELECT ROUND(AVG(DATEDIFF(requiredDate,shippedDate))) 
		AS 'average number of days from shipped date to required date'
FROM orders;
-- What is the average number of days from shippedDate to requiredDate for all countries  
-- (exclude cases when orders have been shipped after required date)?
SELECT country, ROUND(AVG(DATEDIFF(requiredDate,shippedDate))) 
		AS 'average number of days from shipped date to required date'
FROM orders o
JOIN customers c ON o.customerNumber=c.customerNumber
WHERE DATEDIFF(requiredDate,shippedDate)>0 -- exclude cases when orders have been shipped after required date
GROUP BY country
ORDER BY  ROUND(AVG(DATEDIFF(requiredDate,shippedDate))) ;

-- 9.Write a stored procedure that takes the total value of an order per customer
-- and compares it with the customer number and amount in the payment table.If both
-- the customer number and the amount in the payments table match with the customer
-- number and total order value, print the customer number and the ordernumber
--  and the word “match” or else print “fail”
DELIMITER $$
DROP PROCEDURE IF EXISTS compareTotalOrderNumberAndAmount;
CREATE PROCEDURE compareTotalOrderNumberAndAmount(
    in  p_customerNumber int, 
    out p_compare varchar(10)
    )
BEGIN
    DECLARE orderCount int;
    DECLARE paymentCount int;
 
    SELECT SUM(od.quantityOrdered*od.priceEach) INTO orderCount
    FROM orders o
    JOIN orderdetails od ON o.orderNumber=od.orderNumber
	WHERE customerNumber = p_customerNumber;
    
	SELECT SUM(amount) INTO paymentCount
    FROM payments
	WHERE customerNumber = p_customerNumber;
    
    IF orderCount = paymentCount THEN
    SET p_compare = 'match';
    ELSE 
        SET p_compare = 'fail';
    END IF;
 
END$$
DELIMITER ;

-- check 'compareTotalOrderNumberAndAmount'procedure
CALL compareTotalOrderNumberAndAmount('103',@p_compare);
SELECT @p_compare;
CALL compareTotalOrderNumberAndAmount('114',@p_compare);
SELECT @p_cordersompare;

CALL compareTotalOrderNumberAndAmount('119',@p_compare);
SELECT @p_compare;
CALL compareTotalOrderNumberAndAmount('124',@p_compare);
SELECT @p_compare;


-- TEARDOWN
-- To delete procedure uncomment and excute row below
-- DROP PROCEDURE IF EXISTS compareTotalOrderNumberAndAmount;

-- To delete view uncomment and excute row below
-- DROP VIEW IF EXISTS orderskshs;

-- To delete 'orderNumber' column from payments table uncomment and excute 4 rows below
-- ALTER TABLE payments 
-- DROP FOREIGN KEY payments_ibfk_2;
-- ALTER TABLE payments
-- DROP COLUMN orderNumber;



