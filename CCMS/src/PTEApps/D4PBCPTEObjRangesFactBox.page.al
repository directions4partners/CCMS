namespace D4P.CCMS.PTEApps;

using D4P.CCMS.PTEApps;

page 62038 "D4P BC PTE Obj. Ranges FactBox"
{
    ApplicationArea = All;
    Caption = 'D365BC PTE Object Ranges FactBox';
    PageType = ListPart;
    SourceTable = "D4P BC PTE Object Range";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Range From"; Rec."Range From")
                {
                }
                field("Range To"; Rec."Range To")
                {
                }
            }
        }
    }
}
