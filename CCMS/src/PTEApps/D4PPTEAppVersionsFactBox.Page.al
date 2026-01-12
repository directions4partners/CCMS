namespace D4P.CCMS.PTEApps;

using D4P.CCMS.Nuget;

page 62033 "D4P PTE App Versions FactBox"
{
    ApplicationArea = All;
    Caption = 'D365BC Versions';
    PageType = ListPart;
    SourceTable = "D4P BC PTE App Version";
    CardPageId = "D4P BC PTE App Version Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("App Version"; Rec."App Version")
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
