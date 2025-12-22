namespace D4P.CCMS.PTEApps;

page 62027 "D4P PTE App Versions FactBox"
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
}
