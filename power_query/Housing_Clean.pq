let
    Source = Housing_Base,
    #"Change format of Saledate column to Date" = Table.TransformColumnTypes(Source,{{"SaleDate", type date}}),
    #"Merge Lookup_Address Query with Housing_Clean Query" = Table.NestedJoin(#"Change format of Saledate column to Date", {"ParcelID"}, Lookup_Address, {"ParcelID"}, "Lookup_Address", JoinKind.LeftOuter),
    #"Expand Lookup_Address" = Table.ExpandTableColumn(#"Merge Lookup_Address Query with Housing_Clean Query", "Lookup_Address", {"PropertyAddress"}, {"PropertyAddress.1"}),
    #"Add a column with name PropertyAddress_Clean" = Table.AddColumn(#"Expand Lookup_Address", "PropertyAddress_Clean", each if [PropertyAddress] = null then [PropertyAddress.1] else [PropertyAddress]),
    #"Change PropertyAddress_Clean column format into text" = Table.TransformColumnTypes(#"Add a column with name PropertyAddress_Clean",{{"PropertyAddress_Clean", type text}}),
    #"Remove PropertyAddress and PropertyAddress1 columns" = Table.RemoveColumns(#"Change PropertyAddress_Clean column format into text",{"PropertyAddress", "PropertyAddress.1"}),
    #"Rename PropertyAddress_Clean column with PropertyAddress" = Table.RenameColumns(#"Remove PropertyAddress and PropertyAddress1 columns",{{"PropertyAddress_Clean", "PropertyAddress"}}),
    #"Rearrange PropertyAddress column" = Table.ReorderColumns(#"Rename PropertyAddress_Clean column with PropertyAddress",{"UniqueID ", "ParcelID", "LandUse", "PropertyAddress", "SaleDate", "SalePrice", "LegalReference", "SoldAsVacant", "OwnerName", "OwnerAddress", "Acreage", "TaxDistrict", "LandValue", "BuildingValue", "TotalValue", "YearBuilt", "Bedrooms", "FullBath", "HalfBath"}),
    #"Split PropertyAddress column into street and city" = Table.SplitColumn(#"Rearrange PropertyAddress column", "PropertyAddress", Splitter.SplitTextByEachDelimiter({", "}, QuoteStyle.Csv, false), {"PropertyAddress.1", "PropertyAddress.2"}),
    #"Change format of two columns into text" = Table.TransformColumnTypes(#"Split PropertyAddress column into street and city",{{"PropertyAddress.1", type text}, {"PropertyAddress.2", type text}}),
    #"Rename the last two columns" = Table.RenameColumns(#"Change format of two columns into text",{{"PropertyAddress.1", "PropertySplitAddress"}, {"PropertyAddress.2", "PropertySplitCity"}}),
    #"Split OwnerAddress column into street , city and state" = Table.SplitColumn(#"Rename the last two columns", "OwnerAddress", Splitter.SplitTextByDelimiter(", ", QuoteStyle.Csv), {"OwnerAddress.1", "OwnerAddress.2", "OwnerAddress.3"}),
    #"Change format of three columns into text" = Table.TransformColumnTypes(#"Split OwnerAddress column into street , city and state",{{"OwnerAddress.1", type text}, {"OwnerAddress.2", type text}, {"OwnerAddress.3", type text}}),
    #"Rename the last three columns" = Table.RenameColumns(#"Change format of three columns into text",{{"OwnerAddress.1", "OwnerSplitAddress"}, {"OwnerAddress.2", "OwnerSplitCity"}, {"OwnerAddress.3", "OwnerSplitState"}}),
    #"Replace N with No" = Table.ReplaceValue(#"Rename the last three columns","N","No",Replacer.ReplaceValue,{"SoldAsVacant"}),
    #"Replace Y with Yes" = Table.ReplaceValue(#"Replace N with No","Y","Yes",Replacer.ReplaceValue,{"SoldAsVacant"}),
    #"Trim all spaces (LandUse)" = Table.TransformColumns(#"Replace Y with Yes",{{"LandUse", Text.Trim, type text}}),
    #"Clean all spaces (LandUse)" = Table.TransformColumns(#"Trim all spaces (LandUse)",{{"LandUse", Text.Clean, type text}}),
    #"Consolidating terminology for vacant residential land" = Table.ReplaceValue(#"Clean all spaces (LandUse)","VACANT RES LAND","VACANT RESIDENTIAL LAND",Replacer.ReplaceValue,{"LandUse"}),
    #"Correcting a spelling error in a word RESIENTIAL" = Table.ReplaceValue(#"Consolidating terminology for vacant residential land","VACANT RESIENTIAL LAND","VACANT RESIDENTIAL LAND",Replacer.ReplaceValue,{"LandUse"}),
    #"Remove dublicates" = Table.Distinct(#"Correcting a spelling error in a word RESIENTIAL", {"ParcelID", "LandUse", "PropertySplitAddress", "PropertySplitCity", "SaleDate", "SalePrice", "LegalReference", "SoldAsVacant", "OwnerName", "OwnerSplitAddress", "OwnerSplitCity", "OwnerSplitState", "Acreage", "TaxDistrict", "LandValue", "BuildingValue", "TotalValue", "YearBuilt", "Bedrooms", "FullBath", "HalfBath"}),
    // Removed UniqueID 12629: same transaction as the VACANT row but classed SINGLE FAMILY while SoldAsVacant = Yes. Probable, not confirmed.
    #"Remove UniqueID No.12629 " = Table.SelectRows(#"Remove duplicates", each [#"UniqueID "] <> 12629),
    #"Add PriceFlag column" = Table.AddColumn(#"Remove UniqueID No.12629 ", "PriceFlag", each if [SalePrice] <= 100 then "Nominal" else if [SalePrice] >= 10000000 then "Very High" else "Normal"),
    #"Change PriceFlag column into text" = Table.TransformColumnTypes(#"Add PriceFlag column",{{"PriceFlag", type text}})
    // VACANT RES LAND = VACANT RESIDENTAL LAND

   in
        #"Change PriceFlag column into text" 