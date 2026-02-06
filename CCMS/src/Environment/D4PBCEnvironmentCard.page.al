namespace D4P.CCMS.Environment;

using D4P.CCMS.Backup;
using D4P.CCMS.Capacity;
using D4P.CCMS.Extension;
using D4P.CCMS.Features;
using D4P.CCMS.Operations;
using D4P.CCMS.Session;
using D4P.CCMS.Telemetry;
using D4P.CCMS.Tenant;

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
                    Editable = false;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    DrillDown = false;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    Editable = false;
                }
                field("Friendly Name"; Rec."Friendly Name")
                {
                    Editable = false;
                }
                field("Application Family"; Rec."Application Family")
                {
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    Editable = false;
                }
                field(State; Rec.State)
                {
                    Editable = false;
                    StyleExpr = StateStyleExpr;
                }
            }
            group(Location)
            {
                Caption = 'Location';
                field("Country/Region"; Rec."Country/Region")
                {
                    Editable = false;
                }
                field("Location Name"; Rec."Location Name")
                {
                    Editable = false;
                }
                field("Geo Name"; Rec."Geo Name")
                {
                    Editable = false;
                }
            }
            group(Versions)
            {
                Caption = 'Versions';
                field("Current Version"; Rec."Current Version")
                {
                    Editable = false;
                }
                field("Platform Version"; Rec."Platform Version")
                {
                    Editable = false;
                }
                field("Target Version"; Rec."Target Version")
                {
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Available"; Rec."Available")
                {
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Target Version Type"; Rec."Target Version Type")
                {
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Selected DateTime"; Rec."Selected DateTime")
                {
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Latest Selectable Date"; Rec."Latest Selectable Date")
                {
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Expected Availability"; Rec."Expected Availability")
                {
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Rollout Status"; Rec."Rollout Status")
                {
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Ignore Update Window"; Rec."Ignore Update Window")
                {
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field("Ring Name"; Rec."Ring Name")
                {
                    Editable = false;
                }
                field("Grace Period Start Date"; Rec."Grace Period Start Date")
                {
                    Editable = false;
                }
                field("Enforced Update Period Start"; Rec."Enforced Update Period Start")
                {
                    Editable = false;
                }
            }
            group(URLs)
            {
                Caption = 'Access';
                field("Web Client Login URL"; Rec."Web Client Login URL")
                {
                    ExtendedDatatype = URL;
                    Editable = false;
                }
                field("Web Service URL"; Rec."Web Service URL")
                {
                    ExtendedDatatype = URL;
                    Editable = false;
                }
            }
            group(Telemetry)
            {
                Caption = 'Telemetry & Monitoring';
                field("Application Insights String"; Rec."Application Insights String")
                {
                    MaskType = Concealed;

                    trigger OnValidate()
                    var
                        AIConnectionSetup: Record "D4P AppInsights Connection";
                        AIConnectionSetupCard: Page "D4P AppInsights Conn Card";
                    begin
                        // If a new connection string is entered and doesn't exist, offer to create it
                        if (Rec."Application Insights String" <> '') and (not AIConnectionSetup.Get(Rec."Application Insights String")) then
                            if Confirm('The connection string "%1" does not exist in the setup. Do you want to create it now?', false, Rec."Application Insights String") then begin
                                AIConnectionSetup.Init();
                                AIConnectionSetup."Connection String" := Rec."Application Insights String";
                                AIConnectionSetup.Insert(true);

                                Commit(); // Save the new record before opening the card

                                // Open the card for the user to fill in additional details
                                AIConnectionSetupCard.SetRecord(AIConnectionSetup);
                                AIConnectionSetupCard.RunModal();
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
                            Rec."Application Insights String" := AIConnectionSetup."Connection String";
                            Rec.Modify();

                            // Refresh flowfields after lookup
                            Rec.CalcFields("Telemetry API Key", "Telemetry Application ID", "Telemetry Tenant ID", "Telemetry Description");
                            CurrPage.Update();
                        end;
                    end;
                }
                field("Telemetry API Key"; Rec."Telemetry API Key")
                {
                    ExtendedDatatype = Masked;
                }
                field("Telemetry Application ID"; Rec."Telemetry Application ID")
                {
                }
                field("Telemetry Tenant ID"; Rec."Telemetry Tenant ID")
                {
                }
                field("Telemetry Description"; Rec."Telemetry Description")
                {
                }
            }
            group(AppManagement)
            {
                Caption = 'App Management';
                field("AppSource Apps Update Cadence"; Rec."AppSource Apps Update Cadence")
                {
                    Editable = false;
                }
                field("Linked PowerPlatform Env ID"; Rec."Linked PowerPlatform Env ID")
                {
                    Editable = false;
                }
            }
            group(Deletion)
            {
                Caption = 'Deletion';
                Visible = DeletionInfoVisible;
                field("Soft Deleted On"; Rec."Soft Deleted On")
                {
                    Editable = false;
                }
                field("Hard Delete Pending On"; Rec."Hard Delete Pending On")
                {
                    Editable = false;
                }
                field("Delete Reason"; Rec."Delete Reason")
                {
                    Editable = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(InstalledApp; "D4P BC Installed Apps FactBox")
            {
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
                Caption = 'Get App Updates';
                Image = UpdateXML;
                ToolTip = 'Returns information about the available apps update for the specified environment.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    EnvironmentManagement.GetAvailableAppUpdates(Rec, true);
                end;
            }
            action(CopyEnvironment)
            {
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
                    if CopyEnvironmentDialog.RunModal() = Action::OK then
                        CopyEnvironmentDialog.CopyEnvironment();
                end;
            }
            action(RenameEnvironment)
            {
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
                    if CopyEnvironmentDialog.RunModal() = Action::OK then
                        CopyEnvironmentDialog.CopyEnvironment();
                end;
            }
            action(DeleteEnvironment)
            {
                Caption = 'Delete';
                Image = "Invoicing-Delete";
                ToolTip = 'Deletes the selected environment.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    DeleteMsg: Label 'Are you sure you want to delete the environment %1?', Comment = '%1 = Environment Name';
                begin
                    if Confirm(DeleteMsg, false, Rec.Name) then begin
                        BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                        EnvironmentManagement.DeleteBCEnvironment(BCTenant, Rec.Name);
                    end;
                end;
            }
            action(RescheduleUpdate)
            {
                Caption = 'Reschedule Update';
                Image = Timesheet;
                ToolTip = 'Select and schedule an update version for the environment.';
                trigger OnAction()
                var
                    TempAvailableUpdate: Record "D4P BC Available Update" temporary;
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    UpdateSelectionDialog: Page "D4P Update Selection Dialog";
                    SelectedDate: Date;
                    ExpectedMonth: Integer;
                    ExpectedYear: Integer;
                    NoUpdatesAvailableErr: Label 'No updates available for the environment %1.', Comment = '%1 = Environment Name';
                    TargetVersion: Text[100];
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
                Caption = 'Installed Apps';
                Image = ExternalDocument;
                RunObject = page "D4P BC Installed Apps List";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID"),
                            "Environment Name" = field(Name);
                ToolTip = 'View apps installed in this environment.';
            }
            action(Features)
            {
                Caption = 'Features';
                Image = Setup;
                RunObject = page "D4P BC Environment Features";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID"),
                            "Environment Name" = field(Name);
                ToolTip = 'View and manage features for this environment.';
            }
            action(Backups)
            {
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
            action(Operations)
            {
                Caption = 'Operations';
                Image = ServiceTasks;
                ToolTip = 'View operations history for this environment.';

                trigger OnAction()
                var
                    OperationsPage: Page "D4P BC Environment Operations";
                begin
                    OperationsPage.SetEnvironmentContext(Rec);
                    OperationsPage.Run();
                end;
            }
        }
        area(Reporting)
        {
            action(AIConnectionSetup)
            {
                Caption = 'Application Insights Connection Setup';
                Image = Setup;
                RunObject = page "D4P AppInsights Conn List";
                ToolTip = 'View and manage Application Insights connection setups.';
            }
            action(EditCurrentAIConnection)
            {
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
                        if AIConnectionSetupCard.RunModal() = ACTION::OK then
                            // Refresh flowfields after editing
                            Rec.CalcFields("Telemetry API Key", "Telemetry Application ID", "Telemetry Tenant ID", "Telemetry Description");
                        CurrPage.Update();
                    end else
                        Message(NoAIConnectionSetupMsg);
                end;
            }
            action(TelemetryInstalledApps)
            {
                Caption = 'Installed Apps';
                Image = ExternalDocument;
                RunObject = page "D4P BC Installed Apps List";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID"),
                            "Environment Name" = field(Name);
                ToolTip = 'View apps installed in this environment.';
            }
            action(TelemetryKQLQueries)
            {
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
                Caption = 'Set Application Insights Connection String';
                Image = Setup;
                ToolTip = 'Sets the Application Insights connection string for the selected environment (telemetry).';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    AppInsightsMsg: Label 'Are you sure you want to set the Application Insights connection string for environment %1?\Please be aware that this will RESTART the environment.', Comment = '%1 = Environment Name';
                    RemoveAppInsightsMsg: Label 'Are you sure you want to remove the Application Insights connection string for environment %1?\Please be aware that this will RESTART the environment.', Comment = '%1 = Environment Name';
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    if Rec."Application Insights String" <> '' then begin
                        if Confirm(AppInsightsMsg, false, Rec.Name) then
                            EnvironmentManagement.SetApplicationInsightsConnectionString(Rec);
                    end else
                        if Confirm(RemoveAppInsightsMsg, false, Rec.Name) then
                            EnvironmentManagement.SetApplicationInsightsConnectionString(Rec);
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
                actionref(OperationsPromoted; Operations)
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
            StateStyleExpr := Format(PageStyle::Unfavorable)
        else
            StateStyleExpr := Format(PageStyle::Standard);

        // Calculate flowfields for telemetry information
        if Rec."Application Insights String" <> '' then
            Rec.CalcFields("Telemetry API Key", "Telemetry Application ID", "Telemetry Tenant ID", "Telemetry Description");
    end;
}