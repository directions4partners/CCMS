namespace D4P.CCMS.Operations;

using D4P.CCMS.Tenant;
using System.Reflection;
using D4P.CCMS.General;

codeunit 62025 "D4P BC Operations Helper"
{
    var
        APIHelper: Codeunit "D4P BC API Helper";

    /// <summary>
    /// Gets operations for a specific environment.
    /// </summary>
    /// <param name="CustomerNo">Customer number.</param>
    /// <param name="TenantID">Tenant ID.</param>
    /// <param name="EnvironmentName">Environment name.</param>
    procedure GetEnvironmentOperations(CustomerNo: Code[20]; TenantID: Guid; EnvironmentName: Text[100])
    var
        BCTenant: Record "D4P BC Tenant";
        TenantNotFoundForCustomerErr: Label 'Tenant %1 not found for customer %2.';
        OperationFetchErr: Label 'Failed to retrieve operations for environment %1.';
        ResponseText: Text;
        Endpoint: Text;
    begin
        if not BCTenant.Get(CustomerNo, TenantID) then
            Error(TenantNotFoundForCustomerErr, TenantID, CustomerNo);

        Endpoint := '/applications/businesscentral/environments/' + EnvironmentName + '/operations';
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET', Endpoint, '', ResponseText) then
            Error(OperationFetchErr, EnvironmentName);

        DeleteOperationsForEnvironment(CustomerNo, Format(TenantID), EnvironmentName);

        if ResponseText <> '' then
            ParseOperationsResponse(CustomerNo, Format(TenantID), ResponseText);
    end;

    local procedure ParseOperationsResponse(CustomerNo: Code[20]; TenantID: Text[50]; ResponseText: Text)
    var
        ParsingErr: Label 'Failed to parse response.';
        OperationsRetrievedMsg: Label '%1 operation(s) retrieved successfully.';
        JObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        i: Integer;
    begin
        if not JObject.ReadFrom(ResponseText) then
            Error(ParsingErr);

        if not JObject.Get('value', JToken) then
            exit;

        JArray := JToken.AsArray();

        for i := 0 to JArray.Count - 1 do begin
            JArray.Get(i, JToken);
            InsertOperation(CustomerNo, TenantID, JToken.AsObject());
        end;

        Message(OperationsRetrievedMsg, JArray.Count);
    end;

    local procedure InsertOperation(CustomerNo: Code[20]; TenantID: Text[50]; JOperation: JsonObject)
    var
        Operation: Record "D4P BC Environment Operation";
        JToken: JsonToken;
        JParameters: JsonObject;
        OperationID: Guid;
        ParametersText: Text;
        OutStream: OutStream;
    begin
        // Get Operation ID
        if not GetJsonGuid(JOperation, 'id', OperationID) then
            exit;

        Operation.Init();
        Operation."Customer No." := CustomerNo;
        Operation."Tenant ID" := TenantID;
        Operation."Operation ID" := OperationID;

        // Get basic fields
        Operation."Operation Type" := GetJsonText(JOperation, 'type');
        Operation.Status := GetJsonText(JOperation, 'status');
        Operation."AAD Tenant ID" := GetJsonText(JOperation, 'aadTenantId');
        Operation."Created By" := GetJsonText(JOperation, 'createdBy');
        Operation."Error Message" := CopyStr(GetJsonText(JOperation, 'errorMessage'), 1, MaxStrLen(Operation."Error Message"));

        // Get environment fields (at root level)
        Operation."Environment Name" := GetJsonText(JOperation, 'environmentName');
        Operation."Environment Type" := GetJsonText(JOperation, 'environmentType');
        Operation."Product Family" := GetJsonText(JOperation, 'productFamily');

        // Get datetime fields (time zone is UTC, convert to user time zone)
        Operation."Created On" := GetJsonDateTime(JOperation, 'createdOn');
        Operation."Started On" := GetJsonDateTime(JOperation, 'startedOn');
        Operation."Completed On" := GetJsonDateTime(JOperation, 'completedOn');

        // Get parameters and store as blob (parameters are different per operation type)
        if JOperation.Get('parameters', JToken) then begin
            JParameters := JToken.AsObject();
            JParameters.WriteTo(ParametersText);
            Operation.Parameters.CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.WriteText(ParametersText);
        end;

        Operation.Insert(true);
    end;

    local procedure GetJsonText(JObject: JsonObject; PropertyName: Text): Text
    var
        JToken: JsonToken;
    begin
        if JObject.Get(PropertyName, JToken) then
            if not JToken.AsValue().IsNull then
                exit(JToken.AsValue().AsText());
        exit('');
    end;

    local procedure GetJsonGuid(JObject: JsonObject; PropertyName: Text; var Value: Guid): Boolean
    var
        JToken: JsonToken;
        GuidText: Text;
    begin
        if JObject.Get(PropertyName, JToken) then begin
            GuidText := JToken.AsValue().AsText();
            exit(Evaluate(Value, GuidText));
        end;
        exit(false);
    end;

    local procedure GetJsonDateTime(JObject: JsonObject; PropertyName: Text): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        JToken: JsonToken;
        DateTimeText: Text;
        ResultDateTime: DateTime;
    begin
        if JObject.Get(PropertyName, JToken) then
            if not JToken.AsValue().IsNull then begin
                DateTimeText := JToken.AsValue().AsText();
                if Evaluate(ResultDateTime, DateTimeText, 9) then
                    exit(TypeHelper.ConvertDateTimeFromUTCToTimeZone(ResultDateTime, 'UTC'));
            end;
        exit(0DT);
    end;

    local procedure DeleteOperationsForEnvironment(CustomerNo: Code[20]; TenantID: Text; EnvironmentName: Text[100])
    var
        BCEnvironmentOperation: Record "D4P BC Environment Operation";
    begin
        BCEnvironmentOperation.SetRange("Customer No.", CustomerNo);
        BCEnvironmentOperation.SetRange("Tenant ID", TenantID);
        BCEnvironmentOperation.SetRange("Environment Name", EnvironmentName);
        BCEnvironmentOperation.DeleteAll(true);
    end;
}
