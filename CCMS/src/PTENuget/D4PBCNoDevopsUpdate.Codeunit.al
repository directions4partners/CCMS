namespace D4P.CCMS.Nuget;

using D4P.CCMS.PTEApps;
codeunit 62006 "D4P BC NoDevOps Update" implements "D4P BC DevOps Update"
{
    procedure GetNugetServiceTypeUrl(PTEApp: Record "D4P BC PTE App"; ServiceType: Text[100]): Text
    begin
    end;

    procedure GetNugetServiceURL(PTEApp: Record "D4P BC PTE App"): Text
    begin
    end;

    procedure GetToken(TokenName: Text[150]): SecretText
    begin
    end;

    procedure IsEnabled(): Boolean
    begin
        exit(false);
    end;
}