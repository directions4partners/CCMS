namespace D4P.CCMS.Capacity;

using D4P.CCMS.Customer;
using D4P.CCMS.Tenant;

table 62019 "D4P BC Capacity Header"
{
    Caption = 'D365BC Capacity Header';
    DataClassification = CustomerContent;
    DrillDownPageId = "D4P BC Capacity List";
    LookupPageId = "D4P BC Capacity List";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer"."No.";
            ToolTip = 'Specifies the customer number.';
        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            ToolTip = 'Specifies the tenant ID.';
        }
        field(10; "Last Update Date"; DateTime)
        {
            Caption = 'Last Update Date';
            ToolTip = 'Specifies when the capacity data was last updated.';
        }
        // Storage Quota fields from /environments/quotas
        field(20; "Storage Default KB"; BigInteger)
        {
            Caption = 'Storage Default KB';
        }
        field(21; "Storage User Licenses KB"; BigInteger)
        {
            Caption = 'Storage User Licenses KB';
        }
        field(22; "Storage Additional Capacity KB"; BigInteger)
        {
            Caption = 'Storage Additional Capacity KB';
        }
        field(23; "Storage Total KB"; BigInteger)
        {
            Caption = 'Storage Total KB';
        }
        // Calculated GB fields
        field(30; "Storage Default GB"; Decimal)
        {
            Caption = 'Storage Default GB';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the default storage capacity (organization default).';
        }
        field(31; "Storage User Licenses GB"; Decimal)
        {
            Caption = 'Storage User Licenses GB';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the storage capacity from user licenses.';
        }
        field(32; "Storage Additional Capacity GB"; Decimal)
        {
            Caption = 'Storage Additional Capacity GB';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the additional purchased storage capacity.';
        }
        field(33; "Storage Total GB"; Decimal)
        {
            Caption = 'Storage Total GB';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the total database storage capacity allowed.';
        }
        // Total storage used (sum from all environments)
        field(40; "Total Storage Used KB"; BigInteger)
        {
            Caption = 'Total Storage Used KB';
        }
        field(41; "Total Storage Used GB"; Decimal)
        {
            Caption = 'Total Storage Used GB';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the total database storage used across all environments.';
        }
        field(42; "Storage Available GB"; Decimal)
        {
            Caption = 'Storage Available GB';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the available database storage capacity.';
        }
        field(43; "Usage %"; Decimal)
        {
            Caption = 'Usage %';
            DecimalPlaces = 2 : 2;
            Editable = false;
            ToolTip = 'Specifies the percentage of storage capacity used.';
        }
        field(44; "Customer Name"; Text[100])
        {
            CalcFormula = Lookup("D4P BC Customer"."Name" where("No." = field("Customer No.")));
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the name of the customer.';
        }
        field(45; "Tenant Name"; Text[100])
        {
            CalcFormula = Lookup("D4P BC Tenant"."Tenant Name" where("Tenant ID" = field("Tenant ID")));
            Caption = 'Tenant Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the name of the tenant.';
        }
        // Environment quotas
        field(50; "Max Production Environments"; Integer)
        {
            Caption = 'Max Production Environments';
            ToolTip = 'Specifies the maximum allowed number of production environments.';
        }
        field(51; "Max Sandbox Environments"; Integer)
        {
            Caption = 'Max Sandbox Environments';
            ToolTip = 'Specifies the maximum allowed number of sandbox environments.';
        }
        field(52; "Production Environments Used"; Integer)
        {
            Caption = 'Production Environments Used';
            ToolTip = 'Specifies the number of production environments currently in use.';
        }
        field(53; "Sandbox Environments Used"; Integer)
        {
            Caption = 'Sandbox Environments Used';
            ToolTip = 'Specifies the number of sandbox environments currently in use.';
        }
        field(54; "Production Env. Available"; Integer)
        {
            Caption = 'Production Environments Available';
            ToolTip = 'Specifies the number of available production environment slots.';
        }
        field(55; "Sandbox Env. Available"; Integer)
        {
            Caption = 'Sandbox Environments Available';
            ToolTip = 'Specifies the number of available sandbox environment slots.';
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
