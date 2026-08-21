namespace D4P.CCMS.Environment;

using D4P.CCMS.Connector;
using D4P.CCMS.Extension;
using D4P.CCMS.Setup;
using D4P.CCMS.Tenant;

codeunit 62000 "D4P BC Environment Mgt"
{
    var
        AdminAPIClient: Codeunit D4PBCAdminAPIClient;

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
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1', Comment = '%1 = Error message';
    begin
        BCEnvironment.SetRange("Customer No.", BCTenant."Customer No.");
        BCEnvironment.SetRange("Tenant ID", BCTenant."Tenant ID");
        BCEnvironment.DeleteAll();

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Get('/applications/businesscentral/environments', JsonResponse) then
            Error(FailedToFetchErr, Format(JsonResponse));

        if JsonResponse.Get('value', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            BCEnvironment.Init();
            BCEnvironment."Customer No." := BCTenant."Customer No.";
            BCEnvironment."Tenant ID" := BCTenant."Tenant ID";

            foreach JsonTokenLoop in JsonArray do begin
                JsonObjectLoop := JsonTokenLoop.AsObject();
                FillEnvironmentFromJsonObject(BCEnvironment, JsonObjectLoop);
                BCEnvironment.Insert();
            end;
        end;
    end;

    procedure GetEnvironment(var BCTenant: Record "D4P BC Tenant"; EnvironmentName: Text)
    var
        BCEnvironment: Record "D4P BC Environment";
        JsonObject: JsonObject;
        JsonResponse: JsonObject;
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1', Comment = '%1 = Error message';
    begin
        BCEnvironment.SetRange("Customer No.", BCTenant."Customer No.");
        BCEnvironment.SetRange("Tenant ID", BCTenant."Tenant ID");
        BCEnvironment.DeleteAll();

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Get('/applications/businesscentral/environments/' + EnvironmentName, JsonResponse) then
            Error(FailedToFetchErr, Format(JsonResponse));

        BCEnvironment.Init();
        BCEnvironment."Customer No." := BCTenant."Customer No.";
        BCEnvironment."Tenant ID" := BCTenant."Tenant ID";

        JsonObject := JsonResponse;
        FillEnvironmentFromJsonObject(BCEnvironment, JsonObject);
        BCEnvironment.Insert();
    end;

    local procedure FillEnvironmentFromJsonObject(var BCEnvironment: Record "D4P BC Environment"; JsonObject: JsonObject)
    var
        JsonTokenField: JsonToken;
        JsonValue: JsonValue;
        JsonVersionDetails: JsonObject;
    begin
        if JsonObject.Get('name', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment.Name := JsonValue.AsText();
        end;
        if JsonObject.Get('applicationFamily', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Application Family" := JsonValue.AsText();
        end;
        if JsonObject.Get('type', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment.Type := JsonValue.AsText();
        end;
        if JsonObject.Get('status', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment.State := JsonValue.AsText();
        end;
        if JsonObject.Get('countryCode', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Country/Region" := JsonValue.AsText();
        end;
        if JsonObject.Get('applicationVersion', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Current Version" := JsonValue.AsText();
        end;
        if JsonObject.Get('friendlyName', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Friendly Name" := JsonValue.AsText();
        end;
        if JsonObject.Get('aadTenantId', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            if not Evaluate(BCEnvironment."AAD Tenant ID", JsonValue.AsText()) then
                BCEnvironment."AAD Tenant ID" := CreateGuid(); // Fallback if evaluation fails
        end;
        if JsonObject.Get('webClientLoginUrl', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Web Client Login URL" := JsonValue.AsText();
        end;
        if JsonObject.Get('webServiceUrl', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Web Service URL" := JsonValue.AsText();
        end;
        if JsonObject.Get('locationName', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Location Name" := JsonValue.AsText();
        end;
        if JsonObject.Get('geoName', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Geo Name" := JsonValue.AsText();
        end;
        if JsonObject.Get('ringName', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Ring Name" := JsonValue.AsText();
        end;
        if JsonObject.Get('appInsightsKey', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Application Insights String" := JsonValue.AsText();
        end;
        if JsonObject.Get('SoftDeletedOn', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            if not Evaluate(BCEnvironment."Soft Deleted On", JsonValue.AsText()) then
                BCEnvironment."Soft Deleted On" := 0DT; // Clear if evaluation fails
        end;
        if JsonObject.Get('HardDeletePendingOn', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            if not Evaluate(BCEnvironment."Hard Delete Pending On", JsonValue.AsText()) then
                BCEnvironment."Hard Delete Pending On" := 0DT; // Clear if evaluation fails
        end;
        if JsonObject.Get('DeleteReason', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Delete Reason" := JsonValue.AsText();
        end;
        if JsonObject.Get('appSourceAppsUpdateCadence', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."AppSource Apps Update Cadence" := JsonValue.AsText();
        end;
        if JsonObject.Get('platformVersion', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Platform Version" := JsonValue.AsText();
        end;
        if JsonObject.Get('linkedPowerPlatformEnvironmentId', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            BCEnvironment."Linked PowerPlatform Env ID" := JsonValue.AsText();
        end;
        // Handle nested versionDetails object
        if JsonObject.Get('versionDetails', JsonTokenField) then
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
    end;

    procedure GetAllInstalledApps(ShowProgressDialog: Boolean)
    var
        BCEnvironment: Record "D4P BC Environment";
        ProgressDialog: Dialog;
        TotalCount, ProcessedCount : Integer;
        ProcessingMsg: Label 'Processing environment #1#### of #2#### @3@@@@@@@@@@@@@@@@@@@@@@@@', Comment = '%1 - Processed count, %2 - Total count, %3 - Percentage complete';
    begin
        BCEnvironment.SetRange("State", 'Active');

        if not BCEnvironment.FindSet() then
            exit;

        TotalCount := BCEnvironment.Count();
        if ShowProgressDialog and GuiAllowed then begin
            ProgressDialog.Open(ProcessingMsg);
            ProgressDialog.Update(2, TotalCount);
        end;
        repeat
            if ShowProgressDialog and GuiAllowed then begin
                ProcessedCount += 1;
                ProgressDialog.Update(1, ProcessedCount);
                ProgressDialog.Update(3, Round(ProcessedCount / TotalCount * 10000, 1));
            end;
            GetInstalledApps(BCEnvironment);
        until BCEnvironment.Next() = 0;

        if ShowProgressDialog and GuiAllowed then
            ProgressDialog.Close();
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
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1', Comment = '%1 = Error message';
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        InstalledApp.SetRange("Customer No.", BCTenant."Customer No.");
        InstalledApp.SetRange("Tenant ID", BCTenant."Tenant ID");
        InstalledApp.SetRange("Environment Name", BCEnvironment.Name);
        InstalledApp.DeleteAll();

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Get(
            '/applications/businesscentral/environments/' + BCEnvironment.Name + '/apps', JsonResponse) then
            Error(FailedToFetchErr, Format(JsonResponse));

        if JsonResponse.Get('value', JsonToken) then begin
            JsonArray := JsonToken.AsArray();

            InstalledApp.Init();
            InstalledApp."Customer No." := BCTenant."Customer No.";
            InstalledApp."Tenant ID" := BCTenant."Tenant ID";
            InstalledApp."Environment Name" := BCEnvironment.Name;
            InstalledApp."Environment Type" := BCEnvironment.Type;

            foreach JsonTokenLoop in JsonArray do begin
                JsonObjectLoop := JsonTokenLoop.AsObject();
                FillInstalledAppFromJsonObject(InstalledApp, JsonObjectLoop);
                InstalledApp.Insert();
            end;
        end;
    end;

    procedure GetInstalledApp(var BCEnvironment: Record "D4P BC Environment"; AppId: Guid)
    var
        InstalledApp: Record "D4P BC Installed App";
        BCTenant: Record "D4P BC Tenant";
        JsonObject: JsonObject;
        JsonResponse: JsonObject;
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1', Comment = '%1 = Error message';
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        InstalledApp.SetRange("Customer No.", BCTenant."Customer No.");
        InstalledApp.SetRange("Tenant ID", BCTenant."Tenant ID");
        InstalledApp.SetRange("Environment Name", BCEnvironment.Name);
        InstalledApp.DeleteAll();

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Get(
            '/applications/businesscentral/environments/' + BCEnvironment.Name + '/apps/' + Format(AppId), JsonResponse) then
            Error(FailedToFetchErr, Format(JsonResponse));

        InstalledApp.Init();
        InstalledApp."Customer No." := BCTenant."Customer No.";
        InstalledApp."Tenant ID" := BCTenant."Tenant ID";
        InstalledApp."Environment Name" := BCEnvironment.Name;
        InstalledApp."Environment Type" := BCEnvironment.Type;

        JsonObject := JsonResponse;
        FillInstalledAppFromJsonObject(InstalledApp, JsonObject);
        InstalledApp.Insert();
    end;

    local procedure FillInstalledAppFromJsonObject(var InstalledApp: Record "D4P BC Installed App"; JsonObject: JsonObject)
    var
        JsonTokenField: JsonToken;
        JsonValue: JsonValue;
    begin
        if JsonObject.Get('id', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            InstalledApp."App ID" := JsonValue.AsText();
        end;
        if JsonObject.Get('name', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            InstalledApp."App Name" := JsonValue.AsText();
        end;
        if JsonObject.Get('publisher', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            InstalledApp."App Publisher" := JsonValue.AsText();
        end;
        if JsonObject.Get('version', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            InstalledApp."App Version" := JsonValue.AsText();
        end;
        if JsonObject.Get('state', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
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
        if JsonObject.Get('appType', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            case LowerCase(JsonValue.AsText()) of
                'global':
                    InstalledApp."App Type" := Enum::"D4P App Type"::Global;
                'pte', 'tenant':
                    InstalledApp."App Type" := Enum::"D4P App Type"::PTE;
                'dev':
                    InstalledApp."App Type" := Enum::"D4P App Type"::DEV;
                else
                    InstalledApp."App Type" := Enum::"D4P App Type"::" ";
            end;
        end;
        if JsonObject.Get('lastOperationId', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
            InstalledApp."Last Operation Id" := JsonValue.AsText();
        end;
        if JsonObject.Get('lastUpdateAttemptResult', JsonTokenField) then begin
            JsonValue := JsonTokenField.AsValue();
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
        FailedToFetchErr: Label 'Failed to fetch environment updates: %1', Comment = '%1 = Error message';
        NoAvailableUpdatesMsg: Label 'No available updates found for the selected environment.';
        NoSelectedUpdateMsg: Label 'No selected update found for the selected environment.';
        SelectedUpdateVersionFetchedMsg: Label 'Selected update version %1 has been fetched successfully.', Comment = '%1 = Version number';
        Endpoint: Text;
        expectedAvailability: Text;
        rolloutStatus: Text;
        targetVersion: Text;
        targetVersionType: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Call Admin API to get environment updates
        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/updates';
        AdminAPIClient.SetTenant(BCTenant);
        if AdminAPIClient.Get(Endpoint, JsonResponse) then begin
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
                Error(FailedToFetchErr, Format(JsonResponse));
    end;

    procedure GetAllAvailableAppUpdates(ShowProgressDialog: Boolean)
    var
        BCEnvironment: Record "D4P BC Environment";
        ProgressDialog: Dialog;
        TotalCount, ProcessedCount : Integer;
        ProcessingMsg: Label 'Processing environment #1#### of #2#### @3@@@@@@@@@@@@@@@@@@@@@@@@', Comment = '%1 - Processed count, %2 - Total count, %3 - Percentage complete';
    begin
        BCEnvironment.SetRange("State", 'Active');
        if not BCEnvironment.FindSet() then
            exit;

        if ShowProgressDialog and GuiAllowed then begin
            TotalCount := BCEnvironment.Count();
            ProgressDialog.Open(ProcessingMsg);
            ProgressDialog.Update(2, TotalCount);
        end;

        repeat
            if ShowProgressDialog and GuiAllowed then begin
                ProcessedCount += 1;
                ProgressDialog.Update(1, ProcessedCount);
                ProgressDialog.Update(3, Round(ProcessedCount / TotalCount * 10000, 1));
            end;
            GetAvailableAppUpdates(BCEnvironment, false);
        until BCEnvironment.Next() = 0;

        if ShowProgressDialog and GuiAllowed then
            ProgressDialog.Close();
    end;

    procedure GetAvailableAppUpdates(var BCEnvironment: Record "D4P BC Environment"; ShowMessage: Boolean)
    var
        BCTenant: Record "D4P BC Tenant";
        JsonArray: JsonArray;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        AvailableUpdatesFetchedMsg: Label 'Available updates for the selected environment have been fetched successfully.';
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1', Comment = '%1 = Error message';
        NoAvailableUpdatesMsg: Label 'No available updates found for the selected environment.';
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Get(
            '/applications/businesscentral/environments/' + BCEnvironment.Name + '/apps/availableUpdates', JsonResponse) then
            Error(FailedToFetchErr, Format(JsonResponse));

        if JsonResponse.Get('value', JsonToken) then begin
            JsonArray := JsonToken.AsArray();

            foreach JsonTokenLoop in JsonArray do begin
                JsonObjectLoop := JsonTokenLoop.AsObject();
                FillAvailableUpdateVersionFromJsonObject(BCTenant, BCEnvironment, JsonObjectLoop);
            end;
            if ShowMessage and GuiAllowed then
                Message(AvailableUpdatesFetchedMsg);
        end else
            if ShowMessage and GuiAllowed then
                Message(NoAvailableUpdatesMsg);
    end;

    procedure GetAvailableAppUpdate(var BCEnvironment: Record "D4P BC Environment"; AppID: Guid; ShowMessage: Boolean)
    var
        BCTenant: Record "D4P BC Tenant";
        JsonArray: JsonArray;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        AvailableUpdatesFetchedMsg: Label 'Available updates for the selected environment have been fetched successfully.';
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1', Comment = '%1 = Error message';
        NoAvailableUpdatesMsg: Label 'No available updates found for the selected environment.';
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Get(
            '/applications/businesscentral/environments/' + BCEnvironment.Name + '/apps/' + Format(AppID) + '/availableUpdates', JsonResponse) then
            Error(FailedToFetchErr, Format(JsonResponse));

        if JsonResponse.Get('value', JsonToken) then begin
            JsonArray := JsonToken.AsArray();

            foreach JsonTokenLoop in JsonArray do begin
                JsonObjectLoop := JsonTokenLoop.AsObject();
                FillAvailableUpdateVersionFromJsonObject(BCTenant, BCEnvironment, JsonObjectLoop);
            end;
            if ShowMessage and GuiAllowed then
                Message(AvailableUpdatesFetchedMsg);
        end else
            if ShowMessage and GuiAllowed then
                Message(NoAvailableUpdatesMsg);
    end;

    local procedure FillAvailableUpdateVersionFromJsonObject(BCTenant: Record "D4P BC Tenant"; BCEnvironment: Record "D4P BC Environment"; JsonObject: JsonObject)
    var
        InstalledApp: Record "D4P BC Installed App";
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        appId: Guid;
        appVersion: Text;
    begin
        if JsonObject.Get('appId', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            appId := JsonValue.AsText();
        end;
        // if JsonObject.Get('name', JsonToken) then begin
        //     JsonValue := JsonToken.AsValue();
        //     appName := JsonValue.AsText();
        // end;
        // if JsonObject.Get('publisher', JsonToken) then begin
        //     JsonValue := JsonToken.AsValue();
        //     appPublisher := JsonValue.AsText();
        // end;
        if JsonObject.Get('version', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            appVersion := JsonValue.AsText();
        end;
        //Update the app entry
        if InstalledApp.Get(BCTenant."Customer No.", BCTenant."Tenant ID", BCEnvironment.Name, appId) then begin
            InstalledApp."Available Update Version" := appVersion;
            InstalledApp.Modify();
        end;
    end;

    procedure UpdateApp(var BCEnvironment: Record "D4P BC Environment"; AppId: Guid; showNotification: Boolean)
    var
        InstalledApp: Record "D4P BC Installed App";
        BCTenant: Record "D4P BC Tenant";
        AppUpdateNotification: Notification;
        JsonObject: JsonObject;
        AppNotFoundErr: Label 'App not found';
        AppUpdateScheduledMsg: Label 'App %1 update to version %2 successfully scheduled.', Comment = '%1 = App Name, %2 = Version';
        FailedToUpdateErr: Label 'Failed to update app: %1', Comment = '%1 = Error message';
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

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Post(
            '/applications/businesscentral/environments/' + BCEnvironment.Name + '/apps/' + Format(AppId) + '/update',
            JsonObject, ResponseText)
        then
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
        EnvironmentCreatedMsg: Label 'New environment %1 successfully created.', Comment = '%1 = Environment Name';
        FailedToCreateErr: Label 'Failed to create new environment: %1', Comment = '%1 = Error message';
        ResponseText: Text;
    begin
        JsonObject.Add('environmentType', Format(EnvironmentType));
        JsonObject.Add('countryCode', Localization);

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Put(
            '/applications/businesscentral/environments/' + EnvironmentName,
            JsonObject, ResponseText)
        then
            Error(FailedToCreateErr, ResponseText);

        Message(EnvironmentCreatedMsg, EnvironmentName);
    end;

    procedure CopyBCEnvironment(var BCTenant: Record "D4P BC Tenant"; SourceEnvironmentName: Text[100]; NewEnvironmentName: Text[100]; NewEnvironmentType: Enum "D4P Environment Type")
    var
        JsonObject: JsonObject;
        CopyEnvironmentScheduledMsg: Label 'Copy environment %1 to %2 successfully scheduled.', Comment = '%1 = Source Environment Name, %2 = Target Environment Name';
        FailedToCreateErr: Label 'Failed to create new environment: %1', Comment = '%1 = Error message';
        ResponseText: Text;
    begin
        JsonObject.Add('environmentName', NewEnvironmentName);
        JsonObject.Add('type', Format(NewEnvironmentType));

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Post(
            '/applications/businesscentral/environments/' + SourceEnvironmentName + '/copy',
            JsonObject, ResponseText)
        then
            Error(FailedToCreateErr, ResponseText);

        Message(CopyEnvironmentScheduledMsg, SourceEnvironmentName, NewEnvironmentName);
    end;

    procedure RenameBCEnvironment(var BCTenant: Record "D4P BC Tenant"; SourceEnvironmentName: Text[100]; NewEnvironmentName: Text[100])
    var
        JsonObject: JsonObject;
        EnvironmentRenamedMsg: Label 'Environment %1 successfully renamed to %2.', Comment = '%1 = Old Environment Name, %2 = New Environment Name';
        FailedToRenameErr: Label 'Failed to rename environment: %1', Comment = '%1 = Error message';
        ResponseText: Text;
    begin
        JsonObject.Add('NewEnvironmentName', NewEnvironmentName);

        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Post(
            '/applications/businesscentral/environments/' + SourceEnvironmentName + '/rename/',
            JsonObject, ResponseText)
        then
            Error(FailedToRenameErr, ResponseText);

        Message(EnvironmentRenamedMsg, SourceEnvironmentName, NewEnvironmentName);
    end;

    procedure DeleteBCEnvironment(var BCTenant: Record "D4P BC Tenant"; EnvironmentName: Text[100])
    var
        EnvironmentMarkedForDeletionMsg: Label 'Environment %1 successfully marked for deletion.', Comment = '%1 = Environment Name';
        FailedToDeleteErr: Label 'Failed to delete environment: %1', Comment = '%1 = Error message';
        ResponseText: Text;
    begin
        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Delete(
            '/applications/businesscentral/environments/' + EnvironmentName, ResponseText) then
            Error(FailedToDeleteErr, ResponseText);

        Message(EnvironmentMarkedForDeletionMsg, EnvironmentName);
    end;

    procedure GetAvailableUpdates(var BCEnvironment: Record "D4P BC Environment"; var TempAvailableUpdate: Record "D4P BC Available Update" temporary)
    var
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
        FailedToFetchErr: Label 'Failed to fetch available updates: %1', Comment = '%1 = Error message';
        FetchingUpdatesMsg: Label 'Fetching available updates...';
        NoUpdatesFoundMsg: Label 'No updates found in API response for environment %1.', Comment = '%1 = Environment Name';
        ProcessingUpdateMsg: Label 'Processing update #1#### of #2####: #3####################', Comment = '%1 = index, %2 = total number of updates, %3 = Progress bar';
        Endpoint: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");
        TempAvailableUpdate.Reset();
        TempAvailableUpdate.DeleteAll();

        // Show progress dialog
        ProgressDialog.Open(FetchingUpdatesMsg);

        // Call Admin API to get available updates
        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/updates';
        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Get(Endpoint, JsonResponse) then begin
            ProgressDialog.Close();
            Error(FailedToFetchErr, Format(JsonResponse));
        end;

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
        FailedToSelectErr: Label 'Failed to select target version: %1', Comment = '%1 = Error message';
        UpdateScheduledMsg: Label 'Update to version %1 successfully scheduled for %2.', Comment = '%1 = Version, %2 = Date';
        UpdateSelectedMsg: Label 'Update to version %1 successfully selected. Expected availability: %2/%3.', Comment = '%1 = Version, %2 = Month, %3 = Year';
        Endpoint: Text;
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

        // Debug mode: Show request body
        if BCSetup."Debug Mode" then
            Message('DEBUG - Select Target Version Request:\Target Version: %1\Request Body: %2', TargetVersion, Format(JsonObject));

        // Call Admin API to select target version
        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/updates/' + TargetVersion;
        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Patch(Endpoint, JsonObject, ResponseText) then
            Error(FailedToSelectErr, ResponseText);

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

    procedure SetApplicationInsightsConnectionString(var BCEnvironment: Record "D4P BC Environment")
    var
        BCTenant: Record "D4P BC Tenant";
        IsRemoving: Boolean;
        JsonObject: JsonObject;
        ConnectionStringRemovedMsg: Label 'Application Insights connection string successfully removed for environment %1.', Comment = '%1 = Environment Name';
        ConnectionStringSetMsg: Label 'Application Insights connection string successfully set for environment %1.', Comment = '%1 = Environment Name';
        FailedToSetKeyErr: Label 'Failed to set Application Insights key: %1', Comment = '%1 = Error message';
        Endpoint: Text;
        ResponseText: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Determine if we're removing (empty string) or setting the key
        IsRemoving := (BCEnvironment."Application Insights String" = '');

        // Create JSON request body
        JsonObject.Add('key', BCEnvironment."Application Insights String");

        // Call Admin API to set Application Insights key
        Endpoint := '/applications/businesscentral/environments/' + BCEnvironment.Name + '/settings/appinsightskey';
        AdminAPIClient.SetTenant(BCTenant);
        if AdminAPIClient.Post(Endpoint, JsonObject, ResponseText) then begin
            if IsRemoving then
                Message(ConnectionStringRemovedMsg, BCEnvironment.Name)
            else
                Message(ConnectionStringSetMsg, BCEnvironment.Name);
        end else
            Error(FailedToSetKeyErr, ResponseText);
    end;
}