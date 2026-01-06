namespace D4P.CCMS.PTEApps;

using D4P.CCMS.Nuget;
table 62006 "D4P BC DevOps Organization"
{
    DataClassification = CustomerContent;
    Caption = 'D365BC DevOps Organization';

    fields
    {
        field(1; DevOps; enum "D4P BC DevOps Environments")
        {
            Caption = 'DevOps Organization ID';
            ToolTip = 'Specifies the unique identifier for the DevOps organization.';
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
        key(PK; "DevOps", ID)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        if IsolatedStorage.Contains(Rec.ID) then
            IsolatedStorage.Delete(Rec.ID);
    end;



}