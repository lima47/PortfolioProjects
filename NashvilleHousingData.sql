-- Cleaning Data in SQL Queries
SELECT * 
FROM PortfolioProj3.dbo.NashvilleHousing

SELECT SaleDate, CONVERT(Date,SaleDate) AS [NEW SALEDATE]
FROM PortfolioProj3.dbo.NashvilleHousing

UPDATE PortfolioProj3.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

-- Populate Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProj3.dbo.NashvilleHousing a
JOIN PortfolioProj3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProj3.dbo.NashvilleHousing a
JOIN PortfolioProj3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT PropertyAddress
FROM PortfolioProj3.dbo.NashvilleHousing

-- Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProj3.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProj3.dbo.NashvilleHousing

ALTER TABLE PortfolioProj3..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProj3..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProj3..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProj3..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT OwnerAddress
FROM PortfolioProj3..NashvilleHousing


-- Using Parsename
-- Parsename looks for periods, we have commas. Replace 
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM PortfolioProj3..NashvilleHousing


ALTER TABLE PortfolioProj3..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProj3..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProj3..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProj3..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProj3..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProj3..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProj3..NashvilleHousing

-- Change Y/N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProj3..NashvilleHousing
GROUP BY SoldAsVacant
order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END SoldAsVacant
FROM PortfolioProj3..NashvilleHousing

UPDATE PortfolioProj3..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- Removing duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM PortfolioProj3..NashvilleHousing
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Deleting unused columns

SELECT* 
FROM PortfolioProj3..NashvilleHousing

ALTER TABLE PortfolioProj3..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress