

-- Standardize Date Format
select SaleDateConverted
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, saledate)

-- Now to remove the time
alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, saledate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from PortfolioProject..NashvilleHousing
order by ParcelID		-- I noticed same ParcelID, means they have same PropertyAddress

-- Changing all the null PropertyAddress to the respective address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
Join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
Join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Splitting Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address	
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City	-- CHARINDEX returns an int
from PortfolioProject..NashvilleHousing

-- Add two new columns
alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

select *				-- Check whether the two new columns is being updated in the table
from PortfolioProject..NashvilleHousing



select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)			-- PARSENAME is to split between delimiter
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

-- Add three new columns
alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'SoldAsVacant' column

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from PortfolioProject..NashvilleHousing
group by SoldAsVacant

Update NashvilleHousing
set SoldAsVacant = case 
					when SoldAsVacant = 'Y' then 'Yes'
					when SoldAsVacant = 'N' then 'No'
					else SoldAsVacant
					end


--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates (Not recommended to delete original data)

WITH RowNumCTE as(
select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) as row_num
from PortfolioProject..NashvilleHousing
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

select *
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused columns (Dont do this to raw data)

select *
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
drop column SaleDate