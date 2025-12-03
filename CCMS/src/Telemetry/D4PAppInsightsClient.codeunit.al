namespace D4P.CCMS.Telemetry;

using System.Security.Authentication;
using Microsoft.Utilities;
using System.Utilities;
using System.IO;
using System.Reflection;
using System.Environment;
using D4P.CCMS.Environment;

/// <summary>
/// Provides access to Application Insights data.
/// This client supports executing queries and also emitting events.
/// </summary>
codeunit 62030 "D4P AppInsights Client"
{
    var
        TelemetryApplicationId: Text[50];
        TelemetryAPIKey: Text[50];
        TelemetryTenantId: Text[50];
        AIConnectionString: Text[1000];
        TempCurrFields: Record "Name/Value Buffer" temporary;
        ApplicationIdTxt: Label 'ApplicationId', Locked = true;
        ApiKeyTxt: Label 'ApiKey', Locked = true;
        _uniqueSessionId: Guid;
        _instrumentationKey: Guid;
        _emitUri: Text;
        IngestionEndpointUrl: Text;
        LastResponse: Text;
        Rows: JsonArray;
        CurrRow: JsonArray;
        Columns: JsonArray;
        RowIndex: Integer;
        TotalRowCount: Integer;
        ReaderDialogIsOpenValue: Boolean;
        Dlg: Dialog;
        ReaderDialogCounter: array[2] of Integer;
        ReaderDialogFreq: Integer;
        EmptyGuid: Guid;

    procedure GetConfigurationKeys(): List of [Text[250]];
    var
        Result: List of [Text[250]];
    begin
        Result.Add(ApplicationIdTxt);
        exit(Result);
    end;

    procedure GetSecretConfigurationKeys(): List of [Text[250]];
    var
        Result: List of [Text[250]];
    begin
        Result.Add(ApiKeyTxt);
        exit(Result);
    end;

    local procedure ApplicationId(): Text
    begin
        exit(TelemetryApplicationId);
    end;

    local procedure ApiKey(): Text
    begin
        exit(TelemetryAPIKey);
    end;

    local procedure GetQueryBaseUri(): Text
    begin
        exit('https://api.applicationinsights.io');
    end;

    local procedure GetPayload(QueryString: Text): Text
    var
        jw: Codeunit "Json Text Reader/Writer";
        jo: JsonObject;
    begin
        jw.WriteStartObject('');
        jw.WriteStringProperty('query', QueryString);
        jw.WriteEndObject();
        exit(jw.GetJSonAsText());
    end;

    local procedure GetSeverity(aVerbosity: Verbosity): Text
    begin
        case aVerbosity of
            Verbosity::Verbose:
                exit('Verbose');
            Verbosity::Normal:
                exit('Information');
            Verbosity::Warning:
                exit('Warning');
            Verbosity::Error:
                exit('Error');
            Verbosity::Critical:
                exit('Critical');
        end;
    end;

    /// <summary>
    /// Enables log posting to Application Insights.using the given connection string.
    /// </summary>
    /// <param name="ConnectionString">The connection string to use.</param>
    procedure InitializeForPost(ConnectionString: Text);
    var
        ActiveSession: Record "Active Session";
    begin
        SplitConnectionString(ConnectionString);
        if (ActiveSession.Get(ServiceInstanceId(), SessionId())) then
            _uniqueSessionId := ActiveSession."Session Unique ID";
    end;

    procedure Initialize(ApplicationId: Text[50]; APIKey: Text[50]; TenantId: Text[50]; ConnectionString: Text[1000]);
    begin
        TelemetryApplicationId := ApplicationId;
        TelemetryAPIKey := APIKey;
        TelemetryTenantId := TenantId;
        AIConnectionString := ConnectionString;

        if (TelemetryApplicationId <> '') and (TelemetryAPIKey <> '') then begin
            // Use the actual connection string for initialization
            InitializeForPost(AIConnectionString);
        end;
    end;

    procedure InitializeFromEnvironment(Environment: Record "D4P BC Environment");
    var
        AIConnectionSetup: Record "D4P AppInsights Connection";
    begin
        // Get telemetry data from environment and AppInsights connection setup
        if Environment."Application Insights String" <> '' then begin
            if AIConnectionSetup.Get(Environment."Application Insights String") then begin
                // Set the telemetry data from AppInsights connection setup
                TelemetryApplicationId := AIConnectionSetup."Telemetry Application Id";
                TelemetryAPIKey := AIConnectionSetup."Telemetry API Key";
                TelemetryTenantId := AIConnectionSetup."Tenant Id";
                AIConnectionString := AIConnectionSetup."AppInsights Connection String";

                if (TelemetryApplicationId <> '') and (TelemetryAPIKey <> '') then begin
                    // Use the actual connection string for initialization
                    InitializeForPost(AIConnectionString);
                end;
            end;
        end;
    end;


    /// <summary>
    /// Post a message to Application Insights. Use 'CreateMessage' to create a message to be posted.
    /// </summary>
    /// <param name="jo">The message to post.</param>
    /// <returns>True if the message was posted successfully.</returns>
    procedure PostMessage(jo: JsonObject): Boolean
    var
        ja: JsonArray;
    begin
        ja.Add(jo);
        exit(PostMessage(ja));
    end;

    /// <summary>
    /// Post multiple messages to Application Insights. Use 'CreateMessage' to create a message to be posted.
    /// </summary>
    /// <param name="ja">The messages to post.</param>
    /// <returns>True if the message was posted successfully.</returns>
    procedure PostMessage(ja: JsonArray): Boolean
    var
    //rc: Codeunit "Rest Client";
    begin
        // rc.SetServiceConfig(Config.Code);
        // rc.Body(ja);
        // rc.BaseUri(_emitUri);
        // rc.Method('Post');
        // if not rc.SendRequest() then exit(false);
        // if not rc.ResponseStatusSuccess() then exit(false);
        // exit(true);
    end;

    procedure GetOAuthToken() AuthToken: SecretText
    var
        AccessTokenURL: Text;
        OAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
        tenantID: Text;
    begin
        tenantID := TelemetryTenantId.Replace('{', '');
        tenantID := tenantID.Replace('}', '');
        //        AccessTokenURL := 'https://login.microsoftonline.com/' + tenantID + '/oauth2/v2.0/token';
        AccessTokenURL := 'https://login.microsoftonline.com/' + tenantID + '/oauth2/authorize?resource=https%3A%2F%2Fapi.applicationinsights.io';
        //Scopes.Add('https://api.applicationinsights.io/.default');
        if not OAuth2.AcquireTokenWithClientCredentials(TelemetryApplicationId,
            TelemetryAPIKey,
            AccessTokenURL, '', Scopes, AuthToken) then
            Error('Failed to get access token from response\%1', GetLastErrorText());
    end;

    /// <summary>
    /// Create a message to be posted to Application Insights.
    /// </summary>
    /// <param name="Timestamp">The timestamp of the message.</param>
    /// <param name="Message">The message to post.</param>
    /// <param name="Verbosity">The verbosity of the message.</param>
    /// <param name="Properties">Additional properties to include in the message.</param>
    /// <returns>The message as a JsonObject.</returns>
    procedure CreateMessage(
        Timestamp: DateTime;
        Message: Text;
        Verbosity: Verbosity;
        Properties: Dictionary of [Text, Text]
    ) result: JsonObject
    var
        jw: Codeunit "Json Text Reader/Writer";
        k: Text;
    begin
        jw.WriteStartObject('');
        jw.WriteStringProperty('name', 'AppTraces');
        jw.WriteStringProperty('time', Format(Timestamp, 0, 9));
        jw.WriteStringProperty('iKey', FormatGuid(_instrumentationKey));

        jw.WriteStartObject('tags');
        jw.WriteStringProperty('ai.session.id', FormatGuid(_uniqueSessionId));
        jw.WriteStringProperty('ai.user.id', FormatGuid(UserSecurityId()));
        jw.WriteEndObject(); // tags

        jw.WriteStartObject('data');
        jw.WriteStringProperty('baseType', 'MessageData');

        jw.WriteStartObject('baseData');
        jw.WriteStringProperty('ver', '2');
        jw.WriteStringProperty('message', Message);
        jw.WriteStringProperty('severityLevel', GetSeverity(Verbosity));

        jw.WriteStartObject('properties');
        jw.WriteStringProperty('companyName', CompanyName);
        jw.WriteStringProperty('clientType', Format(CurrentClientType));
        foreach k in Properties.Keys do
            jw.WriteStringProperty(k, Properties.Get(k));
        jw.WriteEndObject(); // properties

        jw.WriteEndObject(); // baseData

        jw.WriteEndObject(); // data
        jw.WriteEndObject(); // [root]

        result.ReadFrom(jw.GetJSonAsText());
    end;

    /// <summary>
    /// Executes the given query against Application Insights. This is a TryFunction.
    /// </summary>
    /// <param name="QueryString">The query to execute.</param>
    [TryFunction]
    procedure RunQuery(QueryString: Text)
    var
        response: Text;
        ErrorMessage: Text;

        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpContentMessage: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        JsonResponse: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonTokenLoop: JsonToken;
        JsonValue: JsonValue;
        JsonObjectLoop: JsonObject;
        AuthToken: SecretText;
        ResponseText: Text;
        FailedToFetchErr: Label 'Failed to fetch data from Endpoint: %1 %2';
        FailedToSendRequestErr: Label 'Failed to send HTTP request to Endpoint';
    begin
        IngestionEndpointUrl := 'https://api.applicationinsights.io/v1/apps/' + ApplicationId() + '/query';
        HttpRequestMessage.SetRequestUri(IngestionEndpointUrl);
        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('X-API-Key', ApiKey());

        //QueryString := 'traces | limit 10';
        HttpContentMessage.WriteFrom(GetPayload(QueryString));
        HttpContentMessage.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content := HttpContentMessage;

        // Send the HTTP request
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content.ReadAs(ResponseText);
                //Message(ResponseText);
                LastResponse := ResponseText;
            end else begin
                //Report errors!
                HttpResponseMessage.Content.ReadAs(ResponseText);
                Error(FailedToFetchErr, HttpResponseMessage.HttpStatusCode(), ResponseText);
            end;
        end else
            Error(FailedToSendRequestErr);

    end;

    /// <summary>
    /// Returns the list of tables that the last executed query has returned.
    /// </summary>
    /// <returns>The tables in the current result set.</returns>
    procedure ListTables(): List of [Text]
    var
        jo: JsonObject;
        jt: JsonToken;
        ja: JsonArray;
        result: List of [Text];
    begin
        jo.ReadFrom(LastResponse);
        ja := GetJsonArray(jo, 'tables');
        foreach jt in ja do
            result.Add(GetJsonText(jt.AsObject(), 'name'));
        exit(result);
    end;

    /// <summary>
    /// Loads the given table as the current table.
    /// </summary>
    /// <param name="TableName">The name of the table to load.</param>
    /// <returns>Specifies whether the load was successful.</returns>
    procedure BeginTableRead(TableName: Text): Boolean
    var
        currTable: JsonObject;
        jt: JsonToken;
    begin
        Clear(Rows);
        Clear(Columns);
        if not GetTable(TableName, currTable) then exit(false);

        if (not currTable.Get('columns', jt)) then exit(false);
        Columns := jt.AsArray();
        GetFields(TempCurrFields);

        if (not currTable.Get('rows', jt)) then exit(false);
        Rows := jt.AsArray();
        TotalRowCount := Rows.Count;
        if not GetRow(0) then exit(false);

        exit(true);
    end;

    /// <summary>
    /// Returns the list of columns that the current table has.
    /// </summary>
    /// <param name="TempField">The list of columns.</param>
    procedure GetFields(var TempField: Record "Name/Value Buffer")
    var
        TempField2: Record "Name/Value Buffer" temporary;
        jt: JsonToken;
    begin
        TempField.Copy(TempField2, true);
        foreach jt in Columns do
            TempField.AddNewEntry(
                CopyStr(GetJsonText(jt.AsObject(), 'name'), 1, MaxStrLen(TempField.Name)),
                GetJsonText(jt.AsObject(), 'type'));
    end;

    local procedure GetValue(ColumnName: Text; WithError: Boolean): JsonValue
    var
        TempCurrFields2: Record "Name/Value Buffer" temporary;
        jt: JsonToken;
        jv: JsonValue;
        ColumnDoesNotExistErr: Label 'The column ''%1'' does not exist in the dataset.';
    begin
        TempCurrFields2.Copy(TempCurrFields, true);
        TempCurrFields2.SetRange(Name, ColumnName);
        if not TempCurrFields2.FindLast() then begin
            if (WithError) then
                Error(ColumnDoesNotExistErr, ColumnName);
            jv.SetValueToNull();
            exit(jv);
        end;
        CurrRow.Get(TempCurrFields2.ID - 1, jt);
        exit(jt.AsValue());
    end;

    /// <summary>
    /// Returns the value of the given column as Text.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsText(ColumnName: Text): Text
    begin
        exit(GetValueAsText(ColumnName, false));
    end;

    /// <summary>
    /// Returns the value of the given column as Text.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <param name="WithError">Specifies whether to throw an error if the column does not exist.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsText(ColumnName: Text; WithError: Boolean): Text
    var
        jv: JsonValue;
    begin
        jv := GetValue(ColumnName, WithError);
        if (jv.IsNull()) then exit('');
        exit(jv.AsText());
    end;

    /// <summary>
    /// Checks if a column value is a valid GUID.
    /// </summary>
    /// <param name="ColumnName">The name of the column to check.</param>
    /// <returns>True if the value is a valid GUID, false otherwise.</returns>
    [TryFunction]
    procedure IsValueGuid(ColumnName: Text)
    var
        jv: JsonValue;
        TempValue: Guid;
    begin
        jv := GetValue(ColumnName, false);
        Evaluate(TempValue, jv.AsText());
    end;

    /// <summary>
    /// Returns the value of the given column as Guid.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsGuid(ColumnName: Text): Guid
    begin
        exit(GetValueAsGuid(ColumnName, false));
    end;

    /// <summary>
    /// Returns the value of the given column as Guid.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <param name="WithError">Specifies whether to throw an error if the column does not exist.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsGuid(ColumnName: Text; WithError: Boolean): Guid
    var
        r: Guid;
        jv: JsonValue;
        ValueAsText: Text;
    begin
        jv := GetValue(ColumnName, WithError);
        if (jv.IsNull()) then exit(r);
        ValueAsText := GetValueAsText(ColumnName);
        if (ValueAsText <> '') then
            Evaluate(r, ValueAsText);
        exit(r);
    end;


    /// <summary>
    /// Checks if a column value is a valid Integer.
    /// </summary>
    /// <param name="ColumnName">The name of the column to check.</param>
    /// <returns>True if the value is a valid Integer, false otherwise.</returns>
    [TryFunction]
    procedure IsValueInt(ColumnName: Text)
    var
        jv: JsonValue;
        TempValue: Integer;
    begin
        Clear(TempValue);
        jv := GetValue(ColumnName, false);
        TempValue := jv.AsInteger();
    end;

    /// <summary>
    /// Returns the value of the given column as Integer.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsInt(ColumnName: Text): Integer
    begin
        exit(GetValueAsInt(ColumnName, false));
    end;

    /// <summary>
    /// Returns the value of the given column as Integer.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <param name="WithError">Specifies whether to throw an error if the column does not exist.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsInt(ColumnName: Text; WithError: Boolean): Integer
    var
        jv: JsonValue;
    begin
        jv := GetValue(ColumnName, WithError);
        if (jv.IsNull()) then exit(0);
        exit(jv.AsInteger());
    end;


    /// <summary>
    /// Checks if a column value is a valid Decimal.
    /// </summary>
    /// <param name="ColumnName">The name of the column to check.</param>
    /// <returns>True if the value is a valid Decimal, false otherwise.</returns>
    [TryFunction]
    procedure IsValueDecimal(ColumnName: Text)
    var
        jv: JsonValue;
        TempValue: Decimal;
    begin
        Clear(TempValue);
        jv := GetValue(ColumnName, false);
        TempValue := jv.AsDecimal();
    end;

    /// <summary>
    /// Returns the value of the given column as Decimal.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsDecimal(ColumnName: Text): Decimal
    begin
        exit(GetValueAsDecimal(ColumnName, false));
    end;

    /// <summary>
    /// Returns the value of the given column as Decimal.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <param name="WithError">Specifies whether to throw an error if the column does not exist.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsDecimal(ColumnName: Text; WithError: Boolean): Decimal
    var
        jv: JsonValue;
    begin
        jv := GetValue(ColumnName, WithError);
        if (jv.IsNull()) then exit(0);
        exit(jv.AsDecimal());
    end;


    /// <summary>
    /// Checks if a column value is a valid DateTime.
    /// </summary>
    /// <param name="ColumnName">The name of the column to check.</param>
    /// <returns>True if the value is a valid DateTime, false otherwise.</returns>
    [TryFunction]
    procedure IsValueDateTime(ColumnName: Text)
    var
        jv: JsonValue;
        TempValue: DateTime;
    begin
        Clear(TempValue);
        jv := GetValue(ColumnName, false);
        TempValue := jv.AsDateTime();
    end;

    /// <summary>
    /// Returns the value of the given column as DateTime.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsDateTime(ColumnName: Text): DateTime
    begin
        exit(GetValueAsDateTime(ColumnName, false))
    end;

    /// <summary>
    /// Returns the value of the given column as DateTime.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <param name="WithError">Specifies whether to throw an error if the column does not exist.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsDateTime(ColumnName: Text; WithError: Boolean): DateTime
    var
        jv: JsonValue;
    begin
        jv := GetValue(ColumnName, WithError);
        if (jv.IsNull()) then exit(0DT);
        exit(jv.AsDateTime());
    end;


    /// <summary>
    /// Checks if a column value is a valid Date.
    /// </summary>
    /// <param name="ColumnName">The name of the column to check.</param>
    /// <returns>True if the value is a valid Date, false otherwise.</returns>
    [TryFunction]
    procedure IsValueDateOnly(ColumnName: Text)
    var
        TempValue: Date;
    begin
        Clear(TempValue);
        GetValueAsDateOnly(ColumnName);
    end;

    /// <summary>
    /// Returns the value of the given column as Date.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsDateOnly(ColumnName: Text): Date
    begin
        exit(GetValueAsDateOnly(ColumnName, false))
    end;

    /// <summary>
    /// Returns the value of the given column as Date.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <param name="WithError">Specifies whether to throw an error if the column does not exist.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsDateOnly(ColumnName: Text; WithError: Boolean): Date
    var
        jv: JsonValue;
        TextValue: Text;
        Result: Date;
    begin
        jv := GetValue(ColumnName, WithError);
        if (jv.IsNull()) then exit(0D);
        TextValue := jv.AsText();
        if (StrLen(TextValue) < 10) then exit(0D);
        if (WithError) then
            Evaluate(Result, TextValue.Substring(1, 10), 9)
        else
            if not Evaluate(Result, TextValue.Substring(1, 10), 9) then
                Clear(Result);
        exit(Result);
    end;


    /// <summary>
    /// Checks if a column value is a valid Boolean.
    /// </summary>
    /// <param name="ColumnName">The name of the column to check.</param>
    /// <returns>True if the value is a valid Boolean, false otherwise.</returns>
    [TryFunction]
    procedure IsValueBool(ColumnName: Text)
    var
        jv: JsonValue;
        TempValue: Boolean;
    begin
        Clear(TempValue);
        jv := GetValue(ColumnName, false);
        TempValue := jv.AsBoolean();
    end;

    /// <summary>
    /// Returns the value of the given column as Boolean.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsBool(ColumnName: Text): Boolean
    begin
        exit(GetValueAsBool(ColumnName, false));
    end;

    /// <summary>
    /// Returns the value of the given column as Boolean.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <param name="WithError">Specifies whether to throw an error if the column does not exist.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsBool(ColumnName: Text; WithError: Boolean): Boolean
    var
        jv: JsonValue;
    begin
        jv := GetValue(ColumnName, WithError);
        if (jv.IsNull()) then exit(false);
        exit(jv.AsBoolean());
    end;


    /// <summary>
    /// Checks if a column value is a valid Time.
    /// </summary>
    /// <param name="ColumnName">The name of the column to check.</param>
    /// <returns>True if the value is a valid Time, false otherwise.</returns>
    [TryFunction]
    procedure IsValueTime(ColumnName: Text)
    var
        jv: JsonValue;
        TempValue: Time;
    begin
        Clear(TempValue);
        jv := GetValue(ColumnName, false);
        TempValue := jv.AsTime();
    end;

    /// <summary>
    /// Returns the value of the given column as Time.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsTime(ColumnName: Text): Time
    begin
        exit(GetValueAsTime(ColumnName, false));
    end;

    /// <summary>
    /// Returns the value of the given column as Time.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <param name="WithError">Specifies whether to throw an error if the column does not exist.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsTime(ColumnName: Text; WithError: Boolean): Time
    var
        jv: JsonValue;
    begin
        jv := GetValue(ColumnName, WithError);
        if (jv.IsNull()) then exit(0T);
        exit(jv.AsTime());
    end;


    /// <summary>
    /// Returns the value of the given column as JsonObject.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsObject(ColumnName: Text): JsonObject
    begin
        exit(GetValueAsObject(ColumnName, false));
    end;

    /// <summary>
    /// Returns the value of the given column as JsonObject.
    /// </summary>
    /// <param name="ColumnName">The name of the column to get.</param>
    /// <param name="WithError">Specifies whether to throw an error if the column does not exist.</param>
    /// <returns>The value.</returns>
    procedure GetValueAsObject(ColumnName: Text; WithError: Boolean): JsonObject
    var
        jv: JsonValue;
        jo: JsonObject;
    begin
        jv := GetValue(ColumnName, WithError);
        if (jv.IsNull()) then exit(jo);
        jo.ReadFrom(jv.AsText());
        exit(jo);
    end;


    /// <summary>
    /// Returns the number of rows in the current result set.
    /// </summary>
    /// <returns>The number of rows.</returns>
    procedure RowCount(): Integer
    begin
        exit(TotalRowCount);
    end;

    /// <summary>
    /// Loads the row with the given index as the current row.
    /// </summary>
    /// <param name="NewRowIndex">The index of the row to load.</param>
    /// <returns>True if the row was loaded successfully.</returns>
    procedure GetRow(NewRowIndex: Integer): Boolean
    var
        jt: JsonToken;
    begin
        if (NewRowIndex < 0) or (NewRowIndex > TotalRowCount - 1) then exit(false);
        RowIndex := NewRowIndex;
        Rows.Get(RowIndex, jt);
        CurrRow := jt.AsArray();
        exit(true);
    end;

    /// <summary>
    /// Loads the next row as the current row.
    /// </summary>
    /// <returns>True if the row was loaded successfully.</returns>
    procedure GetNextRow(): Boolean
    begin
        exit(GetRow(RowIndex + 1));
    end;

    local procedure GetTable(name: Text; var result: JsonObject): Boolean
    var
        jo: JsonObject;
        jt: JsonToken;
        ja: JsonArray;
    begin
        Clear(result);
        jo.ReadFrom(LastResponse);
        ja := GetJsonArray(jo, 'tables');
        foreach jt in ja do
            if GetJsonText(jt.AsObject(), 'name') = name then begin
                result := jt.AsObject();
                exit(true);
            end;
        exit(false);
    end;


    /// <summary>
    /// Formats a date query for the given date range.
    /// </summary>
    /// <param name="FromDateTime">The start date and time.</param>
    /// <param name="ToDateTime">The end date and time.</param>
    /// <returns>>The formatted date query.</returns>
    procedure FormatDateQuery(FromDateTime: DateTime; ToDateTime: DateTime): Text
    var
        BetweenTok: Label 'between(datetime(%1) .. datetime(%2))', Locked = true;
    begin
        exit(StrSubstNo(BetweenTok, Format(FromDateTime, 0, 9), Format(ToDateTime, 0, 9)));
    end;

    /// <summary>
    /// Formats a date query for the given date range (from 00:00 to 23:59).
    /// </summary>
    /// <param name="FromDate">The start date and time.</param>
    /// <param name="ToDate">The end date and time.</param>
    /// <returns>>The formatted date query.</returns>
    procedure FormatDateQuery(FromDate: Date; ToDate: Date): Text
    begin
        exit(FormatDateQuery(CreateDateTime(FromDate, 000000T), CreateDateTime(ToDate, 235959T)));
    end;

    /// <summary>
    /// Returns true if the reader dialog is open.
    /// </summary>
    /// <returns>True if the reader dialog is open, false otherwise.</returns>
    procedure ReaderDialogIsOpen(): Boolean
    begin
        exit(ReaderDialogIsOpenValue);
    end;

    /// <summary>
    /// Deserializes the current row to the given RecordRef by trying to find a field with the same name for each column.
    /// Obsolete fields are excluded. 
    /// BLOB fields will be found, but by default no deserialization will happen. You must subscribe to `OnDeserializeToRecordRefSetBlobValue` and handled BLOB fields explicitly.
    /// There are DeserializeToRecordRef[xxx] events available to customize deserialization.
    /// </summary>
    /// <param name="RecRef">The target RecordRef where field values will be written to.</param>
    procedure DeserializeToRecordRef(var RecRef: Recordref)
    var
        TempBuffer: Record "Name/Value Buffer" temporary;
        Field: Record Field;
        FldRef: FieldRef;
        TextValue: Text;
        FoundFieldNo: Integer;
        IsHandled: Boolean;
    begin
        //Convert.FromXMLFormat(); //TBD
        Field.SetRange(TableNo, RecRef.Number);
        GetFields(TempBuffer);
        if TempBuffer.FindSet() then
            repeat
                Clear(FoundFieldNo);
                OnDeserializeToRecordRefBeforeFindFieldNo(TempBuffer.Name, RecRef, FoundFieldNo);
                if (FoundFieldNo = 0) then begin
                    // First try to match by field name (exact match)
                    Field.SetRange(FieldName, TempBuffer.Name);
                    Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
                    if Field.FindFirst() then
                        FoundFieldNo := Field."No."
                    else begin
                        // If not found by field name, try to match by field caption (exact match)
                        Field.SetRange(FieldName);
                        Field.SetRange("Field Caption", TempBuffer.Name);
                        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
                        if Field.FindFirst() then FoundFieldNo := Field."No.";
                    end;
                end;
                if (FoundFieldNo <> 0) then begin
                    FldRef := RecRef.Field(FoundFieldNo);
                    TextValue := GetValueAsText(TempBuffer.Name);
                    // Debug: Show field mapping (temporary for troubleshooting)
                    // Message('Mapping column "%1" to field %2 (%3) with value "%4"', TempBuffer.Name, FoundFieldNo, FldRef.Name, TextValue);
                    Clear(IsHandled);
                    OnDeserializeToRecordRefBeforeSetFieldValue(TempBuffer.Name, RecRef, FldRef, TextValue, IsHandled);
                    if (not IsHandled) then
                        if (FldRef.Type = FldRef.Type::Blob) then begin
                            Clear(IsHandled);
                            OnDeserializeToRecordRefSetBlobValue(TempBuffer.Name, RecRef, FldRef, TextValue, IsHandled);
                            FldRef := RecRef.Field(FoundFieldNo);
                        end else begin
                            if (Field.Len <> 0) and
                               (Field.Type in [Field.Type::Text, Field.Type::Code])
                            then
                                TextValue := CopyStr(TextValue, 1, Field.Len);
                            if (FldRef.Type = FldRef.Type::Guid) and (TextValue = '') then
                                TextValue := Format(EmptyGuid);
                            ConvertToFieldRef(TextValue, FldRef);
                        end;
                    OnDeserializeToRecordRefAfterSetFieldValue(TempBuffer.Name, RecRef, FldRef, TextValue);
                end else begin
                    // Debug: Show unmapped columns
                    // Message('Column "%1" could not be mapped to any field', TempBuffer.Name);
                end;
            until TempBuffer.Next() = 0;
    end;

    /// <summary>
    /// Opens a read status dialog.
    /// </summary>
    procedure OpenReaderDialog()
    begin
        if (not GuiAllowed()) then exit;
        Dlg.Open('#1# %');
        ReaderDialogIsOpenValue := true;
        ReaderDialogCounter[2] := RowCount();
        ReaderDialogCounter[1] := -1;
        ReaderDialogFreq := Round(ReaderDialogCounter[2] / 100, 1, '<');
        if ReaderDialogFreq = 0 then ReaderDialogFreq := 1;
        StepReaderDialog();
    end;

    /// <summary>
    /// Steps the read status dialog. This is called automatically when the dialog is open.
    /// </summary>
    procedure StepReaderDialog()
    begin
        if (not GuiAllowed()) or
           (not ReaderDialogIsOpen()) or
           (ReaderDialogCounter[2] = 0)
        then
            exit;
        ReaderDialogCounter[1] += 1;
        if ReaderDialogCounter[1] mod ReaderDialogFreq <> 0 then exit;
        Dlg.Update(1, Round(ReaderDialogCounter[1] / ReaderDialogCounter[2] * 100, 0.01));
    end;

    /// <summary>
    /// Closes the read status dialog.
    /// </summary>
    procedure CloseReaderDialog()
    begin
        if (not GuiAllowed()) or
           (not ReaderDialogIsOpen())
        then
            exit;
        Dlg.Close();
        ReaderDialogIsOpenValue := false;
    end;

    local procedure FormatGuid(guid: Guid): Text
    begin
        exit(Format(guid, 0, 9).ToLower().Substring(2, 36));
    end;

    local procedure GetJsonArray(jo: JsonObject; PropertyName: Text): JsonArray
    var
        jt: JsonToken;
        ja: JsonArray;
    begin
        if jo.Get(PropertyName, jt) then
            ja := jt.AsArray();
        exit(ja);
    end;

    local procedure GetJsonText(jo: JsonObject; PropertyName: Text): Text
    var
        jt: JsonToken;
        jv: JsonValue;
    begin
        if jo.Get(PropertyName, jt) then begin
            jv := jt.AsValue();
            if not jv.IsNull() then
                exit(jv.AsText());
        end;
        exit('');
    end;

    local procedure ExplodeConnectionString(ConnectionString: Text): Dictionary of [Text, Text]
    var
        parts: List of [Text];
        part: Text;
        kvp: List of [Text];
        result: Dictionary of [Text, Text];
    begin
        parts := ConnectionString.Split(';');
        foreach part in parts do begin
            kvp := part.Split('=');
            result.Add(kvp.Get(1), kvp.Get(2));
        end;
        exit(result);
    end;

    local procedure SplitConnectionString(ConnectionString: Text)
    var
        ub: Codeunit "Uri Builder";
        uri: Codeunit Uri;
        Dict: Dictionary of [Text, Text];
    begin
        Dict := ExplodeConnectionString(ConnectionString);
        _instrumentationKey := Dict.Get('InstrumentationKey');

        ub.Init(Dict.Get('IngestionEndpoint'));
        ub.SetPath(ub.GetPath() + 'v2/track');
        ub.GetUri(uri);
        _emitUri := uri.GetAbsoluteUri();
    end;

    local procedure ConvertToFieldRef(TextValue: Text; var FldRef: FieldRef)
    var
        TempDate: Date;
        TempDateTime: DateTime;
        TempTime: Time;
        TempDecimal: Decimal;
        TempInteger: Integer;
        TempBoolean: Boolean;
        TempGuid: Guid;
    begin
        if TextValue = '' then begin
            case FldRef.Type of
                FldRef.Type::Date:
                    FldRef.Value := 0D;
                FldRef.Type::DateTime:
                    FldRef.Value := 0DT;
                FldRef.Type::Time:
                    FldRef.Value := 0T;
                FldRef.Type::Decimal:
                    FldRef.Value := 0;
                FldRef.Type::Integer:
                    FldRef.Value := 0;
                FldRef.Type::Boolean:
                    FldRef.Value := false;
                FldRef.Type::Guid:
                    FldRef.Value := EmptyGuid;
                FldRef.Type::Text, FldRef.Type::Code:
                    FldRef.Value := '';
            end;
            exit;
        end;

        case FldRef.Type of
            FldRef.Type::Date:
                if Evaluate(TempDate, TextValue, 9) then
                    FldRef.Value := TempDate
                else
                    FldRef.Value := 0D;
            FldRef.Type::DateTime:
                if Evaluate(TempDateTime, TextValue, 9) then
                    FldRef.Value := TempDateTime
                else
                    FldRef.Value := 0DT;
            FldRef.Type::Time:
                if Evaluate(TempTime, TextValue, 9) then
                    FldRef.Value := TempTime
                else
                    FldRef.Value := 0T;
            FldRef.Type::Decimal:
                if Evaluate(TempDecimal, TextValue, 9) then
                    FldRef.Value := TempDecimal
                else
                    FldRef.Value := 0;
            FldRef.Type::Integer:
                if Evaluate(TempInteger, TextValue, 9) then
                    FldRef.Value := TempInteger
                else
                    FldRef.Value := 0;
            FldRef.Type::Boolean:
                if Evaluate(TempBoolean, TextValue, 9) then
                    FldRef.Value := TempBoolean
                else
                    FldRef.Value := false;
            FldRef.Type::Guid:
                if Evaluate(TempGuid, TextValue, 9) then
                    FldRef.Value := TempGuid
                else
                    FldRef.Value := EmptyGuid;
            FldRef.Type::Text, FldRef.Type::Code:
                FldRef.Value := TextValue;
            else
                FldRef.Value := TextValue;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeserializeToRecordRefBeforeFindFieldNo(ColumnName: Text[250]; var RecRef: RecordRef; var FoundFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeserializeToRecordRefBeforeSetFieldValue(ColumnName: Text[250]; var RecRef: RecordRef; var FldRef: FieldRef; TextValue: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeserializeToRecordRefAfterSetFieldValue(ColumnName: Text[250]; var RecRef: RecordRef; var FldRef: FieldRef; TextValue: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeserializeToRecordRefSetBlobValue(ColumnName: Text[250]; var RecRef: RecordRef; var FldRef: FieldRef; TextValue: Text; var Handled: Boolean)
    begin
    end;

}