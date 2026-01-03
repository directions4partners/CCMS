namespace D4P.CCMS.Auth;

page 62027 "D4P BC App Registration List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "D4P BC App Registration";
    Caption = 'D365BC App Registrations';
    CardPageId = "D4P BC App Registration Card";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Client ID"; Rec."Client ID")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Secret Expiration Date"; Rec."Secret Expiration Date")
                {
                    StyleExpr = SecretExpirationStyle;
                }
            }
        }
    }

    var
        SecretExpirationStyle: Text;

    trigger OnAfterGetRecord()
    begin
        SecretExpirationStyle := Rec.GetSecretExpirationStyle();
    end;
}
