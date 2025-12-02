namespace D4P.CCMS.Telemetry;

table 62046 "D4P AppInsights Connection"
{
    Caption = 'Application Insights Connection Setup';
    DataClassification = SystemMetadata;

    fields
    {
        field(10; "AppInsights Connection String"; Text[1000])
        {
            Caption = 'Application Insights Connection String';
            DataClassification = CustomerContent;
        }
        field(20; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Telemetry Application Id"; Text[50])
        {
            Caption = 'Telemetry Application Id';
            DataClassification = CustomerContent;
        }
        field(40; "Telemetry API Key"; Text[50])
        {
            Caption = 'Telemetry API Key';
            DataClassification = CustomerContent;
        }
        field(50; "Tenant Id"; Text[50])
        {
            Caption = 'Tenant Id';
            DataClassification = CustomerContent;
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