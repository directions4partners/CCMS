namespace D4P.CCMS.Environment;

using D4P.CCMS.Extension;
using D4P.CCMS.General;
using D4P.CCMS.Setup;
using D4P.CCMS.Tenant;
using System.Security.Authentication;

codeunit 62000 "D4P BC Environment Mgt"
{
    var
        APIHelper: Codeunit "D4P BC API Helper";

    procedure ShowDebugMessagePublic(ResponseText: Text; ActionName: Text)
    begin
        // Kept for backward compatibility - now handled by API Helper
    end;

    procedure GetEnvironments(var BCTenant: Record "D4P BC Tenant")
    var
        BCEnvironment: Record "D4P BC Environment";
        JsonArray: JsonArray;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonVersionDetails: JsonObject;
        JsonToken: JsonToken;
        JsonTokenField: JsonToken;
        JsonTokenLoop: JsonToken;
        JsonValue: JsonValue;
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1';
        ResponseText: Text;
    begin
        BCEnvironment.SetRange("Customer No.", BCTenant."Customer No.");
        BCEnvironment.SetRange("Tenant ID", BCTenant."Tenant ID");
        BCEnvironment.DeleteAll();

        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET', '/applications/businesscentral/environments', '', ResponseText) then
            Error(FailedToFetchErr, ResponseText);

        JsonResponse.ReadFrom(ResponseText);

        if JsonResponse.Get('value', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            BCEnvironment.Init();
            BCEnvironment."Customer No." := BCTenant."Customer No.";
            BCEnvironment."Tenant ID" := BCTenant."Tenant ID";

            foreach JsonTokenLoop in JsonArray do begin
                JsonObjectLoop := JsonTokenLoop.AsObject();
                if JsonObjectLoop.Get('name', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment.Name := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('applicationFamily', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Application Family" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('type', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment.Type := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('status', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment.State := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('countryCode', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Country/Region" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('applicationVersion', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Current Version" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('friendlyName', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Friendly Name" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('aadTenantId', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    if not Evaluate(BCEnvironment."AAD Tenant ID", JsonValue.AsText()) then
                        BCEnvironment."AAD Tenant ID" := CreateGuid(); // Fallback if evaluation fails
                end;
                if JsonObjectLoop.Get('webClientLoginUrl', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Web Client Login URL" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('webServiceUrl', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Web Service URL" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('locationName', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Location Name" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('geoName', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Geo Name" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('ringName', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Ring Name" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('appInsightsKey', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Application Insights String" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('SoftDeletedOn', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    if not Evaluate(BCEnvironment."Soft Deleted On", JsonValue.AsText()) then
                        BCEnvironment."Soft Deleted On" := 0DT; // Clear if evaluation fails
                end;
                if JsonObjectLoop.Get('HardDeletePendingOn', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    if not Evaluate(BCEnvironment."Hard Delete Pending On", JsonValue.AsText()) then
                        BCEnvironment."Hard Delete Pending On" := 0DT; // Clear if evaluation fails
                end;
                if JsonObjectLoop.Get('DeleteReason', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Delete Reason" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('appSourceAppsUpdateCadence', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."AppSource Apps Update Cadence" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('platformVersion', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Platform Version" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('linkedPowerPlatformEnvironmentId', JsonTokenField) then begin
                    JsonValue := JsonTokenField.AsValue();
                    BCEnvironment."Linked PowerPlatform Env ID" := JsonValue.AsText();
                end;
                // Handle nested versionDetails object
                if JsonObjectLoop.Get('versionDetails', JsonTokenField) then
                    if JsonTokenField.IsObject() then begin
                        JsonVersionDetails := JsonTokenField.AsObject();
                        if JsonVersionDetails.Get('gracePeriodStartDate', JsonTokenField) then begin
                            JsonValue := JsonTokenField.AsValue();
                            if not Evaluate(BCEnvironment."Grace Period Start Date", JsonValue.AsText()) then
                                BCEnvironment."Grace Period Start Date" := 0DT; // Clear if evaluation fails
                        end;
                        if JsonVersionDetails.Get('enforcedUpdatePeriodStartDate', JsonTokenField) then begin
                            JsonValue := JsonTokenField.AsValue();
                            if not Evaluate(BCEnvironment."Enforced Update Period Start", JsonValue.AsText()) then
                                BCEnvironment."Enforced Update Period Start" := 0DT; // Clear if evaluation fails
                        end;
                    end;

                BCEnvironment.Insert();
            end;
        end;
    end;

    procedure GetInstalledApps(var BCEnvironment: Record "D4P BC Environment")
    var
        InstalledApp: Record "D4P BC Installed App";
        BCTenant: Record "D4P BC Tenant";
        JsonArray: JsonArray;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        JsonValue: JsonValue;
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1';
        ResponseText: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        InstalledApp.SetRange("Customer No.", BCTenant."Customer No.");
        InstalledApp.SetRange("Tenant ID", BCTenant."Tenant ID");
        InstalledApp.SetRange("Environment Name", BCEnvironment.Name);
        InstalledApp.DeleteAll();

        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET',
            '/applications/businesscentral/environments/' + BCEnvironment.Name + '/apps', '', ResponseText) then
            Error(FailedToFetchErr, ResponseText);

        JsonResponse.ReadFrom(ResponseText);

        if JsonResponse.Get('value', JsonToken) then begin
            JsonArray := JsonToken.AsArray();

            InstalledApp.Init();
            InstalledApp."Customer No." := BCTenant."Customer No.";
            InstalledApp."Tenant ID" := BCTenant."Tenant ID";
            InstalledApp."Environment Name" := BCEnvironment.Name;

            foreach JsonTokenLoop in JsonArray do begin
                JsonObjectLoop := JsonTokenLoop.AsObject();
                if JsonObjectLoop.Get('id', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    InstalledApp."App ID" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('name', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    InstalledApp."App Name" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('publisher', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    InstalledApp."App Publisher" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('version', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    InstalledApp."App Version" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('state', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    case JsonValue.AsText() of
                        'Installed':
                            InstalledApp.State := Enum::"D4P App State"::Installed;
                        'UpdatePending':
                            InstalledApp.State := Enum::"D4P App State"::"Update Pending";
                        'Updating':
                            InstalledApp.State := Enum::"D4P App State"::Updating;
                        else
                            InstalledApp.State := Enum::"D4P App State"::Installed;
                    end;
                end;
                if JsonObjectLoop.Get('appType', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    case LowerCase(JsonValue.AsText()) of
                        'global':
                            InstalledApp."App Type" := Enum::"D4P App Type"::Global;
                        'pte':
                            InstalledApp."App Type" := Enum::"D4P App Type"::PTE;
                        'dev':
                            InstalledApp."App Type" := Enum::"D4P App Type"::DEV;
                        else
                            InstalledApp."App Type" := Enum::"D4P App Type"::" ";
                    end;
                end;
                if JsonObjectLoop.Get('lastOperationId', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    InstalledApp."Last Operation Id" := JsonValue.AsText();
                end;
                if JsonObjectLoop.Get('lastUpdateAttemptResult', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    case JsonValue.AsText() of
                        'Succeeded':
                            InstalledApp."Last Update Attempt Result" := Enum::"D4P Update Attempt Result"::Succeeded;
                        'Failed':
                            InstalledApp."Last Update Attempt Result" := Enum::"D4P Update Attempt Result"::Failed;
                        'Canceled':
                            InstalledApp."Last Update Attempt Result" := Enum::"D4P Update Attempt Result"::Canceled;
                        'Skipped':
                            InstalledApp."Last Update Attempt Result" := Enum::"D4P Update Attempt Result"::Skipped;
                        else
                            InstalledApp."Last Update Attempt Result" := Enum::"D4P Update Attempt Result"::Succeeded;
                    end;
                end;
                InstalledApp."Available Update Version" := '';
                InstalledApp.Insert();
            end;
        end;
    end;

    procedure GetEnvironmentUpdates(var BCEnvironment: Record "D4P BC Environment"; ShowMessage: Boolean)
    var
        BCTenant: Record "D4P BC Tenant";
        available: Boolean;
        ignoreUpdateWindow: Boolean;
        selected: Boolean;
        latestSelectableDate: DateTime;
        selectedDateTime: DateTime;
        month: Integer;
        year: Integer;
        JsonArray: JsonArray;
        JsonExpectedAvailability: JsonObject;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonScheduleDetails: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        JsonValue: JsonValue;
        FailedToFetchErr: Label 'Failed to fetch environment updates: %1';
        NoAvailableUpdatesMsg: Label 'No available updates found for the selected environment.';
        NoSelectedUpdateMsg: Label 'No selected update found for the selected environment.';
        SelectedUpdateVersionFetchedMsg: Label 'Selected update version %1 has been fetched successfully.';
        Endpoint: Text;
        expectedAvailability: Text;
        ResponseText: Text;
        rolloutStatus: Text;
        targetVersion: Text;
        targetVersionType: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Call Admin API to get environment updates
        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/updates';
        if APIHelper.SendAdminAPIRequest(BCTenant, 'GET', Endpoint, '', ResponseText) then begin
            JsonResponse.ReadFrom(ResponseText);

            if JsonResponse.Get('value', JsonToken) then begin
                JsonArray := JsonToken.AsArray();
                targetVersion := '';

                foreach JsonTokenLoop in JsonArray do begin
                    JsonObjectLoop := JsonTokenLoop.AsObject();

                    // Check if this version is selected
                    selected := false;
                    if JsonObjectLoop.Get('selected', JsonTokenLoop) then begin
                        JsonValue := JsonTokenLoop.AsValue();
                        selected := JsonValue.AsBoolean();
                    end;

                    if selected then begin
                        // Get the target version
                        if JsonObjectLoop.Get('targetVersion', JsonTokenLoop) then begin
                            JsonValue := JsonTokenLoop.AsValue();
                            targetVersion := JsonValue.AsText();
                        end;

                        // Get availability status
                        available := false;
                        if JsonObjectLoop.Get('available', JsonTokenLoop) then begin
                            JsonValue := JsonTokenLoop.AsValue();
                            available := JsonValue.AsBoolean();
                        end;

                        // Get target version type
                        targetVersionType := '';
                        if JsonObjectLoop.Get('targetVersionType', JsonTokenLoop) then begin
                            JsonValue := JsonTokenLoop.AsValue();
                            targetVersionType := JsonValue.AsText();
                        end;

                        // Get schedule details if available (for released versions)
                        if JsonObjectLoop.Get('scheduleDetails', JsonTokenLoop) then begin
                            JsonScheduleDetails := JsonTokenLoop.AsObject();

                            // Get selected date time
                            if JsonScheduleDetails.Get('selectedDateTime', JsonTokenLoop) then begin
                                JsonValue := JsonTokenLoop.AsValue();
                                if not JsonValue.IsNull() then
                                    selectedDateTime := JsonValue.AsDateTime();
                            end;

                            // Get latest selectable date
                            if JsonScheduleDetails.Get('latestSelectableDate', JsonTokenLoop) then begin
                                JsonValue := JsonTokenLoop.AsValue();
                                if not JsonValue.IsNull() then
                                    latestSelectableDate := JsonValue.AsDateTime();
                            end;

                            // Get ignore update window
                            ignoreUpdateWindow := false;
                            if JsonScheduleDetails.Get('ignoreUpdateWindow', JsonTokenLoop) then begin
                                JsonValue := JsonTokenLoop.AsValue();
                                ignoreUpdateWindow := JsonValue.AsBoolean();
                            end;

                            // Get rollout status
                            rolloutStatus := '';
                            if JsonScheduleDetails.Get('rolloutStatus', JsonTokenLoop) then begin
                                JsonValue := JsonTokenLoop.AsValue();
                                rolloutStatus := JsonValue.AsText();
                            end;
                        end;

                        // Get expected availability if available (for unreleased versions)
                        expectedAvailability := '';
                        if JsonObjectLoop.Get('expectedAvailability', JsonTokenLoop) then begin
                            JsonExpectedAvailability := JsonTokenLoop.AsObject();

                            if JsonExpectedAvailability.Get('month', JsonTokenLoop) then begin
                                JsonValue := JsonTokenLoop.AsValue();
                                month := JsonValue.AsInteger();
                            end;

                            if JsonExpectedAvailability.Get('year', JsonTokenLoop) then begin
                                JsonValue := JsonTokenLoop.AsValue();
                                year := JsonValue.AsInteger();
                            end;

                            expectedAvailability := Format(year) + '/' + PadStr('', 2 - StrLen(Format(month)), '0') + Format(month);
                        end;
                    end;
                end;

                // Update the environment with the selected update information
                if targetVersion <> '' then begin
                    BCEnvironment."Target Version" := targetVersion;
                    BCEnvironment."Available" := available;
                    BCEnvironment."Target Version Type" := targetVersionType;
                    BCEnvironment."Selected DateTime" := selectedDateTime;
                    BCEnvironment."Latest Selectable Date" := latestSelectableDate;
                    BCEnvironment."Ignore Update Window" := ignoreUpdateWindow;
                    BCEnvironment."Rollout Status" := rolloutStatus;
                    BCEnvironment."Expected Availability" := expectedAvailability;
                    BCEnvironment.Modify();
                    if ShowMessage then
                        Message(SelectedUpdateVersionFetchedMsg, targetVersion);
                end else
                    if ShowMessage then
                        Message(NoSelectedUpdateMsg);
            end
            else
                if ShowMessage then
                    Message(NoAvailableUpdatesMsg);
        end else
            if ShowMessage then
                Error(FailedToFetchErr, ResponseText);
    end;

    procedure GetAvailableAppUpdates(var BCEnvironment: Record "D4P BC Environment")
    var
        InstalledApp: Record "D4P BC Installed App";
        BCTenant: Record "D4P BC Tenant";
        appId: Guid;
        JsonArray: JsonArray;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        JsonValue: JsonValue;
        AvailableUpdatesFetchedMsg: Label 'Available updates for the selected environment have been fetched successfully.';
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1';
        NoAvailableUpdatesMsg: Label 'No available updates found for the selected environment.';
        appVersion: Text;
        ResponseText: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET',
            '/applications/businesscentral/environments/' + BCEnvironment.Name + '/apps/availableUpdates', '', ResponseText) then
            Error(FailedToFetchErr, ResponseText);

        JsonResponse.ReadFrom(ResponseText);

        if JsonResponse.Get('value', JsonToken) then begin
            JsonArray := JsonToken.AsArray();

            foreach JsonTokenLoop in JsonArray do begin
                JsonObjectLoop := JsonTokenLoop.AsObject();
                if JsonObjectLoop.Get('appId', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    appId := JsonValue.AsText();
                end;
                // if JsonObjectLoop.Get('name', JsonTokenLoop) then begin
                //     JsonValue := JsonTokenLoop.AsValue();
                //     appName := JsonValue.AsText();
                // end;
                // if JsonObjectLoop.Get('publisher', JsonTokenLoop) then begin
                //     JsonValue := JsonTokenLoop.AsValue();
                //     appPublisher := JsonValue.AsText();
                // end;
                if JsonObjectLoop.Get('version', JsonTokenLoop) then begin
                    JsonValue := JsonTokenLoop.AsValue();
                    appVersion := JsonValue.AsText();
                end;
                //Update the app entry
                if InstalledApp.Get(BCTenant."Customer No.", BCTenant."Tenant ID", BCEnvironment.Name, appId) then begin
                    InstalledApp."Available Update Version" := appVersion;
                    InstalledApp.Modify();
                end;
            end;
            Message(AvailableUpdatesFetchedMsg);
        end
        else
            Message(NoAvailableUpdatesMsg);
    end;

    procedure UpdateApp(var BCEnvironment: Record "D4P BC Environment"; AppId: Guid; showNotification: Boolean)
    var
        InstalledApp: Record "D4P BC Installed App";
        BCTenant: Record "D4P BC Tenant";
        AppUpdateNotification: Notification;
        JsonObject: JsonObject;
        AppNotFoundErr: Label 'App not found';
        AppUpdateScheduledMsg: Label 'App %1 update to version %2 successfully scheduled.';
        FailedToUpdateErr: Label 'Failed to update app: %1';
        NoUpdateAvailableErr: Label 'No update available for this app';
        ResponseText: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        if not InstalledApp.Get(BCTenant."Customer No.", BCTenant."Tenant ID", BCEnvironment.Name, AppId) then
            Error(AppNotFoundErr);

        if InstalledApp."Available Update Version" = '' then
            Error(NoUpdateAvailableErr);

        JsonObject.Add('useEnvironmentUpdateWindow', false);
        JsonObject.Add('targetVersion', InstalledApp."Available Update Version");
        JsonObject.Add('allowPreviewVersion', false);
        JsonObject.Add('installOrUpdateNeededDependencies', true);

        if not APIHelper.SendAdminAPIRequest(BCTenant, 'POST',
            '/applications/businesscentral/environments/' + BCEnvironment.Name + '/apps/' + Format(AppId) + '/update',
            Format(JsonObject), ResponseText) then
            Error(FailedToUpdateErr, ResponseText);

        if showNotification then begin
            AppUpdateNotification.Message := StrSubstNo(AppUpdateScheduledMsg, InstalledApp."App Name", InstalledApp."Available Update Version");
            AppUpdateNotification.Send();
        end else
            Message(AppUpdateScheduledMsg, InstalledApp."App Name", InstalledApp."Available Update Version");
    end;

    procedure CreateNewBCEnvironment(var BCTenant: Record "D4P BC Tenant"; EnvironmentName: Text[100]; Localization: Code[2]; EnvironmentType: Enum "D4P Environment Type")
    var
        JsonObject: JsonObject;
        EnvironmentCreatedMsg: Label 'New environment %1 successfully created.';
        FailedToCreateErr: Label 'Failed to create new environment: %1';
        ResponseText: Text;
    begin
        JsonObject.Add('environmentType', Format(EnvironmentType));
        JsonObject.Add('countryCode', Localization);

        if not APIHelper.SendAdminAPIRequest(BCTenant, 'PUT',
            '/applications/businesscentral/environments/' + EnvironmentName,
            Format(JsonObject), ResponseText) then
            Error(FailedToCreateErr, ResponseText);

        Message(EnvironmentCreatedMsg, EnvironmentName);
    end;

    procedure CopyBCEnvironment(var BCTenant: Record "D4P BC Tenant"; SourceEnvironmentName: Text[100]; NewEnvironmentName: Text[100]; NewEnvironmentType: Enum "D4P Environment Type")
    var
        JsonObject: JsonObject;
        CopyEnvironmentScheduledMsg: Label 'Copy environment %1 to %2 successfully scheduled.';
        FailedToCreateErr: Label 'Failed to create new environment: %1';
        ResponseText: Text;
    begin
        JsonObject.Add('environmentName', NewEnvironmentName);
        JsonObject.Add('type', Format(NewEnvironmentType));

        if not APIHelper.SendAdminAPIRequest(BCTenant, 'POST',
            '/applications/businesscentral/environments/' + SourceEnvironmentName + '/copy',
            Format(JsonObject), ResponseText) then
            Error(FailedToCreateErr, ResponseText);

        Message(CopyEnvironmentScheduledMsg, SourceEnvironmentName, NewEnvironmentName);
    end;

    procedure RenameBCEnvironment(var BCTenant: Record "D4P BC Tenant"; SourceEnvironmentName: Text[100]; NewEnvironmentName: Text[100])
    var
        JsonObject: JsonObject;
        EnvironmentRenamedMsg: Label 'Environment %1 successfully renamed to %2.';
        FailedToRenameErr: Label 'Failed to rename environment: %1';
        ResponseText: Text;
    begin
        JsonObject.Add('NewEnvironmentName', NewEnvironmentName);

        if not APIHelper.SendAdminAPIRequest(BCTenant, 'POST',
            '/applications/businesscentral/environments/' + SourceEnvironmentName + '/rename/',
            Format(JsonObject), ResponseText) then
            Error(FailedToRenameErr, ResponseText);

        Message(EnvironmentRenamedMsg, SourceEnvironmentName, NewEnvironmentName);
    end;

    procedure DeleteBCEnvironment(var BCTenant: Record "D4P BC Tenant"; EnvironmentName: Text[100])
    var
        EnvironmentMarkedForDeletionMsg: Label 'Environment %1 successfully marked for deletion.';
        FailedToDeleteErr: Label 'Failed to delete environment: %1';
        ResponseText: Text;
    begin
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'DELETE',
            '/applications/businesscentral/environments/' + EnvironmentName, '', ResponseText) then
            Error(FailedToDeleteErr, ResponseText);

        Message(EnvironmentMarkedForDeletionMsg, EnvironmentName);
    end;

    procedure GetAvailableUpdates(var BCEnvironment: Record "D4P BC Environment"; var TempAvailableUpdate: Record "D4P BC Available Update" temporary)
    var
        BCSetup: Record "D4P BC Setup";
        BCTenant: Record "D4P BC Tenant";
        ProgressDialog: Dialog;
        CurrentUpdate: Integer;
        EntryNo: Integer;
        TotalUpdates: Integer;
        JsonArray: JsonArray;
        JsonExpectedAvailability: JsonObject;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonScheduleDetails: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        JsonValue: JsonValue;
        FailedToFetchErr: Label 'Failed to fetch available updates: %1';
        FetchingUpdatesMsg: Label 'Fetching available updates...';
        NoUpdatesFoundMsg: Label 'No updates found in API response for environment %1.';
        ProcessingUpdateMsg: Label 'Processing update #1#### of #2####: #3####################';
        Endpoint: Text;
        ResponseText: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");
        BCSetup.Get();
        TempAvailableUpdate.Reset();
        TempAvailableUpdate.DeleteAll();

        // Show progress dialog
        ProgressDialog.Open(FetchingUpdatesMsg);

        // Call Admin API to get available updates
        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/updates';
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET', Endpoint, '', ResponseText) then begin
            ProgressDialog.Close();
            Error(FailedToFetchErr, ResponseText);
        end;

        // Debug mode: Show API response
        if BCSetup."Debug Mode" then
            Message('DEBUG - Get Available Updates:\%1', ResponseText);

        JsonResponse.ReadFrom(ResponseText);

        if JsonResponse.Get('value', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            TotalUpdates := JsonArray.Count();
            EntryNo := 0;

            if TotalUpdates = 0 then begin
                ProgressDialog.Close();
                Message(NoUpdatesFoundMsg, BCEnvironment.Name);
                exit;
            end;

            ProgressDialog.Close();
            ProgressDialog.Open(ProcessingUpdateMsg);

            foreach JsonTokenLoop in JsonArray do begin
                JsonObjectLoop := JsonTokenLoop.AsObject();
                EntryNo += 1;
                CurrentUpdate := EntryNo;

                TempAvailableUpdate.Init();
                TempAvailableUpdate."Entry No." := EntryNo;

                // Update progress dialog
                ProgressDialog.Update(1, CurrentUpdate);
                ProgressDialog.Update(2, TotalUpdates);

                // Get target version
                if JsonObjectLoop.Get('targetVersion', JsonToken) then begin
                    JsonValue := JsonToken.AsValue();
                    TempAvailableUpdate."Target Version" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(TempAvailableUpdate."Target Version"));
                    ProgressDialog.Update(3, TempAvailableUpdate."Target Version");
                end;

                // Get availability status
                if JsonObjectLoop.Get('available', JsonToken) then begin
                    JsonValue := JsonToken.AsValue();
                    TempAvailableUpdate.Available := JsonValue.AsBoolean();
                end;

                // Get selected status
                if JsonObjectLoop.Get('selected', JsonToken) then begin
                    JsonValue := JsonToken.AsValue();
                    TempAvailableUpdate.Selected := JsonValue.AsBoolean();
                end;

                // Get target version type
                if JsonObjectLoop.Get('targetVersionType', JsonToken) then begin
                    JsonValue := JsonToken.AsValue();
                    TempAvailableUpdate."Target Version Type" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(TempAvailableUpdate."Target Version Type"));
                end;

                // Get schedule details if available (for released versions)
                if JsonObjectLoop.Get('scheduleDetails', JsonToken) then begin
                    JsonScheduleDetails := JsonToken.AsObject();

                    // Get selected date time
                    if JsonScheduleDetails.Get('selectedDateTime', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        if not JsonValue.IsNull() then
                            TempAvailableUpdate."Selected DateTime" := DT2Date(JsonValue.AsDateTime());
                    end;

                    // Get latest selectable date - try both field names (API inconsistency)
                    if JsonScheduleDetails.Get('latestSelectableDateTime', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        if not JsonValue.IsNull() then
                            TempAvailableUpdate."Latest Selectable Date" := DT2Date(JsonValue.AsDateTime());
                    end else
                        if JsonScheduleDetails.Get('latestSelectableDate', JsonToken) then begin
                            JsonValue := JsonToken.AsValue();
                            if not JsonValue.IsNull() then
                                TempAvailableUpdate."Latest Selectable Date" := DT2Date(JsonValue.AsDateTime());
                        end;

                    // Get ignore update window
                    if JsonScheduleDetails.Get('ignoreUpdateWindow', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        TempAvailableUpdate."Ignore Update Window" := JsonValue.AsBoolean();
                    end;

                    // Get rollout status
                    if JsonScheduleDetails.Get('rolloutStatus', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        TempAvailableUpdate."Rollout Status" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(TempAvailableUpdate."Rollout Status"));
                    end;
                end;

                // Get expected availability if available (for unreleased versions)
                if JsonObjectLoop.Get('expectedAvailability', JsonToken) then begin
                    JsonExpectedAvailability := JsonToken.AsObject();

                    if JsonExpectedAvailability.Get('month', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        TempAvailableUpdate."Expected Month" := JsonValue.AsInteger();
                    end;

                    if JsonExpectedAvailability.Get('year', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        TempAvailableUpdate."Expected Year" := JsonValue.AsInteger();
                    end;
                end;

                TempAvailableUpdate.Insert();
            end;

            ProgressDialog.Close();
        end else begin
            ProgressDialog.Close();
            Message(NoUpdatesFoundMsg, BCEnvironment.Name);
        end;
    end;

    procedure SelectTargetVersion(var BCEnvironment: Record "D4P BC Environment"; TargetVersion: Text[100]; SelectedDate: Date; ExpectedMonth: Integer; ExpectedYear: Integer)
    var
        BCSetup: Record "D4P BC Setup";
        BCTenant: Record "D4P BC Tenant";
        IsAvailable: Boolean;
        SelectedDateTime: DateTime;
        JsonObject: JsonObject;
        JsonScheduleDetails: JsonObject;
        FailedToSelectErr: Label 'Failed to select target version: %1';
        UpdateScheduledMsg: Label 'Update to version %1 successfully scheduled for %2.';
        UpdateSelectedMsg: Label 'Update to version %1 successfully selected. Expected availability: %2/%3.';
        Endpoint: Text;
        RequestBody: Text;
        ResponseText: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");
        BCSetup.Get();

        // Determine if the version is available (has a date) or not (has month/year)
        IsAvailable := (SelectedDate <> 0D);

        // Build JSON request body
        JsonObject.Add('selected', true);

        if IsAvailable then begin
            // Convert Date to DateTime (at midnight)
            SelectedDateTime := CreateDateTime(SelectedDate, 0T);
            // For available versions, include schedule details
            JsonScheduleDetails.Add('selectedDateTime', SelectedDateTime);
            JsonScheduleDetails.Add('ignoreUpdateWindow', false);
            JsonObject.Add('scheduleDetails', JsonScheduleDetails);
        end;

        JsonObject.WriteTo(RequestBody);

        // Debug mode: Show request body
        if BCSetup."Debug Mode" then
            Message('DEBUG - Select Target Version Request:\Target Version: %1\Request Body: %2', TargetVersion, RequestBody);

        // Call Admin API to select target version
        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/updates/' + TargetVersion;
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'PATCH', Endpoint, RequestBody, ResponseText) then
            Error(FailedToSelectErr, ResponseText);

        // Debug mode: Show API response
        if BCSetup."Debug Mode" then
            Message('DEBUG - Select Target Version Response:\%1', ResponseText);

        // Update environment record
        BCEnvironment."Target Version" := TargetVersion;
        if IsAvailable then begin
            BCEnvironment."Selected DateTime" := SelectedDateTime;
            BCEnvironment."Expected Availability" := '';
            Message(UpdateScheduledMsg, TargetVersion, SelectedDate);
        end else begin
            BCEnvironment."Selected DateTime" := 0DT;
            BCEnvironment."Expected Availability" := Format(ExpectedYear) + '/' + PadStr('', 2 - StrLen(Format(ExpectedMonth)), '0') + Format(ExpectedMonth);
            Message(UpdateSelectedMsg, TargetVersion, ExpectedMonth, ExpectedYear);
        end;
        BCEnvironment.Modify();
    end;

    procedure RescheduleBCEnvironmentUpgrade(var BCTenant: Record "D4P BC Tenant"; EnvironmentName: Text[100]; TargetVersion: Text[100]; UpgradeDate: DateTime)
    var
        EnvironmentUpgradeScheduledMsg: Label 'Environment %1 successfully scheduled for upgrade to version %2 on Date %3.';
        FailedToUpgradeErr: Label 'Failed to upgrade environment: %1';
        Endpoint: Text;
        ResponseText: Text;
    begin
        // Call Admin API to reschedule environment upgrade
        Endpoint := '/applications/businesscentral/environments/' + EnvironmentName + '/updates';
        if APIHelper.SendAdminAPIRequest(BCTenant, 'PUT', Endpoint, '', ResponseText) then
            Message(EnvironmentUpgradeScheduledMsg, EnvironmentName, TargetVersion, UpgradeDate)
        else
            Error(FailedToUpgradeErr, ResponseText);
    end;

    procedure SetApplicationInsightsConnectionString(var BCEnvironment: Record "D4P BC Environment")
    var
        BCTenant: Record "D4P BC Tenant";
        IsRemoving: Boolean;
        JsonObject: JsonObject;
        ConnectionStringRemovedMsg: Label 'Application Insights connection string successfully removed for environment %1.';
        ConnectionStringSetMsg: Label 'Application Insights connection string successfully set for environment %1.';
        FailedToSetKeyErr: Label 'Failed to set Application Insights key: %1';
        Endpoint: Text;
        RequestBody: Text;
        ResponseText: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Determine if we're removing (empty string) or setting the key
        IsRemoving := (BCEnvironment."Application Insights String" = '');

        // Create JSON request body
        JsonObject.Add('key', BCEnvironment."Application Insights String");
        JsonObject.WriteTo(RequestBody);

        // Call Admin API to set Application Insights key
        Endpoint := '/applications/businesscentral/environments/' + BCEnvironment.Name + '/settings/appinsightskey';
        if APIHelper.SendAdminAPIRequest(BCTenant, 'POST', Endpoint, RequestBody, ResponseText) then begin
            if IsRemoving then
                Message(ConnectionStringRemovedMsg, BCEnvironment.Name)
            else
                Message(ConnectionStringSetMsg, BCEnvironment.Name);
        end else
            Error(FailedToSetKeyErr, ResponseText);
    end;
}