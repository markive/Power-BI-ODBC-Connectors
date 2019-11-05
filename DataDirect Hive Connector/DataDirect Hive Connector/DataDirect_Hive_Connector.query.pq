// Use this file to write queries to test your data connector
let
    source = DataDirect_Hive_Connector.Contents("nc-bigdata01", 10000, "pmkdatalake"),
            HIVE_Database = source{[Name="pmkdatalake",Kind="Database"]}[Data],
            activity_unsubscribe = HIVE_Database{[Name="activity_unsubscribe",Kind="Table"]}[Data],
            #"Kept First Rows" = Table.FirstN(activity_unsubscribe,10)
in
    #"Kept First Rows"