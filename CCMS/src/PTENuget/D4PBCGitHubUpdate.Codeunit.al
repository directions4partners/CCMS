namespace D4P.CCMS.Nuget;

using D4P.CCMS.PTEApps;
using System.RestClient;
codeunit 62003 "D4P BC GitHub Update" implements "D4P BC DevOps Update"
{
    procedure GetNugetServiceTypeUrl(PTEApp: Record "D4P BC PTE App"; ServiceType: Text[100]): Text
    var
        RestClient: Codeunit "Rest Client";
        JsonToken: JsonToken;
    begin
        RestClient.SetAuthorizationHeader(GetToken(StrSubstNo('%1-%2', PTEApp.DevOps, PTEApp."DevOps Organization")));
        JsonToken := RestClient.GetAsJson(GetNugetServiceURL(PTEApp));
        exit(ProcessServices(JsonToken, ServiceType));
    end;

    procedure GetNugetServiceURL(PTEApp: Record "D4P BC PTE App"): Text
    var
        NugetServiceURL: Label 'https://nuget.pkg.github.com/%1/index.json', Locked = true, Comment = '%1 is Organization Name';
    begin
        exit(StrSubstNo(NugetServiceURL, PTEApp."DevOps Organization"));
    end;

    procedure GetToken(TokenName: Text[150]): SecretText
    var
        BearerLbl: Label 'Bearer %1', Locked = true, Comment = '%1 is the token string';
        Token: SecretText;
    begin
        if not IsolatedStorage.Contains(TokenName) then
            exit(Token); // Return empty token when no value is stored; caller must handle missing token (e.g., anonymous access or error).
        IsolatedStorage.Get(TokenName, Token);
        exit(SecretText.SecretStrSubstNo(BearerLbl, Token));
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

    procedure IsEnabled(): Boolean
    begin
        exit(true);
    end;
}