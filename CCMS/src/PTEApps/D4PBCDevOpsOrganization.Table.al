namespace D4P.CCMS.PTEApps;

using D4P.CCMS.Nuget;
table 62006 "D4P BC DevOps Organization"
{
    DataClassification = CustomerContent;
    Caption = 'D365BC DevOps Organization';
    LookupPageId = "D4P BC DevOps Org. List";
    DrillDownPageId = "D4P BC DevOps Org. List";

    fields
    {
        field(1; "DevOps Environment"; enum "D4P BC DevOps Environment")
        {
            Caption = 'DevOps Environment';
            ToolTip = 'Specifies the environment for the DevOps organization.';
        }
        field(2; ID; Code[20])
        {
            Caption = 'ID';
            ToolTip = 'Specifies the unique identifier for the DevOps organization.';
        }
        field(3; Name; Text[128])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the DevOps organization.';
        }
    }

    keys
    {
        key(PK; "DevOps Environment", ID)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        TokenKey: Text;
    begin
        TokenKey := StrSubstNo('%1-%2', Format(Rec."DevOps Environment"), Rec.ID);
        if IsolatedStorage.Contains(TokenKey) then
            IsolatedStorage.Delete(TokenKey);
    end;



}