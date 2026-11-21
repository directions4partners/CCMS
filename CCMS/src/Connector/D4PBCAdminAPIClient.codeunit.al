namespace D4P.CCMS.Connector;

using D4P.CCMS.Tenant;
using System.RestClient;

codeunit 62036 D4PBCAdminAPIClient
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        BCRestClientFactory: Codeunit D4PBCRestClientFactory;
        RestClient: Codeunit "Rest Client";
        CurrentTenantId: Guid;
        IsInitialized: Boolean;
        NotInitializedErr: Label 'Admin API Client is not initialized. Call SetTenant before making API requests.';
        HttpStatusTxt: Label 'HTTP %1 %2', Locked = true;

    procedure SetTenant(BCTenant: Record "D4P BC Tenant")
    begin
        if IsInitialized and (CurrentTenantId = BCTenant."Tenant ID") then
            exit;

        RestClient := BCRestClientFactory.CreateRestClientForAdminAPI(BCTenant);
        CurrentTenantId := BCTenant."Tenant ID";
        IsInitialized := true;
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

    procedure Post(Endpoint: Text; RequestBody: JsonObject; var Response: Text) Success: Boolean
    var
        HttpContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Post(Endpoint, HttpContent.Create(RequestBody));
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        Response := GetResponseText(HttpResponseMessage);
    end;

    procedure Put(Endpoint: Text; RequestBody: JsonObject; var ResponseText: Text) Success: Boolean
    var
        HttpContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Put(Endpoint, HttpContent.Create(RequestBody));
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        ResponseText := GetResponseText(HttpResponseMessage);
    end;

    procedure Patch(Endpoint: Text; RequestBody: JsonObject; var ResponseText: Text) Success: Boolean
    var
        HttpContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Patch(Endpoint, HttpContent.Create(RequestBody));
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        ResponseText := GetResponseText(HttpResponseMessage);
    end;

    procedure Delete(Endpoint: Text; var ResponseText: Text) Success: Boolean
    var
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);
        HttpResponseMessage := RestClient.Delete(Endpoint);
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        ResponseText := GetResponseText(HttpResponseMessage);
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
