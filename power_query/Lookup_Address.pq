let
    Source = Housing_Base,
    #"Removing empty data from the PropertyAddress column" = Table.SelectRows(Source, each ([PropertyAddress] <> null)),
    #"Remove all columns except ParcelID/ PropertyAddress columns" = Table.SelectColumns(#"Removing empty data from the PropertyAddress column",{"ParcelID", "PropertyAddress"}),
    #"Remove dublicate from ParcelID column" = Table.Distinct(#"Remove all columns except ParcelID/ PropertyAddress columns", {"ParcelID"})
in
    #"Remove dublicate from ParcelID column"