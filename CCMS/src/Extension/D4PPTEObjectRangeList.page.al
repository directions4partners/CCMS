namespace D4P.CCMS.Extension;

using D4P.CCMS.PTEApps;
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
                    ToolTip = 'Specifies the customer number.';
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    ToolTip = 'Specifies the tenant ID.';
                }
                field("PTE ID"; Rec."PTE ID")
                {
                    ToolTip = 'Specifies the Per Tenant Extension''s ID.';
                    TableRelation = "D4P BC PTE App"."PTE ID";

                    trigger OnValidate()
                    begin
                        if IsNullGuid(Rec."PTE ID") then
                            exit;

                        Rec.CopyValuesFromApp(Rec."PTE ID");
                    end;
                }
                field("PTE Name"; Rec."PTE Name")
                {
                    ToolTip = 'Specifies the Per Tenant Extension''s name.';
                }
                field("Range From"; Rec."Range From")
                {
                    ToolTip = 'Specifies the starting range.';
                }
                field("Range To"; Rec."Range To")
                {
                    ToolTip = 'Specifies the ending range.';
                }
            }
        }
    }
}
