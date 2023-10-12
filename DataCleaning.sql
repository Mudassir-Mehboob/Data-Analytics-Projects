--Cleaning Data In SQL Queries

Select Saledate
From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------

-- Standardize  Date Format

Select SaleDateConverted, CONVERT(date, saledate)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date, saledate)

---------------------------------------------------------------------------------------------------------------------

-- Populate Property Address

Select *
From PortfolioProject.dbo.NashvilleHousing
where propertyAddress is Null



Select a.ParcelID, a.propertyAddress, b.parcelID, b.propertyAddress, ISNULL(a.propertyAddress, b.propertyAddress) 
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
 On a.parcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID 
 where a.PropertyAddress is NULL


 update a
 Set PropertyAddress = ISNULL(a.propertyAddress, b.propertyAddress) 
 From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
 On a.parcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
where a.PropertyAddress is NULL


------------------------------------------------------------------------------------------------------------------

--Breaking Out Address In to single column

Select *
From PortfolioProject.dbo.NashvilleHousing

Select	
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) As Address
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 



-------------------------------------------------------------------------------------------------------------------


Select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProject.dbo.NashvilleHousing

Select
parseName(Replace(OwnerAddress, ',', '.') , 3)
, parseName(Replace(OwnerAddress, ',', '.') , 2)
, parseName(Replace(OwnerAddress, ',', '.') , 1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = parseName(Replace(OwnerAddress, ',', '.') , 3)

Alter Table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = parseName(Replace(OwnerAddress, ',', '.') , 2)

Alter Table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = parseName(Replace(OwnerAddress, ',', '.') , 1)

Select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------


-- Change Y and N in "Sold as Vacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant= 'Y' THEN 'Yes'
	When SoldAsVacant= 'N' Then 'No'
	Else SoldAsVacant
	END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant= Case When SoldAsVacant= 'Y' THEN 'Yes'
	When SoldAsVacant= 'N' Then 'No'
	Else SoldAsVacant
	END
-------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

With RowNumCTE As(
Select *
,	ROW_NUMBER() Over(
	Partition By ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order By 
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num>1

-------------------------------------------------------------------------------------------------------------------
--Delete Unused Column


Select *
From PortfolioProject.dbo.NashvilleHousing

Alter TABLE PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate


-------------------------------------------------------------------------------------------------------------------