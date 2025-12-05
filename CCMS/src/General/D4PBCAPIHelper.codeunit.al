namespace D4P.CCMS.General;

using System.Security.Authentication;
using D4P.CCMS.Tenant;
using D4P.CCMS.Setup;

codeunit 62049 "D4P BC API Helper"
{
    procedure SendAdminAPIRequest(var BCTenant: Record "D4P BC Tenant"; Method: Text; Endpoint: Text; RequestBody: Text; var ResponseText: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        AuthToken: SecretText;
        EndpointUrl: Text;
        RequestContent: HttpContent;
        FailedToObtainTokenErr: Label 'Failed to obtain access token.';
        FailedToSendRequestErr: Label 'Failed to send HTTP request';
    begin
        // Get OAuth token
        AuthToken := GetOAuthToken(BCTenant);
        if AuthToken.IsEmpty() then
            Error(FailedToObtainTokenErr);

        // Build full endpoint URL
        EndpointUrl := GetAdminAPIBaseUrl() + Endpoint;

        // Initialize the HTTP request
        HttpRequestMessage.SetRequestUri(EndpointUrl);
        HttpRequestMessage.Method := Method;
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', AuthToken));

        // Add request body if provided
        if RequestBody <> '' then begin
            RequestContent.WriteFrom(RequestBody);
            RequestContent.GetHeaders(Headers);
            Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
            HttpRequestMessage.Content := RequestContent;
        end;

        // Send the request
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(FailedToSendRequestErr);

        HttpResponseMessage.Content.ReadAs(ResponseText);
        ShowDebugMessage(ResponseText, Method + ' ' + Endpoint);

        exit(HttpResponseMessage.IsSuccessStatusCode());
    end;

    procedure SendAutomationAPIRequest(AADTenantId: Guid; EnvironmentName: Text; Method: Text; Endpoint: Text; RequestBody: Text; AuthToken: SecretText; var ResponseText: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        EndpointUrl: Text;
        RequestContent: HttpContent;
        TenantIdText: Text;
        FailedToConnectErr: Label 'Failed to connect to the API.';
    begin
        // Format tenant ID (remove braces)
        TenantIdText := Format(AADTenantId);
        TenantIdText := DelChr(TenantIdText, '=', '{}');

        // Build full endpoint URL
        EndpointUrl := StrSubstNo('%1/%2/%3%4',
            GetAutomationAPIBaseUrl(),
            TenantIdText,
            EnvironmentName,
            Endpoint);

        // Initialize the HTTP request
        HttpRequestMessage.SetRequestUri(EndpointUrl);
        HttpRequestMessage.Method := Method;
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', AuthToken));
        Headers.Add('Accept', 'application/json');

        // Add request body if provided
        if RequestBody <> '' then begin
            RequestContent.WriteFrom(RequestBody);
            RequestContent.GetHeaders(Headers);
            Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
            HttpRequestMessage.Content := RequestContent;
        end;

        // Send the request
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(FailedToConnectErr);

        HttpResponseMessage.Content.ReadAs(ResponseText);
        ShowDebugMessage(ResponseText, Method + ' ' + Endpoint);

        exit(HttpResponseMessage.IsSuccessStatusCode());
    end;

    procedure GetOAuthToken(var BCTenant: Record "D4P BC Tenant") AuthToken: SecretText
    var
        AccessTokenURL: Text;
        OAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
        tenantID: Text;
        ClientSecret: SecretText;
        FailedToGetTokenErr: Label 'Failed to get access token from response\%1';
    begin
        tenantID := BCTenant."Tenant ID".ToText().Replace('{', '');
        tenantID := tenantID.Replace('}', '');
        AccessTokenURL := 'https://login.microsoftonline.com/' + tenantID + '/oauth2/v2.0/token';
        Scopes.Add('https://api.businesscentral.dynamics.com/.default');

        ClientSecret := BCTenant.GetClientSecret();
        if not OAuth2.AcquireTokenWithClientCredentials(BCTenant."Client ID", ClientSecret, AccessTokenURL, '', Scopes, AuthToken) then
            Error(FailedToGetTokenErr, GetLastErrorText());
    end;

    procedure GetAutomationApiOAuthToken(AADTenantId: Guid; ClientID: Text; ClientSecret: SecretText) AuthToken: SecretText
    var
        AccessTokenURL: Text;
        OAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
        AADTenantIdText: Text;
        FailedToGetTokenErr: Label 'Failed to get Automation API access token: %1';
    begin
        // Format AAD Tenant ID
        AADTenantIdText := Format(AADTenantId);
        AADTenantIdText := DelChr(AADTenantIdText, '=', '{}');

        AccessTokenURL := 'https://login.microsoftonline.com/' + AADTenantIdText + '/oauth2/v2.0/token';

        // Use standard BC API scope
        Scopes.Add('https://api.businesscentral.dynamics.com/.default');

        if not OAuth2.AcquireTokenWithClientCredentials(ClientID, ClientSecret, AccessTokenURL, '', Scopes, AuthToken) then
            Error(FailedToGetTokenErr, GetLastErrorText());
    end;

    local procedure ShowDebugMessage(ResponseText: Text; ActionName: Text)
    var
        BCSetup: Record "D4P BC Setup";
        DebugMsg: Label 'DEBUG - %1:\%2';
    begin
        if BCSetup.Get() then
            if BCSetup."Debug Mode" then
                Message(DebugMsg, ActionName, ResponseText);
    end;

    local procedure GetAdminAPIBaseUrl(): Text[250]
    var
        BCSetup: Record "D4P BC Setup";
    begin
        exit(BCSetup.GetAdminAPIBaseUrl());
    end;

    local procedure GetAutomationAPIBaseUrl(): Text[250]
    var
        BCSetup: Record "D4P BC Setup";
    begin
        exit(BCSetup.GetAutomationAPIBaseUrl());
    end;
}
