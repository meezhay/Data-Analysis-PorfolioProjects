/*

Cleaning Data in SQL Queries

*/

Select *
from PortfolioProject..NashvilleHousing


--standardize date format
Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate =  CONVERT(Date,SaleDate)

--above didn't work, so we tried ALTER TABLE 


ALTER TABLE  NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted =  CONVERT(Date,SaleDate)



--Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is not null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress--, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

--The above still adds the ',' in the address. To get rid of it, add -1 in the substring, bascally telling it to backspace by 1..i think

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
From PortfolioProject.dbo.NashvilleHousing

--break out the city too
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--update table as before
ALTER TABLE  NashvilleHousing
Add ProperSplitAddress nvarchar(255);

Update NashvilleHousing
SET ProperSplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE  NashvilleHousing
Add ProperSplitCity nvarchar(255);

Update NashvilleHousing
SET ProperSplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


----check the table to confirm
select *
From PortfolioProject.dbo.NashvilleHousing


---Do the same for owner adrress, but with another method called Parsename
--owner address hass address, city and state

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--Note that Parsename looks for periods (is useful with perods) '.' but we have commas in the address, so add "replace" to replace the , with . 
--Parsename alse does things backwards. so 1 is state, 2 is city, 3 is address..typically it should be the other way 
 
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

--Now alter and update table
ALTER TABLE  NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE  NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE  NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
from PortfolioProject..NashvilleHousing



--Next
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-----Remove Duplicates---
--It is not standard practise to delete data that is in your database

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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
--DELETE
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject.dbo.NashvilleHousing




-- Delete Unused Columns--


Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--added this bit
Select ISNULL(OwnerName,'Owner Not Found')
From PortfolioProject.dbo.NashvilleHousing
