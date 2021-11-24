/*
Cleaning Data in SQL Queries

As the I'm using SQLite, where there is no datetime format. I had to format the date
in Excel earlier before importing the data in. 
*/

-- 1. Populate Property Address data which includes NULL
 

SELECT *
FROM housing_data
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_data a
JOIN housing_data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null;


UPDATE housing_data AS a
SET PropertyAddress = b.PropertyAddress
FROM housing_data AS b
WHERE a.ParcelID = b.ParcelID AND a.PropertyAddress IS NULL AND b.PropertyAddress IS NOT NULL;


-- 2. Breaking out Address into Individual Columns
 
SELECT PropertyAddress
FROM housing_data
ORDER BY ParcelID; 

SELECT 
SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',')-1) as Address,
SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress)) as Address
FROM housing_data;

ALTER TABLE housing_data
ADD PropertySplitAddress TEXT;

UPDATE housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',')-1) 




ALTER TABLE housing_data
ADD PropertySplitCity TEXT;

UPDATE housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress))



SELECT OwnerAddress
FROM housing_data;

SELECT 
    SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1) as col1,
    SUBSTRING(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 1), 1, INSTR(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') - 1) as col2,
    SUBSTRING(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 1), INSTR(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') + 1) as col3
FROM housing_data;


-- Updating Owner address by dividing into three columns 
/* This may be more efficient to do in Excel prior to importing. But I chose to include
it for demonstration purposes
*/

ALTER TABLE housing_data
ADD OwnerSplitAddress TEXT;

UPDATE housing_data
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1)

ALTER TABLE housing_data
ADD OwnerSplitCity TEXT;

UPDATE housing_data
SET OwnerSplitCity = SUBSTRING(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 1), 1, INSTR(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') - 1)


ALTER TABLE housing_data
ADD OwnerSplitState TEXT;

UPDATE housing_data
SET OwnerSplitState = SUBSTRING(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 1), INSTR(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') + 1)


-- 3. Convert 'Y' and 'N' to 'Yes' and 'No' so column is standardized. 
 
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM housing_data
GROUP BY SoldAsVacant
ORDER BY 2


Update housing_data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				 WHEN SoldAsVacant = 'N' THEN 'No'
				 ELSE SoldAsVacant
				 END
				 
				 
-- 4. Remove Duplicate 

WITH RowNumCTE AS (
SELECT *, 
		ROW_NUMBER() OVER (
				PARTITION BY ParcelID,
										 PropertyAddress,
										 SalePrice,
										 SaleDate,
										 LegalReference
										 ORDER BY 
												UniqueID
											) row_num

FROM housing_data
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1;




DELETE FROM housing_data 
WHERE ROWID NOT IN (
  SELECT MIN(ROWID) 
  FROM housing_data 
  GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
);


-- 5. Delete Unused Columns. This a unique process to SQLITE . 


SELECT * 
FROM housing_data
LIMIT 10;



ALTER TABLE housing_data RENAME TO _housing_data_old;

CREATE TABLE "housing_data" (
	"UniqueID"	INTEGER,
	"ParcelID"	TEXT,
	"LandUse"	TEXT,
	"PropertyAddress"	TEXT,
	"SaleDate"	TEXT,
	"SalePrice"	INTEGER,
	"LegalReference"	TEXT,
	"SoldAsVacant"	TEXT,
	"OwnerName"	TEXT,
	"Acreage"	TEXT, 
	"LandValue"	TEXT,
	"BuildingValue"	TEXT,
	"TotalValue"	TEXT,
	"YearBuilt"	TEXT,
	"Bedrooms"	TEXT,
	"FullBath"	TEXT,
	"HalfBath"	TEXT
, PropertySplitAddress TEXT, PropertySplitCity TEXT, OwnerSplitAddress TEXT, OwnerSplitCity TEXT, OwnerSplitState TEXT)

INSERT INTO housing_data (UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, LegalReference, SoldAsVacant, OwnerName, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState)
  SELECT UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, LegalReference, SoldAsVacant, OwnerName, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
  FROM _housing_data_old;

SELECT *
FROM housing_data;













