namespace D4P.CCMS.PTEApps;

using D4P.CCMS.Nuget;

page 62032 "D4P BC PTE App Version Card"
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
                }
                field("App Version"; Rec."App Version")
                {
                }
                field("Package Content Url"; Rec."Package Content Url")
                {
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
                    SuccessDownload: Label 'App package has been downloaded.';
                    FailedDownload: Label 'Failed to download app package.';
                begin
                    if NugetProcessing.DownloadPackageContent(Rec) then
                        Message(SuccessDownload)
                    else
                        Message(FailedDownload);
                end;
            }
        }
    }
}