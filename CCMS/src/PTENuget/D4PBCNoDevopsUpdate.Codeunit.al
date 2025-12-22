namespace D4P.CCMS.Nuget;

using D4P.CCMS.PTEApps;
codeunit 62006 "D4P BC NoDevops Update" implements "D4P BC Devops Update"
{
    procedure GetUpdates(PTEApp: Record "D4P BC PTE App")
    begin

    end;

    procedure GetNugetServiceTypeUrl(PTEApp: Record "D4P BC PTE App"; ServiceType: Text[100]): Text
    begin

    end;

    procedure GetNugetServiceURL(PTEApp: Record "D4P BC PTE App"): Text
    begin

    end;

    procedure GetToken(OrganizationName: Text[100]): SecretText
    begin

    end;

    procedure IsEnabled(): Boolean
    begin
        exit(false);
    end;
}