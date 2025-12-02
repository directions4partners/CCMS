namespace D4P.CCMS.Capacity;

using D4P.CCMS.Customer;

table 62015 "D4P BC Capacity Line"
{
    Caption = 'D365BC Capacity Line';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer"."No.";
        }
        field(5; "Tenant ID"; Text[50])
        {
            Caption = 'Tenant ID';
        }
        field(7; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
        }
        field(12; "Environment Type"; Text[50])
        {
            Caption = 'Environment Type';
        }
        field(14; "Application Family"; Text[50])
        {
            Caption = 'Application Family';
        }
        field(15; "Measurement Date"; DateTime)
        {
            Caption = 'Measurement Date';
        }
        field(20; "Database Storage KB"; BigInteger)
        {
            Caption = 'Database Storage (KB)';
        }
        field(22; "Database Storage MB"; Decimal)
        {
            Caption = 'Database Storage (MB)';
            DecimalPlaces = 2 : 2;
        }
        field(24; "Database Storage GB"; Decimal)
        {
            Caption = 'Database Storage (GB)';
            DecimalPlaces = 2 : 2;
        }
    }

    keys
    {
        key(PK; "Customer No.", "Tenant ID", "Line No.")
        {
            Clustered = true;
        }
        key(Environment; "Customer No.", "Tenant ID", "Environment Name")
        {
        }
    }
}