namespace D4P.CCMS.Telemetry;

using D4P.CCMS.Environment;

codeunit 62032 "D4P Telemetry Helper"
{
    /// <summary>
    /// Validates that an environment has telemetry properly configured
    /// </summary>
    /// <param name="Environment">The environment to validate</param>
    /// <returns>True if validation passes, otherwise throws an error</returns>
    procedure ValidateEnvironmentTelemetrySetup(Environment: Record "D4P BC Environment"): Boolean
    var
        AIConnectionSetup: Record "D4P AppInsights Connection";
        NoConnectionStringErr: Label 'The environment "%1" does not have an Application Insights connection string configured. Please configure telemetry first.';
    begin
        // Verify environment has telemetry configuration
        if Environment."Application Insights String" = '' then
            Error(NoConnectionStringErr, Environment.Name);

        // Optional: Load additional details from setup if it exists
        // If the connection string is not in the setup table, we'll use the raw connection string
        if AIConnectionSetup.Get(Environment."Application Insights String") then
            exit(true);

        // Connection string exists on environment but not in setup table
        // This is acceptable - we can use the connection string directly
        exit(true);
    end;

    /// <summary>
    /// Opens KQL Queries page with environment context
    /// </summary>
    /// <param name="Environment">The environment to use for telemetry queries</param>
    procedure OpenKQLQueriesPage(Environment: Record "D4P BC Environment")
    var
        KQLQueriesPage: Page "D4P KQL Queries";
    begin
        ValidateEnvironmentTelemetrySetup(Environment);

        // Set the environment context and open the page
        KQLQueriesPage.SetEnvironmentContext(Environment);
        KQLQueriesPage.Run();
    end;

    /// <summary>
    /// Runs a telemetry query with environment context
    /// </summary>
    /// <param name="Environment">The environment to use for telemetry query execution</param>
    procedure RunTelemetryQuery(Environment: Record "D4P BC Environment")
    var
        KQLQueryStore: Record "D4P KQL Query Store";
        KQLQuerySelection: Page "D4P KQL Query Selection";
        LoadData: Report "D4P Load Data";
    begin
        ValidateEnvironmentTelemetrySetup(Environment);

        // Let user select a query
        KQLQuerySelection.LookupMode(true);
        if KQLQuerySelection.RunModal() = ACTION::LookupOK then begin
            KQLQuerySelection.GetRecord(KQLQueryStore);

            // Run the selected query directly with this environment's context
            LoadData.InitRequestFromEnvironment(Environment, KQLQueryStore.Code);
            LoadData.Run();
        end;
    end;
}
