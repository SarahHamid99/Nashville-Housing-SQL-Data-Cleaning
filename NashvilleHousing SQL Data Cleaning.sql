/*
Cleaning Data in SQL Queries
*/
select *
from NashvilleHousing

-- Standardize Date Format
select convert(date,SaleDate)
from NashvilleHousing 

UPDATE NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)

-- If it doesn't Update properly
ALTER TABLE NashvilleHousing
add SaleDateConverted date;

UPDATE NashvilleHousing
set SaleDateConverted=CONVERT(date,SaleDate)

-- Populate Property Address data
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
                       SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Addresscity  
FROM Nashvillehousing

ALTER TABLE Nashvillehousing
ADD PropertySpilitAdress nvarchar(225)

UPDATE Nashvillehousing
SET PropertySpilitAdress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE Nashvillehousing
ADD PropertySpilitCity nvarchar(225)

UPDATE Nashvillehousing 
SET PropertySpilitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
       PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashvillehousing 

ALTER TABLE Nashvillehousing
ADD OwnerSplitAdress nvarchar(225)

UPDATE Nashvillehousing
SET OwnerSplitAdress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashvillehousing
ADD OwnerSplitCity nvarchar(225)

UPDATE Nashvillehousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashvillehousing
ADD OwnerSplitState nvarchar(225)

UPDATE Nashvillehousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
 WHEN SoldAsVacant='Y' THEN 'Yes'
 WHEN SoldAsVacant='N' THEN 'No'
 ELSE SoldAsVacant
 END 
 FROM Nashvillehousing

UPDATE Nashvillehousing
SET SoldAsVacant= CASE 
 WHEN SoldAsVacant='Y' THEN 'Yes'
 WHEN SoldAsVacant='N' THEN 'No'
 ELSE SoldAsVacant
 END 

 -- Remove Duplicates
 WITH RowNumberCTE AS(
 SELECT *,ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num 
 FROM Nashvillehousing)
DELETE 
 FROM RowNumberCTE
 WHERE row_num>1

 -- Delete Unused Columns
 ALTER TABLE Nashvillehousing
 DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
