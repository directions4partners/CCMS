namespace D4P.CCMS.Permissions;

using D4P.CCMS.Backup;
using D4P.CCMS.Capacity;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Features;
using D4P.CCMS.General;
using D4P.CCMS.Operations;
using D4P.CCMS.Session;

permissionset 62004 "D4P BC ENV MANAGER"
{
    Assignable = true;
    Caption = 'D365BC Admin Center - Environment Management';
    // Read access to everything and execute on all objects. Customers, tenants and setup stay read only
    IncludedPermissionSets = "D4P BC ADMIN READ";
    Permissions =
        // CCMS keeps a local copy of the environment data that the Get actions delete and reload, so the user needs write access to it.
        // Changes in the environment itself go through the Admin API and are only allowed to members of the environment security group
        tabledata "D4P BC Environment" = RIMD,
        tabledata "D4P BC Installed App" = RIMD,
        tabledata "D4P BC Environment Feature" = RIMD,
        tabledata "D4P BC Environment Backup" = RIMD,
        tabledata "D4P BC Environment Session" = RIMD,
        tabledata "D4P BC Environment Operation" = RIMD,
        tabledata "D4P BC Capacity Header" = RIMD,
        tabledata "D4P BC Capacity Line" = RIMD,
        tabledata "D4P BC Admin Center Cue" = RIM;
}
