// Enable DirectQuery for Progress DataDirect Autonomous REST ODBC Connector.

section DataDirect_Autonomous_REST_Connector;

DriverName = "DataDirect 8.0 Autonomous REST Connector";

[DataSource.Kind="DataDirect_Autonomous_REST_Connector", Publish="DataDirect_Autonomous_REST_Connector.Publish"]
shared DataDirect_Autonomous_REST_Connector.Contents = Value.ReplaceType(AutoRESTImpl, AutoRESTMeta);

AutoRESTMeta = type function (
AuthenticationMethod as ( type text meta [
	    Documentation.FieldCaption = "Authentication Method",
        Documentation.FieldDescription = "Select your Authentication Method",
        Documentation.AllowedValues = {"None", "Basic", "HttpHeader", "UrlParameter", "OAuth2"}
	]),
optional RestSamplePath as ( type text meta [
	    Documentation.FieldCaption = "REST Url",
        Documentation.FieldDescription = "Provide your REST Endpoint",
        Documentation.SampleValues = {"https://example.com/api/"}
	]),
optional RESTConfigPath as ( type text meta [
	    Documentation.FieldCaption = "REST Configuration File",
        Documentation.FieldDescription = "Provide the path to REST Configuration file",
        Documentation.SampleValues = {"C:\Users\<UserName>\...\sample.config"}
	]),
optional AuthParam as ( type text meta [
        Documentation.FieldCaption = "Authentication Parameter",
        Documentation.FieldDescription = "Specify the name of URL Parameter used to pass Key or Token",
        Documentation.SampleValues = {"apikey (URL Parameter)", "token (URL Parameter)"}        
	]),
optional AuthHeader as ( type text meta [
        Documentation.FieldCaption = "Authentication Header",
        Documentation.FieldDescription = "Specify the name of HTTP Header used for authentication",
        Documentation.SampleValues = {"Authorization (HTTP Header/URL Parameter)", "X-Api-Key (HTTP Header/URL Parameter)"}        
	]),
optional SecurityToken as ( type text meta [
        Documentation.FieldCaption = "Security Token",
        Documentation.FieldDescription = "Specify the security token required to make a connection to your REST API endpoint",
        Documentation.SampleValues = {"Your Token/APIKey etc., (HTTP Header/URL Parameter)"}        
	]),
optional LogonID as ( type text meta [
        Documentation.FieldCaption = "Username",
        Documentation.FieldDescription = "Specify the Username to your REST API endpoint",
        Documentation.SampleValues = {"LogonID/Username (Basic/OAuth2)"}        
	]),
optional Password as ( type text meta [
        Documentation.FieldCaption = "Password",
        Documentation.FieldDescription = "Specify the Password to your REST API endpoint",
        Documentation.SampleValues = {"Password (Basic/OAuth2)"}        
	]),
optional ClientID as ( type text meta [
        Documentation.FieldCaption = "Client ID",
        Documentation.FieldDescription = "Provide the OAuth2 ClientID",
        Documentation.SampleValues = {"Your ClientID (OAuth2)"}        
	]),
optional ClientSecret as ( type text meta [
        Documentation.FieldCaption = "Client Secret",
        Documentation.FieldDescription = "Provide the OAuth2 Client Secret",
        Documentation.SampleValues = {"Your Client Secret (OAuth2)"}        
	]),
optional OauthCode as ( type text meta [
        Documentation.FieldCaption = "Authorization Code",
        Documentation.FieldDescription = "Provide the OAuth2 Authorization Code",
        Documentation.SampleValues = {"Your Authorization Code (OAuth2)"}        
	]),
optional TokenURI as ( type text meta [
        Documentation.FieldCaption = "Token URL",
        Documentation.FieldDescription = "Provide the OAuth2 Token URL",
        Documentation.SampleValues = {"https://example.com/token (OAuth2)"}        
	]),
optional Scope as ( type text meta [
        Documentation.FieldCaption = "Scope",
        Documentation.FieldDescription = "Provide the OAuth2 Scope",
        Documentation.SampleValues = {"OAuth2 Scope (OAuth2)"}        
	]),
optional RedirectURI as ( type text meta [
        Documentation.FieldCaption = "Redirect URL",
        Documentation.FieldDescription = "Provide the OAuth2 Redirect URL",
        Documentation.SampleValues = {"https://yourapp.com/redirect (OAuth2)"}        
	]),
optional AccessToken as ( type text meta [
        Documentation.FieldCaption = "Access Token",
        Documentation.FieldDescription = "Provide the OAuth2 Access Token",
        Documentation.SampleValues = {"Your Access Token (OAuth2)"}        
	]),
optional RefreshToken as ( type text meta [
        Documentation.FieldCaption = "Refresh Token",
        Documentation.FieldDescription = "Provide the OAuth2 Refresh Token",
        Documentation.SampleValues = {"Your Refresh Token (OAuth2)"}        
	]))
	as table meta [
        Documentation.Name = "Connect to any REST API - DataDirect Autonomous REST Connector",
        Documentation.LongDescription = "Progress DataDirect Autonomous REST Connector is high performance connector that let's you DirectQuery/Import data from any REST API."
    ];

AutoRESTImpl = (AuthenticationMethod as text, optional RestSamplePath as nullable text, optional RESTConfigPath as nullable text, optional AuthParam as nullable text, 
                optional AuthHeader as nullable text, optional SecurityToken as nullable text, optional ClientID as nullable text, optional ClientSecret as nullable text, 
                optional LogonID as nullable text, optional Password as nullable text, optional AccessToken as nullable text, optional OauthCode as nullable text, 
                optional RefreshToken as nullable text, optional RedirectURI as nullable text, optional TokenURI as nullable text, optional Scope as nullable text) =>
    let ConnectionString = [
        Driver = DriverName,
        RestSamplePath =  RestSamplePath,
        RestConfigFile =  RESTConfigPath,
        AuthenticationMethod = AuthenticationMethod,
        LogonID = LogonID,
        Password = Password,
        AuthParam = AuthParam,
        AuthHeader = AuthHeader,
        SecurityToken = SecurityToken,
        ClientID = ClientID,
        ClientSecret = ClientSecret,
        AccessToken = AccessToken,
        RefreshToken = RefreshToken,
        OauthCode = OauthCode,
        Scope = Scope,
        TokenURI = TokenURI,
        RedirectURI = RedirectURI
        ],

    Credential = Extension.CurrentCredential(),
	CredentialConnectionString =
        if Credential[AuthenticationKind]? = "Implicit" then
            [ UID = null, PWD = null ]
        else
            error Error.Record("Error", "Unhandled authentication kind: " & Credential[AuthenticationKind]?),

    AutoRESTConnector = Odbc.DataSource(ConnectionString, [
            CreateNavigationProperties = false,
            HierarchicalNavigation = true,
            ClientConnectionPooling = true,
            TolerateConcatOverflow = true,
            CredentialConnectionString = CredentialConnectionString,
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
                SQL_IDENTIFIER_QUOTE_CHAR = "",
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
    Authentication = [
        Implicit = []
        //UsernamePassword = []
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