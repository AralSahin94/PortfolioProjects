/*
 Data Cleaning in SQL (CONVERT, PARSENAME, JOIN, CASE STATEMENT, CTE, DROP, ...)
 */ 

 SELECT * 
 FROM PortfolioProject..housing
 
 -- Change data format	

 SELECT SaleDate, CONVERT(Date, SaleDate)
 FROM PortfolioProject..housing
 
 ALTER TABLE PortfolioProject..housing
 ADD NewSaleDate DATE;

 UPDATE PortfolioProject..housing
 SET NewSaleDate = CONVERT(Date,SaleDate)

 -- Fill Missing Property Address by Comparing Parcel ID

 SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM PortfolioProject..housing a
 JOIN PortfolioProject..housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..housing a
 JOIN PortfolioProject..housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Seperate Address as Address, City, State

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1), 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
FROM PortfolioProject..housing

ALTER TABLE PortfolioProject..housing
ADD Address NVARCHAR(255)

UPDATE PortfolioProject..housing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE PortfolioProject..housing
ADD City NVARCHAR(255)

UPDATE PortfolioProject..housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..housing

ALTER TABLE PortfolioProject..housing
ADD OwnerAdd NVARCHAR(255)
ALTER TABLE PortfolioProject..housing
ADD OwnerCity NVARCHAR(255)
ALTER TABLE PortfolioProject..housing
ADD OwnerState NVARCHAR(255)

UPDATE PortfolioProject..housing
SET OwnerAdd = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
UPDATE PortfolioProject..housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
UPDATE PortfolioProject..housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Fix "Y" and "N" to "Yes" and "No" in SoldAsVacant Column

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..housing

UPDATE PortfolioProject..housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..housing
GROUP BY SoldAsVacant


-- Duplicate Removal

WITH RowCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) rownum
FROM PortfolioProject..housing
)

SELECT *
FROM RowCTE
WHERE rownum = 2

-- Delete Unnecessary Columns

SELECT * 
FROM PortfolioProject..housing

ALTER TABLE PortfolioProject..housing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
