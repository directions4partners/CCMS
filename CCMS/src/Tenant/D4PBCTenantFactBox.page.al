namespace D4P.CCMS.Tenant;

page 62012 "D4P BC Tenant FactBox"
{
    PageType = CardPart;
    SourceTable = "D4P BC Tenant";
    Caption = 'Tenant Details';

    layout
    {
        area(Content)
        {
            group(Authentication)
            {
                Caption = 'Authentication';
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure AD application client ID.';
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure AD application client secret.';
                    ExtendedDatatype = Masked;
                }
                field("Secret Expiration Date"; Rec."Secret Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the client secret will expire.';
                }
            }
            group(Backup)
            {
                Caption = 'Backup Configuration';
                field("Backup SAS URI"; Rec."Backup SAS URI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Blob Storage SAS URI where to store the backup from the BC online environment.';
                    ExtendedDatatype = Masked;
                }
                field("Backup Container Name"; Rec."Backup Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Blob Storage container name where to store the backup from the BC online environment.';
                }
                field("Backup SAS Token Exp. Date"; Rec."Backup SAS Token Exp. Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the SAS token expires.';
                }
            }
        }
    }
}
