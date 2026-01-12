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
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                }
                field("PTE ID"; Rec."PTE ID")
                {
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
                }
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
