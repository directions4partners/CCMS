namespace D4P.CCMS.Permissions;

using D4P.CCMS.Backup;
using D4P.CCMS.Capacity;
using D4P.CCMS.Customer;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Features;
using D4P.CCMS.PartnerCenter;
using D4P.CCMS.Operations;
using D4P.CCMS.General;
using D4P.CCMS.Session;
using D4P.CCMS.Setup;
using D4P.CCMS.Telemetry;
using D4P.CCMS.Tenant;

permissionset 62001 "D4P BC ADMIN READ"
{
    Assignable = true;
    Caption = 'D365BC Admin Center - Read Only Access';
    Permissions =        
        tabledata * = R,
        table * = X,
        page * = X,
        report * = X,
        codeunit * = X;
}
