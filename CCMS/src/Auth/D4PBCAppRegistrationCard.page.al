namespace D4P.CCMS.Auth;

page 62026 "D4P BC App Registration Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "D4P BC App Registration";
    Caption = 'D365BC App Registration Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
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
                field("Client Secret"; ClientSecretValue)
                {
                    ApplicationArea = All;
                    Caption = 'Client Secret';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the Azure AD Application Client Secret. This is stored securely in isolated storage.';

                    trigger OnValidate()
                    begin
                        StoreClientSecret();
                    end;
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
        ClientSecretValue, SecretExpirationStyle : Text;

    trigger OnAfterGetRecord()
    begin
        LoadClientSecret();
        SecretExpirationStyle := Rec.GetSecretExpirationStyle();
    end;

    local procedure LoadClientSecret()
    var
        SecretPlaceholderLbl: Label 'SECRETPLACEHOLDER', Locked = true;
    begin
        ClientSecretValue := '';
        if IsNullGuid(Rec."Client ID") then
            exit;

        if Rec.HasClientSecret() then
            ClientSecretValue := SecretPlaceholderLbl;
    end;

    local procedure StoreClientSecret()
    var
        SecretText: SecretText;
    begin
        if IsNullGuid(Rec."Client ID") then
            exit;

        SecretText := ClientSecretValue.Trim();
        Rec.SetClientSecret(Rec."Client ID", SecretText);
    end;
}
