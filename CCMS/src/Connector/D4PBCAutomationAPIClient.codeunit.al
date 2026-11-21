namespace D4P.CCMS.Connector;

using D4P.CCMS.Environment;
using D4P.CCMS.Tenant;
using System.RestClient;

codeunit 62037 D4PBCAutomationAPIClient
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        BCRestClientFactory: Codeunit D4PBCRestClientFactory;
        RestClient: Codeunit "Rest Client";
        CurrentTenantId: Guid;
        EnvironmentName: Text[100];
        IsInitialized: Boolean;
        NotInitializedErr: Label 'Automation API Client is not initialized. Call SetContext before making API requests.';
        HttpStatusTxt: Label 'HTTP %1 %2', Locked = true;

    procedure SetContext(BCTenant: Record "D4P BC Tenant"; BCEnvironment: Record "D4P BC Environment")
    begin
        if IsInitialized and (CurrentTenantId = BCTenant."Tenant ID") and (EnvironmentName = BCEnvironment.Name) then
            exit;

        EnvironmentName := BCEnvironment.Name;
        CurrentTenantId := BCTenant."Tenant ID";
        RestClient := BCRestClientFactory.CreateRestClientForAutomationAPI(BCTenant, EnvironmentName);
        IsInitialized := true;
    end;

    procedure Get(Endpoint: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::GET, Endpoint, '', ResponseText));
    end;

    procedure Get(Endpoint: Text; var Response: JsonObject) Success: Boolean
    var
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Get(Endpoint);
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        Response := GetResponseJson(HttpResponseMessage);
    end;

    procedure Post(Endpoint: Text; RequestBody: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::POST, Endpoint, RequestBody, ResponseText));
    end;

    procedure Put(Endpoint: Text; RequestBody: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::PUT, Endpoint, RequestBody, ResponseText));
    end;

    procedure Patch(Endpoint: Text; RequestBody: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::PATCH, Endpoint, RequestBody, ResponseText));
    end;

    procedure Delete(Endpoint: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::DELETE, Endpoint, '', ResponseText));
    end;

    local procedure SendRequest(Method: Enum "Http Method"; Endpoint: Text; RequestBody: Text; var ResponseText: Text): Boolean
    var
        HttpContent: Codeunit "Http Content";
        HttpRequestMessage: Codeunit "Http Request Message";
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpRequestMessage.SetHttpMethod(Method);
        HttpRequestMessage.SetRequestUri(Endpoint);
        if RequestBody <> '' then
            HttpRequestMessage.SetContent(HttpContent.Create(RequestBody, 'application/json'));

        HttpResponseMessage := RestClient.Send(HttpRequestMessage);
        ResponseText := GetResponseText(HttpResponseMessage);

        exit(HttpResponseMessage.GetIsSuccessStatusCode());
    end;

    /// <summary>
    /// Returns the response body. For a failed request the HTTP status code and reason phrase are prepended,
    /// so the caller can show a meaningful error even when the response body is empty.
    /// </summary>
    local procedure GetResponseText(HttpResponseMessage: Codeunit "Http Response Message") ResponseText: Text
    var
        StatusText: Text;
    begin
        ResponseText := HttpResponseMessage.GetContent().AsText();
        if HttpResponseMessage.GetIsSuccessStatusCode() then
            exit;

        StatusText := StrSubstNo(HttpStatusTxt, HttpResponseMessage.GetHttpStatusCode(), HttpResponseMessage.GetReasonPhrase());
        if ResponseText = '' then
            ResponseText := StatusText
        else
            ResponseText := StatusText + ': ' + ResponseText;
    end;

    /// <summary>
    /// Returns the response body as a JSON object. For a failed request the result contains the HTTP status code,
    /// the reason phrase and the response body (if any), because error responses can be empty or not JSON at all.
    /// </summary>
    local procedure GetResponseJson(HttpResponseMessage: Codeunit "Http Response Message") Response: JsonObject
    var
        Content: JsonToken;
        ResponseText: Text;
    begin
        ResponseText := HttpResponseMessage.GetContent().AsText();
        if HttpResponseMessage.GetIsSuccessStatusCode() then begin
            if ResponseText <> '' then
                Response.ReadFrom(ResponseText);
            exit;
        end;

        Response.Add('statusCode', HttpResponseMessage.GetHttpStatusCode());
        Response.Add('reasonPhrase', HttpResponseMessage.GetReasonPhrase());
        if ResponseText = '' then
            exit;
        if Content.ReadFrom(ResponseText) then
            Response.Add('content', Content)
        else
            Response.Add('content', ResponseText);
    end;
}
