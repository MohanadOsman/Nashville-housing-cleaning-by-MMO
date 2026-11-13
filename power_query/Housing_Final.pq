let
    Source = Housing_Clean,
    #"Merge Sale_Groups Query with Housing_Final Query" = Table.NestedJoin(Source, {"SaleDate", "SalePrice", "LegalReference"}, Sale_Groups, {"SaleDate", "SalePrice", "LegalReference"}, "Sale_Groups", JoinKind.LeftOuter),
    #"Expand Sale_Groups" = Table.ExpandTableColumn(#"Merge Sale_Group Query with Housing_Final Query", "Sale_Groups", {"RowsInSale"}, {"RowsInSale"}),
    #"Add SaleType column" = Table.AddColumn(#"Expand Sale_Groups", "SaleType", each if [RowsInSale] > 1 then "Multi-unit sale" else "Single"),
    #"Change SaleType column format into text" = Table.TransformColumnTypes(#"Add SaleType column",{{"SaleType", type text}}),
    #"Add QualityNote column" = Table.AddColumn(#"Change SaleType column format into text", "QualityNote", each if Text.StartsWith([LandUse], "VACANT") and [SoldAsVacant] = "No" then "LandUse vacant, SoldAsVacant = No"
else if not Text.StartsWith([LandUse], "VACANT") and [SoldAsVacant] = "Yes" then "SoldAsVacant = Yes, LandUse not vacant"
else null),
    // There is a discrepancy between `LandUse` and `SoldAsVacant` in 2,148 rows (3.8%): 1,296 rows are classified as vacant land but have `SoldAsVacant = No` (1,285 of which are categorized as "VACANT RESIDENTIAL LAND"), while 852 rows have `SoldAsVacant = Yes` but are not classified as vacant land. No changes have been made; a `QualityNote` column has been added to highlight these instances. A possible explanation is a difference in the timing of the data recorded for these two columns, which requires confirmation from the data source.
    #"Change QualityNote column format  into text" = Table.TransformColumnTypes(#"Add QualityNote column",{{"QualityNote", type text}})
in
    #"Change QualityNote column format  into text"