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

    /// <summary>
    /// Retrieve the client secret which has been saved in isolated storage for this client id.
    /// </summary>
    /// <param name="ClientId">The app registration client id to retrieve the client secret for.</param>
    /// <returns>SecretText containing the client secret.</returns>
    procedure GetClientSecret(ClientId: Guid) ClientSecret: SecretText
    begin
        if IsNullGuid(ClientId) then
            exit;

        if IsolatedStorage.Contains(ClientId, DataScope::Company) then
            IsolatedStorage.Get(ClientId, DataScope::Company, ClientSecret);
    end;

    /// <summary>
    /// Saves the client secret in isolated storage for the specified app registration client id.
    /// If the secret is empty then any existing secret for the client id will be deleted.
    /// </summary>
    /// <param name="ClientId">The client id to save the client secret for.</param>
    /// <param name="ClientSecret">The client secret to save.</param>
    procedure SetClientSecret(ClientId: Guid; ClientSecret: SecretText)
    begin
        if IsNullGuid(ClientId) then
            exit;

        if ClientSecret.IsEmpty() then begin
            if IsolatedStorage.Contains(ClientId, DataScope::Company) then
                IsolatedStorage.Delete(ClientId, DataScope::Company);

            exit;
        end;

        IsolatedStorage.Set(ClientId, ClientSecret, DataScope::Company);
    end;

    /// <summary>
    /// Tests whether a client secret exists for this app registration.
    /// </summary>
    /// <returns>Boolean indicating whether a client secret exists for this app registration.</returns>
    procedure HasClientSecret(): Boolean
    begin
        exit(HasClientSecret(Rec."Client ID"));
    end;

    /// <summary>
    /// Test whether there is a client secret saved for the specified client id.
    /// </summary>
    /// <param name="ClientId">The client id to test for the existence of a client secret.</param>
    /// <returns>Boolean indicating whether a client secret exists for the specified client id.</returns>
    procedure HasClientSecret(ClientId: Guid): Boolean
    begin
        if IsNullGuid(ClientId) then
            exit(false);

        exit(IsolatedStorage.Contains(ClientId, DataScope::Company));
    end;

    procedure GetSecretExpirationStyle(): Text
    begin
        exit(GetSecretExpirationStyle("Secret Expiration Date"));
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

    /// <summary>
    /// Sends a notification to the user warning that no client secret has been set for this app registration.
    /// The notification includes a link to open the app registration card.
    /// </summary>
    procedure SendMissingClientSecretNotification()
    var
        MissingSecretNotification: Notification;
        OpenCardMsg: Label 'Open App Registration';
        NoSecretMsg: Label 'No client secret has been set for app registration %1. Click here to configure the secret.', Comment = '%1 = Client ID or Description';
        NotificationIdLbl: Label 'ef2984fd-326b-489c-933f-906617b4fe59', Locked = true;
    begin
        MissingSecretNotification.Id := NotificationIdLbl;
        if Rec.Description <> '' then
            MissingSecretNotification.Message := StrSubstNo(NoSecretMsg, Rec.Description)
        else
            MissingSecretNotification.Message := StrSubstNo(NoSecretMsg, Rec."Client ID");

        MissingSecretNotification.Scope := NotificationScope::LocalScope;
        MissingSecretNotification.AddAction(OpenCardMsg, Codeunit::"D4P BC App Registration", 'OpenAppRegistrationCard');
        MissingSecretNotification.SetData('ClientID', Format(Rec."Client ID"));
        MissingSecretNotification.Send();
    end;
}
