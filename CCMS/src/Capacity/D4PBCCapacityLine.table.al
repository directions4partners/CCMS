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
            ToolTip = 'Specifies the customer number.';
        }
        field(5; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            ToolTip = 'Specifies the tenant ID.';
        }
        field(7; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            ToolTip = 'Specifies the environment name.';
        }
        field(12; "Environment Type"; Text[50])
        {
            Caption = 'Environment Type';
            ToolTip = 'Specifies the environment type (Production or Sandbox).';
        }
        field(14; "Application Family"; Text[50])
        {
            Caption = 'Application Family';
            ToolTip = 'Specifies the application family.';
        }
        field(15; "Measurement Date"; DateTime)
        {
            Caption = 'Measurement Date';
            ToolTip = 'Specifies when the capacity data was measured.';
        }
        field(20; "Database Storage KB"; BigInteger)
        {
            Caption = 'Database Storage (KB)';
            ToolTip = 'Specifies the database storage used by this environment in KB.';
        }
        field(22; "Database Storage MB"; Decimal)
        {
            Caption = 'Database Storage (MB)';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the database storage used by this environment in MB.';
        }
        field(24; "Database Storage GB"; Decimal)
        {
            Caption = 'Database Storage (GB)';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the database storage used by this environment in GB.';
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