namespace D4P.CCMS.PTEApps;

using D4P.CCMS.Nuget;

page 62029 "D4P BC PTE Apps List"
{
    ApplicationArea = All;
    Caption = 'D365BC PTE Apps List';
    PageType = List;
    SourceTable = "D4P BC PTE App";
    UsageCategory = Administration;
    CardPageId = "D4P BC PTE App Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
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
                begin
                    NugetProcessing.GetPTEAppVersions(Rec);

                    Message('Latest versions have been updated.');
                end;
            }
        }
    }

}
