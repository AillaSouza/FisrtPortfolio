/* 
Cleaning Data in SQL Queries 
*/

SELECT*
FROM Portfolio.dbo.NashvilleHousing

-- Standardize Data Format 

SELECT SaleDate
FROM Portfolio.dbo.NashvilleHousing
-- it's fine 

-- Populate Property Address data 
SELECT *
FROM Portfolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL 
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing a 
JOIN Portfolio.dbo.NashvilleHousing b 
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio.dbo.NashvilleHousing a 
JOIN Portfolio.dbo.NashvilleHousing b 
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]


SELECT *
FROM Portfolio.dbo.NashvilleHousing a 
JOIN Portfolio.dbo.NashvilleHousing b 
    on a.ParcelID = b.ParcelID
WHERE a.PropertyAddress is NULL

-- there's no more null values 

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio.dbo.NashvilleHousing 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) Address 
FROM Portfolio.dbo.NashvilleHousing 

ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE Portfolio.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE Portfolio.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT*
FROM Portfolio.dbo.NashvilleHousing 
--------

SELECT OwnerAddress 
FROM Portfolio.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio.dbo.NashvilleHousing

ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE Portfolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE Portfolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE Portfolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT*
FROM Portfolio.dbo.NashvilleHousing 



-- Change Y and N to Yes and No  in 'Sold as Vacant' field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2 

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' then 'Yes'
       WHEN SoldAsVacant = 'N' then 'No'
       ELSE SoldAsVacant
       END
FROM Portfolio.dbo.NashvilleHousing 

UPDATE Portfolio.dbo.NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
       WHEN SoldAsVacant = 'N' then 'No'
       ELSE SoldAsVacant
       END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2 


-- Remove Duplicates

WITH RowNumCTE AS(
SELECT*,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate, 
                 LegalReference
                 ORDER BY 
                    UniqueID
    )row_num
FROM Portfolio.dbo.NashvilleHousing 
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE 
WHERE row_num > 1 
ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT*,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate, 
                 LegalReference
                 ORDER BY 
                    UniqueID
    )row_num
FROM Portfolio.dbo.NashvilleHousing 
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE 
WHERE row_num > 1 

WITH RowNumCTE AS(
SELECT*,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate, 
                 LegalReference
                 ORDER BY 
                    UniqueID
    )row_num
FROM Portfolio.dbo.NashvilleHousing 
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE 
WHERE row_num > 1 
ORDER BY PropertyAddress

-- Delet Unused Columns 

SELECT*
FROM Portfolio.dbo.NashvilleHousing 

ALTER TABLE Portfolio.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio.dbo.NashvilleHousing 
DROP COLUMN SaleDate