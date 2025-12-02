namespace D4P.CCMS.Telemetry;

using D4P.CCMS.Environment;
using D4P.CCMS.Setup;
using System.Reflection;
using Microsoft.Utilities;

report 62032 "D4P Load Data"
{

    UsageCategory = None;
    ProcessingOnly = true;
    Caption = 'Telemetry Analysis - Load Data';

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(EnvironmentCodeField; EnvironmentCode)
                    {
                        Caption = 'Environment Code';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the environment code for telemetry data.';
                    }
                    field(EnvironmentNameField; EnvironmentName)
                    {
                        Caption = 'Environment Name';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the environment name for filtering telemetry data.';
                    }
                    field(EnvironmentTypeField; EnvironmentType)
                    {
                        Caption = 'Environment Type';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the environment type (Production, Sandbox, etc.) for filtering telemetry data.';
                    }
                    field(AADTenantIdField; EnvironmentAADTenantId)
                    {
                        Caption = 'Entra Tenant ID';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Entra Tenant ID for filtering telemetry data.';
                    }
                    field(QueryCodeField; SelectedQueryCode)
                    {
                        Caption = 'Query Code';
                        ApplicationArea = All;
                        TableRelation = "D4P KQL Query Store".Code;
                        ToolTip = 'Select the query to run from the KQL Query Store.';
                    }
                    field(FromDateField; FromDateTime)
                    {
                        Caption = 'From Date/Time';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the "From Date" field.';
                    }
                    field(ToDateField; ToDateTime)
                    {
                        Caption = 'To Date/Time';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the "To Date" field.';
                    }
                    field(TimeCompressionField; TimeCompression)
                    {
                        Caption = 'Time Compression';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the a time compression to use to group data by time. This applies only to some queries. Leave this field blank to not compress data at all. This value is a timestamp (https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/scalar-data-types/timespan).';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if (TimeCompression = '') then TimeCompression := '30d';
            if (FromDateTime = 0DT) and (ToDateTime = 0DT) then
                SetDates(CreateDateTime(CalcDate('<-30D>', Today()), 000000T), CreateDateTime(Today(), 235959T));
        end;
    }

    var
        Client: Codeunit "D4P AppInsights Client";
        SelectedQuery: Record "D4P KQL Query Store";
        SelectedQueryCode: Code[20];
        FromDateTime, ToDateTime : DateTime;
        TimeCompression: Text;
        EnvironmentCode: Code[100];
        EnvironmentType: Text[50];
        EnvironmentName: Text[100];
        EnvironmentAADTenantId: Guid;
        TelemetryApplicationId: Text[50];
        TelemetryAPIKey: Text[50];
        TelemetryTenantId: Text[50];
        AIConnectionString: Text[1000];
        StoredEnvironment: Record "D4P BC Environment";

    trigger OnPreReport()
    begin
        RunQuery();
    end;

    local procedure GetWorksheetFilter(RecVariant: Variant): Code[20]
    var
        Field: Record Field;
        TempRec: Record "D4P KQL Report Execution" temporary;
        RecRef: RecordRef;
        Fldref: FieldRef;
        WorkSheetCode: Code[20];
    begin
        RecRef.GetTable(RecVariant);
        Field.SetRange(TableNo, RecRef.Number());
        Field.SetRange(FieldName, TempRec.FieldName("Environment Code"));
        Field.FindLast();
        FldRef := RecRef.Field(Field."No.");
        RecRef.FilterGroup(0);
        WorkSheetCode := CopyStr(Fldref.GetFilter(), 1, MaxStrLen(WorkSheetCode));
        if (WorkSheetCode = '') then begin
            RecRef.FilterGroup(2);
            WorkSheetCode := CopyStr(Fldref.GetFilter(), 1, MaxStrLen(WorkSheetCode));
        end;
        exit(WorkSheetCode);
    end;

    procedure InitRequest(DocVariant: Variant; QueryCode: Code[20]; NewTimeCompression: Text)
    begin
        InitRequest(GetWorksheetFilter(DocVariant), QueryCode, NewTimeCompression);
    end;

    procedure InitRequest(DocVariant: Variant; QueryCode: Code[20])
    begin
        InitRequest(GetWorksheetFilter(DocVariant), QueryCode, '');
    end;

    procedure InitRequest(NewWorkSheetCode: Code[20]; QueryCode: Code[20])
    begin
        InitRequest(NewWorkSheetCode, QueryCode, '30d');
    end;

    procedure InitRequest(NewWorkSheetCode: Code[20]; QueryCode: Code[20]; NewTimeCompression: Text)
    var
        InitMethodDeprecatedErr: Label 'This initialization method is no longer supported. Use InitRequestFromEnvironment instead.';
    begin
        // This method is deprecated - use InitRequestFromEnvironment instead
        Error(InitMethodDeprecatedErr);
    end;

    procedure SetDates(NewFromDateTime: DateTime; NewToDateTime: DateTime)
    begin
        ToDateTime := NewToDateTime;
        FromDateTime := NewFromDateTime;
    end;

    procedure SetDates(NewFromDate: Date; NewToDate: Date)
    begin
        SetDates(CreateDateTime(NewFromDate, 000000T), CreateDateTime(NewToDate, 235959T));
    end;

    procedure InitRequestFromEnvironment(Environment: Record "D4P BC Environment"; QueryCode: Code[20])
    var
        AIConnectionSetup: Record "D4P AppInsights Connection";
        NoConnectionStringErr: Label 'The selected environment does not have an Application Insights connection string configured.';
        SetupNotFoundErr: Label 'Application Insights connection setup not found for the selected environment.';
    begin
        // Validate environment has telemetry configuration
        if Environment."Application Insights String" = '' then
            Error(NoConnectionStringErr);

        if not AIConnectionSetup.Get(Environment."Application Insights String") then
            Error(SetupNotFoundErr);

        // Store the environment record for passing context to result pages
        StoredEnvironment := Environment;

        // Store telemetry data from environment and AppInsights connection setup
        EnvironmentCode := CopyStr(Environment.Name, 1, MaxStrLen(EnvironmentCode));
        EnvironmentName := CopyStr(Environment.Name, 1, MaxStrLen(EnvironmentName));
        EnvironmentType := CopyStr(Environment.Type, 1, MaxStrLen(EnvironmentType));
        EnvironmentAADTenantId := Environment."Tenant ID";
        AIConnectionString := AIConnectionSetup."AppInsights Connection String";
        TelemetryApplicationId := AIConnectionSetup."Telemetry Application Id";
        TelemetryAPIKey := AIConnectionSetup."Telemetry API Key";
        TelemetryTenantId := AIConnectionSetup."Tenant Id";

        SelectedQueryCode := QueryCode;
        SetDates(CreateDateTime(CalcDate('<-30D>', Today()), 000000T), CreateDateTime(Today(), 235959T));
    end;

    local procedure RunQuery()
    var
        PleaseSelectQueryErr: Label 'Please select a Query Code';
        QueryNotFoundErr: Label 'Query Code %1 was not found in the KQL Query Store.';
    begin
        if SelectedQueryCode = '' then
            Error(PleaseSelectQueryErr);
        if not SelectedQuery.Get(SelectedQueryCode) then
            Error(QueryNotFoundErr, SelectedQueryCode);

        LoadTable();
        ProcessResults();
        ShowResultsPage();
    end;

    local procedure LoadTable()
    var
        TableName, QueryText : Text;
        Tables: List of [Text];
        NotSupportedErr: Label 'The query must return at least one result table.';
        TelemetryIncompleteErr: Label 'Telemetry configuration is incomplete. Ensure Application ID and API Key are specified.';
    begin
        // Check if we have telemetry configuration data
        if (TelemetryApplicationId = '') or (TelemetryAPIKey = '') then
            Error(TelemetryIncompleteErr);

        QueryText := GetStoredQueryText(SelectedQuery);
        QueryText := ApplyTokens(QueryText);

        Client.Initialize(TelemetryApplicationId, TelemetryAPIKey, TelemetryTenantId, AIConnectionString);
        Client.RunQuery(QueryText);

        Tables := Client.ListTables();
        if (Tables.Count() < 1) then
            Error(NotSupportedErr);
        TableName := Tables.Get(Tables.Count());
        Client.BeginTableRead(TableName);
    end;

    local procedure ProcessResults()
    var
        RecRef: RecordRef;
        EntryNoFieldRef: FieldRef;
        WorksheetCodeFieldRef: FieldRef;
        UserIDFieldRef: FieldRef;
        EntryNo: Integer;
    begin
        if SelectedQuery."Result Table ID" = 0 then
            exit; // No specific table to populate

        // Open the result table
        RecRef.Open(SelectedQuery."Result Table ID");

        // Clear existing records for this environment code and user
        WorksheetCodeFieldRef := RecRef.Field(10); // Environment Code field
        WorksheetCodeFieldRef.SetRange(EnvironmentCode);
        UserIDFieldRef := RecRef.Field(16); // User ID field
        UserIDFieldRef.SetRange(UserId());
        if not RecRef.IsEmpty() then
            RecRef.DeleteAll();

        if Client.RowCount() = 0 then begin
            RecRef.Close();
            exit;
        end;

        // Debug mode: Show API result content
        ShowDebugInfo();

        Client.OpenReaderDialog();
        repeat
            Client.StepReaderDialog();
            RecRef.Init();

            // Set Environment Code
            WorksheetCodeFieldRef := RecRef.Field(10);
            WorksheetCodeFieldRef.Value := EnvironmentCode;

            // Set Entry No.
            EntryNo += 1;
            EntryNoFieldRef := RecRef.Field(15);
            EntryNoFieldRef.Value := EntryNo;

            // Set User ID
            UserIDFieldRef := RecRef.Field(16);
            UserIDFieldRef.Value := UserId();

            // Deserialize data from Application Insights
            Client.DeserializeToRecordRef(RecRef);

            // Handle specific field calculations (like Execution Date from DateTime)
            HandleSpecificFieldCalculations(RecRef);

            RecRef.Insert();
        until not Client.GetNextRow();

        Client.CloseReaderDialog();
        RecRef.Close();
    end;

    local procedure HandleSpecificFieldCalculations(var RecRef: RecordRef)
    var
        ExecutionDateFieldRef: FieldRef;
        ExecutionDateTimeFieldRef: FieldRef;
        ExecutionDateTime: DateTime;
        ExecutionDate: Date;
    begin
        // Handle Page Execution specific calculation
        if RecRef.Number = Database::"D4P KQL Page Execution" then begin
            if RecRef.FieldExist(30) and RecRef.FieldExist(31) then begin // Execution Date and Execution Date/Time
                ExecutionDateTimeFieldRef := RecRef.Field(31);
                ExecutionDateTime := ExecutionDateTimeFieldRef.Value;
                if ExecutionDateTime <> 0DT then begin
                    ExecutionDate := DT2Date(ExecutionDateTime);
                    ExecutionDateFieldRef := RecRef.Field(30);
                    ExecutionDateFieldRef.Value := ExecutionDate;
                end;
            end;
        end;

        // Handle Report Execution specific calculation
        if RecRef.Number = Database::"D4P KQL Report Execution" then begin
            if RecRef.FieldExist(30) and RecRef.FieldExist(31) then begin // Execution Date and Execution Date/Time
                ExecutionDateTimeFieldRef := RecRef.Field(31);
                ExecutionDateTime := ExecutionDateTimeFieldRef.Value;
                if ExecutionDateTime <> 0DT then begin
                    ExecutionDate := DT2Date(ExecutionDateTime);
                    ExecutionDateFieldRef := RecRef.Field(30);
                    ExecutionDateFieldRef.Value := ExecutionDate;
                end;
            end;
        end;

        // Handle Slow AL Method specific calculation
        if RecRef.Number = Database::"D4P KQL Slow AL Method" then begin
            if RecRef.FieldExist(20) and RecRef.FieldExist(21) then begin // Execution Date and Execution Date/Time
                ExecutionDateTimeFieldRef := RecRef.Field(21);
                ExecutionDateTime := ExecutionDateTimeFieldRef.Value;
                if ExecutionDateTime <> 0DT then begin
                    ExecutionDate := DT2Date(ExecutionDateTime);
                    ExecutionDateFieldRef := RecRef.Field(20);
                    ExecutionDateFieldRef.Value := ExecutionDate;
                end;
            end;
        end;
    end;

    local procedure ShowResultsPage()
    var
        PageExecutionRec: Record "D4P KQL Page Execution";
        ReportExecutionRec: Record "D4P KQL Report Execution";
        SlowALMethodRec: Record "D4P KQL Slow AL Method";
        ExtensionLifecycleRec: Record "D4P KQL Extension Lifecycle";
        PageExecutionsPage: Page "D4P KQL Page Executions";
        ReportExecutionsPage: Page "D4P KQL Report Executions";
        SlowALMethodsPage: Page "D4P KQL Slow AL Methods";
        ExtensionLifecyclePage: Page "D4P KQL Extension Lifecycle";
        QueryExecutedMsg: Label 'Query executed successfully. No specific results page configured.';
        QueryExecutedWithResultsMsg: Label 'Query executed successfully. Results stored in Table ID %1.';
    begin
        if SelectedQuery."Result Table ID" = 0 then begin
            Message(QueryExecutedMsg);
            exit;
        end;

        // Show debug info about processed results
        ShowResultsDebugInfo();

        // Run the appropriate page based on table ID and pass environment context
        case SelectedQuery."Result Table ID" of
            Database::"D4P KQL Page Execution":
                begin
                    PageExecutionRec.SetRange("Environment Code", EnvironmentCode);
                    PageExecutionsPage.SetEnvironmentContext(StoredEnvironment);
                    PageExecutionsPage.SetTableView(PageExecutionRec);
                    PageExecutionsPage.Run();
                end;
            Database::"D4P KQL Report Execution":
                begin
                    ReportExecutionRec.SetRange("Environment Code", EnvironmentCode);
                    ReportExecutionsPage.SetEnvironmentContext(StoredEnvironment);
                    ReportExecutionsPage.SetTableView(ReportExecutionRec);
                    ReportExecutionsPage.Run();
                end;
            Database::"D4P KQL Slow AL Method":
                begin
                    SlowALMethodRec.SetRange("Environment Code", EnvironmentCode);
                    SlowALMethodsPage.SetEnvironmentContext(StoredEnvironment);
                    SlowALMethodsPage.SetTableView(SlowALMethodRec);
                    SlowALMethodsPage.Run();
                end;
            Database::"D4P KQL Extension Lifecycle":
                begin
                    ExtensionLifecycleRec.SetRange("Environment Code", EnvironmentCode);
                    ExtensionLifecyclePage.SetEnvironmentContext(StoredEnvironment);
                    ExtensionLifecyclePage.SetTableView(ExtensionLifecycleRec);
                    ExtensionLifecyclePage.Run();
                end;
            else
                Message(QueryExecutedWithResultsMsg, SelectedQuery."Result Table ID");
        end;
    end;

    local procedure GetStoredQueryText(QueryRec: Record "D4P KQL Query Store"): Text
    var
        InS: InStream;
        Line: Text;
        Txt: Text;
        NoQueryTextErr: Label 'The selected query does not contain any text.';
    begin
        QueryRec.CalcFields(Query);
        if not QueryRec.Query.HasValue() then
            Error(NoQueryTextErr);
        QueryRec.Query.CreateInStream(InS, TEXTENCODING::UTF8);
        while not InS.EOS do begin
            InS.ReadText(Line);
            if Txt = '' then
                Txt := Line
            else
                Txt += '\n' + Line;
        end;
        exit(Txt);
    end;

    local procedure ApplyTokens(Kql: Text): Text
    var
        TimestampCompression: Text;
        TenantIdText: Text;
    begin
        Kql := Kql.Replace('{{FROM}}', Format(FromDateTime, 0, 9));
        Kql := Kql.Replace('{{TO}}', Format(ToDateTime, 0, 9));
        Kql := Kql.Replace('{{DATEFILTER}}', Client.FormatDateQuery(FromDateTime, ToDateTime));

        // Handle timestamp compression
        if TimeCompression <> '' then
            TimestampCompression := StrSubstNo('bin(timestamp, %1)', TimeCompression)
        else
            TimestampCompression := 'timestamp';
        Kql := Kql.Replace('{{TIMESTAMP_COMPRESSION}}', TimestampCompression);

        // Keep backwards compatibility
        if TimeCompression <> '' then
            Kql := Kql.Replace('{{TIMECOMPRESSION}}', TimeCompression);

        // Replace environment-specific placeholders
        // Remove curly braces from GUID and convert to lowercase
        TenantIdText := Format(EnvironmentAADTenantId).ToLower();
        TenantIdText := TenantIdText.Replace('{', '').Replace('}', '');
        Kql := Kql.Replace('{{AADTENANTID}}', TenantIdText);
        Kql := Kql.Replace('{{ENVIRONMENTTYPE}}', EnvironmentType);
        Kql := Kql.Replace('{{ENVIRONMENTNAME}}', EnvironmentName);

        exit(Kql);
    end;

    local procedure ShowDebugInfo()
    var
        BCSetup: Record "D4P BC Setup";
        DebugText: Text;
        ColumnList: Text;
        ValueList: Text;
        TempBuffer: Record "Name/Value Buffer" temporary;
        RowCounter: Integer;
    begin
        if not BCSetup.IsDebugModeEnabled() then
            exit;

        // Show query information
        DebugText := 'DEBUG MODE - API Query Result:' + '\' + '\';
        DebugText += 'Query Code: ' + SelectedQueryCode + '\';
        DebugText += 'Query Name: ' + SelectedQuery.Name + '\';
        DebugText += 'Total Rows: ' + Format(Client.RowCount()) + '\';
        DebugText += 'Result Table ID: ' + Format(SelectedQuery."Result Table ID") + '\' + '\';

        // Show actual KQL query being sent (with tokens replaced)
        DebugText += 'KQL Query:' + '\' + ApplyTokens(GetStoredQueryText(SelectedQuery)) + '\' + '\';

        // Show column names from first row
        if Client.GetNextRow() then begin
            Client.GetFields(TempBuffer);
            if TempBuffer.FindSet() then
                repeat
                    if ColumnList <> '' then
                        ColumnList += ', ';
                    ColumnList += '"' + TempBuffer.Name + '"';
                until TempBuffer.Next() = 0;

            DebugText += 'Available Columns:' + '\' + ColumnList + '\' + '\';

            // Show first few rows of data
            DebugText += 'Sample Data (first 3 rows):';
            Client.BeginTableRead(Client.ListTables().Get(Client.ListTables().Count()));

            repeat
                RowCounter += 1;
                if RowCounter > 3 then break;

                Client.GetFields(TempBuffer);
                ValueList := '';
                if TempBuffer.FindSet() then
                    repeat
                        if ValueList <> '' then
                            ValueList += ' | ';
                        ValueList += TempBuffer.Name + '=' + Client.GetValueAsText(TempBuffer.Name, false);
                    until TempBuffer.Next() = 0;

                DebugText += 'Row ' + Format(RowCounter) + ': ' + ValueList + '\';
            until not Client.GetNextRow() or (RowCounter >= 3);

            // Reset to beginning for normal processing
            Client.BeginTableRead(Client.ListTables().Get(Client.ListTables().Count()));
        end;

        Message(DebugText);
    end;

    local procedure ShowResultsDebugInfo()
    var
        BCSetup: Record "D4P BC Setup";
        RecRef: RecordRef;
        DebugText: Text;
        RecordCount: Integer;
    begin
        if not BCSetup.IsDebugModeEnabled() then
            exit;

        if SelectedQuery."Result Table ID" = 0 then
            exit;

        // Count records that were created
        RecRef.Open(SelectedQuery."Result Table ID");
        RecRef.Field(10).SetRange(EnvironmentCode); // Environment Code field
        RecRef.Field(16).SetRange(UserId()); // User ID field
        RecordCount := RecRef.Count();
        RecRef.Close();

        DebugText := 'DEBUG MODE - Processing Results:' + '\' + '\';
        DebugText += 'Records Created: ' + Format(RecordCount) + '\';
        DebugText += 'Target Table ID: ' + Format(SelectedQuery."Result Table ID") + '\';
        DebugText += 'Environment Code: ' + EnvironmentCode + '\';
        DebugText += 'User ID: ' + UserId() + '\';
        DebugText += 'Opening results page...';

        Message(DebugText);
    end;

}