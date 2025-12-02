namespace D4P.CCMS.Backup;

using System.Security.Authentication;
using D4P.CCMS.Environment;
using D4P.CCMS.Tenant;
using D4P.CCMS.Setup;
using D4P.CCMS.General;

codeunit 62015 "D4P BC Backup Helper"
{
    procedure StartEnvironmentDatabaseExport(var BCEnvironment: Record "D4P BC Environment")
    var
        BCTenant: Record "D4P BC Tenant";
        JsonObject: JsonObject;
        ResponseText: Text;
        BlobName: Text;
        ConfirmMsg: Label 'You are about to start a database export with the following settings:\\ Environment: %1\ Container: %2\ Blob File: %3\\These settings CANNOT be changed after the export starts.\\Do you want to continue?';
        NoSASURIErr: Label 'Backup SAS URI is not configured for this tenant. Please configure it in the tenant settings before starting a database export.';
        NoContainerErr: Label 'Backup Container Name is not configured for this tenant. Please configure it in the tenant settings before starting a database export.';
        NotProductionErr: Label 'Database exports can only be created from Production environments.\ Environment "%1" is of type "%2".\ Please select a Production environment to perform a database export.';
        FailedExportErr: Label 'Failed to start database export: %1';
        ExportStartedMsg: Label 'Database export for environment %1 successfully started.\Blob: %2';
    begin
        // Validate environment is Production
        if BCEnvironment.Type <> 'Production' then
            Error(NotProductionErr, BCEnvironment.Name, BCEnvironment.Type);

        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Validate that SAS URI and Container Name are configured
        if BCTenant."Backup SAS URI" = '' then
            Error(NoSASURIErr);

        if BCTenant."Backup Container Name" = '' then
            Error(NoContainerErr);

        // Generate blob name with timestamp
        BlobName := StrSubstNo('%1_%2.bacpac', BCEnvironment.Name, Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hours24><Minutes,2><Seconds,2>'));

        // Show confirmation with storage details
        if not Confirm(ConfirmMsg, false, BCEnvironment.Name, BCTenant."Backup Container Name", BlobName) then
            exit;

        // Create JSON request body
        JsonObject.Add('storageAccountSasUri', BCTenant."Backup SAS URI");
        JsonObject.Add('container', BCTenant."Backup Container Name");
        JsonObject.Add('blob', BlobName);

        // Send API request
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'POST',
            StrSubstNo('/exports/applications/businesscentral/environments/%1', BCEnvironment.Name),
            Format(JsonObject), ResponseText) then
            Error(FailedExportErr, ResponseText);

        Message(ExportStartedMsg, BCEnvironment.Name, BlobName);
    end;

    procedure GetExportMetrics(var BCEnvironment: Record "D4P BC Environment")
    var
        BCTenant: Record "D4P BC Tenant";
        ResponseText: Text;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        ExportsPerMonth: Integer;
        ExportsRemaining: Integer;
        FailedMetricsErr: Label 'Failed to get export metrics: %1';
        MetricsMsg: Label 'Export Metrics for %1:\Exports Per Month: %2\Exports Remaining This Month: %3';
        ParseMetricsErr: Label 'Failed to parse export metrics response.';
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Send API request
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET',
            StrSubstNo('/exports/applications/businesscentral/environments/%1/metrics', BCEnvironment.Name),
            '', ResponseText) then
            Error(FailedMetricsErr, ResponseText);

        // Parse response
        if JsonResponse.ReadFrom(ResponseText) then begin
            if JsonResponse.Get('exportsPerMonth', JsonToken) then begin
                JsonValue := JsonToken.AsValue();
                ExportsPerMonth := JsonValue.AsInteger();
            end;

            if JsonResponse.Get('exportsRemainingThisMonth', JsonToken) then begin
                JsonValue := JsonToken.AsValue();
                ExportsRemaining := JsonValue.AsInteger();
            end;

            Message(MetricsMsg,
                BCEnvironment.Name, ExportsPerMonth, ExportsRemaining);
        end else
            Error(ParseMetricsErr);
    end;

    procedure GetExportHistory(var BCEnvironment: Record "D4P BC Environment"; StartTime: DateTime; EndTime: DateTime)
    var
        BCTenant: Record "D4P BC Tenant";
        ResponseText: Text;
        JsonResponse: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        JsonObjectLoop: JsonObject;
        JsonValue: JsonValue;
        BCBackup: Record "D4P BC Environment Backup";
        StartTimeText: Text;
        EndTimeText: Text;
        InsertedCount: Integer;
        FailedHistoryErr: Label 'Failed to get export history: %1';
        HistorySuccessMsg: Label 'Export history retrieved successfully. Found %1 export(s) for %2.';
        ParseHistoryErr: Label 'Failed to parse export history response.';
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Format datetime parameters for URL
        StartTimeText := Format(StartTime, 0, 9); // ISO 8601 format
        EndTimeText := Format(EndTime, 0, 9); // ISO 8601 format

        // Clear existing records for this environment BEFORE getting new data
        BCBackup.SetRange("Customer No.", BCEnvironment."Customer No.");
        BCBackup.SetRange("Tenant ID", Format(BCEnvironment."Tenant ID"));
        BCBackup.SetRange("Environment Name", BCEnvironment.Name);
        BCBackup.DeleteAll();

        // Send API request
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET',
            '/exports/history?start=' + StartTimeText + '&end=' + EndTimeText,
            '', ResponseText) then
            Error(FailedHistoryErr, ResponseText);

        // Parse response and populate backup records
        if JsonResponse.ReadFrom(ResponseText) then begin
            if JsonResponse.Get('value', JsonToken) then begin
                JsonArray := JsonToken.AsArray();

                foreach JsonTokenLoop in JsonArray do begin
                    JsonObjectLoop := JsonTokenLoop.AsObject();
                    BCBackup.Init();
                    BCBackup."Customer No." := BCEnvironment."Customer No.";
                    BCBackup."Tenant ID" := Format(BCEnvironment."Tenant ID");

                    if JsonObjectLoop.Get('environmentName', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        BCBackup."Environment Name" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCBackup."Environment Name"));
                    end;

                    // Skip exports from other environments
                    if BCBackup."Environment Name" <> BCEnvironment.Name then
                        continue;

                    if JsonObjectLoop.Get('applicationType', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        BCBackup."Application Type" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCBackup."Application Type"));
                    end;

                    if JsonObjectLoop.Get('applicationVersion', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        BCBackup."Application Version" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCBackup."Application Version"));
                    end;

                    if JsonObjectLoop.Get('country', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        BCBackup."Country Code" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCBackup."Country Code"));
                    end;

                    if JsonObjectLoop.Get('time', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        if Evaluate(BCBackup."Export Time", JsonValue.AsText()) then;
                    end;

                    if JsonObjectLoop.Get('storageAccount', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        BCBackup."Storage Account" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCBackup."Storage Account"));
                    end;

                    if JsonObjectLoop.Get('container', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        BCBackup."Container" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCBackup."Container"));
                    end;

                    if JsonObjectLoop.Get('blob', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        BCBackup."Blob" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCBackup."Blob"));
                    end;

                    if JsonObjectLoop.Get('user', JsonToken) then begin
                        JsonValue := JsonToken.AsValue();
                        BCBackup."Exported By" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCBackup."Exported By"));
                    end;

                    // Use blob name as unique Export ID (it's already unique per export)
                    BCBackup."Export ID" := CopyStr(BCBackup."Blob", 1, MaxStrLen(BCBackup."Export ID"));

                    BCBackup."Export Status" := Enum::"D4P Export Status"::Completed;

                    BCBackup.Insert(true);
                    InsertedCount += 1;
                end;

                Message(HistorySuccessMsg, InsertedCount, BCEnvironment.Name);
            end;
        end else
            Error(ParseHistoryErr);
    end;

    var
        APIHelper: Codeunit "D4P BC API Helper";
}
