namespace D4P.CCMS.Environment;

using D4P.CCMS.Backup;
using D4P.CCMS.Capacity;
using D4P.CCMS.Tenant;
using D4P.CCMS.Extension;
using D4P.CCMS.Features;
using D4P.CCMS.Telemetry;
using D4P.CCMS.Session;

page 62003 "D4P BC Environment List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "D4P BC Environment";
    Caption = 'D365BC Environments';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number associated with this environment.';
                    Editable = false;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tenant ID of the environment.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the environment.';
                }
                field("Application Family"; Rec."Application Family")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application family of the environment.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the environment.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current state of the environment.';
                    StyleExpr = StateStyleExpr;
                }
                field("Contry/Region"; Rec."Contry/Region")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country/region of the environment.';
                }
                field("Current Version"; Rec."Current Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current version of Business Central.';
                }
                field("Target Version"; Rec."Target Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the target version of Business Central update.';
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Available"; Rec."Available")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether the target version has been released.';
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Target Version Type"; Rec."Target Version Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates the type of the target version (GA or Preview).';
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Selected DateTime"; Rec."Selected DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates the datetime for which the update to the target version has been scheduled.';
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Latest Selectable Date"; Rec."Latest Selectable Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates the last date for which the update to this target version can be scheduled.';
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Expected Availability"; Rec."Expected Availability")
                {
                    ApplicationArea = All;
                    ToolTip = 'Expected availability month/year for unreleased versions.';
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Rollout Status"; Rec."Rollout Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates the rollout status of updates to this target version.';
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Ignore Update Window"; Rec."Ignore Update Window")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether the update window for the environment may be ignored.';
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Application Insights String"; Rec."Application Insights String")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the connection string for Application Insights.';
                }
                field("Friendly Name"; Rec."Friendly Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the friendly/display name of the environment.';
                }
                field("Ring Name"; Rec."Ring Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the update ring name (e.g., Prod, Preview).';
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure Region where the environment database is stored.';
                }
                field("Geo Name"; Rec."Geo Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure Geo where the environment database is stored.';
                }
                field("Web Client Login URL"; Rec."Web Client Login URL")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the URL to log into the environment.';
                }
                field("Web Service URL"; Rec."Web Service URL")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the URL to access the environment service API.';
                }
                field("AppSource Apps Update Cadence"; Rec."AppSource Apps Update Cadence")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cadence for automatic AppSource apps updates.';
                }
                field("Platform Version"; Rec."Platform Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the platform version of the environment.';
                }
                field("Telemetry API Key"; Rec."Telemetry API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API key for telemetry data access (automatically retrieved from AppInsights Connection Setup).';
                    Editable = false;
                    ExtendedDatatype = Masked;
                }
                field("Telemetry Application ID"; Rec."Telemetry Application ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Application ID for telemetry data access (automatically retrieved from AppInsights Connection Setup).';
                    Editable = false;
                }
                field("Telemetry Tenant ID"; Rec."Telemetry Tenant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Tenant ID for telemetry data access (automatically retrieved from AppInsights Connection Setup).';
                    Editable = false;
                }
                field("Telemetry Description"; Rec."Telemetry Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description for the telemetry connection (automatically retrieved from AppInsights Connection Setup).';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetEnvironments)
            {
                ApplicationArea = All;
                Caption = 'Get';
                Image = Refresh;
                ToolTip = 'Get the list of environments.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    EnvironmentManagement.GetEnvironments(BCTenant);
                end;
            }
            action(GetEnvironmentUpdateInfo)
            {
                ApplicationArea = All;
                Caption = 'Get Updates';
                Image = UpdateDescription;
                ToolTip = 'Returns information about the available version updates for all environments in the list.';
                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    ProcessedCount: Integer;
                    ProgressDialog: Dialog;
                    TotalCount: Integer;
                begin
                    // Copy filter from current view
                    BCEnvironment.CopyFilters(Rec);
                    TotalCount := BCEnvironment.Count();

                    if TotalCount = 0 then
                        Error('No environments to update.');

                    if not Confirm('This will get update information for %1 environment(s). Continue?', true, TotalCount) then
                        exit;

                    ProgressDialog.Open('Processing environment #1#### of #2#### @3@@@@@@@@@@@@@@@@@@@@@@@@');

                    BCEnvironment.ReadIsolation := IsolationLevel::ReadUncommitted;
                    if BCEnvironment.FindSet() then
                        repeat
                            ProcessedCount += 1;
                            ProgressDialog.Update(1, ProcessedCount);
                            ProgressDialog.Update(2, TotalCount);
                            ProgressDialog.Update(3, Round(ProcessedCount / TotalCount * 10000, 1));

                            if BCTenant.Get(BCEnvironment."Customer No.", BCEnvironment."Tenant ID") then
                                EnvironmentManagement.GetEnvironmentUpdates(BCEnvironment, false);
                        until BCEnvironment.Next() = 0;

                    ProgressDialog.Close();
                    Message('Successfully processed %1 environment(s).', ProcessedCount);
                    CurrPage.Update(false);
                end;
            }
            action(CreateNewEnvironment)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = NewProperties;
                ToolTip = 'Creates a new environment.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    NewEnvironmentDialog: Page "D4P New Environment Dialog";
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    NewEnvironmentDialog.SetBCTenant(BCTenant);
                    if NewEnvironmentDialog.RunModal() = Action::OK then begin
                        NewEnvironmentDialog.CreateNewBCEnvironment();
                    end;
                end;
            }
            action(CopyEnvironment)
            {
                ApplicationArea = All;
                Caption = 'Copy';
                Image = Copy;
                ToolTip = 'Creates a copy for the selected environment.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    CopyEnvironmentDialog: Page "D4P Copy Environment Dialog";
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    CopyEnvironmentDialog.SetBCTenant(BCTenant);
                    CopyEnvironmentDialog.SetCurrentBCEnvironment(Rec.Name);
                    if CopyEnvironmentDialog.RunModal() = Action::OK then begin
                        CopyEnvironmentDialog.CopyEnvironment();
                    end;
                end;
            }
            action(RenameEnvironment)
            {
                ApplicationArea = All;
                Caption = 'Rename';
                Image = NewStatusChange;
                ToolTip = 'Renames selected environment.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    CopyEnvironmentDialog: Page "D4P Copy Environment Dialog";
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    CopyEnvironmentDialog.SetBCTenant(BCTenant);
                    CopyEnvironmentDialog.SetCurrentBCEnvironment(Rec.Name);
                    if CopyEnvironmentDialog.RunModal() = Action::OK then begin
                        CopyEnvironmentDialog.CopyEnvironment();
                    end;
                end;
            }
            action(RescheduleUpdate)
            {
                ApplicationArea = All;
                Caption = 'Reschedule Update';
                Image = Timesheet;
                ToolTip = 'Reschedule the update of the selected environment.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    RescheduleMsg: Label 'Are you sure you want to schedule the update of the environment %1 for %2?';
                    RescheduleErrorMsg: Label 'Target Version is not specified for the environment %1.';
                begin
                    if Rec."Target Version" = '' then
                        Error(RescheduleErrorMsg, Rec.Name);
                    if Confirm(RescheduleMsg, false, Rec.Name, rec."Selected DateTime") then begin
                        BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                        EnvironmentManagement.RescheduleBCEnvironmentUpgrade(BCTenant, Rec.Name, Rec."Target Version", Rec."Selected DateTime");
                    end;
                end;
            }
            action(DeleteAllFetched)
            {
                ApplicationArea = All;
                Caption = 'Delete All Fetched';
                Image = Delete;
                ToolTip = 'Delete all fetched environment records from the local database.';
                trigger OnAction()
                var
                    Environment: Record "D4P BC Environment";
                    DeleteMsg: Label 'Are you sure you want to delete all %1 fetched environment records from the local database?\This will NOT delete the actual environments in Business Central.';
                    RecordCount: Integer;
                begin
                    Environment.CopyFilters(Rec);
                    RecordCount := Environment.Count;
                    if RecordCount = 0 then
                        exit;

                    if Confirm(DeleteMsg, false, RecordCount) then begin
                        Environment.DeleteAll();
                        CurrPage.Update(false);
                        Message('%1 environment records deleted from local database.', RecordCount);
                    end;
                end;
            }
        }
        area(Navigation)
        {
            action(EnvironmentDetails)
            {
                ApplicationArea = All;
                Caption = 'Details';
                Image = ViewDetails;
                RunObject = Page "D4P BC Environment Card";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID"),
                            Name = field(Name);
                ToolTip = 'View detailed information about this environment.';
            }
            action(InstalledApps)
            {
                ApplicationArea = All;
                Caption = 'Installed Apps';
                Image = ExternalDocument;
                RunObject = Page "D4P BC Installed Apps List";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID"),
                            "Environment Name" = field(Name);
                ToolTip = 'View apps installed in this environment.';
            }
            action(DatabaseExports)
            {
                ApplicationArea = All;
                Caption = 'Database Exports';
                Image = Export;
                ToolTip = 'View database export history and start new exports for this environment.';

                trigger OnAction()
                var
                    BackupPage: Page "D4P BC Environment Backups";
                begin
                    BackupPage.SetEnvironmentContext(Rec);
                    BackupPage.RunModal();
                end;
            }
            action(RunTelemetryQuery)
            {
                ApplicationArea = All;
                Caption = 'Run Query';
                Image = Start;
                ToolTip = 'Select and run a telemetry query directly using the selected environment''s configuration.';

                trigger OnAction()
                var
                    TelemetryHelper: Codeunit "D4P Telemetry Helper";
                begin
                    TelemetryHelper.RunTelemetryQuery(Rec);
                end;
            }
            action(KQLQueries)
            {
                ApplicationArea = All;
                Caption = 'KQL Queries';
                Image = Log;
                ToolTip = 'View and execute KQL queries for telemetry data analysis on the selected environment.';

                trigger OnAction()
                var
                    TelemetryHelper: Codeunit "D4P Telemetry Helper";
                begin
                    TelemetryHelper.OpenKQLQueriesPage(Rec);
                end;
            }
            action(Telemetry)
            {
                ApplicationArea = All;
                Caption = 'Telemetry';
                Image = Log;
                RunObject = Page "D4P KQL Query Selection";
                ToolTip = 'View telemetry data for this environment.';
            }
            action(SetAppInsightsConnectionString)
            {
                ApplicationArea = All;
                Caption = 'Set Application Insights Connection String';
                Image = Setup;
                ToolTip = 'Sets the Application Insights connection string for the selected environment (telemetry).';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    AppInsightsMsg: Label 'Are you sure you want to set the Application Insights connection string for environment %1?';
                    RemoveAppInsightsMsg: Label 'Are you sure you want to remove the Application Insights connection string for environment %1?';
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    if Rec."Application Insights String" <> '' then begin
                        if Confirm(AppInsightsMsg, false, Rec.Name) then begin
                            EnvironmentManagement.SetApplicationInsightsConnectionString(Rec);
                        end;
                    end else begin
                        if Confirm(RemoveAppInsightsMsg, false, Rec.Name) then begin
                            EnvironmentManagement.SetApplicationInsightsConnectionString(Rec);
                        end;
                    end;
                end;
            }
            action(Features)
            {
                ApplicationArea = All;
                Caption = 'Features';
                Image = Setup;
                RunObject = Page "D4P BC Environment Features";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID"),
                            "Environment Name" = field(Name);
                ToolTip = 'View and manage features for this environment.';
            }
            action(Backups)
            {
                ApplicationArea = All;
                Caption = 'Backups';
                Image = History;
                RunObject = Page "D4P BC Environment Backups";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID"),
                            "Environment Name" = field(Name);
                ToolTip = 'View and manage backups for this environment.';
                Enabled = Rec.Type = 'Production';
            }
            action(Capacity)
            {
                ApplicationArea = All;
                Caption = 'Capacity';
                Image = Capacity;
                ToolTip = 'View capacity information for all environments.';

                trigger OnAction()
                var
                    CapacityWorksheet: Page "D4P BC Capacity Worksheet";
                    CapacityHeader: Record "D4P BC Capacity Header";
                begin
                    CapacityHeader.SetRange("Customer No.", Rec."Customer No.");
                    CapacityHeader.SetRange("Tenant ID", Format(Rec."Tenant ID"));
                    CapacityWorksheet.SetTableView(CapacityHeader);
                    CapacityWorksheet.Run();
                end;
            }
            action(Sessions)
            {
                ApplicationArea = All;
                Caption = 'Sessions';
                Image = Users;
                ToolTip = 'View active sessions for this environment.';

                trigger OnAction()
                var
                    SessionsPage: Page "D4P BC Environment Sessions";
                begin
                    SessionsPage.SetEnvironmentContext(Rec);
                    SessionsPage.Run();
                end;
            }
        }
        area(Promoted)
        {
            group(EnvironmentTasks)
            {
                Caption = 'Environment Tasks';
                actionref(GetEnvironmentsPromoted; GetEnvironments)
                {
                }
                actionref(EnvironmentDetailsPromoted; EnvironmentDetails)
                {
                }
                actionref(GetEnvironmentUpdateInfoPromoted; GetEnvironmentUpdateInfo)
                {
                }
                actionref(CreateNewEnvironmentPromoted; CreateNewEnvironment)
                {
                }
                actionref(CopyEnvironmentPromoted; CopyEnvironment)
                {
                }
                actionref(RenameEnvironmentPromoted; RenameEnvironment)
                {
                }
            }
            group(AppsTasks)
            {
                Caption = 'App Tasks';
                actionref(InstalledAppsPromoted; InstalledApps)
                {
                }
            }
            group(TelemetryTasks)
            {
                Caption = 'Telemetry';
                actionref(RunTelemetryQueryPromoted; RunTelemetryQuery)
                {
                }
                actionref(KQLQueriesPromoted; KQLQueries)
                {
                }
                actionref(SetAppInsightsConnectionStringPromoted; SetAppInsightsConnectionString)
                {
                }
            }
            group(AdvancedTasks)
            {
                Caption = 'Advanced';
                actionref(DatabaseExportsPromoted; DatabaseExports)
                {
                }
                actionref(TelemetryPromoted; Telemetry)
                {
                }
                actionref(FeaturesPromoted; Features)
                {
                }
                actionref(BackupsPromoted; Backups)
                {
                }
                actionref(CapacityPromoted; Capacity)
                {
                }
                actionref(SessionsPromoted; Sessions)
                {
                }
                actionref(DeleteAllFetchedPromoted; DeleteAllFetched)
                {
                }
            }
        }
    }

    var
        StateStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        // Set style for State field
        if Rec.State <> 'Active' then
            StateStyleExpr := 'Unfavorable'
        else
            StateStyleExpr := 'Standard';

        // Calculate flowfields for telemetry information
        if Rec."Application Insights String" <> '' then begin
            Rec.CalcFields("Telemetry API Key", "Telemetry Application ID", "Telemetry Tenant ID", "Telemetry Description");
        end;
    end;
}