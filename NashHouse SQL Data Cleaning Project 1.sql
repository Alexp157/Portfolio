-- Cleaning Data in SQL Queries

select * 
from PortfolioProject..NashHouse

-- Standardize Date Format

select SaleDateConverted, CONVERT (date, SaleDate) 
from PortfolioProject..NashHouse

Update NashHouse
Set SaleDate = CONVERT(Date, Saledate)

Alter Table NashHouse
Add SaleDateConverted Date

Update NashHouse
Set SaleDateConverted = CONVERT(Date, SaleDate)

/*
This section standardizes the date format in the SaleDate column of the NashHouse table by creating a new column SaleDateConverted
and updating the existing SaleDate column.
*/

----------------------------------------------------

--Populate Property Address Date

select * 
from PortfolioProject..NashHouse
--where PropertyAddress is NULL
ORDER BY ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashHouse a
join PortfolioProject..NashHouse b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashHouse a
join PortfolioProject..NashHouse b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

/*
This section populates the PropertyAddress column where it is NULL by matching records with the same 
ParcelID but different UniqueID values and copying the non-NULL PropertyAddress.
*/

-------------------------------------------------------------


--Breaking Out Address into Indivdidual Columns (Address, City, State)

select PropertyAddress 
from PortfolioProject..NashHouse
--where PropertyAddress is NULL
--ORDER BY ParcelID

Select 
Substring(PropertyAddress, 1, CHARINDEX(', ', PropertyAddress) -1) as Address
, Substring(PropertyAddress, CHARINDEX(', ', PropertyAddress) +1, LEN(PropertyAddress)) as Address

from PortfolioProject..NashHouse 


Alter Table NashHouse
Add PropertySplitAddress Nvarchar(255)

Update NashHouse
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(', ', PropertyAddress) -1)

Alter Table NashHouse
Add PropertySplitCity Nvarchar(255)

Update NashHouse
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(', ', PropertyAddress) +1, LEN(PropertyAddress))


Select * 
from PortfolioProject..NashHouse

/* 
This section breaks down the PropertyAddress column into individual columns 
(PropertySplitAddress, PropertySplitCity) for Address and City, respectively
*/

Select OwnerAddress 
from PortfolioProject..NashHouse

Select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
, PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
, PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
from PortfolioProject..NashHouse


Alter Table NashHouse
Add OwnerSplitAddress Nvarchar(255)

Update NashHouse
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Alter Table NashHouse
Add OwnerSplitCity Nvarchar(255)

Update NashHouse
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter Table NashHouse
Add StateSplitAddress Nvarchar(255)

Update NashHouse
Set StateSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)

Select *
from PortfolioProject..NashHouse

/* 
This section parses the OwnerAddress into split columns 
(OwnerSplitAddress, OwnerSplitCity, StateSplitAddress) using the PARSENAME function
*/
--------------------------------------------------------------

--Change Y and N to Yes and No In "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashHouse
group by SoldAsVacant
ORDER BY 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
from PortfolioProject..NashHouse

Update NashHouse
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END

/*
This section changes the values in the SoldAsVacant column from 'Y' and 'N'
to 'Yes' and 'No' using the CASE statement.
*/
---------------------------------------------------------------

-- Removing Duplicates
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

from PortfolioProject..NashHouse
--ORDER BY ParcelID
)
DELETE
from RowNumCTE
where row_num > 1
--order by PropertyAddress

/*
This section removes duplicate records based on specific columns using a Common Table Expression (CTE)
and the ROW_NUMBER window function.
*/

-------------------------------------------------------------

-- Delete Unused Columns

Select *
from PortfolioProject..NashHouse

ALTER TABLE PortfolioProject..NashHouse
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashHouse
DROP COLUMN SaleDate

/*
This section selects all columns, then drops the specified columns 
(OwnerAddress, TaxDistrict, PropertyAddress, SaleDate) from the NashHouse table. 
*/