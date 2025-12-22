namespace D4P.CCMS.PTEApps;

using D4P.CCMS.Nuget;
table 62007 "D4P BC PTE App"
{
    DataClassification = CustomerContent;
    Caption = 'D365BC PTE App';
    drilldownpageid = "D4P BC PTE Apps List";
    LookupPageId = "D4P BC PTE Apps List";

    fields
    {
        field(1; "PTE ID"; Guid)
        {
            Caption = 'PTE ID';
        }
        field(2; "PTE Name"; Text[100])
        {
            Caption = 'PTE Name';
        }
        field(4; "Range From"; Integer)
        {
            Caption = 'Range From';
        }
        field(5; "Range To"; Integer)
        {
            Caption = 'Range To';
        }
        field(6; "Latest App Version"; Text[50])
        {
            Caption = 'App Version';
            ToolTip = 'Specifies the latest version of the PTE app.';
        }
        field(7; DevOps; enum "D4P BC DevOps Environments")
        {
            Caption = 'DevOps Environment';
            ToolTip = 'Specifies the DevOps environment associated with the PTE app.';
        }
        field(8; "DevOps Organization"; Text[100])
        {
            Caption = 'Organization';
            ToolTip = 'Specifies the organization associated with the PTE app.';
            TableRelation = "D4P BC DevOps Organization".ID;
        }
        field(9; "DevOps Package"; Text[100])
        {
            Caption = 'Repository';
            ToolTip = 'Specifies the repository associated with the PTE app.';
        }
        field(10; "DevOps Feed"; Text[100])
        {
            Caption = 'Feed';
            ToolTip = 'Specifies the feed associated with the PTE app.';
        }
        field(11; "NuGet Package Name"; Text[250])
        {
            Caption = 'NuGet Package Name';
            ToolTip = 'Specifies the NuGet package name of the PTE app.';
        }
    }

    keys
    {
        key(PK; "PTE ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "PTE ID", "PTE Name")
        { }
        fieldgroup(Brick; "PTE ID", "PTE Name")
        { }
    }
    trigger OnDelete()
    var
        PTEAppVersion: Record "D4P BC PTE App Version";
    begin
        PTEAppVersion.SetRange("PTE ID", Rec."PTE ID");
        if not PTEAppVersion.IsEmpty() then
            PTEAppVersion.DeleteAll();
    end;
}