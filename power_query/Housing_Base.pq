let
    Source = Excel.CurrentWorkbook(){[Name="Housing_Raw"]}[Content],
    #"change file into Table format" = Table.TransformColumnTypes(Source,{{"UniqueID ", Int64.Type}, {"ParcelID", type text}, {"LandUse", type text}, {"PropertyAddress", type text}, {"SaleDate", type datetime}, {"SalePrice", Int64.Type}, {"LegalReference", type text}, {"SoldAsVacant", type text}, {"OwnerName", type text}, {"OwnerAddress", type text}, {"Acreage", type number}, {"TaxDistrict", type text}, {"LandValue", Int64.Type}, {"BuildingValue", Int64.Type}, {"TotalValue", Int64.Type}, {"YearBuilt", Int64.Type}, {"Bedrooms", Int64.Type}, {"FullBath", Int64.Type}, {"HalfBath", Int64.Type}})
in
    #"change file into Table format"