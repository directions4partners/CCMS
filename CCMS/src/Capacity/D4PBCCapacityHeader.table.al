namespace D4P.CCMS.Capacity;

using D4P.CCMS.Customer;

table 62019 "D4P BC Capacity Header"
{
    DataClassification = CustomerContent;
    Caption = 'D365BC Capacity Header';

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer"."No.";
        }
        field(2; "Tenant ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Tenant ID';
        }
        field(10; "Last Update Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Update Date';
        }
        // Storage Quota fields from /environments/quotas
        field(20; "Storage Default KB"; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Storage Default KB';
        }
        field(21; "Storage User Licenses KB"; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Storage User Licenses KB';
        }
        field(22; "Storage Additional Capacity KB"; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Storage Additional Capacity KB';
        }
        field(23; "Storage Total KB"; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Storage Total KB';
        }
        // Calculated GB fields
        field(30; "Storage Default GB"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Storage Default GB';
            DecimalPlaces = 2 : 2;
        }
        field(31; "Storage User Licenses GB"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Storage User Licenses GB';
            DecimalPlaces = 2 : 2;
        }
        field(32; "Storage Additional Capacity GB"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Storage Additional Capacity GB';
            DecimalPlaces = 2 : 2;
        }
        field(33; "Storage Total GB"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Storage Total GB';
            DecimalPlaces = 2 : 2;
        }
        // Total storage used (sum from all environments)
        field(40; "Total Storage Used KB"; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Storage Used KB';
        }
        field(41; "Total Storage Used GB"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Storage Used GB';
            DecimalPlaces = 2 : 2;
        }
        field(42; "Storage Available GB"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Storage Available GB';
            DecimalPlaces = 2 : 2;
        }
        // Environment quotas
        field(50; "Max Production Environments"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Max Production Environments';
        }
        field(51; "Max Sandbox Environments"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Max Sandbox Environments';
        }
        field(52; "Production Environments Used"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Production Environments Used';
        }
        field(53; "Sandbox Environments Used"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sandbox Environments Used';
        }
        field(54; "Production Env. Available"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Production Environments Available';
        }
        field(55; "Sandbox Env. Available"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sandbox Environments Available';
        }
    }

    keys
    {
        key(PK; "Customer No.", "Tenant ID")
        {
            Clustered = true;
        }
    }
}
