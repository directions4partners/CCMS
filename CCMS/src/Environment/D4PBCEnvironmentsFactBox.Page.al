namespace D4P.CCMS.Environment;

page 62015 "D4P BC Environments FactBox"
{
    Caption = 'Environments';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "D4P BC Environment";
    CardPageId = "D4P BC Environment Card";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Environments)
            {
                field(Name; Rec."Name")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec."Type")
                {
                    ApplicationArea = All;
                }
                field("Country/Region"; Rec."Country/Region")
                {
                    ApplicationArea = All;
                }
                field("Current Version"; Rec."Current Version")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}