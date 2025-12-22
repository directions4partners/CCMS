namespace D4P.CCMS.Tenant;

using D4P.CCMS.Auth;

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
                field("Secret Expiration Date"; GetSecretExpirationDate())
                {
                    ApplicationArea = All;
                    Caption = 'Secret Expiration Date';
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

    local procedure GetSecretExpirationDate(): Date
    var
        D4PBCAppRegistration: Record "D4P BC App Registration";
    begin
        case Rec."App Registration Type" of
            Rec."App Registration Type"::Shared:
                if D4PBCAppRegistration.Get(Rec."Client ID") then
                    exit(D4PBCAppRegistration."Secret Expiration Date")
                else
                    exit(0D);
            Rec."App Registration Type"::Individual:
                exit(Rec."Secret Expiration Date");
        end;
    end;
}
