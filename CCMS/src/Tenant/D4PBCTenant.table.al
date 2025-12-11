namespace D4P.CCMS.Tenant;

using D4P.CCMS.Customer;
using D4P.CCMS.Auth;

table 62001 "D4P BC Tenant"
{
    Caption = 'D365BC Tenant';
    DataClassification = CustomerContent;
    DrillDownPageId = "D4P BC Tenant List";
    LookupPageId = "D4P BC Tenant List";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = "D4P BC Customer";

        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = CustomerContent;
        }
        field(3; "Tenant Name"; Text[100])
        {
            Caption = 'Tenant Name';
            DataClassification = CustomerContent;
        }
        field(4; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            DataClassification = CustomerContent;

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
            DataClassification = CustomerContent;
            ObsoleteReason = 'Client secrets are now stored in isolated storage. Use GetClientSecret() method instead.';
            ObsoleteState = Pending;
            ObsoleteTag = '0.0.1.0';
        }
        field(6; "Secret Expiration Date"; Date)
        {
            Caption = 'Secret Expiration Date';
            DataClassification = CustomerContent;
        }
        field(7; "Backup SAS URI"; Text[250])
        {
            Caption = 'Backup SAS URI';
            DataClassification = CustomerContent;
        }
        field(8; "Backup Container Name"; Text[250])
        {
            Caption = 'Backup Container Name';
            DataClassification = CustomerContent;
        }
        field(9; "Backup SAS Token Exp. Date"; Date)
        {
            Caption = 'Backup SAS Token Expiration Date';
            DataClassification = CustomerContent;
        }
        field(10; "App Registration Type"; Enum "D4P BC App Reg. Type")
        {
            Caption = 'App Registration Type';
            DataClassification = CustomerContent;
            InitValue = Individual;

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
}