namespace D4P.CCMS.Connector.RestClientOAuth;
table 62007 "D4P Entra App Registration"
{
    Caption = 'Microsoft Entra App Registration';
    DataPerCompany = false;
    ReplicateData = false;
    LookupPageId = "D4P Entra App Registr. List";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(2; "Display Name"; Text[100])
        {
            Caption = 'Display name';
            DataClassification = CustomerContent;
        }
        field(3; "App ID"; Text[36])
        {
            Caption = 'Application (client) ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Guid: Guid;
            begin
                if Rec."App ID" = '' then
                    exit;
                Evaluate(Guid, Rec."App ID");
                Rec."App ID" := Format(Guid, 0, 4).ToLower();
            end;
        }
        field(4; "Publisher Tenant Id"; Text[100])
        {
            Caption = 'Publisher tenant ID';
            DataClassification = CustomerContent;
            ToolTip = 'The full qualified domain name or the id of the Azure Active Directory where this app has been registered.';

            trigger OnValidate()
            var
                Guid: Guid;
            begin
                if Evaluate(Guid, Rec."Publisher Tenant Id") then
                    Rec."Publisher Tenant Id" := Format(Guid, 0, 4).ToLower();
            end;
        }
        field(5; "Supported Account Types"; Enum "D4P Entra Account Types")
        {
            Caption = 'Supported account types';
            DataClassification = CustomerContent;
        }
        field(6; "Certificate Code"; Code[20])
        {
            Caption = 'Certificate code';
            TableRelation = "D4P Entra Certificate";
            DataClassification = CustomerContent;
        }
        field(7; "Redirect Uri Type"; Enum "D4P Redirect URI Type")
        {
            Caption = 'Use built-in redirect uri';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                RedirectURI: Interface "D4P Redirect URI";
            begin
                RedirectURI := "Redirect Uri Type";
                "Redirect Uri" := RedirectURI.GetDefaultRedirectURI();
            end;
        }
        field(8; "Redirect Uri"; Text[250])
        {
            Caption = 'Redirect uri';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }

    var
        AzAppCodeTxt: Label 'AZAPP', Locked = true;

    trigger OnInsert()
    begin
        if Code = '' then
            Code := GetNextCode();
    end;

    local procedure GetNextCode() ReturnValue: Code[10]
    begin
        ReturnValue := AzAppCodeTxt;
        ReturnValue := ReturnValue + Format(GetNextNumber()).PadLeft(MaxStrLen(ReturnValue) - StrLen(ReturnValue), '0');
    end;

    local procedure GetNextNumber() NextNumber: BigInteger
    begin
        if not NumberSequence.Exists(AzAppCodeTxt, false) then
            NumberSequence.Insert(AzAppCodeTxt, 0, 1, false);

        NextNumber := NumberSequence.Next(AzAppCodeTxt, false);
    end;

    local procedure FindAppSecret(var EntraAppSecret: Record "D4P Entra Secret"): Boolean
    begin
        EntraAppSecret.SetRange("Application Code", Code);
        EntraAppSecret.SetFilter("Start Date/Time", '..%1', CurrentDateTime);
        EntraAppSecret.SetFilter("End Date/Time", '%1|%2..', 0DT, CurrentDateTime + 60000);
        exit(EntraAppSecret.FindFirst());
    end;

    internal procedure GetCertificate() OAuthCertificate: Codeunit "D4P OAuth Certificate"
    var
        EntraCertificate: Record "D4P Entra Certificate";
    begin
        EntraCertificate.Get("Certificate Code");
        OAuthCertificate.SetCertificate(EntraCertificate.GetCertificate());
        OAuthCertificate.SetPrivateKey(EntraCertificate.GetPrivateKey());
    end;

    procedure GetOAuthApplicationConfig(EntraAppRegistrationCode: Code[20]) OAuthApplicationConfig: Codeunit "D4P OAuth Appl. Config"
    var
        EntraAppSecret: Record "D4P Entra Secret";
    begin
        Rec.Get(EntraAppRegistrationCode);

        Rec.TestField("App ID");
        OAuthApplicationConfig.SetClientId(Rec."App ID");
        OAuthApplicationConfig.SetRedirectUriType(Rec."Redirect Uri Type");
        OAuthApplicationConfig.SetRedirectUri(Rec."Redirect Uri");
        if Rec."Certificate Code" <> '' then
            OAuthApplicationConfig.SetCertificate(Rec.GetCertificate());

        if FindAppSecret(EntraAppSecret) then
            OAuthApplicationConfig.SetClientSecret(EntraAppSecret.GetSecretText());
    end;
}