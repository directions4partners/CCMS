namespace D4P.CCMS.Permissions;

using D4P.CCMS.Environment;
using D4P.CCMS.Telemetry;
using D4P.CCMS.Setup;

permissionset 62003 "D4P BC TELEMETRY"
{
    Assignable = true;
    Caption = 'D365BC Admin Center - Telemetry Only';

    Permissions =
        // Core environment data (read-only for telemetry)
        tabledata "D4P BC Environment" = R,
        table "D4P BC Environment" = X,

        // AppInsights Connection Setup (read-only for security)
        tabledata "D4P AppInsights Connection" = R,
        table "D4P AppInsights Connection" = X,

        // KQL Query Store (read-only to prevent query modification)
        tabledata "D4P KQL Query Store" = R,
        table "D4P KQL Query Store" = X,

        // KQL Result tables (full access for storing query results)
        tabledata "D4P KQL Extension Lifecycle" = RIMD,
        tabledata "D4P KQL Page Execution" = RIMD,
        tabledata "D4P KQL Report Execution" = RIMD,
        tabledata "D4P KQL Slow AL Method" = RIMD,
        table "D4P KQL Extension Lifecycle" = X,
        table "D4P KQL Page Execution" = X,
        table "D4P KQL Report Execution" = X,
        table "D4P KQL Slow AL Method" = X,

        // Setup table (read-only for debug mode check)
        tabledata "D4P BC Setup" = R,
        table "D4P BC Setup" = X,

        // Pages for telemetry functionality
        page "D4P BC Environment List" = X,
        page "D4P BC Environment Card" = X,
        page "D4P KQL Query Selection" = X,
        page "D4P KQL Queries" = X,
        page "D4P KQL Query Preview" = X,
        page "D4P KQL Extension Lifecycle" = X,
        page "D4P KQL Page Executions" = X,
        page "D4P KQL Report Executions" = X,
        page "D4P KQL Slow AL Methods" = X,
        page "D4P AppInsights Conn List" = X,
        page "D4P AppInsights Conn Card" = X,

        // Codeunits for telemetry functionality
        codeunit "D4P AppInsights Client" = X,
        codeunit "D4P KQL Query Store Init" = X,
        codeunit "D4P Telemetry Helper" = X,

        // Reports for running telemetry queries
        report "D4P Load Data" = X;
}