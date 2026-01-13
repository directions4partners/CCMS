namespace D4P.CCMS.PTEApps;

using D4P.CCMS.Nuget;

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

                field("ID"; Rec."ID")
                {
                }
                field("Name"; Rec."Name")
                {
                }
                field("Latest App Version"; Rec."Latest App Version")
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
                SubPageLink = "PTE ID" = field("ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetLatestVersions)
            {
                Caption = 'Get Latest Versions';
                ApplicationArea = All;
                Image = Refresh;
                trigger OnAction()
                var
                    NugetProcessing: Codeunit "D4P BC Nuget Processing";
                    OldLatestAppVersion: Text;
                    NoNewVersionsFound: Label 'No newer versions were found.';
                    LatestVersionsUpdated: Label 'Latest versions have been updated.';
                begin
                    OldLatestAppVersion := Rec."Latest App Version";
                    NugetProcessing.GetPTEAppVersions(Rec);
                    if Rec."Latest App Version" <> OldLatestAppVersion then
                        Message(LatestVersionsUpdated)
                    else
                        Message(NoNewVersionsFound);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(GetLatestVersions_Promoted; GetLatestVersions)
                {
                }
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
