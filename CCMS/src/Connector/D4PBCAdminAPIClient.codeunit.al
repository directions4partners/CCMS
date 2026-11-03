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

    procedure Get(Endpoint: Text; var Response: JsonObject) Success: Boolean
    var
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Get(Endpoint);
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        Response := HttpResponseMessage.GetContent().AsJson().AsObject();
    end;

    /// <summary>
    /// Gets the Microsoft Entra security group assigned to an environment. The API returns 204 when no group is set.
    /// </summary>
    /// <returns>True when the call succeeded (also when no group is assigned), false otherwise.</returns>
    procedure GetSecurityGroup(EnvironmentName: Text; var GroupId: Text; var GroupName: Text) Success: Boolean
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        ResponseText: Text;
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        GroupId := '';
        GroupName := '';

        HttpResponseMessage := RestClient.Get('/applications/businesscentral/environments/' + EnvironmentName + '/settings/securitygroupaccess');
        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            exit(false);

        Success := true;
        ResponseText := HttpResponseMessage.GetContent().AsText();
        if (HttpResponseMessage.GetHttpStatusCode() = 204) or (ResponseText = '') then
            exit;

        if not JsonResponse.ReadFrom(ResponseText) then
            exit(false);
        if JsonResponse.Get('id', JsonToken) then
            GroupId := JsonToken.AsValue().AsText();
        if JsonResponse.Get('displayName', JsonToken) then
            GroupName := JsonToken.AsValue().AsText();
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