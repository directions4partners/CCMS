namespace D4P.CCMS.Auth;

table 62005 "D4P BC App Registration"
{
    Caption = 'App Registration';
    DataClassification = CustomerContent;
    LookupPageId = "D4P BC App Registration List";
    DrillDownPageId = "D4P BC App Registration List";

    fields
    {
        field(1; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Secret Expiration Date"; Date)
        {
            Caption = 'Secret Expiration Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Client ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Client ID", Description)
        {
        }
    }

    procedure GetClientSecret(ClientId: Guid) ClientSecret: SecretText
    begin
        if IsNullGuid(ClientId) then
            exit;

        if IsolatedStorage.Contains(ClientId, DataScope::Company) then
            IsolatedStorage.Get(ClientId, DataScope::Company, ClientSecret);
    end;

    procedure SetClientSecret(ClientId: Guid; ClientSecret: SecretText)
    begin
        if IsNullGuid(ClientId) then
            exit;

        if ClientSecret.IsEmpty() then
            if IsolatedStorage.Contains(ClientId, DataScope::Company) then begin
                IsolatedStorage.Delete(ClientId, DataScope::Company);
                exit;
            end;

        IsolatedStorage.Set(ClientId, ClientSecret, DataScope::Company);
    end;

    procedure HasClientSecret(ClientId: Guid): Boolean
    begin
        if IsNullGuid(ClientId) then
            exit(false);

        exit(IsolatedStorage.Contains(ClientId, DataScope::Company));
    end;

    procedure GetSecretExpirationStyle(ExpirationDate: Date): Text
    var
        DaysToExpiration: Integer;
    begin
        if ExpirationDate = 0D then
            exit;

        DaysToExpiration := ExpirationDate - Today;

        if DaysToExpiration < 0 then
            exit('Unfavorable')
        else
            if DaysToExpiration <= 30 then
                exit('Attention')
            else
                exit('Favorable');
    end;
}
