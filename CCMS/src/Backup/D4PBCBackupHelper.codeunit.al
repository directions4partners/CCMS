namespace D4P.CCMS.Backup;

using D4P.CCMS.Connector;
using D4P.CCMS.Environment;
using D4P.CCMS.Tenant;

codeunit 62015 "D4P BC Backup Helper"
{
    procedure StartEnvironmentDatabaseExport(var BCEnvironment: Record "D4P BC Environment")
    var
        BCTenant: Record "D4P BC Tenant";
        EnvironmentAccess: Codeunit "D4P BC Environment Access";
        JsonObject: JsonObject;
        ConfirmMsg: Label 'You are about to start a database export with the following settings:\\ Environment: %1\ Container: %2\ Blob File: %3\\These settings CANNOT be changed after the export starts.\\Do you want to continue?', Comment = '%1 = Environment Name, %2 = Container Name, %3 = Blob Name';
        ExportStartedMsg: Label 'Database export for environment %1 successfully started.\Blob: %2', Comment = '%1 = Environment Name, %2 = Blob Name';
        FailedExportErr: Label 'Failed to start database export: %1', Comment = '%1 = Error message';
        NoContainerErr: Label 'Backup Container Name is not configured for this tenant. Please configure it in the tenant settings before starting a database export.';
        NoSASURIErr: Label 'Backup SAS URI is not configured for this tenant. Please configure it in the tenant settings before starting a database export.';
        NotProductionErr: Label 'Database exports can only be created from Production environments.\ Environment "%1" is of type "%2".\ Please select a Production environment to perform a database export.', Comment = '%1 = Environment Name, %2 = Environment Type';
        BlobName: Text;
        ResponseText: Text;
    begin
        // Validate environment is Production
        if BCEnvironment.Type <> 'Production' then
            Error(NotProductionErr, BCEnvironment.Name, BCEnvironment.Type);

        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");
        EnvironmentAccess.CheckCanManage(BCTenant, BCEnvironment.Name);

        // Validate that SAS URI and Container Name are configured
        if BCTenant."Backup SAS URI" = '' then
            Error(NoSASURIErr);

        if BCTenant."Backup Container Name" = '' then
            Error(NoContainerErr);

        // Generate blob name with timestamp
        BlobName := StrSubstNo('%1_%2.bacpac', BCEnvironment.Name, Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hours24><Minutes,2><Seconds,2>'));

        // Show confirmation with storage details
        if not Confirm(ConfirmMsg, false, BCEnvironment.Name, BCTenant."Backup Container Name", BlobName) then
            exit;

        // Create JSON request body
        JsonObject.Add('storageAccountSasUri', BCTenant."Backup SAS URI");
        JsonObject.Add('container', BCTenant."Backup Container Name");
        JsonObject.Add('blob', BlobName);

        // Send API request
        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Post(
            StrSubstNo('/exports/applications/businesscentral/environments/%1', BCEnvironment.Name),
            JsonObject, ResponseText)
        then
            Error(FailedExportErr, ResponseText);

        Message(ExportStartedMsg, BCEnvironment.Name, BlobName);
    end;

    procedure GetExportMetrics(var BCEnvironment: Record "D4P BC Environment")
    var
        BCTenant: Record "D4P BC Tenant";
        ExportsPerMonth: Integer;
        ExportsRemaining: Integer;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        FailedMetricsErr: Label 'Failed to get export metrics: %1', Comment = '%1 = Error message';
        MetricsMsg: Label 'Export Metrics for %1:\Exports Per Month: %2\Exports Remaining This Month: %3', Comment = '%1 = Environment Name, %2 = Exports Per Month, %3 = Exports Remaining';
    begin
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Send API request
        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Get(
            StrSubstNo('/exports/applications/businesscentral/environments/%1/metrics', BCEnvironment.Name),
            JsonResponse)
        then
            Error(FailedMetricsErr, Format(JsonResponse));

        // Parse response
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
    end;

    procedure GetExportHistory(var BCEnvironment: Record "D4P BC Environment"; StartTime: DateTime; EndTime: DateTime)
    var
        BCBackup: Record "D4P BC Environment Backup";
        BCTenant: Record "D4P BC Tenant";
        InsertedCount: Integer;
        JsonArray: JsonArray;
        JsonObjectLoop: JsonObject;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        JsonValue: JsonValue;
        FailedHistoryErr: Label 'Failed to get export history: %1', Comment = '%1 = Error message';
        HistorySuccessMsg: Label 'Export history retrieved successfully. Found %1 export(s) for %2.', Comment = '%1 = Number of exports, %2 = Environment Name';
        EndTimeText: Text;
        StartTimeText: Text;
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
        AdminAPIClient.SetTenant(BCTenant);
        if not AdminAPIClient.Get(
            StrSubstNo('/exports/applications/businesscentral/environments/%1/history?start=%2&end=%3', BCEnvironment.Name, StartTimeText, EndTimeText),
            JsonResponse)
        then
            Error(FailedHistoryErr, Format(JsonResponse));

        // Parse response and populate backup records
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
    end;

    var
        AdminAPIClient: Codeunit D4PBCAdminAPIClient;
}
