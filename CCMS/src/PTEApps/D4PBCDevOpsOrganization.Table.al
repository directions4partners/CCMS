namespace D4P.CCMS.PTEApps;
table 62006 "D4P BC DevOps Organization"
{
    DataClassification = CustomerContent;
    Caption = 'D365BC DevOps Organization';

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'ID';
            ToolTip = 'Specifies the unique identifier for the DevOps organization.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the DevOps organization.';
        }
    }

    keys
    {
        key(PK; ID)
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