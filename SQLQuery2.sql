--Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProject..NashvilleHousing

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing
UPDATE NashvilleHousing
SET SaleDate=CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(date,SaleDate)

--Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is null
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" Field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
		END 
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=  CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
		END 

--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

select *
from RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress 

--Delete unused columns

Select *
from PortfolioProject..NashvilleHousing 
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate




