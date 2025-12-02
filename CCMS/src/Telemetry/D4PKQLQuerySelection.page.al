namespace D4P.CCMS.Telemetry;

#pragma warning disable AA0218
page 62039 "D4P KQL Query Selection"
{

    PageType = List;
    UsageCategory = None;
    SourceTable = "D4P KQL Query Store";
    Caption = 'Query Selection', Locked = true;

    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Query Code';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Query Name';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
            }
        }
    }

    var
        SelectedQueryCode: Code[20];

    trigger OnAfterGetCurrRecord()
    begin
        SelectedQueryCode := Rec.Code;
    end;

    procedure GetSelectedQueryCode(): Code[20]
    begin
        exit(SelectedQueryCode);
    end;

}