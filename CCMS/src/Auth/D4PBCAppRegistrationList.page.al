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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure AD Application (Client) ID.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description for this app registration.';
                }
                field("Secret Expiration Date"; Rec."Secret Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the client secret expires. Update the secret before this date.';
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
