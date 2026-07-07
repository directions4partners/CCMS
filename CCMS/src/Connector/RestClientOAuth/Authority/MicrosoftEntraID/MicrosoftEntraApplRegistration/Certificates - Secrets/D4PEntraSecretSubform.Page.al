namespace D4P.CCMS.Connector.RestClientOAuth;
page 62037 "D4P Entra Secret Subform"
{
    PageType = ListPart;
    Caption = 'Secrets';
    ApplicationArea = All;
    SourceTable = "D4P Entra Secret";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field(Description; Rec.Description) { }
                field("End Date/Time"; Rec."End Date/Time") { }
                field(SecretTxt; SecretTxt)
                {
                    Caption = 'Value';
                    Editable = SecretEditable;

                    trigger OnValidate()
                    begin
                        Rec.Hint := SecretTxt.Substring(1, 3);
                        CurrPage.SaveRecord();
                        Rec.SetSecretText(SecretTxt);
                        CurrPage.Update(false);
                    end;
                }
                field(Id; Rec.Id) { }
            }
        }
    }

    var
        [NonDebuggable]
        SecretTxt: Text;
        SecretEditable: Boolean;


    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Id := Format(CreateGuid(), 0, 4).ToLower();
        SecretTxt := '';
        SecretEditable := true;
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Hint = '' then begin
            SecretTxt := '';
            SecretEditable := true;
        end else begin
            SecretTxt := Rec.Hint + '******************';
            SecretEditable := false;
        end;
    end;
}