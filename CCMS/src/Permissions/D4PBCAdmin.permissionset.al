namespace D4P.CCMS.Permissions;

using D4P.CCMS.Auth;
using D4P.CCMS.Backup;
using D4P.CCMS.Capacity;
using D4P.CCMS.Customer;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Features;
using D4P.CCMS.PartnerCenter;
using D4P.CCMS.General;
using D4P.CCMS.Operations;
using D4P.CCMS.Session;
using D4P.CCMS.Setup;
using D4P.CCMS.Telemetry;
using D4P.CCMS.Tenant;
using D4P.CCMS.Connector.RestClientOAuth;
using D4P.CCMS.Connector;

permissionset 62000 "D4P BC ADMIN"
{
    Assignable = true;
    Caption = 'D365BC Admin Center - Full Access';
    Permissions =
        tabledata * = RIMD,
        table * = X,
        page * = X,
        report * = X,
        codeunit * = X;
}