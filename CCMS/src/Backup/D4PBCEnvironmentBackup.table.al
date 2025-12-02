namespace D4P.CCMS.Backup;

using D4P.CCMS.Customer;

table 62014 "D4P BC Environment Backup"
{
    Caption = 'D365BC Environment Database Export';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Export ID"; Code[50])
        {
            Caption = 'Export ID';
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer"."No.";
        }
        field(10; "Tenant ID"; Text[50])
        {
            Caption = 'Tenant ID';
        }
        field(15; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
        }
        field(20; "Application Type"; Text[50])
        {
            Caption = 'Application Type';
        }
        field(25; "Application Version"; Text[50])
        {
            Caption = 'Application Version';
        }
        field(30; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
        }
        field(35; "Export Time"; DateTime)
        {
            Caption = 'Export Time';
        }
        field(40; "Storage Account"; Text[100])
        {
            Caption = 'Storage Account';
        }
        field(45; "Container"; Text[100])
        {
            Caption = 'Container';
        }
        field(50; "Blob"; Text[100])
        {
            Caption = 'Blob';
        }
        field(55; "Exported By"; Text[100])
        {
            Caption = 'Exported By';
        }
        field(60; "Export Status"; Enum "D4P Export Status")
        {
            Caption = 'Export Status';
        }
        field(65; "SAS URI"; Text[250])
        {
            Caption = 'SAS URI';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(70; "Exports Per Month"; Integer)
        {
            Caption = 'Exports Per Month';
        }
        field(75; "Exports Remaining This Month"; Integer)
        {
            Caption = 'Exports Remaining This Month';
        }
    }

    keys
    {
        key(PK; "Export ID")
        {
            Clustered = true;
        }
        key(Environment; "Environment Name", "Export Time")
        {
        }
    }
}