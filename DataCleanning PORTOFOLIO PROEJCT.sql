select * 
from PortfolioProject..NashvilleHousing

--Standarize Date Format 
select SaleDateConverted , CONVERT(DATE , SaleDate)
from PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE , SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE , SaleDate)


--populate property address data 
select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID =b.ParcelID 
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID =b.ParcelID 
and a.[UniqueID ]<> b.[UniqueID ]


--breaking out address into columns (Address , City , State)
select 
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address ,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City  
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySpiltAddress Nvarchar(255) 

UPDATE NashvilleHousing
SET PropertySpiltAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySpiltCity Nvarchar(255)  

UPDATE NashvilleHousing
SET PropertySpiltCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select *
from PortfolioProject..NashvilleHousing


-- Modify owner address
select *
from PortfolioProject..NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
from PortfolioProject..NashvilleHousing

--UPDATE THEM IN THE ORGINAL TABLE 
ALTER TABLE NashvilleHousing
ADD OwnerSpiltAddress Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSpiltAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSpiltCity Nvarchar(255)  

UPDATE NashvilleHousing
SET OwnerSpiltCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSpiltState Nvarchar(255)  

UPDATE NashvilleHousing
SET OwnerSpiltState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

-- Change Y and N to yes and no in SoldAsVacant
select distinct(SoldAsVacant)
from PortfolioProject..NashvilleHousing


select SoldAsVacant ,
case when SoldAsVacant  = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

--Let's update it in the orginal table 
UPDATE NashvilleHousing
SET SoldAsVacant =case when SoldAsVacant  = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing



-------------------------------------------------------------------------------
--Remove the Duplicates
WITH RowNumCTE AS (
select * ,
ROW_NUMBER () OVER (
PARTITION BY ParcelID, propertyaddress,saleDate, salePrice,legalreference 
ORDER BY uniqueid 
)row_n
 
from PortfolioProject..NashvilleHousing
)
select *  
from RowNumCTE
where (row_n )>1
--order by propertyAddress\



--------------------------------------------------------------------------------
--Delete Unused columns