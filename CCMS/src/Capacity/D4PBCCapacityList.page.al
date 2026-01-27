namespace D4P.CCMS.Capacity;

page 62031 "D4P BC Capacity List"
{
    Caption = 'BC Capacities';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "D4P BC Capacity Header";
    Editable = false;
    CardPageId = "D4P BC Capacity Worksheet";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    DrillDown = false;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                }
                field("Tenant Name"; Rec."Tenant Name")
                {
                    DrillDown = false;
                }
                field("Total Storage Used GB"; Rec."Total Storage Used GB")
                {
                }
                field("Storage Total GB"; Rec."Storage Total GB")
                {
                }
                field("Storage Available GB"; Rec."Storage Available GB")
                {
                }
                field("Usage %"; Rec."Usage %")
                {
                }
            }
        }
    }
}