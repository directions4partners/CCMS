namespace D4P.CCMS.PTEApps;

using D4P.CCMS.Nuget;

page 62026 "D4P BC PTE App Version Card"
{
    ApplicationArea = All;
    Caption = 'D365BC PTE App Versions Card';
    PageType = Card;
    SourceTable = "D4P BC PTE App Version";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("PTE ID"; Rec."PTE ID")
                {
                    ToolTip = 'Specifies the value of the PTE ID field.', Comment = '%';
                }
                field("App Version"; Rec."App Version")
                {
                    ToolTip = 'Specifies the value of the App Version field.', Comment = '%';
                }
                field("Package Content Url"; Rec."Package Content Url")
                {
                    ToolTip = 'Specifies the value of the Package Content Url field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadAppPackage)
            {
                Caption = 'Download App Package';
                ApplicationArea = All;
                Image = Download;
                trigger OnAction()
                var
                    NugetProcessing: Codeunit "D4P BC Nuget Processing";
                begin
                    NugetProcessing.DownloadPackageContent(Rec);

                    Message('App package has been downloaded.');
                end;
            }
        }
    }
}
