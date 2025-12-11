namespace D4P.CCMS.Features;

using System.Security.Authentication;
using D4P.CCMS.Environment;
using D4P.CCMS.Tenant;
using D4P.CCMS.Setup;
using D4P.CCMS.General;

codeunit 62014 "D4P BC Features Helper"
{
    procedure GetFeatures(var EnvironmentFeatures: Record "D4P BC Environment Features")
    var
        BCEnvironment: Record "D4P BC Environment";
        BCTenant: Record "D4P BC Tenant";
        APIHelper: Codeunit "D4P BC API Helper";
        ResponseText: Text;
        AuthToken: SecretText;
        EnvironmentNotFoundErr: Label 'Environment not found.';
        TenantNotFoundErr: Label 'Tenant not found.';
        FailedToObtainTokenErr: Label 'Failed to obtain authentication token.';
        APIRequestFailedErr: Label 'API request failed. Error details: %1';
    begin
        // Find the environment
        BCEnvironment.SetRange("Customer No.", EnvironmentFeatures."Customer No.");
        BCEnvironment.SetRange("Tenant ID", EnvironmentFeatures."Tenant ID");
        BCEnvironment.SetRange(Name, EnvironmentFeatures."Environment Name");
        if not BCEnvironment.FindFirst() then
            Error(EnvironmentNotFoundErr);

        // Find the tenant
        if not BCTenant.Get(EnvironmentFeatures."Customer No.", EnvironmentFeatures."Tenant ID") then
            Error(TenantNotFoundErr);

        // Get OAuth token using the AAD Tenant ID (Entra ID) from the environment
        AuthToken := APIHelper.GetAutomationApiOAuthToken(BCEnvironment."AAD Tenant ID", BCTenant."Client ID", BCTenant.GetClientSecret());
        if AuthToken.IsEmpty() then
            Error(FailedToObtainTokenErr);

        // Get companies first
        if not APIHelper.SendAutomationAPIRequest(
            BCEnvironment."AAD Tenant ID",
            BCEnvironment.Name,
            'GET',
            '/api/microsoft/automation/v2.0/companies',
            '',
            AuthToken,
            ResponseText)
        then
            Error(APIRequestFailedErr, ResponseText);

        ShowDebugMessage(ResponseText, 'Get Companies');
        // Now get features using the first company
        GetFeaturesForCompany(ResponseText, AuthToken, BCEnvironment, EnvironmentFeatures);
    end;

    local procedure GetFeaturesForCompany(CompaniesResponse: Text; AuthToken: SecretText; BCEnvironment: Record "D4P BC Environment"; var EnvironmentFeatures: Record "D4P BC Environment Features")
    var
        APIHelper: Codeunit "D4P BC API Helper";
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        ResponseText: Text;
        CompanyId: Text;
        Endpoint: Text;
        FailedToParseErr: Label 'Failed to parse companies response.';
        NoValueArrayErr: Label 'No value array found in companies response.';
        NoCompaniesErr: Label 'No companies found in the environment.';
        CouldNotFindCompanyErr: Label 'Could not find company ID in response.';
        FeaturesAPIFailedErr: Label 'Features API request failed. Error details: %1';
    begin
        // Parse companies response to get the first company ID
        if not JObject.ReadFrom(CompaniesResponse) then
            Error(FailedToParseErr);

        if not JObject.Get('value', JToken) then
            Error(NoValueArrayErr);

        JArray := JToken.AsArray();
        if JArray.Count = 0 then
            Error(NoCompaniesErr);

        // Get the first company ID
        JArray.Get(0, JToken);
        JObject := JToken.AsObject();

        if JObject.Get('id', JToken) then
            CompanyId := JToken.AsValue().AsText()
        else
            Error(CouldNotFindCompanyErr);

        // Build features endpoint
        Endpoint := StrSubstNo('/api/microsoft/automation/v2.0/companies(%1)/features', CompanyId);

        // Make GET request for features
        if not APIHelper.SendAutomationAPIRequest(
            BCEnvironment."AAD Tenant ID",
            BCEnvironment.Name,
            'GET',
            Endpoint,
            '',
            AuthToken,
            ResponseText)
        then
            Error(FeaturesAPIFailedErr, ResponseText);

        ShowDebugMessage(ResponseText, 'Get Features');
        ProcessFeaturesResponse(ResponseText, EnvironmentFeatures);
    end;

    local procedure ProcessFeaturesResponse(ResponseText: Text; var EnvironmentFeatures: Record "D4P BC Environment Features")
    var
        JToken: JsonToken;
        JObject: JsonObject;
        JArray: JsonArray;
        JValue: JsonValue;
        Feature: Record "D4P BC Environment Features";
        i: Integer;
        FailedToParseErr: Label 'Failed to parse features JSON response.';
        NoValueArrayErr: Label 'No value array found in features response.';
    begin
        // Clear existing features
        Feature.SetRange("Customer No.", EnvironmentFeatures."Customer No.");
        Feature.SetRange("Tenant ID", EnvironmentFeatures."Tenant ID");
        Feature.SetRange("Environment Name", EnvironmentFeatures."Environment Name");
        Feature.DeleteAll();

        // Parse JSON response
        if not JObject.ReadFrom(ResponseText) then
            Error(FailedToParseErr);

        if not JObject.Get('value', JToken) then
            Error(NoValueArrayErr);

        JArray := JToken.AsArray();

        // Process each feature
        for i := 0 to JArray.Count - 1 do begin
            JArray.Get(i, JToken);
            JObject := JToken.AsObject();

            Feature.Init();
            Feature."Customer No." := EnvironmentFeatures."Customer No.";
            Feature."Tenant ID" := EnvironmentFeatures."Tenant ID";
            Feature."Environment Name" := EnvironmentFeatures."Environment Name";

            // Get feature key (id)
            if JObject.Get('id', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Feature Key" := CopyStr(JValue.AsText(), 1, MaxStrLen(Feature."Feature Key"));
                Feature."Feature Name" := Feature."Feature Key"; // Use key as name initially
            end;

            // Get enabled status (text field: "All Users", "None", etc.)
            if JObject.Get('enabled', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Is Enabled" := CopyStr(JValue.AsText(), 1, MaxStrLen(Feature."Is Enabled"));
            end;

            // Get description
            if JObject.Get('description', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Feature Description" := CopyStr(JValue.AsText(), 1, MaxStrLen(Feature."Feature Description"));
            end;

            // Get descriptionInEnglish
            if JObject.Get('descriptionInEnglish', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Description In English" := CopyStr(JValue.AsText(), 1, MaxStrLen(Feature."Description In English"));
            end;

            // Get learnMoreLink
            if JObject.Get('learnMoreLink', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Learn More Link" := CopyStr(JValue.AsText(), 1, MaxStrLen(Feature."Learn More Link"));
            end;

            // Get mandatoryBy
            if JObject.Get('mandatoryBy', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Mandatory By" := CopyStr(JValue.AsText(), 1, MaxStrLen(Feature."Mandatory By"));
            end;

            // Get mandatoryByVersion
            if JObject.Get('mandatoryByVersion', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Mandatory By Version" := CopyStr(JValue.AsText(), 1, MaxStrLen(Feature."Mandatory By Version"));
            end;

            // Get canTry
            if JObject.Get('canTry', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Can Try" := JValue.AsBoolean();
            end;

            // Get isOneWay
            if JObject.Get('isOneWay', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Is One Way" := JValue.AsBoolean();
            end;

            // Get dataUpdateRequired
            if JObject.Get('dataUpdateRequired', JToken) then begin
                JValue := JToken.AsValue();
                Feature."Data Update Required" := JValue.AsBoolean();
            end;

            Feature."Last Modified" := CurrentDateTime();
            Feature.Insert();
        end;
    end;

    local procedure ShowDebugMessage(ResponseText: Text; ActionName: Text)
    var
        BCSetup: Record "D4P BC Setup";
        DebugMsg: Label 'DEBUG - %1 Response:\%2';
    begin
        BCSetup := BCSetup.GetSetup();
        if BCSetup."Debug Mode" then
            Message(DebugMsg, ActionName, ResponseText);
    end;

    procedure ActivateFeature(var Feature: Record "D4P BC Environment Features"; UpdateInBackground: Boolean; StartDateTime: DateTime)
    var
        BCEnvironment: Record "D4P BC Environment";
        BCTenant: Record "D4P BC Tenant";
        APIHelper: Codeunit "D4P BC API Helper";
        ResponseText: Text;
        AuthToken: SecretText;
        CompanyId: Text;
        RequestBody: Text;
        Endpoint: Text;
        EnvironmentNotFoundErr: Label 'Environment not found.';
        TenantNotFoundErr: Label 'Tenant not found.';
        FailedToObtainTokenErr: Label 'Failed to obtain authentication token.';
        FailedToActivateErr: Label 'Failed to activate feature. Error details: %1';
        FeatureActivatedMsg: Label 'Feature "%1" activated successfully.';
    begin
        // Find the environment
        BCEnvironment.SetRange("Customer No.", Feature."Customer No.");
        BCEnvironment.SetRange("Tenant ID", Feature."Tenant ID");
        BCEnvironment.SetRange(Name, Feature."Environment Name");
        if not BCEnvironment.FindFirst() then
            Error(EnvironmentNotFoundErr);

        // Find the tenant
        if not BCTenant.Get(Feature."Customer No.", Feature."Tenant ID") then
            Error(TenantNotFoundErr);

        // Get OAuth token
        AuthToken := APIHelper.GetAutomationApiOAuthToken(BCEnvironment."AAD Tenant ID", BCTenant."Client ID", BCTenant.GetClientSecret());
        if AuthToken.IsEmpty() then
            Error(FailedToObtainTokenErr);

        // Get company ID
        CompanyId := GetFirstCompanyId(BCEnvironment, AuthToken);

        // Build Activate API endpoint
        Endpoint := StrSubstNo('/api/microsoft/automation/v2.0/companies(%1)/features(''%2'')/Microsoft.NAV.Activate',
            CompanyId,
            Feature."Feature Key");

        // Build request body
        RequestBody := StrSubstNo('{"updateInBackground": %1, "startDateTime": "%2"}',
            Format(UpdateInBackground, 0, 9).ToLower(),
            Format(StartDateTime, 0, 9));

        // Make POST request
        if not APIHelper.SendAutomationAPIRequest(
            BCEnvironment."AAD Tenant ID",
            BCEnvironment.Name,
            'POST',
            Endpoint,
            RequestBody,
            AuthToken,
            ResponseText)
        then
            Error(FailedToActivateErr, ResponseText);

        ShowDebugMessage(ResponseText, 'Activate Feature');
        Message(FeatureActivatedMsg, Feature."Feature Name");
    end;

    procedure DeactivateFeature(var Feature: Record "D4P BC Environment Features")
    var
        BCEnvironment: Record "D4P BC Environment";
        BCTenant: Record "D4P BC Tenant";
        APIHelper: Codeunit "D4P BC API Helper";
        ResponseText: Text;
        AuthToken: SecretText;
        CompanyId: Text;
        Endpoint: Text;
        EnvironmentNotFoundErr: Label 'Environment not found.';
        TenantNotFoundErr: Label 'Tenant not found.';
        FailedToObtainTokenErr: Label 'Failed to obtain authentication token.';
        FailedToDeactivateErr: Label 'Failed to deactivate feature. Error details: %1';
        FeatureDeactivatedMsg: Label 'Feature "%1" deactivated successfully.';
    begin
        // Find the environment
        BCEnvironment.SetRange("Customer No.", Feature."Customer No.");
        BCEnvironment.SetRange("Tenant ID", Feature."Tenant ID");
        BCEnvironment.SetRange(Name, Feature."Environment Name");
        if not BCEnvironment.FindFirst() then
            Error(EnvironmentNotFoundErr);

        // Find the tenant
        if not BCTenant.Get(Feature."Customer No.", Feature."Tenant ID") then
            Error(TenantNotFoundErr);

        // Get OAuth token
        AuthToken := APIHelper.GetAutomationApiOAuthToken(BCEnvironment."AAD Tenant ID", BCTenant."Client ID", BCTenant.GetClientSecret());
        if AuthToken.IsEmpty() then
            Error(FailedToObtainTokenErr);

        // Get company ID
        CompanyId := GetFirstCompanyId(BCEnvironment, AuthToken);

        // Build Deactivate API endpoint
        Endpoint := StrSubstNo('/api/microsoft/automation/v2.0/companies(%1)/features(''%2'')/Microsoft.NAV.Deactivate',
            CompanyId,
            Feature."Feature Key");

        // Make POST request
        if not APIHelper.SendAutomationAPIRequest(
            BCEnvironment."AAD Tenant ID",
            BCEnvironment.Name,
            'POST',
            Endpoint,
            '',
            AuthToken,
            ResponseText)
        then
            Error(FailedToDeactivateErr, ResponseText);

        ShowDebugMessage(ResponseText, 'Deactivate Feature');
        Message(FeatureDeactivatedMsg, Feature."Feature Name");
    end;

    local procedure GetFirstCompanyId(BCEnvironment: Record "D4P BC Environment"; AuthToken: SecretText): Text
    var
        APIHelper: Codeunit "D4P BC API Helper";
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        ResponseText: Text;
        CompanyId: Text;
        FailedToGetCompanyErr: Label 'Failed to get company ID. Error details: %1';
        FailedToParseErr: Label 'Failed to parse companies response.';
        NoValueArrayErr: Label 'No value array found in companies response.';
        NoCompaniesErr: Label 'No companies found in the environment.';
        CouldNotFindCompanyErr: Label 'Could not find company ID in response.';
    begin
        // Get companies
        if not APIHelper.SendAutomationAPIRequest(
            BCEnvironment."AAD Tenant ID",
            BCEnvironment.Name,
            'GET',
            '/api/microsoft/automation/v2.0/companies',
            '',
            AuthToken,
            ResponseText)
        then
            Error(FailedToGetCompanyErr, ResponseText);

        // Parse response
        if not JObject.ReadFrom(ResponseText) then
            Error(FailedToParseErr);

        if not JObject.Get('value', JToken) then
            Error(NoValueArrayErr);

        JArray := JToken.AsArray();
        if JArray.Count = 0 then
            Error(NoCompaniesErr);

        // Get the first company ID
        JArray.Get(0, JToken);
        JObject := JToken.AsObject();
        if JObject.Get('id', JToken) then
            CompanyId := JToken.AsValue().AsText()
        else
            Error(CouldNotFindCompanyErr);

        exit(CompanyId);
    end;
}
