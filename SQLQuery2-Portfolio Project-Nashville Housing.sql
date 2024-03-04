/*

Cleaning Data in SQL Queries

*/


SELECT*
FROM PortfolioProject..NashvilleHousing

--STANDARDIZE DATE FORMAT

SELECT SaleDate, convert(date,SaleDate)
FROM PortfolioProject..NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate= convert(date,SaleDate)

ALTER TABLE	NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted=convert(date,SaleDate)

    -----------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
join PortfolioProject..NashvilleHousing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

UPDATE a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
join PortfolioProject..NashvilleHousing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

   ---------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address

FROM PortfolioProject..NashvilleHousing

ALTER TABLE	NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE	NashvilleHousing
ADD PropertySplitcity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select*
from PortfolioProject..NashvilleHousing



SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress IS NOT NULL


SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress IS NOT NULL


ALTER TABLE	NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)



ALTER TABLE	NashvilleHousing
ADD CitySplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET CitySplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),2)



ALTER TABLE	NashvilleHousing
ADD StateSplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET StateSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select*
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null


  ------------------------------------------------------------------------------------------------------

  --Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant='Y' THEN 'YES'
      WHEN SoldAsVacant='N' THEN 'NO'
	  ELSE SoldAsVacant
 END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'YES'
      WHEN SoldAsVacant='N' THEN 'NO'
	  ELSE SoldAsVacant
 END
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS ( 
SELECT*,
        ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		             PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 order by 
					 UniqueID
					 ) AS row_num

FROM PortfolioProject..NashvilleHousing
)
SELECT*
FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress

select*
from PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------

--Delete Unused Columns

select*
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN  PropertyAddress,OwnerAddress,TaxDistrict,SaleDate

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN  SaleDate