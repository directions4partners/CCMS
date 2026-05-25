namespace D4P.CCMS.Nuget;

using D4P.CCMS.PTEApps;
using System.RestClient;

codeunit 62004 "D4P BC Azure Update" implements "D4P BC DevOps Update"
{
    procedure GetNugetServiceTypeUrl(PTEApp: Record "D4P BC PTE App"; ServiceType: Text[100]): Text
    var
        RestClient: Codeunit "Rest Client";
        JsonToken: JsonToken;
    begin
        RestClient.SetAuthorizationHeader(GetToken(PTEApp."DevOps Organization"));
        JsonToken := RestClient.GetAsJson(GetNugetServiceURL(PTEApp));
        exit(ProcessServices(JsonToken, ServiceType));
    end;

    procedure GetNugetServiceURL(PTEApp: Record "D4P BC PTE App"): Text
    var
        NugetServiceURL: Label 'https://pkgs.dev.azure.com/%1/%2/_packaging/%3/nuget/v3/index.json', Locked = true, Comment = '%1 is Organization Name, %2 is Project Name, %3 is Feed Name';
    begin
        exit(StrSubstNo(NugetServiceURL, PTEApp."DevOps Organization", PTEApp."DevOps Package", PTEApp."DevOps Feed"));
    end;

    procedure GetToken(TokenName: Text[150]): SecretText
    var
        BearerLbl: Label 'Bearer %1', Locked = true, Comment = '%1 is the token string';
        Token: SecretText;
    begin
        if not IsolatedStorage.Contains(TokenName) then
            exit(Token); // No token stored for this organization; return empty value so the caller can handle missing authorization (e.g., anonymous access or explicit error handling).
        IsolatedStorage.Get(TokenName, Token);
        exit(SecretText.SecretStrSubstNo(BearerLbl, Token));
    end;

    procedure IsEnabled(): Boolean
    begin
        exit(false);
        // Azure DevOps support is intentionally disabled by default
        // pending final testing/completion of this implementation.
    end;

    local procedure ProcessServices(JsonToken: JsonToken; ServiceType: Text[100]): Text
    var
        JsonObject: JsonObject;
        ServiceArray: JsonArray;
        ServiceToken: JsonToken;
        ServiceTypeName: Text;
    begin
        if not JsonToken.IsObject() then
            exit('');
        JsonObject := JsonToken.AsObject();
        ServiceArray := JsonObject.GetArray('resources');
        foreach ServiceToken in ServiceArray do begin
            if not ServiceToken.IsObject() then
                continue;
            ServiceTypeName := ServiceToken.AsObject().GetText('@type');
            if ServiceTypeName = ServiceType then
                exit(ServiceToken.AsObject().GetText('@id'));
        end;
    end;
}