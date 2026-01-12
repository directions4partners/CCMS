namespace D4P.CCMS.Telemetry;

table 62046 "D4P AppInsights Connection"
{
    Caption = 'D365 BC Application Insights';
    DataClassification = SystemMetadata;
    DrillDownPageId = "D4P AppInsights Conn List";
    LookupPageId = "D4P AppInsights Conn List";

    fields
    {
        field(10; "AppInsights Connection String"; Text[1024])
        {
            Caption = 'Application Insights Connection String';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Application Insights connection string.';
        }
        field(20; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description for this connection.';
        }
        field(30; "Telemetry Application Id"; Text[50])
        {
            Caption = 'Telemetry Application Id';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Application ID for telemetry data access.';
        }
        field(40; "Telemetry API Key"; Text[50])
        {
            Caption = 'Telemetry API Key';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the API key for telemetry data access.';
        }
        field(50; "Tenant Id"; Text[50])
        {
            Caption = 'Tenant Id';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Tenant ID for telemetry data access.';
        }
    }

    keys
    {
        key(Key1; "AppInsights Connection String")
        {
            Clustered = true;
        }
    }
}