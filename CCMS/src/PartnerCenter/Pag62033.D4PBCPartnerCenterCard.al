namespace D4P.CCMS.PartnerCenter;

page 62033 "D4P BC Partner Center Card"
{
    ApplicationArea = All;
    Caption = 'Partner Center Card';
    PageType = Card;
    SourceTable = "D4P BC Partner Center";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."Code")
                {
                }
                field(Description; Rec.Description)
                {
                }
            }
        }
    }
}
