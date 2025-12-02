namespace D4P.CCMS.General;

using D4P.CCMS.Customer;
using D4P.CCMS.Tenant;

table 62047 "D4P BC Admin Center Cue"
{
    Caption = 'BC Admin Center Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Customers Count"; Integer)
        {
            Caption = 'Customers';
            FieldClass = FlowField;
            CalcFormula = count("D4P BC Customer");
            Editable = false;
        }
        field(3; "Tenants Count"; Integer)
        {
            Caption = 'Tenants';
            FieldClass = FlowField;
            CalcFormula = count("D4P BC Tenant");
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
