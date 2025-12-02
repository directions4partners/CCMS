namespace D4P.CCMS.Telemetry;

table 62036 "D4P KQL Page Execution"
{

    DataClassification = SystemMetadata;
    Caption = 'KQL Page Execution', Locked = true;

    DrillDownPageId = "D4P KQL Page Executions";
    LookupPageId = "D4P KQL Page Executions";

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
        field(20; "Page Name"; Text[2014])
        {
            DataClassification = SystemMetadata;
            Caption = 'Page Name', Locked = true;
        }
        field(30; "Execution Date"; Date)
        {
            DataClassification = SystemMetadata;
            Caption = 'Execution Date', Locked = true;
        }
        field(31; "Execution Date/Time"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Execution Date/Time', Locked = true;
        }
        field(40; "Average Execution Time"; Decimal)
        {
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 2;
            Caption = 'Average Execution Time', Locked = true;
        }
        field(50; "Max. Execution Time"; Decimal)
        {
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 2;
            Caption = 'Max. Execution Time', Locked = true;
        }
        field(60; "No. Of Executions"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'No. of Executions', Locked = true;
        }
        field(70; "Page ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Page ID', Locked = true;
        }
        field(80; "Company Name"; Text[50])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Company Name', Locked = true;
        }
        field(100; "Tenant ID"; Text[250])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Tenant ID', Locked = true;
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