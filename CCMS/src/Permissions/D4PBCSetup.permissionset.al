namespace D4P.CCMS.Permissions;

using D4P.CCMS.Setup;

permissionset 62002 "D4P BC SETUP"
{
    Assignable = true;
    Caption = 'D365BC Admin Center - Setup Only';

    Permissions =
        // Setup table only
        tabledata "D4P BC Setup" = RIMD,
        table "D4P BC Setup" = X,
        page "D4P BC Setup" = X;
}