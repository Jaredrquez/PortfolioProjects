
-- Cleaning Data
SELECT *
FROM CleaningData..NashHousing

-- Standardize Date format 
SELECT SaleDate, CONVERT(date, SaleDate)
FROM CleaningData..NashHousing

ALTER TABLE NashHousing
AlTER COLUMN SaleDate Date
--or
ALTER TABLE NashHousing
Add SaleDateConverterd Date:

UPDATE NashHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data
Select *
FROM CleaningData..NashHousing
WHERE PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM CleaningData..NashHousing as A
JOIN CleaningData..NashHousing as B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM CleaningData..NashHousing as A
JOIN CleaningData..NashHousing as B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

-- Breaking out address into individual columns 

Select PropertyAddress
FROM CleaningData..NashHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From CleaningData..NashHousing


ALTER TABLE NashHousing
Add PropertySplitAddress Nvarchar(255);

Update NashHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashHousing
Add PropertySplitCity Nvarchar(255);

Update NashHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SElECT *
from CleaningData..NashHousing

-- OR

SELECT OwnerAddress
from CleaningData..NashHousing

SELECT  
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM CleaningData..NashHousing

ALTER TABLE NashHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashHousing
Add OwnerSplitCity Nvarchar(255);

Update NashHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashHousing
Add OwnerSplitState Nvarchar(255);

Update NashHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change y and n to yes and no in a field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM CleaningData..NashHousing
GROUP BY SoldAsVacant
ORDER by 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
FROM CleaningData..NashHousing

UPDATE NashHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END

-- Removing Duplicates
WITH RowNumCTE as (
SELECT *,
	ROW_NUMBER() OVER 
	(
	PARTITION BY parcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					uniqueID
					) as row_num
FROM CleaningData..NashHousing

)
select *
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

SELECT *
FROM CleaningData..NashHousing

ALTER TABLE  CleaningData..NashHousing
DROP COLUMN Owneraddress, TaxDistrict