namespace D4P.CCMS.Telemetry;

codeunit 62031 "D4P KQL Query Store Init"
{
    Access = Internal;

    procedure InitializeKQLQueries()
    begin
        InitializePageExecutionQuery();
        InitializeReportExecutionQuery();
        InitializeSlowALMethodsQuery();
        InitializeExtensionLifecycleQuery();
    end;

    local procedure InitializePageExecutionQuery()
    var
        QueryStore: Record "D4P KQL Query Store";
        OutStr: OutStream;
        QueryText: Text;
    begin
        if QueryStore.Get('PAGEEXEC') then
            QueryStore.Delete(); // Delete existing to recreate with correct syntax

        QueryStore.Init();
        QueryStore.Code := 'PAGEEXEC';
        QueryStore.Name := 'Page Execution Analysis';
        QueryStore.Description := 'Analyzes page execution performance including average and max execution times';
        QueryStore."Result Table ID" := Database::"D4P KQL Page Execution";

        QueryText := 'pageViews ' +
            '| where timestamp {{DATEFILTER}} ' +
            '| where customDimensions.aadTenantId == "{{AADTENANTID}}" ' +
            '| where customDimensions.environmentType == "{{ENVIRONMENTTYPE}}" ' +
            '| where customDimensions.environmentName == "{{ENVIRONMENTNAME}}" ' +
            '| where customDimensions.alObjectId > 0 ' +
            '| extend ' +
            '    alObjectId = toint(customDimensions.alObjectId), ' +
            '    aadID = tostring(customDimensions.aadTenantId), ' +
            '    alObjectName = tostring(customDimensions.alObjectName), ' +
            '    clientType = tostring(customDimensions.clientType), ' +
            '    eventId = tostring(customDimensions.eventID), ' +
            '    pageMode = tostring(customDimensions.pageMode), ' +
            '    pageType = tostring(customDimensions.pageType), ' +
            '    companyName = tostring(customDimensions.companyName), ' +
            '    environmentName = tostring(customDimensions.environmentName), ' +
            '    environmentType = tostring(customDimensions.environmentType) ' +
            '| summarize ' +
            '    avgTime = toint(avg(duration)), ' +
            '    maxTime = toint(max(duration)), ' +
            '    ExecutionCount = count() ' +
            'by ' +
            '    aadID, environmentType, environmentName, alObjectId, alObjectName, ' +
            '    timestamp = {{TIMESTAMP_COMPRESSION}}, ' +
            '    eventId, pageMode, pageType, companyName ' +
            '| project ' +
            '    ["Execution Date/Time"] = timestamp, ' +
            '    ["Page ID"] = alObjectId, ' +
            '    ["Page Name"] = alObjectName, ' +
            '    ["Average Execution Time"] = avgTime, ' +
            '    ["Max. Execution Time"] = maxTime, ' +
            '    ["No. of Executions"] = ExecutionCount, ' +
            '    ["Company Name"] = companyName, ' +
            '    ["Tenant ID"] = aadID, ' +
            '    ["Environment Type"] = environmentType, ' +
            '    ["Environment Name"] = environmentName';

        QueryStore.Query.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(QueryText);
        QueryStore.Insert();
    end;

    local procedure InitializeReportExecutionQuery()
    var
        QueryStore: Record "D4P KQL Query Store";
        OutStr: OutStream;
        QueryText: Text;
    begin
        if QueryStore.Get('REPORTEXEC') then
            QueryStore.Delete(); // Delete existing to recreate with correct syntax

        QueryStore.Init();
        QueryStore.Code := 'REPORTEXEC';
        QueryStore.Name := 'Report Execution Analysis';
        QueryStore.Description := 'Analyzes report execution performance including execution times and row counts';
        QueryStore."Result Table ID" := Database::"D4P KQL Report Execution";

        QueryText := 'traces ' +
            '| where timestamp {{DATEFILTER}} ' +
            '| where customDimensions.aadTenantId == "{{AADTENANTID}}" ' +
            '| where customDimensions.environmentType == "{{ENVIRONMENTTYPE}}" ' +
            '| where customDimensions.environmentName == "{{ENVIRONMENTNAME}}" ' +
            '| where 1==1 ' +
            '    and  customDimensions.eventId == ''RT0006'' ' +
            '| extend reportName = tostring(customDimensions.alObjectName) ' +
            '    , executionTimeInSec = toreal(totimespan(customDimensions.totalTime))/10000000 ' +
            '    , numberofRows = toint(customDimensions.numberOfRows) ' +
            '    , reportId = toint(customDimensions.alObjectId) ' +
            '    , extensionName = tostring(customDimensions.extensionName) ' +
            '    , companyName = tostring(customDimensions.companyName) ' +
            '    , environmentName = tostring(customDimensions.environmentName) ' +
            '    , environmentType = tostring(customDimensions.environmentType) ' +
            '| where reportName <> '''' ' +
            '| summarize ' +
            '     avgTime = toint(avg(executionTimeInSec)), ' +
            '     avgRows = toint(avg(numberofRows)), ' +
            '     maxTime = toint(max(executionTimeInSec)), ' +
            '     maxRows = toint(max(numberofRows)), ' +
            '     ExecutionCount = count() ' +
            '  by ' +
            '     reportName, environmentName, environmentType, companyName, reportId, ' +
            '{{TIMESTAMP_COMPRESSION}}, ' +
            '     extensionName ' +
            '| order by reportName asc, reportId asc, timestamp asc ' +
            '| project ' +
            '    ["Company Name"] = companyName, ' +
            '    ["Report ID"] = reportId, ' +
            '    ["Report Name"] = reportName, ' +
            '    ["Execution Date/Time"] = timestamp, ' +
            '    ["Average Execution Time"] = avgTime, ' +
            '    ["Average Rows"] = avgRows, ' +
            '    ["Max. Execution Time"] = maxTime, ' +
            '    ["Max. Rows"] = maxRows, ' +
            '    ["No. of Executions"] = ExecutionCount, ' +
            '    ["Environment Type"] = environmentType, ' +
            '    ["Environment Name"] = environmentName, ' +
            '    ["Extension Name"] = extensionName';

        QueryStore.Query.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(QueryText);
        QueryStore.Insert();
    end;

    local procedure InitializeSlowALMethodsQuery()
    var
        QueryStore: Record "D4P KQL Query Store";
        OutStr: OutStream;
        QueryText: Text;
    begin
        if QueryStore.Get('SLOWAL') then
            QueryStore.Delete(); // Delete existing to recreate with correct syntax

        QueryStore.Init();
        QueryStore.Code := 'SLOWAL';
        QueryStore.Name := 'Slow AL Methods Analysis';
        QueryStore.Description := 'Analyzes long-running AL method executions';
        QueryStore."Result Table ID" := Database::"D4P KQL Slow AL Method";

        QueryText := 'traces ' +
            '| where timestamp {{DATEFILTER}} ' +
            '| where customDimensions.aadTenantId == "{{AADTENANTID}}" ' +
            '| where customDimensions.environmentType == "{{ENVIRONMENTTYPE}}" ' +
            '| where customDimensions.environmentName == "{{ENVIRONMENTNAME}}" ' +
            '| where customDimensions.eventId == "RT0018" ' +
            '| extend aadID = tostring(customDimensions.aadTenantId), ' +
            '         environmentType = tostring(customDimensions.environmentType), ' +
            '         environmentName = tostring(customDimensions.environmentName), ' +
            '         extensionId = tostring(customDimensions.extensionId), ' +
            '         extensionName = tostring(customDimensions.extensionName), ' +
            '         extensionPublisher = tostring(customDimensions.extensionPublisher), ' +
            '         extensionVersion = tostring(customDimensions.extensionVersion), ' +
            '         companyName = tostring(customDimensions.companyName), ' +
            '         alObjectId = toint(customDimensions.alObjectId), ' +
            '         alObjectType = tostring(customDimensions.alObjectType), ' +
            '         alObjectName = tostring(customDimensions.alObjectName), ' +
            '         alMethod = tostring(customDimensions.alMethod), ' +
            '         clientType = tostring(customDimensions.clientType), ' +
            '         executionTimeInMS = toreal(totimespan(customDimensions.executionTime))/10000 ' +
            '| summarize ' +
            '    ["Max. Execution Time"] = max(executionTimeInMS), ' +
            '    ["No. of Executions"] = count() ' +
            '    by aadID, extensionId, extensionName, extensionPublisher, extensionVersion, ' +
            '       companyName, alObjectId, alObjectType, alObjectName, alMethod, clientType, ' +
            '       environmentType, environmentName ' +
            '| order by ["Max. Execution Time"] desc ' +
            '| project ' +
            '    ["Execution Date/Time"] = now(), ' +
            '    ["Tenant ID"] = aadID, ' +
            '    ["Extension ID"] = extensionId, ' +
            '    ["Extension Name"] = extensionName, ' +
            '    ["Company Name"] = companyName, ' +
            '    ["AL Object ID"] = alObjectId, ' +
            '    ["AL Object Type"] = alObjectType, ' +
            '    ["AL Object Name"] = alObjectName, ' +
            '    ["Method Name"] = alMethod, ' +
            '    ["Client Type"] = clientType, ' +
            '    ["Max. Execution Time"] = ["Max. Execution Time"], ' +
            '    ["Publisher"] = extensionPublisher, ' +
            '    ["Version"] = extensionVersion, ' +
            '    ["No. of Executions"] = ["No. of Executions"], ' +
            '    ["Environment Type"] = environmentType, ' +
            '    ["Environment Name"] = environmentName';

        QueryStore.Query.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(QueryText);
        QueryStore.Insert();
    end;

    local procedure InitializeExtensionLifecycleQuery()
    var
        QueryStore: Record "D4P KQL Query Store";
        OutStr: OutStream;
        QueryText: Text;
    begin
        if QueryStore.Get('EXTLIFECYCLE') then
            QueryStore.Delete(); // Delete existing to recreate with correct syntax

        QueryStore.Init();
        QueryStore.Code := 'EXTLIFECYCLE';
        QueryStore.Name := 'Extension Lifecycle Analysis';
        QueryStore.Description := 'Analyzes extension installation, updates, and synchronization events';
        QueryStore."Result Table ID" := Database::"D4P KQL Extension Lifecycle";

        QueryText := 'traces ' +
            '| where timestamp {{DATEFILTER}} ' +
            '| where customDimensions.aadTenantId == "{{AADTENANTID}}" ' +
            '| where customDimensions.environmentType == "{{ENVIRONMENTTYPE}}" ' +
            '| where customDimensions.environmentName == "{{ENVIRONMENTNAME}}" ' +
            '| where (customDimensions.eventId == "LC0012") or (customDimensions.eventId == "LC0013") ' +
            '| extend aadID = tostring(customDimensions.aadTenantId), ' +
            '         eventId = tostring(customDimensions.eventId), ' +
            '         environmentType = tostring(customDimensions.environmentType), ' +
            '         environmentName = tostring(customDimensions.environmentName), ' +
            '         extensionName = tostring(customDimensions.extensionName), ' +
            '         extensionId = tostring(customDimensions.extensionId), ' +
            '         extensionPublisher = tostring(customDimensions.extensionPublisher), ' +
            '         extensionVersion = tostring(customDimensions.extensionVersion), ' +
            '         extensionSynchronizationMode = tostring(customDimensions.extensionSynchronizationMode), ' +
            '         serverExecutionTimeInMS = toreal(totimespan(customDimensions.serverExecutionTime))/10000, ' +
            '         messageText = tostring(message), ' +
            '         result = tostring(customDimensions.result), ' +
            '         failureReason = tostring(customDimensions.failureReason) ' +
            '| order by extensionName asc, extensionId asc, timestamp asc ' +
            '| project ' +
            '    ["Extension Name"] = extensionName, ' +
            '    ["Extension ID"] = extensionId, ' +
            '    ["Publisher"] = extensionPublisher, ' +
            '    ["Version"] = extensionVersion, ' +
            '    ["Event ID"] = eventId, ' +
            '    ["Message"] = messageText, ' +
            '    ["Result"] = result, ' +
            '    ["Exec. Date/Time"] = timestamp, ' +
            '    ["Tenant ID"] = aadID, ' +
            '    ["Sync. Mode"] = extensionSynchronizationMode, ' +
            '    ["Execution Time"] = serverExecutionTimeInMS, ' +
            '    ["Failure Reason"] = failureReason, ' +
            '    ["Environment Type"] = environmentType, ' +
            '    ["Environment Name"] = environmentName';

        QueryStore.Query.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(QueryText);
        QueryStore.Insert();
    end;
}