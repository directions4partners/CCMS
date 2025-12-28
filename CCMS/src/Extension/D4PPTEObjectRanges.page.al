namespace D4P.CCMS.Extension;
page 62009 "D4P PTE Object Ranges"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "D4P PTE Object Range";
    Caption = 'PTE Object Ranges';
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number.';
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tenant ID.';
                }
                field("PTE ID"; Rec."PTE ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Per Tenant Extension''s ID.';
                }
                field("PTE Name"; Rec."PTE Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Per Tenant Extension''s name.';
                }
                field("Range From"; Rec."Range From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the starting range.';
                }
                field("Range To"; Rec."Range To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ending range.';
                }
            }
        }
    }
}
