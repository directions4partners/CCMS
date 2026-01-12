namespace D4P.CCMS.PTEApps;
page 62035 "D4P BC PTE App Card"
{
    ApplicationArea = All;
    Caption = 'D365BC PTE App Card';
    PageType = Card;
    SourceTable = "D4P BC PTE App";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("PTE ID"; Rec."PTE ID")
                {
                }
                field("PTE Name"; Rec."PTE Name")
                {
                }
                field("App Version"; Rec."Latest App Version")
                {
                }
                field("Range From"; Rec."Range From")
                {
                }
                field("Range To"; Rec."Range To")
                {
                }
            }
            group(DevOpsGroup)
            {
                Caption = 'DevOps';

                field(DevOps; Rec."DevOps Environment")
                {
                }
                field("DevOps Organization"; Rec."DevOps Organization")
                {
                }
                field("DevOps Package"; Rec."DevOps Package")
                {
                    Caption = 'Package';
                    Visible = DevOpsPackageVisible;
                }
                field("DevOps Feed"; Rec."DevOps Feed")
                {
                    Visible = DevOpsFeedVisible;
                }
                field("NuGet Package Name"; Rec."NuGet Package Name")
                {
                }
            }
        }

        area(FactBoxes)
        {
            part(PTEAppVersionsFactBox; "D4P PTE App Versions FactBox")
            {
                Caption = 'Versions';
                SubPageLink = "PTE ID" = field("PTE ID");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetVisibleFields();
    end;

    local procedure SetVisibleFields()
    begin
        if Rec."DevOps Environment" = Rec."DevOps Environment"::Azure then begin
            DevOpsPackageVisible := true;
            DevOpsFeedVisible := true;
        end else begin
            DevOpsPackageVisible := false;
            DevOpsFeedVisible := false;
        end;
    end;

    var
        DevOpsPackageVisible: Boolean;
        DevOpsFeedVisible: Boolean;
}
