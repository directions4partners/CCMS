namespace D4P.CCMS.PartnerCenter;

table 62006 "D4P BC Partner Center"
{
    Caption = 'Partner Center';
    DataClassification = CustomerContent;
    DrillDownPageId = "D4P BC Partner Center List";
    LookupPageId = "D4P BC Partner Center List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            ToolTip = 'Unique code to identify the Partner Center';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Partner Center description';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
