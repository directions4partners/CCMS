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
        JsonTokenLoop: JsonToken;
        TextValue: Text;
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1', Comment = '%1 = Error message';
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
                if GetJsonText(JsonObjectLoop, 'name', TextValue) then
                    BCEnvironment.Name := TextValue;
                if GetJsonText(JsonObjectLoop, 'applicationFamily', TextValue) then
                    BCEnvironment."Application Family" := TextValue;
                if GetJsonText(JsonObjectLoop, 'type', TextValue) then
                    BCEnvironment.Type := TextValue;
                if GetJsonText(JsonObjectLoop, 'status', TextValue) then
                    BCEnvironment.State := TextValue;
                if GetJsonText(JsonObjectLoop, 'countryCode', TextValue) then
                    BCEnvironment."Country/Region" := TextValue;
                if GetJsonText(JsonObjectLoop, 'applicationVersion', TextValue) then
                    BCEnvironment."Current Version" := TextValue;
                if GetJsonText(JsonObjectLoop, 'friendlyName', TextValue) then
                    BCEnvironment."Friendly Name" := TextValue;
                if GetJsonText(JsonObjectLoop, 'aadTenantId', TextValue) then
                    if not Evaluate(BCEnvironment."AAD Tenant ID", TextValue) then
                        BCEnvironment."AAD Tenant ID" := CreateGuid();
                if GetJsonText(JsonObjectLoop, 'webClientLoginUrl', TextValue) then
                    BCEnvironment."Web Client Login URL" := TextValue;
                if GetJsonText(JsonObjectLoop, 'webServiceUrl', TextValue) then
                    BCEnvironment."Web Service URL" := TextValue;
                if GetJsonText(JsonObjectLoop, 'locationName', TextValue) then
                    BCEnvironment."Location Name" := TextValue;
                if GetJsonText(JsonObjectLoop, 'geoName', TextValue) then
                    BCEnvironment."Geo Name" := TextValue;
                if GetJsonText(JsonObjectLoop, 'ringName', TextValue) then
                    BCEnvironment."Ring Name" := TextValue;
                if GetJsonText(JsonObjectLoop, 'appInsightsKey', TextValue) then
                    BCEnvironment."Application Insights String" := TextValue;
                if GetJsonText(JsonObjectLoop, 'SoftDeletedOn', TextValue) then
                    if not Evaluate(BCEnvironment."Soft Deleted On", TextValue) then
                        BCEnvironment."Soft Deleted On" := 0DT;
                if GetJsonText(JsonObjectLoop, 'HardDeletePendingOn', TextValue) then
                    if not Evaluate(BCEnvironment."Hard Delete Pending On", TextValue) then
                        BCEnvironment."Hard Delete Pending On" := 0DT;
                if GetJsonText(JsonObjectLoop, 'DeleteReason', TextValue) then
                    BCEnvironment."Delete Reason" := TextValue;
                if GetJsonText(JsonObjectLoop, 'appSourceAppsUpdateCadence', TextValue) then
                    BCEnvironment."AppSource Apps Update Cadence" := TextValue;
                if GetJsonText(JsonObjectLoop, 'platformVersion', TextValue) then
                    BCEnvironment."Platform Version" := TextValue;
                if GetJsonText(JsonObjectLoop, 'linkedPowerPlatformEnvironmentId', TextValue) then
                    BCEnvironment."Linked PowerPlatform Env ID" := TextValue;

                if GetJsonObject(JsonObjectLoop, 'versionDetails', JsonVersionDetails) then begin
                    if GetJsonText(JsonVersionDetails, 'gracePeriodStartDate', TextValue) then
                        if not Evaluate(BCEnvironment."Grace Period Start Date", TextValue) then
                            BCEnvironment."Grace Period Start Date" := 0DT;
                    if GetJsonText(JsonVersionDetails, 'enforcedUpdatePeriodStartDate', TextValue) then
                        if not Evaluate(BCEnvironment."Enforced Update Period Start", TextValue) then
                            BCEnvironment."Enforced Update Period Start" := 0DT;
                end;

                BCEnvironment.Insert();
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
        TextValue: Text;
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1', Comment = '%1 = Error message';
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
                if GetJsonText(JsonObjectLoop, 'id', TextValue) then
                    InstalledApp."App ID" := TextValue;
                if GetJsonText(JsonObjectLoop, 'name', TextValue) then
                    InstalledApp."App Name" := TextValue;
                if GetJsonText(JsonObjectLoop, 'publisher', TextValue) then
                    InstalledApp."App Publisher" := TextValue;
                if GetJsonText(JsonObjectLoop, 'version', TextValue) then
                    InstalledApp."App Version" := TextValue;
                if GetJsonText(JsonObjectLoop, 'state', TextValue) then
                    case TextValue of
                        'Installed':
                            InstalledApp.State := Enum::"D4P App State"::Installed;
                        'UpdatePending':
                            InstalledApp.State := Enum::"D4P App State"::"Update Pending";
                        'Updating':
                            InstalledApp.State := Enum::"D4P App State"::Updating;
                        else
                            InstalledApp.State := Enum::"D4P App State"::Installed;
                    end;
                if GetJsonText(JsonObjectLoop, 'appType', TextValue) then
                    case LowerCase(TextValue) of
                        'global':
                            InstalledApp."App Type" := Enum::"D4P App Type"::Global;
                        'pte', 'tenant':
                            InstalledApp."App Type" := Enum::"D4P App Type"::PTE;
                        'dev':
                            InstalledApp."App Type" := Enum::"D4P App Type"::DEV;
                        else
                            InstalledApp."App Type" := Enum::"D4P App Type"::" ";
                    end;
                if GetJsonText(JsonObjectLoop, 'lastOperationId', TextValue) then
                    InstalledApp."Last Operation Id" := TextValue;
                if GetJsonText(JsonObjectLoop, 'lastUpdateAttemptResult', TextValue) then
                    case TextValue of
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
        ParsedDate: Date;
        ParsedDateTime: DateTime;
        month: Integer;
        year: Integer;
        JsonArray: JsonArray;
        JsonExpectedAvailability: JsonObject;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonScheduleDetails: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        FailedToFetchErr: Label 'Failed to fetch environment updates: %1', Comment = '%1 = Error message';
        NoAvailableUpdatesMsg: Label 'No available updates found for the selected environment.';
        NoSelectedUpdateMsg: Label 'No selected update found for the selected environment.';
        SelectedUpdateVersionFetchedMsg: Label 'Selected update version %1 has been fetched successfully.', Comment = '%1 = Version number';
        Endpoint: Text;
        expectedAvailability: Text;
        ResponseText: Text;
        rolloutStatus: Text;
        targetVersion: Text;
        targetVersionType: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/updates';
        if APIHelper.SendAdminAPIRequest(BCTenant, 'GET', Endpoint, '', ResponseText) then begin
            JsonResponse.ReadFrom(ResponseText);

            if JsonResponse.Get('value', JsonToken) then begin
                JsonArray := JsonToken.AsArray();
                targetVersion := '';

                foreach JsonTokenLoop in JsonArray do begin
                    JsonObjectLoop := JsonTokenLoop.AsObject();

                    selected := false;
                    GetJsonBoolean(JsonObjectLoop, 'selected', selected);

                    if selected then begin
                        GetJsonText(JsonObjectLoop, 'targetVersion', targetVersion);
                        available := false;
                        GetJsonBoolean(JsonObjectLoop, 'available', available);
                        targetVersionType := '';
                        GetJsonText(JsonObjectLoop, 'targetVersionType', targetVersionType);

                        if GetJsonObject(JsonObjectLoop, 'scheduleDetails', JsonScheduleDetails) then begin
                            TryGetJsonDateTime(JsonScheduleDetails, 'selectedDateTime', selectedDateTime);

                            ParsedDateTime := 0DT;
                            if not TryGetJsonDateTime(JsonScheduleDetails, 'latestSelectableDateTime', ParsedDateTime) then begin
                                ParsedDate := 0D;
                                if TryGetJsonDate(JsonScheduleDetails, 'latestSelectableDate', ParsedDate) then
                                    ParsedDateTime := CreateDateTime(ParsedDate, 0T);
                            end;
                            latestSelectableDate := ParsedDateTime;

                            ignoreUpdateWindow := false;
                            GetJsonBoolean(JsonScheduleDetails, 'ignoreUpdateWindow', ignoreUpdateWindow);
                            rolloutStatus := '';
                            GetJsonText(JsonScheduleDetails, 'rolloutStatus', rolloutStatus);
                        end;

                        expectedAvailability := '';
                        if GetJsonObject(JsonObjectLoop, 'expectedAvailability', JsonExpectedAvailability) then begin
                            month := 0;
                            GetJsonInteger(JsonExpectedAvailability, 'month', month);
                            year := 0;
                            GetJsonInteger(JsonExpectedAvailability, 'year', year);
                            expectedAvailability := FormatExpectedAvailability(year, month);
                        end;
                    end;
                end;

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
        InstalledApp: Record "D4P BC Installed App";
        BCTenant: Record "D4P BC Tenant";
        appId: Guid;
        JsonArray: JsonArray;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        TextValue: Text;
        AvailableUpdatesFetchedMsg: Label 'Available updates for the selected environment have been fetched successfully.';
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1', Comment = '%1 = Error message';
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
                Clear(appId);
                Clear(appVersion);
                if GetJsonText(JsonObjectLoop, 'appId', TextValue) then
                    appId := TextValue;
                if GetJsonText(JsonObjectLoop, 'version', appVersion) then
                    if InstalledApp.Get(BCTenant."Customer No.", BCTenant."Tenant ID", BCEnvironment.Name, appId) then begin
                        InstalledApp."Available Update Version" := appVersion;
                        InstalledApp.Modify();
                    end;
            end;
            if ShowMessage and GuiAllowed then
                Message(AvailableUpdatesFetchedMsg);
        end
        else
            if ShowMessage and GuiAllowed then
                Message(NoAvailableUpdatesMsg);
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
        EnvironmentCreatedMsg: Label 'New environment %1 successfully created.', Comment = '%1 = Environment Name';
        FailedToCreateErr: Label 'Failed to create new environment: %1', Comment = '%1 = Error message';
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
        CopyEnvironmentScheduledMsg: Label 'Copy environment %1 to %2 successfully scheduled.', Comment = '%1 = Source Environment Name, %2 = Target Environment Name';
        FailedToCreateErr: Label 'Failed to create new environment: %1', Comment = '%1 = Error message';
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
        EnvironmentRenamedMsg: Label 'Environment %1 successfully renamed to %2.', Comment = '%1 = Old Environment Name, %2 = New Environment Name';
        FailedToRenameErr: Label 'Failed to rename environment: %1', Comment = '%1 = Error message';
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
        EnvironmentMarkedForDeletionMsg: Label 'Environment %1 successfully marked for deletion.', Comment = '%1 = Environment Name';
        FailedToDeleteErr: Label 'Failed to delete environment: %1', Comment = '%1 = Error message';
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
        ParsedDate: Date;
        ParsedDateTime: DateTime;
        JsonArray: JsonArray;
        JsonExpectedAvailability: JsonObject;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonScheduleDetails: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        TextValue: Text;
        FailedToFetchErr: Label 'Failed to fetch available updates: %1', Comment = '%1 = Error message';
        FetchingUpdatesMsg: Label 'Fetching available updates...';
        NoUpdatesFoundMsg: Label 'No updates found in API response for environment %1.', Comment = '%1 = Environment Name';
        ProcessingUpdateMsg: Label 'Processing update #1#### of #2####: #3####################', Comment = '%1 = index, %2 = total number of updates, %3 = Progress bar';
        Endpoint: Text;
        ResponseText: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");
        BCSetup.Get();
        TempAvailableUpdate.Reset();
        TempAvailableUpdate.DeleteAll();

        ProgressDialog.Open(FetchingUpdatesMsg);

        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/updates';
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET', Endpoint, '', ResponseText) then begin
            ProgressDialog.Close();
            Error(FailedToFetchErr, ResponseText);
        end;

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

                ProgressDialog.Update(1, CurrentUpdate);
                ProgressDialog.Update(2, TotalUpdates);

                if GetJsonText(JsonObjectLoop, 'targetVersion', TextValue) then begin
                    TempAvailableUpdate."Target Version" := CopyStr(TextValue, 1, MaxStrLen(TempAvailableUpdate."Target Version"));
                    ProgressDialog.Update(3, TempAvailableUpdate."Target Version");
                end;

                GetJsonBoolean(JsonObjectLoop, 'available', TempAvailableUpdate.Available);
                GetJsonBoolean(JsonObjectLoop, 'selected', TempAvailableUpdate.Selected);

                if GetJsonText(JsonObjectLoop, 'targetVersionType', TextValue) then
                    TempAvailableUpdate."Target Version Type" := CopyStr(TextValue, 1, MaxStrLen(TempAvailableUpdate."Target Version Type"));

                if GetJsonObject(JsonObjectLoop, 'scheduleDetails', JsonScheduleDetails) then begin
                    ParsedDateTime := 0DT;
                    if TryGetJsonDateTime(JsonScheduleDetails, 'selectedDateTime', ParsedDateTime) then
                        TempAvailableUpdate."Selected DateTime" := DT2Date(ParsedDateTime);

                    ParsedDate := 0D;
                    if not TryGetJsonDate(JsonScheduleDetails, 'latestSelectableDateTime', ParsedDate) then
                        TryGetJsonDate(JsonScheduleDetails, 'latestSelectableDate', ParsedDate);
                    TempAvailableUpdate."Latest Selectable Date" := ParsedDate;

                    GetJsonBoolean(JsonScheduleDetails, 'ignoreUpdateWindow', TempAvailableUpdate."Ignore Update Window");

                    if GetJsonText(JsonScheduleDetails, 'rolloutStatus', TextValue) then
                        TempAvailableUpdate."Rollout Status" := CopyStr(TextValue, 1, MaxStrLen(TempAvailableUpdate."Rollout Status"));
                end;

                if GetJsonObject(JsonObjectLoop, 'expectedAvailability', JsonExpectedAvailability) then begin
                    GetJsonInteger(JsonExpectedAvailability, 'month', TempAvailableUpdate."Expected Month");
                    GetJsonInteger(JsonExpectedAvailability, 'year', TempAvailableUpdate."Expected Year");
                end;

                TempAvailableUpdate.Insert();
            end;

            ProgressDialog.Close();
        end else begin
            ProgressDialog.Close();
            Message(NoUpdatesFoundMsg, BCEnvironment.Name);
        end;
    end;

    internal procedure SelectTargetVersion(var BCEnvironment: Record "D4P BC Environment"; TargetVersion: Text[100]; SelectedDate: Date; ExpectedMonth: Integer; ExpectedYear: Integer; IgnoreUpdateWindow: Boolean)
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
        RequestBody: Text;
        ResponseText: Text;
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");
        BCSetup.Get();

        IsAvailable := (SelectedDate <> 0D);

        JsonObject.Add('selected', true);

        if IsAvailable then begin
            SelectedDateTime := CreateDateTime(SelectedDate, 0T);
            JsonScheduleDetails.Add('selectedDateTime', SelectedDateTime);
            JsonScheduleDetails.Add('ignoreUpdateWindow', IgnoreUpdateWindow);
            JsonObject.Add('scheduleDetails', JsonScheduleDetails);
        end;

        JsonObject.WriteTo(RequestBody);

        if BCSetup."Debug Mode" then
            Message('DEBUG - Select Target Version Request:\Target Version: %1\Request Body: %2', TargetVersion, RequestBody);

        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/updates/' + TargetVersion;
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'PATCH', Endpoint, RequestBody, ResponseText) then
            Error(FailedToSelectErr, ResponseText);

        if BCSetup."Debug Mode" then
            Message('DEBUG - Select Target Version Response:\%1', ResponseText);

        BCEnvironment."Target Version" := TargetVersion;
        BCEnvironment."Ignore Update Window" := IgnoreUpdateWindow;
        if IsAvailable then begin
            BCEnvironment."Selected DateTime" := SelectedDateTime;
            BCEnvironment."Expected Availability" := '';
            Message(UpdateScheduledMsg, TargetVersion, SelectedDate);
        end else begin
            BCEnvironment."Selected DateTime" := 0DT;
            BCEnvironment."Expected Availability" := FormatExpectedAvailability(ExpectedYear, ExpectedMonth);
            Message(UpdateSelectedMsg, TargetVersion, ExpectedMonth, ExpectedYear);
        end;
        BCEnvironment.Modify();
    end;

    procedure RescheduleBCEnvironmentUpgrade(var BCTenant: Record "D4P BC Tenant"; EnvironmentName: Text[100]; TargetVersion: Text[100]; UpgradeDate: DateTime)
    var
        EnvironmentUpgradeScheduledMsg: Label 'Environment %1 successfully scheduled for upgrade to version %2 on Date %3.', Comment = '%1 = Environment Name, %2 = Version, %3 = Date';
        FailedToUpgradeErr: Label 'Failed to upgrade environment: %1', Comment = '%1 = Error message';
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
        ConnectionStringRemovedMsg: Label 'Application Insights connection string successfully removed for environment %1.', Comment = '%1 = Environment Name';
        ConnectionStringSetMsg: Label 'Application Insights connection string successfully set for environment %1.', Comment = '%1 = Environment Name';
        FailedToSetKeyErr: Label 'Failed to set Application Insights key: %1', Comment = '%1 = Error message';
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

    local procedure GetJsonText(JsonObj: JsonObject; FieldName: Text; var Value: Text): Boolean
    var
        JsonToken: JsonToken;
        JsonValue: JsonValue;
    begin
        if not JsonObj.Get(FieldName, JsonToken) then
            exit(false);
        JsonValue := JsonToken.AsValue();
        if JsonValue.IsNull() then
            exit(false);
        Value := JsonValue.AsText();
        exit(true);
    end;

    local procedure GetJsonBoolean(JsonObj: JsonObject; FieldName: Text; var Value: Boolean): Boolean
    var
        JsonToken: JsonToken;
        JsonValue: JsonValue;
    begin
        if not JsonObj.Get(FieldName, JsonToken) then
            exit(false);
        JsonValue := JsonToken.AsValue();
        if JsonValue.IsNull() then
            exit(false);
        Value := JsonValue.AsBoolean();
        exit(true);
    end;

    local procedure GetJsonInteger(JsonObj: JsonObject; FieldName: Text; var Value: Integer): Boolean
    var
        JsonToken: JsonToken;
        JsonValue: JsonValue;
    begin
        if not JsonObj.Get(FieldName, JsonToken) then
            exit(false);
        JsonValue := JsonToken.AsValue();
        if JsonValue.IsNull() then
            exit(false);
        Value := JsonValue.AsInteger();
        exit(true);
    end;

    local procedure GetJsonObject(JsonObj: JsonObject; FieldName: Text; var ChildObj: JsonObject): Boolean
    var
        JsonToken: JsonToken;
    begin
        if not JsonObj.Get(FieldName, JsonToken) then
            exit(false);
        if not JsonToken.IsObject() then
            exit(false);
        ChildObj := JsonToken.AsObject();
        exit(true);
    end;

    local procedure FormatExpectedAvailability(Year: Integer; Month: Integer): Text
    begin
        exit(Format(Year) + '/' + PadStr('', 2 - StrLen(Format(Month)), '0') + Format(Month));
    end;

    internal procedure TryGetJsonDate(JsonObj: JsonObject; FieldName: Text; var ResultDate: Date): Boolean
    var
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        ResultDateTime: DateTime;
        TextValue: Text;
    begin
        ResultDate := 0D;
        if not JsonObj.Get(FieldName, JsonToken) then
            exit(false);
        JsonValue := JsonToken.AsValue();
        if JsonValue.IsNull() then
            exit(false);
        TextValue := JsonValue.AsText();
        if Evaluate(ResultDate, TextValue) then
            exit(true);
        ResultDateTime := 0DT;
        if Evaluate(ResultDateTime, TextValue) then begin
            ResultDate := DT2Date(ResultDateTime);
            exit(true);
        end;
        exit(false);
    end;

    internal procedure TryGetJsonDateTime(JsonObj: JsonObject; FieldName: Text; var ResultDateTime: DateTime): Boolean
    var
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        TextValue: Text;
    begin
        ResultDateTime := 0DT;
        if not JsonObj.Get(FieldName, JsonToken) then
            exit(false);
        JsonValue := JsonToken.AsValue();
        if JsonValue.IsNull() then
            exit(false);
        TextValue := JsonValue.AsText();
        exit(Evaluate(ResultDateTime, TextValue));
    end;
}