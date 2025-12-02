namespace D4P.CCMS.Permissions;

using D4P.CCMS.Customer;
using D4P.CCMS.Tenant;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Setup;
using D4P.CCMS.Features;
using D4P.CCMS.Backup;
using D4P.CCMS.Capacity;
using D4P.CCMS.Session;
using D4P.CCMS.Telemetry;

permissionset 62001 "D4P BC ADMIN READ"
{
    Assignable = true;
    Caption = 'D365BC Admin Center - Read Only Access';

    Permissions =
        // Tables - Read only
        tabledata "D4P BC Customer" = R,
        tabledata "D4P BC Tenant" = R,
        tabledata "D4P BC Environment" = R,
        tabledata "D4P BC Installed Apps" = R,
        tabledata "D4P BC Setup" = R,
        tabledata "D4P BC Environment Features" = R,
        tabledata "D4P BC Environment Backup" = R,
        tabledata "D4P BC Capacity Header" = R,
        tabledata "D4P BC Capacity Line" = R,
        tabledata "D4P BC Environment Sessions" = R,
        tabledata "D4P KQL Query Store" = R,
        tabledata "D4P KQL Extension Lifecycle" = RIMD,
        tabledata "D4P KQL Page Execution" = RIMD,
        tabledata "D4P KQL Report Execution" = RIMD,
        tabledata "D4P KQL Slow AL Method" = RIMD,
        tabledata "D4P AppInsights Connection" = R,
        tabledata "D4P PTE Object Range" = R,

        // Table Objects
        table "D4P BC Customer" = X,
        table "D4P BC Tenant" = X,
        table "D4P BC Environment" = X,
        table "D4P BC Installed Apps" = X,
        table "D4P BC Setup" = X,
        table "D4P BC Environment Features" = X,
        table "D4P BC Environment Backup" = X,
        table "D4P BC Capacity Header" = X,
        table "D4P BC Capacity Line" = X,
        table "D4P BC Environment Sessions" = X,
        table "D4P KQL Query Store" = X,
        table "D4P KQL Extension Lifecycle" = X,
        table "D4P KQL Page Execution" = X,
        table "D4P KQL Report Execution" = X,
        table "D4P KQL Slow AL Method" = X,
        table "D4P AppInsights Connection" = X,
        table "D4P PTE Object Range" = X,

        // Pages - List and Card pages for viewing
        page "D4P BC Customers List" = X,
        page "D4P BC Customer Card" = X,
        page "D4P BC Tenant List" = X,
        page "D4P BC Environment List" = X,
        page "D4P BC Environment Card" = X,
        page "D4P BC Installed Apps List" = X,
        page "D4P BC Environment Features" = X,
        page "D4P BC Environment Backups" = X,
        page "D4P BC Capacity Worksheet" = X,
        page "D4P BC Capacity Subform" = X,
        page "D4P BC Capacity Card" = X,
        page "D4P BC Environment Sessions" = X,
        page "D4P KQL Query Selection" = X,
        page "D4P KQL Queries" = X,
        page "D4P KQL Query Preview" = X,
        page "D4P KQL Extension Lifecycle" = X,
        page "D4P KQL Page Executions" = X,
        page "D4P KQL Report Executions" = X,
        page "D4P KQL Slow AL Methods" = X,
        page "D4P AppInsights Conn List" = X,
        page "D4P AppInsights Conn Card" = X,
        page "D4P PTE Object Ranges" = X,

        // Codeunit for reading data
        codeunit "D4P BC Environment Mgt" = X,
        codeunit "D4P BC Debug Helper" = X,
        codeunit "D4P AppInsights Client" = X,
        codeunit "D4P KQL Query Store Init" = X,
        codeunit "D4P Telemetry Helper" = X,

        // Reports - needed for telemetry queries
        report "D4P Load Data" = X;
}