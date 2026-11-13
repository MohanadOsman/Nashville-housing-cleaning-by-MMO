let
    Source = Housing_Clean,
    #"Grouped Rows" = Table.Group(Source, {"SaleDate", "SalePrice", "LegalReference"}, {{"RowsInSale", each Table.RowCount(_), Int64.Type}})
in
    #"Grouped Rows"