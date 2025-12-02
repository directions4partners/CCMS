namespace D4P.CCMS.Telemetry;

table 62038 "D4P KQL Slow AL Method"
{

    DataClassification = SystemMetadata;
    Caption = 'Long Running AL Method', Locked = true;

    DrillDownPageId = "D4P KQL Slow AL Methods";
    LookupPageId = "D4P KQL Slow AL Methods";

    fields
    {
        field(10; "Environment Code"; Code[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Environment Code';
        }
        field(15; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
        }
        field(16; "User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User ID';
        }
        field(20; "Execution Date"; Date)
        {
            DataClassification = SystemMetadata;
            Caption = 'Execution Date', Locked = true;
        }
        field(21; "Execution Date/Time"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Execution Date/Time', Locked = true;
        }
        field(30; "Tenant ID"; Text[250])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Tenant ID', Locked = true;
        }
        field(40; "Extension ID"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Extension ID', Locked = true;
        }
        field(50; "Extension Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Extension Name', Locked = true;
        }
        field(60; "Company Name"; Text[50])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Company Name', Locked = true;
        }
        field(70; "AL Object ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'AL Object ID', Locked = true;
        }
        field(80; "AL Object Type"; Text[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'AL Object Type', Locked = true;
        }
        field(90; "AL Object Name"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'AL Object Name', Locked = true;
        }
        field(100; "Method Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Method Name', Locked = true;
        }
        field(110; "Client Type"; Text[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Client Type', Locked = true;
        }
        field(120; "Max. Execution Time"; Decimal)
        {
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 2;
            Caption = 'Max. Execution Time', Locked = true;
        }
        field(130; Publisher; Text[100])
        {
            DataClassification = SystemMetadata;
            Caption = 'Publisher', Locked = true;
        }
        field(140; Version; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Version', Locked = true;
        }
        field(150; "No. of Executions"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'No. of Executions', Locked = true;
        }
        field(160; "Environment Type"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Environment Type', Locked = true;
        }
        field(161; "Environment Name"; Text[50])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Environment Name', Locked = true;
        }
    }

    keys
    {
        key(Key1; "Environment Code", "User ID", "Entry No.")
        {
            Clustered = true;
        }
    }

}