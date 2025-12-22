namespace D4P.CCMS.Session;

using System.Security.Authentication;
using System.Reflection;
using D4P.CCMS.Environment;
using D4P.CCMS.Tenant;
using D4P.CCMS.Setup;
using D4P.CCMS.General;

codeunit 62017 "D4P BC Session Helper"
{
    var
        APIHelper: Codeunit "D4P BC API Helper";

    procedure GetSessions(var BCEnvironment: Record "D4P BC Environment")
    var
        JsonResponse: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        ResponseText: Text;
        BCTenant: Record "D4P BC Tenant";
        ProgressDialog: Dialog;
        SessionCount: Integer;
        ProcessingMsg: Label 'Retrieving sessions...\\Please wait.';
        SuccessMsg: Label '%1 session(s) retrieved successfully.';
        NoSessionsMsg: Label 'No active sessions found.';
        Endpoint: Text;
        FailedToRetrieveErr: Label 'Failed to retrieve sessions: %1';
    begin
        ProgressDialog.Open(ProcessingMsg);

        // Get the tenant record
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Delete existing sessions for this environment
        DeleteSessionsForEnvironment(BCEnvironment);

        // Call Admin API to get sessions
        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/sessions';
        if APIHelper.SendAdminAPIRequest(BCTenant, 'GET', Endpoint, '', ResponseText) then begin
            JsonResponse.ReadFrom(ResponseText);

            if JsonResponse.Get('value', JsonToken) then begin
                JsonArray := JsonToken.AsArray();
                SessionCount := JsonArray.Count;
                ProcessSessionsArray(BCEnvironment, JsonArray);
                ProgressDialog.Close();
                if SessionCount > 0 then
                    Message(SuccessMsg, SessionCount)
                else
                    Message(NoSessionsMsg);
            end else begin
                ProgressDialog.Close();
                Message(NoSessionsMsg);
            end;
        end else begin
            ProgressDialog.Close();
            Error(FailedToRetrieveErr, ResponseText);
        end;
    end;

    procedure GetSessionDetails(var BCEnvironment: Record "D4P BC Environment"; SessionId: Text)
    var
        JsonResponse: JsonObject;
        ResponseText: Text;
        BCTenant: Record "D4P BC Tenant";
        BCSession: Record "D4P BC Environment Sessions";
        Endpoint: Text;
        SessionDetailsRefreshedMsg: Label 'Session details refreshed.';
        SessionDetailsRetrievedMsg: Label 'Session details retrieved.';
        FailedToRetrieveErr: Label 'Failed to retrieve session details: %1';
    begin
        // Get the tenant record
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Call Admin API to get session details
        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/sessions/' + SessionId;
        if APIHelper.SendAdminAPIRequest(BCTenant, 'GET', Endpoint, '', ResponseText) then begin
            JsonResponse.ReadFrom(ResponseText);

            // Update or insert the session details
            if BCSession.Get(SessionId) then begin
                ProcessSessionObject(BCEnvironment, JsonResponse, BCSession);
                BCSession.Modify();
                Message(SessionDetailsRefreshedMsg);
            end else
                Message(SessionDetailsRetrievedMsg);
        end else
            Error(FailedToRetrieveErr, ResponseText);
    end;

    procedure DeleteSession(var BCEnvironment: Record "D4P BC Environment"; SessionId: Text)
    var
        ResponseText: Text;
        BCTenant: Record "D4P BC Tenant";
        BCSession: Record "D4P BC Environment Sessions";
        ConfirmMsg: Label 'Are you sure you want to terminate session %1 for user %2?';
        Endpoint: Text;
        SessionNotFoundErr: Label 'Session %1 not found.';
        SessionTerminatedMsg: Label 'Session %1 terminated successfully.';
        FailedToTerminateErr: Label 'Failed to terminate session: %1';
    begin
        // Get the session record to show user info
        if not BCSession.Get(SessionId) then
            Error(SessionNotFoundErr, SessionId);

        if not Confirm(ConfirmMsg, false, SessionId, BCSession."User ID") then
            exit;

        // Get the tenant record
        BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID");

        // Call Admin API to delete session
        Endpoint := '/applications/' + BCEnvironment."Application Family" + '/environments/' + BCEnvironment.Name + '/sessions/' + SessionId;
        if APIHelper.SendAdminAPIRequest(BCTenant, 'DELETE', Endpoint, '', ResponseText) then begin
            Message(SessionTerminatedMsg, SessionId);
            // Remove the session from the local table
            if BCSession.Get(SessionId) then
                BCSession.Delete();
        end else
            Error(FailedToTerminateErr, ResponseText);
    end;

    local procedure DeleteSessionsForEnvironment(var BCEnvironment: Record "D4P BC Environment")
    var
        BCSession: Record "D4P BC Environment Sessions";
        TenantIdGuid: Guid;
    begin
        TenantIdGuid := BCEnvironment."Tenant ID";
        BCSession.SetRange("Customer No.", BCEnvironment."Customer No.");
        BCSession.SetRange("Tenant ID", Format(TenantIdGuid));
        BCSession.SetRange("Environment Name", BCEnvironment.Name);
        BCSession.DeleteAll();
    end;

    local procedure ProcessSessionsArray(var BCEnvironment: Record "D4P BC Environment"; JsonArray: JsonArray)
    var
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        BCSession: Record "D4P BC Environment Sessions";
    begin
        foreach JsonToken in JsonArray do begin
            JsonObject := JsonToken.AsObject();
            BCSession.Init();
            ProcessSessionObject(BCEnvironment, JsonObject, BCSession);
            BCSession.Insert();
        end;
    end;

    local procedure ProcessSessionObject(var BCEnvironment: Record "D4P BC Environment"; JsonObject: JsonObject; var BCSession: Record "D4P BC Environment Sessions")
    var
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        SessionIdInt: Integer;
        TenantIdGuid: Guid;
    begin
        BCSession."Customer No." := BCEnvironment."Customer No.";
        TenantIdGuid := BCEnvironment."Tenant ID";
        BCSession."Tenant ID" := Format(TenantIdGuid);
        BCSession."Environment Name" := BCEnvironment.Name;

        if JsonObject.Get('applicationFamily', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Application Family" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCSession."Application Family"));
        end;

        if JsonObject.Get('sessionId', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            SessionIdInt := JsonValue.AsInteger();
            BCSession."Session ID" := Format(SessionIdInt);
        end;

        if JsonObject.Get('userId', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."User ID" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCSession."User ID"));
        end;

        if JsonObject.Get('clientType', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Client Type" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCSession."Client Type"));
        end;

        if JsonObject.Get('logOnDate', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            // The API returns UTC time in format "12/18/2025 3:44:21 PM", convert to local time
            BCSession."Login Date" := ParseDateTimeFromAPI(JsonValue.AsText());
        end;

        if JsonObject.Get('entryPointOperation', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Entry Point Operation" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCSession."Entry Point Operation"));
        end;

        if JsonObject.Get('entryPointObjectName', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Entry Point Object Name" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCSession."Entry Point Object Name"));
        end;

        if JsonObject.Get('entryPointObjectId', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Entry Point Object ID" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCSession."Entry Point Object ID"));
        end;

        if JsonObject.Get('entryPointObjectType', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Entry Point Object Type" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCSession."Entry Point Object Type"));
        end;

        if JsonObject.Get('currentObjectName', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Current Object Name" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCSession."Current Object Name"));
        end;

        if JsonObject.Get('currentObjectId', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Current Object ID" := JsonValue.AsInteger();
        end;

        if JsonObject.Get('currentObjectType', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Current Object Type" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(BCSession."Current Object Type"));
        end;

        if JsonObject.Get('currentOperationDuration', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            BCSession."Current Operation Duration" := JsonValue.AsInteger();
        end;
    end;

    local procedure ParseDateTimeFromAPI(DateTimeText: Text): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        DateTimeValue: Variant;
        ParsedDateTime: DateTime;
    begin
        DateTimeValue := ParsedDateTime;
        if TypeHelper.Evaluate(DateTimeValue, DateTimeText, 'M/d/yyyy h:mm:ss tt', 'en-US') then begin
            ParsedDateTime := DateTimeValue;
            exit(TypeHelper.ConvertDateTimeFromInputTimeZoneToClientTimezone(ParsedDateTime, 'UTC'));
        end;
        exit(0DT);
    end;
}
