CREATE TABLE Address (
    address_ID INT PRIMARY KEY,
    unit_num VARCHAR(10),
    street_number VARCHAR(10),
    street_name VARCHAR(100),
    street_type VARCHAR(10),
    street_direction VARCHAR(10),
    postal_code VARCHAR(10),
    city VARCHAR(100),
    province VARCHAR(10)
);

INSERT INTO Address (address_ID, unit_num, street_number, street_name, street_type, street_direction, postal_code, city, province)
SELECT address_ID, unit_num, street_number, street_name, street_type, street_direction, postal_code, city, province
FROM [dbo].[BIACase2];

Select * from Address


CREATE TABLE Volunteer (
    volunteer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    group_leader VARCHAR(50)
);
INSERT INTO Volunteer (volunteer_id, first_name, last_name, group_leader)
SELECT volunteer_ID, first_name, last_name, group_leader
FROM [dbo].[BIACase2];

CREATE TABLE Donation (
    donor_first_name VARCHAR(50),
    donor_last_name VARCHAR(50),
    donation_date DATE,
    donation_amount DECIMAL(10,2),
    payment_method VARCHAR(50)
);
INSERT INTO Donation (donor_first_name, donor_last_name, donation_date, donation_amount, payment_method)
SELECT donor_first_name, donor_last_name, TRY_PARSE(donation_date AS DATE USING 'en-US'), donation_amount, payment_method
FROM [dbo].[BIACase2];

-- • The average and sum of the donation by day, month, and year
IF OBJECT_ID('donations_by_date', 'P') IS NOT NULL
    DROP PROCEDURE donations_by_date
GO

CREATE PROCEDURE donations_by_date
AS
BEGIN
  SELECT 
    CONVERT(date, donation_date) AS donation_day,
    DATEPART(month, donation_date) AS donation_month,
    DATEPART(year, donation_date) AS donation_year,
    AVG(donation_amount) AS average_donation,
    SUM(donation_amount) AS total_donation
  FROM Donation
  GROUP BY 
    CONVERT(date, donation_date),
    DATEPART(month, donation_date),
    DATEPART(year, donation_date)
END

EXEC donations_by_date

--The average and sum of the donations by postal code and City in a specific month. define the city and month as variables to allow flexibility.
IF OBJECT_ID('GetDonationStatsByPostalCodeAndCity', 'P') IS NOT NULL
    DROP PROCEDURE GetDonationStatsByPostalCodeAndCity
GO

CREATE PROCEDURE GetDonationStatsByPostalCodeAndCity
    @city VARCHAR(50),
    @month VARCHAR(50)
AS
BEGIN
    SELECT pc.PostalCode, pc.City, AVG(d.DonationAmount) AS AverageDonation, SUM(d.DonationAmount) AS TotalDonation
    FROM Donation d
    JOIN Address pc ON d.AddressID = pc.AddressID
    WHERE pc.City = @city AND MONTH(d.DonationDate) = MONTH(@month)
    GROUP BY pc.PostalCode, pc.City
END

EXEC GetDonationStatsByPostalCodeAndCity 'Hamilton', '2022-04-01'


--The amount collected per payment method from the city with highest $ value of donations. Define the payment method as variable to allow flexibility.
IF OBJECT_ID('GetHighestDonationByCityName', 'P') IS NOT NULL
    DROP PROCEDURE GetHighestDonationByCityName
GO
CREATE PROCEDURE GetHighestDonationByCityName
    @paymentMethod VARCHAR(50)
AS
BEGIN
    SELECT a.city, MAX(d.DonationAmount) as highest_donation
    FROM Donation d
    INNER JOIN address a ON d.addressid = a.addressid
    WHERE d.paymentmethod = @paymentMethod
    GROUP BY a.city
END

EXEC GetHighestDonationByCityName @paymentMethod = 'Cash'

