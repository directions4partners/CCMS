namespace D4P.CCMS.Features;

using D4P.CCMS.Connector;
using D4P.CCMS.Environment;
using D4P.CCMS.Setup;
using D4P.CCMS.Tenant;

codeunit 62014 "D4P BC Features Helper"
{
    procedure GetFeatures(var EnvironmentFeature: Record "D4P BC Environment Feature")
    var
        BCEnvironment: Record "D4P BC Environment";
        BCTenant: Record "D4P BC Tenant";
        APIRequestFailedErr: Label 'API request failed. Error details: %1', Comment = '%1 = Error message';
        EnvironmentNotFoundErr: Label 'Environment not found.';
        FailedToObtainTokenErr: Label 'Failed to obtain authentication token.';
        TenantNotFoundErr: Label 'Tenant not found.';
        ResponseJson: JsonObject;
    begin
        // Find the environment
        BCEnvironment.SetRange("Customer No.", EnvironmentFeature."Customer No.");
        BCEnvironment.SetRange("Tenant ID", EnvironmentFeature."Tenant ID");
        BCEnvironment.SetRange(Name, EnvironmentFeature."Environment Name");
        if not BCEnvironment.FindFirst() then
            Error(EnvironmentNotFoundErr);

        // Find the tenant
        if not BCTenant.Get(EnvironmentFeature."Customer No.", EnvironmentFeature."Tenant ID") then
            Error(TenantNotFoundErr);

        // Get companies first
        AutomationAPIClient.SetContext(BCTenant, BCEnvironment);
        if not AutomationAPIClient.Get('/api/microsoft/automation/v2.0/companies', ResponseJson) then
            Error(APIRequestFailedErr, Format(ResponseJson));

        // Now get features using the first company
        GetFeaturesForCompany(ResponseJson, BCTenant, BCEnvironment, EnvironmentFeature);
    end;

    local procedure GetFeaturesForCompany(CompaniesResponse: JsonObject; BCTenant: Record "D4P BC Tenant"; BCEnvironment: Record "D4P BC Environment"; var EnvironmentFeature: Record "D4P BC Environment Feature")
    var
        JArray: JsonArray;
        JToken: JsonToken;
        CouldNotFindCompanyErr: Label 'Could not find company ID in response.';
        FailedToParseErr: Label 'Failed to parse companies response.';
        FeaturesAPIFailedErr: Label 'Features API request failed. Error details: %1', Comment = '%1 = Error message';
        NoCompaniesErr: Label 'No companies found in the environment.';
        NoValueArrayErr: Label 'No value array found in companies response.';
        CompanyId: Text;
        Endpoint: Text;
        ResponseJson: JsonObject;
    begin
        // Parse companies response to get the first company ID
        if not CompaniesResponse.Get('value', JToken) then
            Error(NoValueArrayErr);

        JArray := JToken.AsArray();
        if JArray.Count() = 0 then
            Error(NoCompaniesErr);

        // Get the first company ID
        JArray.Get(0, JToken);
        CompaniesResponse := JToken.AsObject();

        if CompaniesResponse.Get('id', JToken) then
            CompanyId := JToken.AsValue().AsText()
        else
            Error(CouldNotFindCompanyErr);

        // Build features endpoint
        Endpoint := StrSubstNo('/api/microsoft/automation/v2.0/companies(%1)/features', CompanyId);

        AutomationAPIClient.SetContext(BCTenant, BCEnvironment);
        if not AutomationAPIClient.Get(Endpoint, ResponseJson) then
            Error(FeaturesAPIFailedErr, Format(ResponseJson));

        ProcessFeaturesResponse(ResponseJson, EnvironmentFeature);
    end;

    local procedure ProcessFeaturesResponse(Features: JsonObject; var EnvironmentFeature: Record "D4P BC Environment Feature")
    var
        Feature: Record "D4P BC Environment Feature";
        JArray: JsonArray;
        JToken: JsonToken;
        JValue: JsonValue;
        JObject: JsonObject;
        FailedToParseErr: Label 'Failed to parse features JSON response.';
        NoValueArrayErr: Label 'No value array found in features response.';
    begin
        // Clear existing features
        Feature.SetRange("Customer No.", EnvironmentFeature."Customer No.");
        Feature.SetRange("Tenant ID", EnvironmentFeature."Tenant ID");
        Feature.SetRange("Environment Name", EnvironmentFeature."Environment Name");
        Feature.DeleteAll();

        if not Features.Get('value', JToken) then
            Error(NoValueArrayErr);

        JArray := JToken.AsArray();

        // Process each feature
        foreach JToken in JArray do begin
            JObject := JToken.AsObject();

            Feature.Init();
            Feature."Customer No." := EnvironmentFeature."Customer No.";
            Feature."Tenant ID" := EnvironmentFeature."Tenant ID";
            Feature."Environment Name" := EnvironmentFeature."Environment Name";

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
        DebugMsg: Label 'DEBUG - %1 Response:\%2', Comment = '%1 = Response type, %2 = Response body';
    begin
        BCSetup := BCSetup.GetSetup();
        if BCSetup."Debug Mode" then
            Message(DebugMsg, ActionName, ResponseText);
    end;

    procedure ActivateFeature(var Feature: Record "D4P BC Environment Feature"; UpdateInBackground: Boolean; StartDateTime: DateTime)
    var
        BCEnvironment: Record "D4P BC Environment";
        BCTenant: Record "D4P BC Tenant";
        EnvironmentNotFoundErr: Label 'Environment not found.';
        FailedToActivateErr: Label 'Failed to activate feature. Error details: %1', Comment = '%1 = Error message';
        FailedToObtainTokenErr: Label 'Failed to obtain authentication token.';
        FeatureActivatedMsg: Label 'Feature "%1" activated successfully.', Comment = '%1 = Feature Name';
        TenantNotFoundErr: Label 'Tenant not found.';
        CompanyId: Text;
        Endpoint: Text;
        RequestBody: Text;
        ResponseText: Text;
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

        // Get company ID
        CompanyId := GetFirstCompanyId(BCTenant, BCEnvironment);

        // Build Activate API endpoint
        Endpoint := StrSubstNo('/api/microsoft/automation/v2.0/companies(%1)/features(''%2'')/Microsoft.NAV.Activate',
            CompanyId,
            Feature."Feature Key");

        // Build request body
        RequestBody := StrSubstNo('{"updateInBackground": %1, "startDateTime": "%2"}',
            Format(UpdateInBackground, 0, 9).ToLower(),
            Format(StartDateTime, 0, 9));

        // Make POST request
        AutomationAPIClient.SetContext(BCTenant, BCEnvironment);
        if not AutomationAPIClient.Post(Endpoint, RequestBody, ResponseText) then
            Error(FailedToActivateErr, ResponseText);

        ShowDebugMessage(ResponseText, 'Activate Feature');
        Message(FeatureActivatedMsg, Feature."Feature Name");
    end;

    procedure DeactivateFeature(var Feature: Record "D4P BC Environment Feature")
    var
        BCEnvironment: Record "D4P BC Environment";
        BCTenant: Record "D4P BC Tenant";
        EnvironmentNotFoundErr: Label 'Environment not found.';
        FailedToDeactivateErr: Label 'Failed to deactivate feature. Error details: %1', Comment = '%1 = Error message';
        FailedToObtainTokenErr: Label 'Failed to obtain authentication token.';
        FeatureDeactivatedMsg: Label 'Feature "%1" deactivated successfully.', Comment = '%1 = Feature Name';
        TenantNotFoundErr: Label 'Tenant not found.';
        CompanyId: Text;
        Endpoint: Text;
        ResponseText: Text;
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

        // Get company ID
        CompanyId := GetFirstCompanyId(BCTenant, BCEnvironment);

        // Build Deactivate API endpoint
        Endpoint := StrSubstNo('/api/microsoft/automation/v2.0/companies(%1)/features(''%2'')/Microsoft.NAV.Deactivate',
            CompanyId,
            Feature."Feature Key");

        // Make POST request
        AutomationAPIClient.SetContext(BCTenant, BCEnvironment);
        if not AutomationAPIClient.Post(Endpoint, '', ResponseText) then
            Error(FailedToDeactivateErr, ResponseText);

        ShowDebugMessage(ResponseText, 'Deactivate Feature');
        Message(FeatureDeactivatedMsg, Feature."Feature Name");
    end;

    local procedure GetFirstCompanyId(BCTenant: Record "D4P BC Tenant"; BCEnvironment: Record "D4P BC Environment"): Text
    var
        JArray: JsonArray;
        ResponseJson: JsonObject;
        JToken: JsonToken;
        CouldNotFindCompanyErr: Label 'Could not find company ID in response.';
        FailedToGetCompanyErr: Label 'Failed to get company ID. Error details: %1', Comment = '%1 = Error message';
        FailedToParseErr: Label 'Failed to parse companies response.';
        NoCompaniesErr: Label 'No companies found in the environment.';
        NoValueArrayErr: Label 'No value array found in companies response.';
        CompanyId: Text;
    begin
        // Get companies
        AutomationAPIClient.SetContext(BCTenant, BCEnvironment);
        if not AutomationAPIClient.Get('/api/microsoft/automation/v2.0/companies', ResponseJson) then
            Error(FailedToGetCompanyErr, Format(ResponseJson));

        if not ResponseJson.Get('value', JToken) then
            Error(NoValueArrayErr);

        JArray := JToken.AsArray();
        if JArray.Count() = 0 then
            Error(NoCompaniesErr);

        // Get the first company ID
        JArray.Get(0, JToken);
        ResponseJson := JToken.AsObject();
        if ResponseJson.Get('id', JToken) then
            CompanyId := JToken.AsValue().AsText()
        else
            Error(CouldNotFindCompanyErr);

        exit(CompanyId);
    end;

    var
        AutomationAPIClient: Codeunit D4PBCAutomationAPIClient;
}
