namespace D4P.CCMS.Tenant;

using D4P.CCMS.Customer;
using D4P.CCMS.Auth;

table 62001 "D4P BC Tenant"
{
    Caption = 'D365BC Tenant';
    DataClassification = SystemMetadata;
    DrillDownPageId = "D4P BC Tenant List";
    LookupPageId = "D4P BC Tenant List";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer";
            ToolTip = 'Specifies the customer number associated with this tenant.';
        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            ToolTip = 'Specifies the unique identifier (GUID) of the Microsoft Entra tenant.';
        }
        field(3; "Tenant Name"; Text[100])
        {
            Caption = 'Tenant Name';
            ToolTip = 'Specifies the name of the Business Central tenant.';
        }
        field(4; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            ToolTip = 'Specifies the Microsoft Entra Application (Client) ID for API authentication. Select from shared app registrations.';
            trigger OnValidate()
            var
                D4PBCAppRegistration: Record "D4P BC App Registration";
            begin
                if IsNullGuid("Client ID") then
                    exit;

                if "App Registration Type" = "App Registration Type"::Shared then begin
                    D4PBCAppRegistration.Get("Client ID");
                    if not D4PBCAppRegistration.HasClientSecret() then
                        D4PBCAppRegistration.SendMissingClientSecretNotification();
                end;
            end;
        }
        field(5; "Client Secret"; Text[100])
        {
            Caption = 'Client Secret';
            ObsoleteReason = 'Client secrets are now stored in isolated storage. Use GetClientSecret() method instead.';
            ObsoleteState = Pending;
            ObsoleteTag = '0.0.1.0';
        }
        field(6; "Secret Expiration Date"; Date)
        {
            Caption = 'Secret Expiration Date';
            ToolTip = 'Specifies when the client secret expires. Update the secret before this date.';
        }
        field(7; "Backup SAS URI"; Text[250])
        {
            Caption = 'Backup SAS URI';
            ToolTip = 'Specifies the Azure Storage SAS URI for environment backups.';
        }
        field(8; "Backup Container Name"; Text[250])
        {
            Caption = 'Backup Container Name';
            ToolTip = 'Specifies the Azure Storage container name for environment backups.';
        }
        field(9; "Backup SAS Token Exp. Date"; Date)
        {
            Caption = 'Backup SAS Token Expiration Date';
            ToolTip = 'Specifies when the SAS token expires. Update the SAS URI before this date.';
        }
        field(10; "App Registration Type"; Enum "D4P BC App Reg. Type")
        {
            Caption = 'App Registration Type';
            InitValue = Individual;
            ToolTip = 'Specifies whether to use an individual or shared app registration.';
            trigger OnValidate()
            begin
                if "App Registration Type" <> xRec."App Registration Type" then
                    Clear("Client ID");
            end;
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Tenant ID")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Gets the client secret from isolated storage for this tenant's configured Client ID.
    /// If the Client ID is a null GUID, or a secret has not been set for this Client ID then an empty SecretText will be returned.
    /// </summary>
    /// <returns>SecretText containing the client secret</returns>
    procedure GetClientSecret() ClientSecret: SecretText
    var
        AppRegistration: Record "D4P BC App Registration";
    begin
        if IsNullGuid("Client ID") then
            exit;

        ClientSecret := AppRegistration.GetClientSecret("Client ID");
    end;

    internal procedure OpenAdminCenter()
    begin
        if IsNullGuid("Tenant ID") then
            exit;

        Hyperlink(StrSubstNo('https://businesscentral.dynamics.com/%1/admin', "Tenant ID".ToText().ToLower().Replace('{', '').Replace('}', '')));
    end;
}