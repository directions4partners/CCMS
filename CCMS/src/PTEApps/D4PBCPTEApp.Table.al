namespace D4P.CCMS.PTEApps;

using D4P.CCMS.Nuget;
table 62007 "D4P BC PTE App"
{
    DataClassification = CustomerContent;
    Caption = 'D365BC PTE App';
    DrillDownPageId = "D4P BC PTE App List";
    LookupPageId = "D4P BC PTE App List";

    fields
    {
        field(1; "ID"; Guid)
        {
            Caption = 'PTE ID';
            ToolTip = 'Specifies the ID of the Per Tenant Extension.';
        }
        field(2; "Name"; Text[100])
        {
            Caption = 'PTE Name';
            ToolTip = 'Specifies the name of the Per Tenant Extension.';
        }
        field(4; "Range From"; Integer)
        {
            Caption = 'Range From';
            ToolTip = 'Specifies the starting range for the PTE app.';
        }
        field(5; "Range To"; Integer)
        {
            Caption = 'Range To';
            ToolTip = 'Specifies the ending range for the PTE app.';
        }
        field(6; "Latest App Version"; Text[50])
        {
            Caption = 'App Version';
            ToolTip = 'Specifies the latest version of the PTE app.';
        }
        field(7; "DevOps Environment"; enum "D4P BC DevOps Environment")
        {
            Caption = 'DevOps Environment';
            ToolTip = 'Specifies the DevOps environment associated with the PTE app.';
            trigger OnValidate()
            begin
                if Rec."DevOps Environment" <> xRec."DevOps Environment" then
                    ClearFieldsOnDevOpsChange();
            end;
        }
        field(8; "DevOps Organization"; Text[100])
        {
            Caption = 'Organization';
            ToolTip = 'Specifies the organization associated with the PTE app.';
            trigger OnLookup()
            var
                DevOpsOrganization: Record "D4P BC DevOps Organization";
            begin
                DevOpsOrganization.SetRange("DevOps Environment", Rec."DevOps Environment");
                if Page.RunModal(Page::"D4P BC DevOps Org. List", DevOpsOrganization) = Action::LookupOK then
                    Rec."DevOps Organization" := DevOpsOrganization.ID;
            end;
        }
        field(9; "DevOps Package"; Text[100])
        {
            Caption = 'Package';
            ToolTip = 'Specifies the package associated with the PTE app.';
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
        key(PK; "ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "ID", "Name")
        { }
        fieldgroup(Brick; "ID", "Name")
        { }
    }
    trigger OnDelete()
    var
        PTEAppVersion: Record "D4P BC PTE App Version";
    begin
        PTEAppVersion.SetRange("PTE ID", Rec."ID");
        if not PTEAppVersion.IsEmpty() then
            PTEAppVersion.DeleteAll(true);
    end;

    local procedure ClearFieldsOnDevOpsChange()
    begin
        Rec."DevOps Organization" := '';
        Rec."DevOps Feed" := '';
        Rec."DevOps Package" := '';
        Rec."NuGet Package Name" := '';
    end;
}