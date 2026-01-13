namespace D4P.CCMS.Nuget;

using D4P.CCMS.PTEApps;
using System.RestClient;
codeunit 62008 "D4P BC Nuget Processing"
{
    procedure GetPTEAppVersions(var PTEApp: Record "D4P BC PTE App")
    var
        BCDevOpsUpdate: Interface "D4P BC DevOps Update";
        ServiceTypeUrl: Text;
        ServiceType: Label 'SearchQueryService', Locked = true;
    begin
        DevOpsUpdateFactory(BCDevOpsUpdate, PTEApp."DevOps Environment");
        if not BCDevOpsUpdate.IsEnabled() then
            exit;
        ServiceTypeUrl := BCDevOpsUpdate.GetNugetServiceTypeUrl(PTEApp, ServiceType);
        if ServiceTypeUrl = '' then
            exit;
        GetAppVersions(PTEApp, BCDevOpsUpdate, ServiceTypeUrl);
    end;

    local procedure DevOpsUpdateFactory(var BCDevOpsUpdateInterface: Interface "D4P BC DevOps Update"; BCDevOpsEnvironments: Enum "D4P BC DevOps Environment")
    begin
        BCDevOpsUpdateInterface := BCDevOpsEnvironments;
    end;

    local procedure GetAppVersions(var PTEApp: Record "D4P BC PTE App"; BCDevOpsUpdate: Interface "D4P BC DevOps Update"; ServiceTypeUrl: Text)
    var
        RestClient: Codeunit "Rest Client";
        JsonToken: JsonToken;
        SearchURLLbl: Label '%1?q=%2', Locked = true, Comment = '%1 is Service Type URL, %2 is Package Name';
        SearchURL: Text;
    begin
        RestClient.SetAuthorizationHeader(BCDevOpsUpdate.GetToken(PTEApp."DevOps Organization"));
        SearchURL := StrSubstNo(SearchURLLbl, ServiceTypeUrl, PTEApp."NuGet Package Name");
        JsonToken := RestClient.GetAsJson(SearchURL);
        ProcessVersions(JsonToken, PTEApp, BCDevOpsUpdate);
    end;

    local procedure ProcessVersions(JsonToken: JsonToken; var PTEApp: Record "D4P BC PTE App"; var BCDevOpsUpdate: Interface "D4P BC DevOps Update")
    var
        JsonArray: JsonArray;
        TotalHits: Integer;
        PTEAppVersion: Record "D4P BC PTE App Version";
    begin
        if not JsonToken.IsObject() then
            exit;
        TotalHits := JsonToken.AsObject().GetInteger('totalHits');
        if TotalHits <> 1 then
            exit;
        JsonArray := JsonToken.AsObject().GetArray('data');
        JsonArray.Get(0, JsonToken);

        if JsonToken.AsObject().Contains('version') then
            PTEApp."Latest App Version" := JsonToken.AsObject().GetText('version');

        JsonArray := JsonToken.AsObject().GetArray('versions');
        foreach JsonToken in JsonArray do begin

            PTEAppVersion.Init();
            PTEAppVersion."PTE ID" := PTEApp."ID";
            PTEAppVersion."App Version" := JsonToken.AsObject().GetText('version');
            if PTEAppVersion.DoExists() then
                PTEAppVersion.Modify(true)
            else
                PTEAppVersion.Insert(true);

            PTEAppVersion."Package Content Url" := GetPackageContentUrl(PTEAppVersion, JsonToken.AsObject().GetText('@id'), BCDevOpsUpdate);
            PTEAppVersion.Modify(true);
        end;
    end;

    procedure GetPackageContentUrl(PTEAppVersion: Record "D4P BC PTE App Version"; PackageVersionUrl: Text; BCDevOpsUpdate: Interface "D4P BC DevOps Update"): Text
    var
        RestClient: Codeunit "Rest Client";
        JsonToken: JsonToken;
    begin
        RestClient.SetAuthorizationHeader(BCDevOpsUpdate.GetToken(PTEAppVersion.GetPTEOrganizationName()));
        JsonToken := RestClient.GetAsJson(PackageVersionUrl);
        if not JsonToken.IsObject() then
            exit('');
        if JsonToken.AsObject().Contains('packageContent') then
            exit(JsonToken.AsObject().GetText('packageContent'));
    end;

    procedure DownloadPackageContent(PTEAppVersion: Record "D4P BC PTE App Version"): Boolean
    var
        BCDevOpsUpdate: Interface "D4P BC DevOps Update";
        RestClient: Codeunit "Rest Client";
        Response: Codeunit "HTTP Response Message";
        Instream: InStream;
        FileName: Text;
    begin
        DevOpsUpdateFactory(BCDevOpsUpdate, PTEAppVersion.GetPTEAppDevOps());
        RestClient.SetAuthorizationHeader(BCDevOpsUpdate.GetToken(PTEAppVersion.GetPTEOrganizationName()));
        Response := RestClient.Get(PTEAppVersion."Package Content Url");
        if not Response.GetIsSuccessStatusCode() then
            exit(false);
        Instream := Response.GetContent().AsInStream();
        FileName := PTEAppVersion.GetPTEAppName() + '_' + PTEAppVersion."App Version" + '.app';
        exit(DownloadFromStream(Instream, 'Download App Package', '', '', FileName));
    end;

}