namespace D4P.CCMS.Capacity;

using D4P.CCMS.Environment;
using D4P.CCMS.Tenant;
using D4P.CCMS.General;

codeunit 62018 "D4P BC Capacity Helper"
{
    var
        APIHelper: Codeunit "D4P BC API Helper";

    procedure GetCapacityData(CustomerNo: Code[20]; TenantID: Guid)
    var
        ProgressDialog: Dialog;
        ProcessingMsg: Label 'Retrieving capacity information...\\Please wait.';
        SuccessMsg: Label 'Capacity information retrieved successfully.';
    begin
        ProgressDialog.Open(ProcessingMsg);

        // Get quotas and storage for all environments
        GetQuotasAndStorage(CustomerNo, TenantID);

        ProgressDialog.Close();
        Message(SuccessMsg);
    end;

    local procedure GetQuotasAndStorage(CustomerNo: Code[20]; TenantID: Guid)
    var
        BCTenant: Record "D4P BC Tenant";
        CapacityHeader: Record "D4P BC Capacity Header";
        CapacityLine: Record "D4P BC Capacity Line";
        TenantIdText: Text[50];
    begin
        // Get the tenant record
        if not BCTenant.Get(CustomerNo, TenantID) then
            exit;

        // Delete existing capacity lines first
        TenantIdText := Format(TenantID);
        CapacityLine.SetRange("Customer No.", CustomerNo);
        CapacityLine.SetRange("Tenant ID", TenantIdText);
        CapacityLine.DeleteAll();

        // Delete existing capacity header
        if CapacityHeader.Get(CustomerNo, TenantIdText) then
            CapacityHeader.Delete();

        // Create new header
        CapacityHeader.Init();
        CapacityHeader."Customer No." := CustomerNo;
        CapacityHeader."Tenant ID" := TenantIdText;
        CapacityHeader."Last Update Date" := CurrentDateTime;
        CapacityHeader.Insert();

        // Get quotas
        GetQuotas(CapacityHeader, BCTenant);

        // Get storage for all environments
        GetAllEnvironmentsStorage(CapacityHeader, BCTenant);

        // Calculate totals and update header
        UpdateCapacityHeader(CapacityHeader);
    end;

    local procedure GetQuotas(var CapacityHeader: Record "D4P BC Capacity Header"; BCTenant: Record "D4P BC Tenant")
    var
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        JsonObject2: JsonObject;
        ResponseText: Text;
    begin
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET', '/environments/quotas', '', ResponseText) then
            exit;

        JsonResponse.ReadFrom(ResponseText);

        // Parse environmentsCount
        if JsonResponse.Get('environmentsCount', JsonToken) then begin
            JsonObject2 := JsonToken.AsObject();
            if JsonObject2.Get('production', JsonToken) then begin
                JsonValue := JsonToken.AsValue();
                CapacityHeader."Max Production Environments" := JsonValue.AsInteger();
            end;
            if JsonObject2.Get('sandbox', JsonToken) then begin
                JsonValue := JsonToken.AsValue();
                CapacityHeader."Max Sandbox Environments" := JsonValue.AsInteger();
            end;
        end;

        // Parse storageInKilobytes
        if JsonResponse.Get('storageInKilobytes', JsonToken) then begin
            JsonObject2 := JsonToken.AsObject();
            if JsonObject2.Get('default', JsonToken) then begin
                JsonValue := JsonToken.AsValue();
                CapacityHeader."Storage Default KB" := JsonValue.AsBigInteger();
                CapacityHeader."Storage Default GB" := Round(CapacityHeader."Storage Default KB" / 1024 / 1024, 0.01);
            end;
            if JsonObject2.Get('userLicenses', JsonToken) then begin
                JsonValue := JsonToken.AsValue();
                CapacityHeader."Storage User Licenses KB" := JsonValue.AsBigInteger();
                CapacityHeader."Storage User Licenses GB" := Round(CapacityHeader."Storage User Licenses KB" / 1024 / 1024, 0.01);
            end;
            if JsonObject2.Get('additionalCapacity', JsonToken) then begin
                JsonValue := JsonToken.AsValue();
                CapacityHeader."Storage Additional Capacity KB" := JsonValue.AsBigInteger();
                CapacityHeader."Storage Additional Capacity GB" := Round(CapacityHeader."Storage Additional Capacity KB" / 1024 / 1024, 0.01);
            end;
            if JsonObject2.Get('total', JsonToken) then begin
                JsonValue := JsonToken.AsValue();
                CapacityHeader."Storage Total KB" := JsonValue.AsBigInteger();
                CapacityHeader."Storage Total GB" := Round(CapacityHeader."Storage Total KB" / 1024 / 1024, 0.01);
            end;
        end;

        CapacityHeader.Modify();
    end;

    local procedure GetAllEnvironmentsStorage(var CapacityHeader: Record "D4P BC Capacity Header"; BCTenant: Record "D4P BC Tenant")
    var
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        ResponseText: Text;
        i: Integer;
    begin
        if not APIHelper.SendAdminAPIRequest(BCTenant, 'GET', '/environments/usedstorage', '', ResponseText) then
            exit;

        JsonResponse.ReadFrom(ResponseText);

        if JsonResponse.Get('value', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            for i := 0 to JsonArray.Count - 1 do begin
                JsonArray.Get(i, JsonToken);
                ProcessStorageObject(CapacityHeader, JsonToken.AsObject(), i + 1);
            end;
        end;
    end;

    local procedure ProcessStorageObject(var CapacityHeader: Record "D4P BC Capacity Header"; JsonObj: JsonObject; LineNo: Integer)
    var
        CapacityLine: Record "D4P BC Capacity Line";
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        DatabaseStorageKB: BigInteger;
    begin
        CapacityLine.Init();
        CapacityLine."Customer No." := CapacityHeader."Customer No.";
        CapacityLine."Tenant ID" := CapacityHeader."Tenant ID";
        CapacityLine."Line No." := LineNo;
        CapacityLine."Measurement Date" := CurrentDateTime;

        if JsonObj.Get('environmentName', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            CapacityLine."Environment Name" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(CapacityLine."Environment Name"));
        end;

        if JsonObj.Get('environmentType', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            CapacityLine."Environment Type" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(CapacityLine."Environment Type"));
        end;

        if JsonObj.Get('applicationFamily', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            CapacityLine."Application Family" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(CapacityLine."Application Family"));
        end;

        if JsonObj.Get('databaseStorageInKilobytes', JsonToken) then begin
            JsonValue := JsonToken.AsValue();
            DatabaseStorageKB := JsonValue.AsBigInteger();
            CapacityLine."Database Storage KB" := DatabaseStorageKB;
            CapacityLine."Database Storage MB" := Round(DatabaseStorageKB / 1024, 0.01);
            CapacityLine."Database Storage GB" := Round(DatabaseStorageKB / 1024 / 1024, 0.01);
        end;

        CapacityLine.Insert();
    end;

    local procedure UpdateCapacityHeader(var CapacityHeader: Record "D4P BC Capacity Header")
    var
        CapacityLine: Record "D4P BC Capacity Line";
        TotalStorageKB: BigInteger;
        ProductionCount: Integer;
        SandboxCount: Integer;
    begin
        // Calculate total storage used
        CapacityLine.SetRange("Customer No.", CapacityHeader."Customer No.");
        CapacityLine.SetRange("Tenant ID", CapacityHeader."Tenant ID");
        CapacityLine.ReadIsolation := IsolationLevel::ReadUncommitted;
        if CapacityLine.FindSet() then
            repeat
                TotalStorageKB += CapacityLine."Database Storage KB";
                if CapacityLine."Environment Type" = 'Production' then
                    ProductionCount += 1
                else
                    if CapacityLine."Environment Type" = 'Sandbox' then
                        SandboxCount += 1;
            until CapacityLine.Next() = 0;

        CapacityHeader."Total Storage Used KB" := TotalStorageKB;
        CapacityHeader."Total Storage Used GB" := Round(TotalStorageKB / 1024 / 1024, 0.01);
        CapacityHeader."Storage Available GB" := CapacityHeader."Storage Total GB" - CapacityHeader."Total Storage Used GB";

        // Count environments from header/lines
        CapacityHeader."Production Environments Used" := ProductionCount;
        CapacityHeader."Sandbox Environments Used" := SandboxCount;
        CapacityHeader."Production Env. Available" := CapacityHeader."Max Production Environments" - ProductionCount;
        CapacityHeader."Sandbox Env. Available" := CapacityHeader."Max Sandbox Environments" - SandboxCount;

        CapacityHeader.Modify();
    end;
}
