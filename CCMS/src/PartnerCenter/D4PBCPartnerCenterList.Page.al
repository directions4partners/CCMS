namespace D4P.CCMS.PartnerCenter;

page 62032 "D4P BC Partner Center List"
{
    ApplicationArea = All;
    Caption = 'Partner Center List';
    CardPageId = "D4P BC Partner Center Card";
    Editable = false;
    PageType = List;
    SourceTable = "D4P BC Partner Center";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
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
