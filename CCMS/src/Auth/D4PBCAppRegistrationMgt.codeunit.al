namespace D4P.CCMS.Auth;

codeunit 62005 "D4P BC App Registration"
{
    /// <summary>
    /// Opens the App Registration Card page for the client ID specified in the notification data.
    /// This is used as a notification action handler.
    /// </summary>
    /// <param name="MissingSecretNotification">The notification containing the client ID data.</param>
    procedure OpenAppRegistrationCard(MissingSecretNotification: Notification)
    var
        AppRegistration: Record "D4P BC App Registration";
        AppRegistrationCard: Page "D4P BC App Registration Card";
        ClientIDText: Text;
        ClientIDGuid: Guid;
    begin
        ClientIDText := MissingSecretNotification.GetData('ClientID');
        if ClientIDText = '' then
            exit;

        if not Evaluate(ClientIDGuid, ClientIDText) then
            exit;

        if not AppRegistration.Get(ClientIDGuid) then
            exit;

        AppRegistrationCard.SetRecord(AppRegistration);
        AppRegistrationCard.Run();
    end;
}
