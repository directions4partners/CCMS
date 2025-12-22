namespace D4P.CCMS.PTEApps;
page 62028 "D4P BC PTE App Card"
{
    ApplicationArea = All;
    Caption = 'D365BC PTE Apps Card';
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
            }
            group(DevOpsGroup)
            {
                Caption = 'DevOps';

                field("Range From"; Rec."Range From")
                {
                }
                field("Range To"; Rec."Range To")
                {
                }
                field(DevOps; Rec.DevOps)
                {
                }
                field("DevOps Organization"; Rec."DevOps Organization")
                {
                }
                field("DevOps Package"; Rec."DevOps Package")
                {
                    Visible = DevOpsPackageVisible;
                }
                field("DevOps Feed"; Rec."DevOps Feed")
                {
                    Visible = DevopsFeedVisible;
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
                ApplicationArea = All;
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
        if Rec.DevOps = Rec.DevOps::Azure then begin
            DevOpsPackageVisible := true;
            DevopsFeedVisible := true;
        end else begin
            DevOpsPackageVisible := false;
            DevopsFeedVisible := false;
        end;
    end;

    var
        DevOpsPackageVisible: Boolean;
        DevopsFeedVisible: Boolean;
}
