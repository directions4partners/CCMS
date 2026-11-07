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

    procedure SetTenant(BCTenant: Record "D4P BC Tenant")
    begin
        if IsInitialized and (CurrentTenantId = BCTenant."Tenant ID") then
            exit;

        RestClient := BCRestClientFactory.CreateRestClientForAdminAPI(BCTenant);
        CurrentTenantId := BCTenant."Tenant ID";
        IsInitialized := true;
    end;

    /// <summary>
    /// Sends a GET request to the Admin Center API.
    /// If the response body is not a JSON object (for example an empty body or an HTML error page),
    /// the request counts as failed and the raw body is returned in the "message" property,
    /// instead of raising a runtime error that would stop the caller.
    /// </summary>
    /// <param name="Endpoint">The endpoint relative to the Admin Center API base URL.</param>
    /// <param name="Response">The JSON response, or {"message": body} if the body is not a JSON object.</param>
    /// <returns>True if the status code indicates success and the body is a JSON object.</returns>
    procedure Get(Endpoint: Text; var Response: JsonObject) Success: Boolean
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        ResponseText: Text;
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Get(Endpoint);
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        ResponseText := HttpResponseMessage.GetContent().AsText();

        Clear(Response);
        if not Response.ReadFrom(ResponseText) then begin
            Clear(Response);
            Response.Add('message', ResponseText);
            Success := false;
        end;
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
        Response := HttpResponseMessage.GetContent().AsText();
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
        ResponseText := HttpResponseMessage.GetContent().AsText();
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
        ResponseText := HttpResponseMessage.GetContent().AsText();
    end;

    procedure Delete(Endpoint: Text; var ResponseText: Text) Success: Boolean
    var
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);
        HttpResponseMessage := RestClient.Delete(Endpoint);
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        ResponseText := HttpResponseMessage.GetContent().AsText();
    end;
}