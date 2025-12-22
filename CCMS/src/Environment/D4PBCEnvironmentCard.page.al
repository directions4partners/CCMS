namespace D4P.CCMS.Environment;

using D4P.CCMS.Tenant;
using D4P.CCMS.Telemetry;
using D4P.CCMS.Extension;
using D4P.CCMS.Features;
using D4P.CCMS.Backup;
using D4P.CCMS.Capacity;
using D4P.CCMS.Session;

page 62004 "D4P BC Environment Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "D4P BC Environment";
    Caption = 'D365BC Environment Details';
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
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
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the environment.';
                    Editable = false;
                }
                field("Friendly Name"; Rec."Friendly Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the friendly/display name of the environment.';
                    Editable = false;
                }
                field("Application Family"; Rec."Application Family")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application family of the environment.';
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the environment.';
                    Editable = false;
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current state of the environment.';
                    Editable = false;
                    StyleExpr = StateStyleExpr;
                }
            }
            group(Location)
            {
                Caption = 'Location';
                field("Country/Region"; Rec."Country/Region")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country/region of the environment.';
                    Editable = false;
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure Region where the environment database is stored.';
                    Editable = false;
                }
                field("Geo Name"; Rec."Geo Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure Geo where the environment database is stored.';
                    Editable = false;
                }
            }
            group(Versions)
            {
                Caption = 'Versions';
                field("Current Version"; Rec."Current Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current version of Business Central.';
                    Editable = false;
                }
                field("Platform Version"; Rec."Platform Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the platform version of the environment.';
                    Editable = false;
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
                field("Ring Name"; Rec."Ring Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the update ring name (e.g., Prod, Preview).';
                    Editable = false;
                }
                field("Grace Period Start Date"; Rec."Grace Period Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the grace period start date for the current major version.';
                    Editable = false;
                }
                field("Enforced Update Period Start"; Rec."Enforced Update Period Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the enforced update period start date for the current major version.';
                    Editable = false;
                }
            }
            group(URLs)
            {
                Caption = 'Access';
                field("Web Client Login URL"; Rec."Web Client Login URL")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the URL to log into the environment.';
                    Editable = false;
                }
                field("Web Service URL"; Rec."Web Service URL")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the URL to access the environment service API.';
                    Editable = false;
                }
            }
            group(Telemetry)
            {
                Caption = 'Telemetry & Monitoring';
                field("Application Insights String"; Rec."Application Insights String")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the connection string for Application Insights. Use the lookup to select from existing configurations or type directly to create new entries.';
                    MaskType = Concealed;

                    trigger OnValidate()
                    var
                        AIConnectionSetup: Record "D4P AppInsights Connection";
                        AIConnectionSetupCard: Page "D4P AppInsights Conn Card";
                    begin
                        // If a new connection string is entered and doesn't exist, offer to create it
                        if (Rec."Application Insights String" <> '') and (not AIConnectionSetup.Get(Rec."Application Insights String")) then begin
                            if Confirm('The connection string "%1" does not exist in the setup. Do you want to create it now?', false, Rec."Application Insights String") then begin
                                AIConnectionSetup.Init();
                                AIConnectionSetup."AppInsights Connection String" := Rec."Application Insights String";
                                AIConnectionSetup.Insert(true);

                                // Open the card for the user to fill in additional details
                                AIConnectionSetupCard.SetRecord(AIConnectionSetup);
                                AIConnectionSetupCard.RunModal();
                            end;
                        end;

                        // Refresh flowfields when connection string changes
                        if Rec."Application Insights String" <> '' then begin
                            Rec.CalcFields("Telemetry API Key", "Telemetry Application ID", "Telemetry Tenant ID", "Telemetry Description");
                            CurrPage.Update();
                        end;
                    end;

                    trigger OnAssistEdit()
                    var
                        AIConnectionSetup: Record "D4P AppInsights Connection";
                        AIConnectionSetupList: Page "D4P AppInsights Conn List";
                    begin
                        // Open lookup to select existing connection
                        AIConnectionSetupList.LookupMode(true);
                        if AIConnectionSetupList.RunModal() = ACTION::LookupOK then begin
                            AIConnectionSetupList.GetRecord(AIConnectionSetup);
                            Rec."Application Insights String" := AIConnectionSetup."AppInsights Connection String";
                            Rec.Modify();

                            // Refresh flowfields after lookup
                            Rec.CalcFields("Telemetry API Key", "Telemetry Application ID", "Telemetry Tenant ID", "Telemetry Description");
                            CurrPage.Update();
                        end;
                    end;
                }
                field("Telemetry API Key"; Rec."Telemetry API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API key for telemetry data access (automatically retrieved from AppInsights Connection Setup).';
                    ExtendedDatatype = Masked;
                }
                field("Telemetry Application ID"; Rec."Telemetry Application ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Application ID for telemetry data access (automatically retrieved from AppInsights Connection Setup).';
                }
                field("Telemetry Tenant ID"; Rec."Telemetry Tenant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Tenant ID for telemetry data access (automatically retrieved from Application Insights Connection Setup).';
                }
                field("Telemetry Description"; Rec."Telemetry Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description for the telemetry connection (automatically retrieved from Application Insights Connection Setup).';
                }
            }
            group(AppManagement)
            {
                Caption = 'App Management';
                field("AppSource Apps Update Cadence"; Rec."AppSource Apps Update Cadence")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cadence for automatic AppSource apps updates.';
                    Editable = false;
                }
                field("Linked PowerPlatform Env ID"; Rec."Linked PowerPlatform Env ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the linked Power Platform environment ID.';
                    Editable = false;
                }
            }
            group(Deletion)
            {
                Caption = 'Deletion';
                Visible = DeletionInfoVisible;
                field("Soft Deleted On"; Rec."Soft Deleted On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the environment was soft deleted.';
                    Editable = false;
                }
                field("Hard Delete Pending On"; Rec."Hard Delete Pending On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the environment will be permanently deleted.';
                    Editable = false;
                }
                field("Delete Reason"; Rec."Delete Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason why the environment was deleted.';
                    Editable = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(InstalledApp; "D4P BC Installed Apps FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID"),
                            "Environment Name" = field(Name);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetEnvironmentUpdateInfo)
            {
                ApplicationArea = All;
                Caption = 'Get Updates';
                Image = UpdateDescription;
                ToolTip = 'Returns information about the available version update for the specified environment.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    EnvironmentManagement.GetEnvironmentUpdates(Rec, true);
                    CurrPage.Update(false);
                end;
            }
            action(GetEnvironmentAppsUpdateInfo)
            {
                ApplicationArea = All;
                Caption = 'Get App Updates';
                Image = UpdateXML;
                ToolTip = 'Returns information about the available apps update for the specified environment.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    EnvironmentManagement.GetAvailableAppUpdates(Rec);
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
            action(DeleteEnvironment)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Image = "Invoicing-Delete";
                ToolTip = 'Deletes the selected environment.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    DeleteMsg: Label 'Are you sure you want to delete the environment %1?';
                begin
                    if Confirm(DeleteMsg, false, Rec.Name) then begin
                        BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                        EnvironmentManagement.DeleteBCEnvironment(BCTenant, Rec.Name);
                    end;
                end;
            }
            action(RescheduleUpdate)
            {
                ApplicationArea = All;
                Caption = 'Reschedule Update';
                Image = Timesheet;
                ToolTip = 'Select and schedule an update version for the environment.';
                trigger OnAction()
                var
                    TempAvailableUpdate: Record "D4P BC Available Update" temporary;
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    UpdateSelectionDialog: Page "D4P Update Selection Dialog";
                    TargetVersion: Text[100];
                    SelectedDate: Date;
                    ExpectedMonth: Integer;
                    ExpectedYear: Integer;
                    NoUpdatesAvailableErr: Label 'No updates available for the environment %1.';
                begin
                    // Get available updates from API
                    EnvironmentManagement.GetAvailableUpdates(Rec, TempAvailableUpdate);

                    if TempAvailableUpdate.IsEmpty() then
                        Error(NoUpdatesAvailableErr, Rec.Name);

                    // Pass data to selection dialog and show it
                    UpdateSelectionDialog.SetData(TempAvailableUpdate);
                    if UpdateSelectionDialog.RunModal() = Action::OK then begin
                        UpdateSelectionDialog.GetSelectedVersion(TargetVersion, SelectedDate, ExpectedMonth, ExpectedYear);
                        EnvironmentManagement.SelectTargetVersion(Rec, TargetVersion, SelectedDate, ExpectedMonth, ExpectedYear);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
        area(Navigation)
        {
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
                ToolTip = 'View and manage backups for this environment.';
                Enabled = Rec.Type = 'Production';

                trigger OnAction()
                var
                    BackupPage: Page "D4P BC Environment Backups";
                begin
                    BackupPage.SetEnvironmentContext(Rec);
                    BackupPage.RunModal();
                end;
            }
            action(Capacity)
            {
                ApplicationArea = All;
                Caption = 'Capacity';
                Image = Capacity;
                ToolTip = 'View capacity information for this environment.';

                trigger OnAction()
                var
                    CapacityLine: Record "D4P BC Capacity Line";
                    CapacityNotAvailableMsg: Label 'Capacity data not available for this environment. Please refresh capacity data from the tenant.';
                begin
                    CapacityLine.SetRange("Customer No.", Rec."Customer No.");
                    CapacityLine.SetRange("Tenant ID", Format(Rec."Tenant ID"));
                    CapacityLine.SetRange("Environment Name", Rec.Name);
                    if CapacityLine.FindFirst() then
                        Page.Run(Page::"D4P BC Capacity Card", CapacityLine)
                    else
                        Message(CapacityNotAvailableMsg);
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
        area(Reporting)
        {
            action(AIConnectionSetup)
            {
                ApplicationArea = All;
                Caption = 'Application Insights Connection Setup';
                Image = Setup;
                RunObject = Page "D4P AppInsights Conn List";
                ToolTip = 'View and manage Application Insights connection setups.';
            }
            action(EditCurrentAIConnection)
            {
                ApplicationArea = All;
                Caption = 'Edit Current Application Insights Connection';
                Image = Edit;
                Enabled = Rec."Application Insights String" <> '';
                ToolTip = 'Edit the current Application Insights connection setup.';

                trigger OnAction()
                var
                    AIConnectionSetup: Record "D4P AppInsights Connection";
                    AIConnectionSetupCard: Page "D4P AppInsights Conn Card";
                    NoAIConnectionSetupMsg: Label 'No Application Insights connection setup found for the current connection string.';
                begin
                    if AIConnectionSetup.Get(Rec."Application Insights String") then begin
                        AIConnectionSetupCard.SetRecord(AIConnectionSetup);
                        if AIConnectionSetupCard.RunModal() = ACTION::OK then begin
                            // Refresh flowfields after editing
                            Rec.CalcFields("Telemetry API Key", "Telemetry Application ID", "Telemetry Tenant ID", "Telemetry Description");
                        end;
                        CurrPage.Update();
                    end else
                        Message(NoAIConnectionSetupMsg);
                end;
            }
            action(TelemetryInstalledApps)
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
            action(TelemetryKQLQueries)
            {
                ApplicationArea = All;
                Caption = 'KQL Queries';
                Image = Log;
                ToolTip = 'View and execute KQL queries for telemetry data analysis.';

                trigger OnAction()
                var
                    TelemetryHelper: Codeunit "D4P Telemetry Helper";
                begin
                    TelemetryHelper.OpenKQLQueriesPage(Rec);
                end;
            }
            action(RunDirectTelemetryQuery)
            {
                ApplicationArea = All;
                Caption = 'Run Telemetry Query';
                Image = Start;
                ToolTip = 'Select and run a telemetry query directly using this environment''s configuration.';

                trigger OnAction()
                var
                    TelemetryHelper: Codeunit "D4P Telemetry Helper";
                begin
                    TelemetryHelper.RunTelemetryQuery(Rec);
                end;
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
                    AppInsightsMsg: Label 'Are you sure you want to set the Application Insights connection string for environment %1?\Please be aware that this will RESTART the environment.';
                    RemoveAppInsightsMsg: Label 'Are you sure you want to remove the Application Insights connection string for environment %1?\Please be aware that this will RESTART the environment.';
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
        }
        area(Promoted)
        {
            group(EnvironmentTasks)
            {
                Caption = 'Environment Tasks';
                actionref(GetEnvironmentUpdateInfoPromoted; GetEnvironmentUpdateInfo)
                {
                }
                actionref(CopyEnvironmentPromoted; CopyEnvironment)
                {
                }
                actionref(RenameEnvironmentPromoted; RenameEnvironment)
                {
                }
                actionref(DeleteEnvironmentPromoted; DeleteEnvironment)
                {
                }
                actionref(RescheduleUpdatePromoted; RescheduleUpdate)
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
                actionref(RunDirectTelemetryQueryPromoted; RunDirectTelemetryQuery)
                {
                }
                actionref(TelemetryKQLQueriesPromoted; TelemetryKQLQueries)
                {
                }
                actionref(AIConnectionSetupPromoted; AIConnectionSetup)
                {
                }
                actionref(EditCurrentAIConnectionPromoted; EditCurrentAIConnection)
                {
                }
                actionref(SetAppInsightsConnectionStringPromoted; SetAppInsightsConnectionString)
                {
                }
            }
            group(AdvancedTasks)
            {
                Caption = 'Advanced';
                actionref(BackupsPromoted; Backups)
                {
                }
                actionref(FeaturesPromoted; Features)
                {
                }
                actionref(CapacityPromoted; Capacity)
                {
                }
                actionref(SessionsPromoted; Sessions)
                {
                }
            }
        }
    }

    var
        DeletionInfoVisible: Boolean;
        StateStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        DeletionInfoVisible := (Rec."Soft Deleted On" <> 0DT) or (Rec."Hard Delete Pending On" <> 0DT) or (Rec."Delete Reason" <> '');

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