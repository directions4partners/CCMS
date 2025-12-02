namespace D4P.CCMS.Telemetry;

table 62035 "D4P KQL Extension Lifecycle"
{

    DataClassification = SystemMetadata;
    Caption = 'KQL Extension Lifecycle', Locked = true;

    DrillDownPageId = "D4P KQL Extension Lifecycle";
    LookupPageId = "D4P KQL Extension Lifecycle";

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
        field(20; "Extension Name"; Text[1024])
        {
            DataClassification = SystemMetadata;
            Caption = 'Extension Name', Locked = true;
        }
        field(30; "Extension ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Extension ID', Locked = true;
        }
        field(40; Publisher; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Publisher', Locked = true;
        }
        field(50; Version; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Version', Locked = true;
        }
        field(60; "Event ID"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Event ID', Locked = true;
        }
        field(70; Message; Text[1024])
        {
            DataClassification = SystemMetadata;
            Caption = 'Message', Locked = true;
        }
        field(80; Result; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Result', Locked = true;
        }
        field(90; "Exec. Date/Time"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Exec. Date/Time', Locked = true;
        }
        field(100; "Tenant ID"; Text[250])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Tenant ID', Locked = true;
        }
        field(110; "Sync. Mode"; Text[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Sync. Mode', Locked = true;
        }
        field(120; "Execution Time"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Execution Time', Locked = true;
        }
        field(130; "Failure Reason"; Text[1024])
        {
            DataClassification = SystemMetadata;
            Caption = 'Failure Reason', Locked = true;
        }
        field(140; "Environment Type"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Environment Type', Locked = true;
        }
        field(141; "Environment Name"; Text[50])
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