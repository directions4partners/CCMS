namespace D4P.CCMS.Tenant;

using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Auth;

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
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                }
                field("Tenant Name"; Rec."Tenant Name")
                {
                }
            }
            group(Authentication)
            {
                Caption = 'Authentication';
                field("App Registration Type"; Rec."App Registration Type")
                {
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                group(SharedAppRegistration)
                {
                    ShowCaption = false;
                    Visible = Rec."App Registration Type" = Rec."App Registration Type"::Shared;

                    field("Client ID Lookup"; Rec."Client ID")
                    {
                        Caption = 'Client ID';
                        TableRelation = "D4P BC App Registration"."Client ID";
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                }
                group(IndividualAppRegistration)
                {
                    ShowCaption = false;
                    Visible = Rec."App Registration Type" = Rec."App Registration Type"::Individual;
                    field("Client ID"; Rec."Client ID")
                    {
                        ShowMandatory = true;
                    }
                    field("Client Secret Individual"; ClientSecretValue)
                    {
                        Caption = 'Client Secret';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the Microsoft Entra Application Client Secret for API authentication. This is stored securely in isolated storage.';

                        trigger OnValidate()
                        begin
                            StoreClientSecret();
                            CurrPage.Update(true);
                        end;
                    }
                    field("Secret Expiration Date"; Rec."Secret Expiration Date")
                    {
                        StyleExpr = SecretExpirationStyle;
                    }
                }
            }
            group(Backup)
            {
                Caption = 'Backup Configuration';
                field("Backup SAS URI"; Rec."Backup SAS URI")
                {
                    ExtendedDatatype = URL;
                }
                field("Backup Container Name"; Rec."Backup Container Name")
                {
                }
                field("Backup SAS Token Exp. Date"; Rec."Backup SAS Token Exp. Date")
                {
                    StyleExpr = SASTokenExpirationStyle;
                }
            }
        }
        area(FactBoxes)
        {
            part(TenantDetails; "D4P BC Tenant FactBox")
            {
                SubPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
            }
            part(EnvironmentsFactBox; "D4P BC Environments FactBox")
            {
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
                RunObject = page "D4P BC Environment List";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
                ToolTip = 'View Business Central environments for this tenant.';
            }
            action(PTEObjectRanges)
            {
                ApplicationArea = All;
                Caption = 'PTE Object Ranges';
                Image = NumberSetup;
                RunObject = page "D4P PTE Object Ranges";
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
        SecretPlaceholderLbl: Label 'SECRETPLACEHOLDER', Locked = true;
        ClientSecretValue: Text;
        SASTokenExpirationStyle: Text;
        SecretExpirationStyle: Text;

    trigger OnAfterGetRecord()
    begin
        UpdateSecretExpirationStyle();
        UpdateSASTokenExpirationStyle();
        LoadClientSecret();
    end;

    local procedure LoadClientSecret()
    var
        AppRegistration: Record "D4P BC App Registration";
    begin
        ClientSecretValue := '';
        if IsNullGuid(Rec."Client ID") then
            exit;

        if AppRegistration.HasClientSecret(Rec."Client ID") then
            ClientSecretValue := SecretPlaceholderLbl;
    end;

    local procedure StoreClientSecret()
    var
        AppRegistration: Record "D4P BC App Registration";
        SecretText: SecretText;
    begin
        Rec.TestField("Client ID");

        if ClientSecretValue = SecretPlaceholderLbl then
            exit;

        SecretText := ClientSecretValue;
        AppRegistration.SetClientSecret(Rec."Client ID", SecretText);
    end;

    local procedure UpdateSecretExpirationStyle()
    var
        D4PBCAppRegistration: Record "D4P BC App Registration";
    begin
        if Rec."App Registration Type" = Rec."App Registration Type"::Individual then
            SecretExpirationStyle := D4PBCAppRegistration.GetSecretExpirationStyle(Rec."Secret Expiration Date")
        else
            if D4PBCAppRegistration.Get(Rec."Client ID") then
                SecretExpirationStyle := D4PBCAppRegistration.GetSecretExpirationStyle();
    end;

    local procedure UpdateSASTokenExpirationStyle()
    var
        DaysToExpiration: Integer;
    begin
        SASTokenExpirationStyle := '';

        if Rec."Backup SAS Token Exp. Date" = 0D then
            exit;

        DaysToExpiration := Rec."Backup SAS Token Exp. Date" - Today();

        if DaysToExpiration < 0 then
            SASTokenExpirationStyle := 'Unfavorable'
        else
            if DaysToExpiration <= 30 then
                SASTokenExpirationStyle := 'Attention'
            else
                SASTokenExpirationStyle := 'Favorable';
    end;
}
