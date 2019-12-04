// Enable DirectQuery for Progress DataDirect Autonomous REST ODBC Connector.

section DataDirect_Autonomous_REST_Connector;

DriverName = "DataDirect 8.0 Autonomous REST Connector";

[DataSource.Kind="DataDirect_Autonomous_REST_Connector", Publish="DataDirect_Autonomous_REST_Connector.Publish"]
shared DataDirect_Autonomous_REST_Connector.Contents = Value.ReplaceType(AutoRESTImpl, AutoRESTMeta);

AutoRESTMeta = type function (
DSN as ( type text meta [
	    Documentation.FieldCaption = "DSN Name",
        Documentation.FieldDescription = "Provide your ODBC DSN Name",
        Documentation.SampleValues = {"Name of ODBC Data Source you have defined on your machine"}
	]))
	as table meta [
        Documentation.Name = "Progress DataDirect Autonomous REST Connector",
        Documentation.LongDescription = "Progress DataDirect Autonomous REST Connector is high performance connector that let's you DirectQuery/Import data from any REST API."
    ];

AutoRESTImpl = (DSN as text) =>
    let ConnectionString = [
        DSN = DSN
        ],

    Credential = Extension.CurrentCredential(),
    CredentialConnectionString =
            if (Credential[AuthenticationKind]?) = "UsernamePassword" then 
                [ UID = Credential[Username], PWD = Credential[Password] ]
            else
                ...,
            
    AutoRESTConnector = Odbc.DataSource(ConnectionString, [
            CreateNavigationProperties = false,
            HierarchicalNavigation = true,
            ClientConnectionPooling = true,
            TolerateConcatOverflow = true,
            SqlCapabilities = [
                //SQL Capabilities Overrides : https://docs.microsoft.com/en-us/power-query/odbc#overriding-sqlcapabilities
                SupportsTop = true,
                SupportsNumericLiterals = true,
                SupportsStringLiterals = true,
                SupportsOdbcDateLiterals = true,
                SupportsOdbcTimeLiterals = true,
                SupportsOdbcTimestampLiterals = true,
                StringLiteralEscapeCharacters = { "\" }
            ],
            SQLGetInfo = [
                SQL_AGGREGATE_FUNCTIONS = 0x0000001F,
                SQL_CONVERT_BIGINT = 0x00A0717F,
                SQL_CONVERT_BINARY = 0x00A46D1F,
                SQL_CONVERT_BIT = 0x00A0717F,
                SQL_CONVERT_CHAR = 0x01E67F7F,
		        SQL_CONVERT_DATE = 0x00000000,
		        SQL_CONVERT_DECIMAL = 0x00A0717F,
		        SQL_CONVERT_DOUBLE = 0x00000000,
		        SQL_CONVERT_FLOAT = 0x00A0717F,
                SQL_CONVERT_FUNCTIONS = 0x00000003,
                SQL_CONVERT_INTEGER = 0x00A0717F,
                SQL_CONVERT_INTERVAL_YEAR_MONTH = 0x00000000,
                SQL_CONVERT_INTERVAL_DAY_TIME = 0x00000000,
                SQL_CONVERT_LONGVARBINARY = 0x00040C00,
                SQL_CONVERT_LONGVARCHAR = 0x00E00301,
                SQL_CONVERT_NUMERIC = 0x00A0717F,
                SQL_CONVERT_REAL = 0x00A0717F,
                SQL_CONVERT_SMALLINT = 0x00A0717F,
                SQL_CONVERT_TIME = 0x00000000,
                SQL_CONVERT_TIMESTAMP = 0x00A20101,
                SQL_CONVERT_TINYINT = 0x00A0717F,
                SQL_CONVERT_VARBINARY = 0x00A46D1F,
                SQL_CONVERT_VARCHAR = 0x01E67F7F,
                SQL_CONVERT_WCHAR = 0x01E67F7F,
		        SQL_CONVERT_WLONGVARCHAR = 0x00E00301,
		        SQL_CONVERT_WVARCHAR = 0x01E67F7F,
                SQL_IDENTIFIER_QUOTE_CHAR = """",
                SQL_GROUP_BY = 2,
                SQL_NUMERIC_FUNCTIONS = 0x00FFFFFF,
                SQL_SCROLL_OPTIONS = 0x00000011,
                SQL_SQL_CONFORMANCE = 1,
                SQL_SQL92_DATETIME_FUNCTIONS = 0x00000000,
                SQL_SQL92_NUMERIC_VALUE_FUNCTIONS = 0x00000000,
                SQL_SQL92_PREDICATES = 0x00000007,
                SQL_SQL92_RELATIONAL_JOIN_OPERATORS = 0x0000035A,
                SQL_SQL92_STRING_FUNCTIONS = 0x00000006,
                SQL_SQL92_VALUE_EXPRESSIONS = 0x0000000F,
                SQL_STRING_FUNCTIONS = 0x007FFFFF,
                SQL_SUBQUERIES = 0x0000001F,
                SQL_SYSTEM_FUNCTIONS = 0x00000007,
                SQL_TIMEDATE_FUNCTIONS = 0x0011FFFF
            ],
            OnError = (errorRecord as record) =>
            if errorRecord[Reason] = DataSourceMissingClientLibrary then
					error Error.Record(
                        DataSourceMissingClientLibrary, Text.Format(
                        "Progress DataDirect Autonomous REST Connector is not installed. Please Download and Install the driver from here: #{0}", { DriverDownloadUrl }),
                        errorRecord[Detail])
            else
                error errorRecord
        ])
    in AutoRESTConnector;

// Data Source Kind description
DataDirect_Autonomous_REST_Connector = [
     TestConnection = (dataSourcePath) =>
        let
            json = Json.Document(dataSourcePath),
            dsn = json[DSN]
        in
            {"DataDirect_Autonomous_REST_Connector.Contents", dsn},
    Authentication = [
        Implicit = [],
        UsernamePassword = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
DataDirect_Autonomous_REST_Connector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://www.progress.com/odbc/autonomous-rest-api",
    SourceImage = DataDirect_Autonomous_REST_Connector.Icons,
    SourceTypeImage = DataDirect_Autonomous_REST_Connector.Icons,
    SupportsDirectQuery = true
];

DataDirect_Autonomous_REST_Connector.Icons = [
    Icon16 = { Extension.Contents("DataDirect_Autonomous_REST_Connector16.png"), Extension.Contents("DataDirect_Autonomous_REST_Connector20.png"), Extension.Contents("DataDirect_Autonomous_REST_Connector24.png"), Extension.Contents("DataDirect_Autonomous_REST_Connector32.png") },
    Icon32 = { Extension.Contents("DataDirect_Autonomous_REST_Connector32.png"), Extension.Contents("DataDirect_Autonomous_REST_Connector40.png"), Extension.Contents("DataDirect_Autonomous_REST_Connector48.png"), Extension.Contents("DataDirect_Autonomous_REST_Connector64.png") }
];

EnableTraceOutput = true;

//ErrorHandling
DataSourceMissingClientLibrary = "DataSource.MissingClientLibrary";
DriverDownloadUrl = "https://www.progress.com/odbc/autonomous-rest-api";
