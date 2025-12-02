namespace D4P.CCMS.Telemetry;

table 62037 "D4P KQL Report Execution"
{

    DataClassification = SystemMetadata;
    Caption = 'KQL Report Execution', Locked = true;

    LookupPageId = "D4P KQL Report Executions";
    DrillDownPageId = "D4P KQL Report Executions";

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
        field(20; "Report Name"; Text[1024])
        {
            Caption = 'Report Name', Locked = true;
            DataClassification = SystemMetadata;
        }
        field(30; "Execution Date"; Date)
        {
            Caption = 'Execution Date', Locked = true;
            DataClassification = SystemMetadata;
        }
        field(31; "Execution Date/Time"; DateTime)
        {
            Caption = 'Execution Date/Time', Locked = true;
            DataClassification = SystemMetadata;
        }
        field(40; "Average Execution Time"; Decimal)
        {
            Caption = 'Average Execution Time', Locked = true;
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 2;
        }
        field(50; "Average Rows"; Decimal)
        {
            Caption = 'Average Rows', Locked = true;
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 2;
        }
        field(60; "Max. Execution Time"; Decimal)
        {
            Caption = 'Max. Execution Time', Locked = true;
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 2;
        }
        field(61; "Max. Rows"; Decimal)
        {
            Caption = 'Max. Rows', Locked = true;
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 2;
        }
        field(70; "No. of Executions"; Integer)
        {
            Caption = 'No. of Executions', Locked = true;
            DataClassification = SystemMetadata;
        }
        field(80; "Report ID"; Integer)
        {
            Caption = 'Report ID', Locked = true;
            DataClassification = SystemMetadata;
        }
        field(90; "Extension Name"; Text[1024])
        {
            Caption = 'Extension Name', Locked = true;
            DataClassification = SystemMetadata;
        }
        field(100; "Company Name"; Text[50])
        {
            Caption = 'Company Name', Locked = true;
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(110; "Environment Type"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Environment Type', Locked = true;
        }
        field(111; "Environment Name"; Text[50])
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
        key(Key2; "Environment Code", "User ID", "Execution Date/Time") { }
    }

}