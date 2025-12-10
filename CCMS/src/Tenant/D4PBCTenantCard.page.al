namespace D4P.CCMS.Tenant;

using D4P.CCMS.Environment;
using D4P.CCMS.Extension;

page 62011 "D4P BC Tenant Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "D4P BC Tenant";
    Caption = 'D365BC Entra Tenant Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number associated with this tenant.';
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier (GUID) of the Microsoft Entra tenant.';
                }
                field("Tenant Name"; Rec."Tenant Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Business Central tenant.';
                }
            }
            group(Authentication)
            {
                Caption = 'Authentication';
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure AD Application (Client) ID for API authentication.';
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the Azure AD Application Client Secret for API authentication.';
                }
                field("Secret Expiration Date"; Rec."Secret Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the client secret expires. Update the secret before this date.';
                    StyleExpr = SecretExpirationStyle;
                }
            }
            group(Backup)
            {
                Caption = 'Backup Configuration';
                field("Backup SAS URI"; Rec."Backup SAS URI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure Storage SAS URI for environment backups.';
                    ExtendedDatatype = URL;
                }
                field("Backup Container Name"; Rec."Backup Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure Storage container name for environment backups.';
                }
                field("Backup SAS Token Exp. Date"; Rec."Backup SAS Token Exp. Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the SAS token expires. Update the SAS URI before this date.';
                    StyleExpr = SASTokenExpirationStyle;
                }
            }
        }
        area(FactBoxes)
        {
            part(TenantDetails; "D4P BC Tenant FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
            }
            part(EnvironmentsFactBox; "D4P BC Environments FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Environments)
            {
                ApplicationArea = All;
                Caption = 'Environments';
                Image = ViewDetails;
                RunObject = Page "D4P BC Environment List";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
                ToolTip = 'View Business Central environments for this tenant.';
            }
            action(PTEObjectRanges)
            {
                ApplicationArea = All;
                Caption = 'PTE Object Ranges';
                Image = NumberSetup;
                RunObject = Page "D4P PTE Object Ranges";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
                ToolTip = 'View PTE object ranges for this customer and tenant.';
            }
        }
        area(Promoted)
        {
            group(Category_Navigation)
            {
                Caption = 'Navigation';
                actionref(EnvironmentsPromoted; Environments)
                {
                }
                actionref(PTEObjectRangesPromoted; PTEObjectRanges)
                {
                }
            }
        }
    }

    var
        SecretExpirationStyle: Text;
        SASTokenExpirationStyle: Text;

    trigger OnAfterGetRecord()
    begin
        UpdateSecretExpirationStyle();
        UpdateSASTokenExpirationStyle();
    end;

    local procedure UpdateSecretExpirationStyle()
    var
        DaysToExpiration: Integer;
    begin
        SecretExpirationStyle := '';

        if Rec."Secret Expiration Date" = 0D then
            exit;

        DaysToExpiration := Rec."Secret Expiration Date" - Today;

        if DaysToExpiration < 0 then
            SecretExpirationStyle := 'Unfavorable'
        else if DaysToExpiration <= 30 then
            SecretExpirationStyle := 'Attention'
        else
            SecretExpirationStyle := 'Favorable';
    end;

    local procedure UpdateSASTokenExpirationStyle()
    var
        DaysToExpiration: Integer;
    begin
        SASTokenExpirationStyle := '';

        if Rec."Backup SAS Token Exp. Date" = 0D then
            exit;

        DaysToExpiration := Rec."Backup SAS Token Exp. Date" - Today;

        if DaysToExpiration < 0 then
            SASTokenExpirationStyle := 'Unfavorable'
        else if DaysToExpiration <= 30 then
            SASTokenExpirationStyle := 'Attention'
        else
            SASTokenExpirationStyle := 'Favorable';
    end;
}
