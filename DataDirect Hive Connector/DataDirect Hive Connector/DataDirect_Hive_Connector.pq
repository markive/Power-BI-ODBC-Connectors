// Enable DirectQuery for Progress DataDirect Hive ODBC Driver.

section DataDirect_Hive_Connector;

//Set Configuration
DriverName = "DataDirect 8.0 Apache Hive Wire Protocol";

[DataSource.Kind="DataDirect_Hive_Connector", Publish="DataDirect_Hive_Connector.Publish"]
shared DataDirect_Hive_Connector.Contents = Value.ReplaceType(HiveConnectorImpl, HiveConnectorMeta);

HiveConnectorMeta = type function (
	HostName as ( type text meta [
		Documentation.FieldCaption = "HostName",
        Documentation.FieldDescription = "Provide your Hive Server Address",
        Documentation.SampleValues = {"localhost", "127.0.0.1"}
	]),
	PortNumber as ( type number meta [
		Documentation.FieldCaption = "PortNumber",
        Documentation.FieldDescription = "Provide your Hive Server's Port Number",
        Documentation.SampleValues = {"10000"}
	]),
	Database as ( type text meta [
		Documentation.FieldCaption = "Database",
        Documentation.FieldDescription = "Provide your Hive Database Name",
        Documentation.SampleValues = {"default"}
	]))
	as table meta [
        Documentation.Name = "Connect to Hive - Progress DataDirect",
        Documentation.LongDescription = "Progress DataDirect Hive Connector is high performance connector that let's you DirectQuery/Import data from your Hive Instance"
    ];
	
HiveConnectorImpl = (HostName as text, PortNumber as number, Database as text) =>
    let
        // Connection String
        ConnectionString = [
            Driver = DriverName,
            HostName = HostName,
            PortNumber = PortNumber,
            Database = Database
        ],

        // Authentication
        Credential = Extension.CurrentCredential(),
		CredentialConnectionString =
            if Credential[AuthenticationKind]? = "UsernamePassword" then
                [ UID = Credential[Username], PWD = Credential[Password] ]
            else if Credential[AuthenticationKind]? = "Implicit" then
                [ UID = "", PWD = "" ]
            else
                error Error.Record("Error", "Unhandled authentication kind: " & Credential[AuthenticationKind]?),

        // Configure LIMIT 
        // https://docs.microsoft.com/en-us/power-query/odbc#overriding-astvisitor
        // https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Select#LanguageManualSelect-LIMITClause
        AstVisitor = [
            LimitClause = (skip, take) =>
                let
                    limit = if (take <> null and skip > 0) 
                                then Text.Format("LIMIT #{1}, #{0}", {take}, {skip}) 
                            else if (take <> null and ( skip = 0 or skip = null))
                                then Text.Format("LIMIT #{0}", {take})
                            else ""
                in
                    [
                        Text = Text.Format("#{0}", {limit}),
                        Location = "AfterQuerySpecification"
                    ]
        ],

        HiveDataSource = Odbc.DataSource(ConnectionString, [
            // Options Documentation: https://docs.microsoft.com/en-us/power-query/odbc#parameters-for-odbcdatasource
            CreateNavigationProperties = false,
            HierarchicalNavigation = true,
            ClientConnectionPooling = true,
            TolerateConcatOverflow = true,
            CredentialConnectionString = CredentialConnectionString,
            AstVisitor = AstVisitor,
            SqlCapabilities = [
                //SQL Capabilities Overrides : https://docs.microsoft.com/en-us/power-query/odbc#overriding-sqlcapabilities
                SupportsTop = false,
                SupportsNumericLiterals = true,
                SupportsStringLiterals = true,
                SupportsOdbcDateLiterals = true,
                SupportsOdbcTimeLiterals = true,
                SupportsOdbcTimestampLiterals = true,
                StringLiteralEscapeCharacters = { "\" }
            ],
            SQLGetFunctions = [
                // SQLGetFunctions Overrides: https://docs.microsoft.com/en-us/power-query/odbc#overriding-sqlgetfunctions
                SQL_CONVERT_FUNCTIONS = 0x00000002
            ],
            SQLGetInfo = [
                // SQLGetinfo Overrides: https://docs.microsoft.com/en-us/power-query/odbc#overriding-sqlgetinfo
                SQL_AGGREGATE_FUNCTIONS = 0x0000007F,
                SQL_CONVERT_BIGINT = 0x000273D8,
                SQL_CONVERT_BINARY = 0x00000000,
                SQL_CONVERT_BIT = 0x000273D8,
                SQL_CONVERT_CHAR = 0x00000000,
				SQL_CONVERT_DATE = 0x00000000,
				SQL_CONVERT_DECIMAL = 0x00000000,
				SQL_CONVERT_DOUBLE = 0x00000000,
				SQL_CONVERT_FLOAT = 0x00000000,
                SQL_CONVERT_FUNCTIONS = 0x00000003,
                SQL_CONVERT_INTEGER = 0x000273D8,
                SQL_CONVERT_INTERVAL_YEAR_MONTH = 0x00000000,
                SQL_CONVERT_INTERVAL_DAY_TIME = 0x00000000,
                SQL_CONVERT_LONGVARBINARY = 0x00000000,
                SQL_CONVERT_LONGVARCHAR = 0x000273D8,
                SQL_CONVERT_NUMERIC = 0x00000000,
                SQL_CONVERT_REAL = 0x000273D8,
                SQL_CONVERT_SMALLINT = 0x000273D8,
                SQL_CONVERT_TIME = 0x00000000,
                SQL_CONVERT_TIMESTAMP = 0x00023318,
                SQL_CONVERT_TINYINT = 0x000273D8,
                SQL_CONVERT_VARBINARY = 0x00000000,
                SQL_CONVERT_VARCHAR = 0x000273D8,
                SQL_CONVERT_WCHAR = 0x00000000,
				SQL_CONVERT_WLONGVARCHAR = 0x00000000,
				SQL_CONVERT_WVARCHAR = 0x00000000,
                SQL_IDENTIFIER_QUOTE_CHAR = "`",
                SQL_GROUP_BY = 2,
                SQL_NUMERIC_FUNCTIONS = 0x007FFFEF,
                SQL_SCROLL_OPTIONS = 0x00000011,
                SQL_SQL_CONFORMANCE = 1,
                SQL_SQL92_DATETIME_FUNCTIONS = 0x00000007,
                SQL_SQL92_NUMERIC_VALUE_FUNCTIONS = 0x00000000,
                SQL_SQL92_PREDICATES = 0x00001E07,
                SQL_SQL92_RELATIONAL_JOIN_OPERATORS = 0x00000158,
                SQL_SQL92_STRING_FUNCTIONS = 0x00000009,
                SQL_SQL92_VALUE_EXPRESSIONS = 0x00000007,
                SQL_STRING_FUNCTIONS = 0x00053FFF,
                SQL_SYSTEM_FUNCTIONS = 0x00000006,
                SQL_TIMEDATE_FUNCTIONS = 0x001E7FE7
            ],
			OnError = (errorRecord as record) =>
            if errorRecord[Reason] = DataSourceMissingClientLibrary then
					error Error.Record(
                        DataSourceMissingClientLibrary, Text.Format(
                        "Progress DataDirect Apache Hive ODBC Driver is not installed. Please Download and Install the driver from here: #{0}", { DriverDownloadUrl }),
                        errorRecord[Detail])
            else
                error errorRecord
        ])

    in
        HiveDataSource;

// Data Source Kind description
DataDirect_Hive_Connector = [
    TestConnection = (dataSourcePath) =>
        let
            json = Json.Document(dataSourcePath),
            hostname = json[HostName],
            portnumber = json[PortNumber],
            database = json[Database]
        in
            {"DataDirect_Hive_Connector.Contents", hostname, portnumber, database},
    Authentication = [
        UsernamePassword = [],
        Implicit = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
DataDirect_Hive_Connector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://www.progress.com/odbc/apache-hadoop-hive",
    SourceImage = DataDirect_Hive_Connector.Icons,
    SourceTypeImage = DataDirect_Hive_Connector.Icons,
    SupportsDirectQuery = true
];

DataDirect_Hive_Connector.Icons = [
    Icon16 = { Extension.Contents("DataDirect_Hive_Connector16.png"), Extension.Contents("DataDirect_Hive_Connector20.png"), Extension.Contents("DataDirect_Hive_Connector24.png"), Extension.Contents("DataDirect_Hive_Connector32.png") },
    Icon32 = { Extension.Contents("DataDirect_Hive_Connector32.png"), Extension.Contents("DataDirect_Hive_Connector40.png"), Extension.Contents("DataDirect_Hive_Connector48.png"), Extension.Contents("DataDirect_Hive_Connector64.png") }
];


// Debug.
EnableTraceOutput = true;

//ErrorHandling
DataSourceMissingClientLibrary = "DataSource.MissingClientLibrary";
DriverDownloadUrl = "https://www.progress.com/odbc/apache-hadoop-hive";
