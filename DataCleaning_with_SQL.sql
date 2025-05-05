/*

Cleaning Data with SQL Queries using Nashville Housing Data

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Standardize Date Format. 
-- It is in Datetime, but we don't need the time part

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing

-- Was not working so go for Altering table instead

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

--

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing


---------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null

SELECT *
FROM NashvilleHousing
order by ParcelID

-- Populate Property Address when null if other same ParcelID has an Address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Update query to make the above query happen

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



---------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

-- Create two new columns

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

-- Update new columns

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing


-- Splitting Owner Address into address, City, State

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',',  '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',',  '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',',  '.'),1)
FROM NashvilleHousing


-- Add new columns

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

-- Update new columns

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',',  '.'),3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',',  '.'),2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',',  '.'),1)

SELECT *
FROM NashvilleHousing



---------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant

-- Without making changes, select new column that shows what will happen

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing

-- Update statement

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------

-- Remove Duplicates

-- Standard practice may not to delete data but will for case of this example project

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
FROM NashvilleHousing
)


DELETE
FROM RowNumCTE
WHERE row_num > 1

-----------------------------------------------------------------------------

-- Delete Unused Columns

-- Do not delete RAW data typically but will for this example project

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate