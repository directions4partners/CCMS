namespace D4P.CCMS.PTEApps;

table 62008 "D4P BC PTE Object Range"
{
    DataClassification = CustomerContent;
    Caption = 'D365BC PTE Object Range';
    LookupPageId = "D4P BC PTE Object Range";
    DrillDownPageId = "D4P BC PTE Object Range";

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number.';
            AutoIncrement = true;
        }
        field(2; "PTE ID"; Guid)
        {
            Caption = 'PTE ID';
            ToolTip = 'Specifies the Per Tenant Extension''s ID.';
        }

        field(3; "Range From"; Integer)
        {
            Caption = 'Range From';
            ToolTip = 'Specifies the starting range for the PTE app.';
        }
        field(4; "Range To"; Integer)
        {
            Caption = 'Range To';
            ToolTip = 'Specifies the ending range for the PTE app.';
        }
    }

    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
    }
}