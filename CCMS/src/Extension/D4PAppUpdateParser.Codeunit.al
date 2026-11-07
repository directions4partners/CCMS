namespace D4P.CCMS.Extension;

/// <summary>
/// Interprets Admin Center API responses about apps (state, available updates, app operations)
/// without making any HTTP calls, so the logic can be tested in isolation.
/// </summary>
codeunit 62042 "D4P App Update Parser"
{
    Access = Internal;

    /// <summary>
    /// Transfers one entry of the installed apps response (GET .../apps) to the installed app record.
    /// Every API field is assigned explicitly, so a missing or null property results in the default value
    /// instead of keeping a value from a previously processed app. Update information (available version,
    /// requirements, scheduled operation) is cleared; it is filled by the available updates request.
    /// The key fields Customer No., Tenant ID and Environment Name are not touched.
    /// </summary>
    /// <param name="AppJson">One entry of the "value" array of the installed apps response.</param>
    /// <param name="InstalledApp">The installed app record to fill; it is not inserted or modified in the database.</param>
    procedure ApplyInstalledApp(AppJson: JsonObject; var InstalledApp: Record "D4P BC Installed App")
    begin
        // The documentation names the property "appId", the API currently returns "id"
        InstalledApp."App ID" := GetJsonGuid(AppJson, 'id');
        if IsNullGuid(InstalledApp."App ID") then
            InstalledApp."App ID" := GetJsonGuid(AppJson, 'appId');
        InstalledApp."App Name" := CopyStr(GetJsonText(AppJson, 'name'), 1, MaxStrLen(InstalledApp."App Name"));
        InstalledApp."App Publisher" := CopyStr(GetJsonText(AppJson, 'publisher'), 1, MaxStrLen(InstalledApp."App Publisher"));
        InstalledApp."App Version" := CopyStr(GetJsonText(AppJson, 'version'), 1, MaxStrLen(InstalledApp."App Version"));
        InstalledApp.State := ParseAppState(GetJsonText(AppJson, 'state'));
        InstalledApp."App Type" := ParseAppType(GetJsonText(AppJson, 'appType'));
        InstalledApp."Last Operation Id" := GetJsonGuid(AppJson, 'lastOperationId');
        InstalledApp."Last Update Attempt Result" := ParseUpdateAttemptResult(GetJsonText(AppJson, 'lastUpdateAttemptResult'));
        InstalledApp."Last Uninstall Operation Id" := GetJsonGuid(AppJson, 'lastUninstallOperationId');
        InstalledApp."Last Uninstall Attempt Result" := ParseUninstallAttemptResult(GetJsonText(AppJson, 'lastUninstallAttemptResult'));
        InstalledApp."Can Be Uninstalled" := LowerCase(GetJsonText(AppJson, 'canBeUninstalled')) = 'true';

        InstalledApp."Available Update Version" := '';
        InstalledApp."Update Requirements" := '';
        Clear(InstalledApp."Scheduled Operation Id");
        InstalledApp.SetUpdateStatus();
    end;

    /// <summary>
    /// Maps the "appType" of the installed apps endpoint (global, tenant, dev) case-insensitively.
    /// </summary>
    /// <param name="AppTypeText">The app type as returned by the API.</param>
    /// <returns>The app type; blank for unknown values.</returns>
    procedure ParseAppType(AppTypeText: Text): Enum "D4P App Type"
    begin
        case LowerCase(AppTypeText) of
            'global':
                exit(Enum::"D4P App Type"::Global);
            'pte', 'tenant':
                exit(Enum::"D4P App Type"::PTE);
            'dev':
                exit(Enum::"D4P App Type"::DEV);
            else
                exit(Enum::"D4P App Type"::" ");
        end;
    end;

    /// <summary>
    /// Maps "lastUpdateAttemptResult" (Failed, Succeeded, Canceled, Skipped) case-insensitively.
    /// </summary>
    /// <param name="ResultText">The result as returned by the API.</param>
    /// <returns>The update attempt result; blank if there was no attempt or the value is unknown.</returns>
    procedure ParseUpdateAttemptResult(ResultText: Text): Enum "D4P Update Attempt Result"
    begin
        case LowerCase(ResultText) of
            'failed':
                exit(Enum::"D4P Update Attempt Result"::Failed);
            'succeeded':
                exit(Enum::"D4P Update Attempt Result"::Succeeded);
            'canceled':
                exit(Enum::"D4P Update Attempt Result"::Canceled);
            'skipped':
                exit(Enum::"D4P Update Attempt Result"::Skipped);
            else
                exit(Enum::"D4P Update Attempt Result"::" ");
        end;
    end;

    /// <summary>
    /// Maps "lastUninstallAttemptResult" (Failed, Succeeded, Canceled, Skipped) case-insensitively.
    /// </summary>
    /// <param name="ResultText">The result as returned by the API.</param>
    /// <returns>The uninstall attempt result; blank if there was no attempt or the value is unknown.</returns>
    procedure ParseUninstallAttemptResult(ResultText: Text): Enum "D4P Uninstall Attempt Result"
    begin
        case LowerCase(ResultText) of
            'failed':
                exit(Enum::"D4P Uninstall Attempt Result"::Failed);
            'succeeded':
                exit(Enum::"D4P Uninstall Attempt Result"::Succeeded);
            'canceled':
                exit(Enum::"D4P Uninstall Attempt Result"::Canceled);
            'skipped':
                exit(Enum::"D4P Uninstall Attempt Result"::Skipped);
            else
                exit(Enum::"D4P Uninstall Attempt Result"::" ");
        end;
    end;

    /// <summary>
    /// Maps the "state" of the installed apps endpoint (Installed, UpdatePending, Updating) case-insensitively.
    /// </summary>
    /// <param name="StateText">The state as returned by the API.</param>
    /// <returns>The app state; Installed for unknown values.</returns>
    procedure ParseAppState(StateText: Text): Enum "D4P App State"
    begin
        case LowerCase(StateText) of
            'updatepending':
                exit(Enum::"D4P App State"::"Update Pending");
            'updating':
                exit(Enum::"D4P App State"::Updating);
            else
                exit(Enum::"D4P App State"::Installed);
        end;
    end;

    /// <summary>
    /// Builds a readable list of the "requirements" of an available update entry
    /// (apps that must be installed or updated first, shown as "Action Required" in the admin center).
    /// </summary>
    /// <param name="AvailableUpdate">One entry of the availableUpdates response.</param>
    /// <returns>For example "Update Continia Core (28.7.0.1), Install Some App (1.0.0.0)"; empty if there are no requirements.</returns>
    procedure GetUpdateRequirements(AvailableUpdate: JsonObject): Text[250]
    var
        Requirement: JsonObject;
        JsonToken: JsonToken;
        RequirementToken: JsonToken;
        Requirements: Text;
        RequirementTok: Label '%1 %2 (%3)', Locked = true;
    begin
        if not AvailableUpdate.Get('requirements', JsonToken) then
            exit('');
        if not JsonToken.IsArray() then
            exit('');
        foreach RequirementToken in JsonToken.AsArray() do
            if RequirementToken.IsObject() then begin
                Requirement := RequirementToken.AsObject();
                if Requirements <> '' then
                    Requirements += ', ';
                Requirements += StrSubstNo(RequirementTok,
                    GetJsonText(Requirement, 'type'), GetJsonText(Requirement, 'name'), GetJsonText(Requirement, 'version'));
            end;
        exit(CopyStr(Requirements, 1, 250));
    end;

    /// <summary>
    /// Returns the ID of the first operation with status "scheduled" from an app operations response.
    /// </summary>
    /// <param name="OperationsResponse">The response of GET .../apps/{appId}/operations.</param>
    /// <returns>The operation ID, or an empty GUID if no operation is scheduled.</returns>
    procedure FindScheduledOperationId(OperationsResponse: JsonObject): Guid
    var
        Operation: JsonObject;
        JsonToken: JsonToken;
        OperationToken: JsonToken;
        EmptyGuid: Guid;
        OperationId: Guid;
    begin
        if not OperationsResponse.Get('value', JsonToken) then
            exit(EmptyGuid);
        if not JsonToken.IsArray() then
            exit(EmptyGuid);
        foreach OperationToken in JsonToken.AsArray() do
            if OperationToken.IsObject() then begin
                Operation := OperationToken.AsObject();
                if LowerCase(GetJsonText(Operation, 'status')) = 'scheduled' then begin
                    // Skip entries with an invalid id and keep looking for a usable scheduled operation
                    OperationId := GetJsonGuid(Operation, 'id');
                    if not IsNullGuid(OperationId) then
                        exit(OperationId);
                end;
            end;
        exit(EmptyGuid);
    end;

    /// <summary>
    /// Applies the operation returned by the update endpoint to the installed app and recalculates the update status.
    /// A "scheduled" operation sets the scheduled operation ID, any other status means the update is running.
    /// The record is not modified in the database.
    /// </summary>
    /// <param name="InstalledApp">The installed app that was updated.</param>
    /// <param name="ResponseText">The response body of POST .../apps/{appId}/update.</param>
    procedure ApplyUpdateOperationResponse(var InstalledApp: Record "D4P BC Installed App"; ResponseText: Text)
    var
        OperationResponse: JsonObject;
    begin
        if OperationResponse.ReadFrom(ResponseText) then
            if LowerCase(GetJsonText(OperationResponse, 'status')) = 'scheduled' then
                InstalledApp."Scheduled Operation Id" := GetJsonGuid(OperationResponse, 'id')
            else
                InstalledApp.State := InstalledApp.State::Updating;
        InstalledApp.SetUpdateStatus();
    end;

    /// <summary>
    /// Reads a property as GUID; returns an empty GUID if it is missing, null or not a valid GUID.
    /// </summary>
    /// <param name="JsonObject">The JSON object.</param>
    /// <param name="PropertyName">The property to read.</param>
    /// <returns>The property value as GUID.</returns>
    procedure GetJsonGuid(JsonObject: JsonObject; PropertyName: Text) Result: Guid
    begin
        if not Evaluate(Result, GetJsonText(JsonObject, PropertyName)) then
            Clear(Result);
    end;

    /// <summary>
    /// Reads a property as text; returns an empty text if it is missing, not a value or null.
    /// </summary>
    /// <param name="JsonObject">The JSON object.</param>
    /// <param name="PropertyName">The property to read.</param>
    /// <returns>The property value as text.</returns>
    procedure GetJsonText(JsonObject: JsonObject; PropertyName: Text): Text
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(PropertyName, JsonToken) then
            exit('');
        if not JsonToken.IsValue() then
            exit('');
        if JsonToken.AsValue().IsNull() then
            exit('');
        exit(JsonToken.AsValue().AsText());
    end;
}
