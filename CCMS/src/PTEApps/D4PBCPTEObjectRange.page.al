namespace D4P.CCMS.PTEApps;

page 62037 "D4P BC PTE Object Range"
{
    ApplicationArea = All;
    Caption = 'D365BC PTE Object Range';
    PageType = List;
    SourceTable = "D4P BC PTE Object Range";
    UsageCategory = None;

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

    procedure SetAppId(PTEAppIdParameter: Guid)
    begin
        Rec.SetRange("PTE ID", PTEAppIdParameter);
        PTEAppId := PTEAppIdParameter;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."PTE ID" := PTEAppId;
    end;

    var
        PTEAppId: Guid;
}
