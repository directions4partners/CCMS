namespace D4P.CCMS.Extension;

using D4P.CCMS.Environment;

page 62008 "D4P BC Installed Apps List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "D4P BC Installed App";
    Caption = 'D365BC Installed Apps';
    InsertAllowed = false;
    ModifyAllowed = false;
    CardPageId = "D4P BC Installed App Card";
    SourceTableView = sorting("Customer No.", "Tenant ID", "Environment Name", "App Name");

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("App Name"; Rec."App Name")
                {
                    StyleExpr = UpdateAvailableStyleExpr;
                }
                field("App Publisher"; Rec."App Publisher")
                {
                }
                field("App Version"; Rec."App Version")
                {
                }
                field(State; Rec.State)
                {
                }
                field("App Type"; Rec."App Type")
                {
                }
                field("Can Be Uninstalled"; Rec."Can Be Uninstalled")
                {
                }
                field("Last Update Attempt Result"; Rec."Last Update Attempt Result")
                {
                }
                field("Last Uninstall Attempt Result"; Rec."Last Uninstall Attempt Result")
                {
                }
                field("Available Update Version"; Rec."Available Update Version")
                {
                    StyleExpr = UpdateAvailableStyleExpr;
                }
                field("Environment Type"; Rec."Environment Type")
                {
                }
                field("Environment Name"; Rec."Environment Name")
                {
                }
                field("App ID"; Rec."App ID")
                {
                }
                field("Customer No."; Rec."Customer No.")
                {
                    Visible = false;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetInstalledApps)
            {
                Caption = 'Get Installed Apps';
                Image = Refresh;
                ToolTip = 'Get the list of installed apps for the environments of the selected apps. If the list is empty, the environments matching the current filters are used.';
                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment" temporary;
                    ConfirmationGetInstalledAppsQst: Label 'Do you want to get the installed apps for %1 environment(s)?', Comment = '%1 = Number of environments';
                    DoneMsg: Label 'Installed apps retrieved for %1 environment(s), %2 failure(s).', Comment = '%1 = Number of environments, %2 = Number of failures';
                    FailedCount: Integer;
                begin
                    if not GetTargetEnvironments(BCEnvironment) then
                        exit;

                    if not Confirm(ConfirmationGetInstalledAppsQst, true, BCEnvironment.Count()) then
                        exit;

                    if BCEnvironment.FindSet(false) then
                        repeat
                            // TryFunction + Commit: an error on one environment does not block the others
                            if TryGetInstalledApps(BCEnvironment) then
                                Commit()
                            else
                                FailedCount += 1;
                        until BCEnvironment.Next() = 0;

                    Message(DoneMsg, BCEnvironment.Count(), FailedCount);
                    CurrPage.Update(false);
                end;
            }
            action(GetAvailableUpdates)
            {
                Caption = 'Get Available Updates';
                Image = Refresh;
                ToolTip = 'Get the list of available apps updates for the environments of the selected apps. If the list is empty, the environments matching the current filters are used.';
                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment" temporary;
                    ConfirmationGetAvailableUpdatesQst: Label 'Do you want to get the available app updates for %1 environment(s)?', Comment = '%1 = Number of environments';
                    DoneMsg: Label 'Available app updates retrieved for %1 environment(s), %2 failure(s).', Comment = '%1 = Number of environments, %2 = Number of failures';
                    FailedCount: Integer;
                begin
                    if not GetTargetEnvironments(BCEnvironment) then
                        exit;

                    if not Confirm(ConfirmationGetAvailableUpdatesQst, true, BCEnvironment.Count()) then
                        exit;

                    if BCEnvironment.FindSet(false) then
                        repeat
                            // TryFunction + Commit: an error on one environment does not block the others
                            if TryGetAvailableAppUpdates(BCEnvironment) then
                                Commit()
                            else
                                FailedCount += 1;
                        until BCEnvironment.Next() = 0;

                    Message(DoneMsg, BCEnvironment.Count(), FailedCount);
                    CurrPage.Update(false);
                end;
            }
            action(UpdateApp)
            {
                Caption = 'Update App';
                Image = UpdateXML;
                ToolTip = 'Update the selected app to the latest version.';
                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    BCEnvironment.Get(Rec."Customer No.", Rec."Tenant ID", Rec."Environment Name");
                    EnvironmentManagement.UpdateApp(BCEnvironment, Rec."App ID", false);
                end;
            }
            action(UpdateSelectedApps)
            {
                Caption = 'Update Selected Apps';
                Image = UpdateXML;
                ToolTip = 'Update the selected apps (multiple) to the latest version.';
                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    SelectedInstalledApp: Record "D4P BC Installed App";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    GetTargetInstalledApps(SelectedInstalledApp);
                    SelectedInstalledApp.SetLoadFields("Customer No.", "Tenant ID", "Environment Name", "App ID");
                    // The targets may span several environments: read the environment of each row
                    if SelectedInstalledApp.FindSet(false) then
                        repeat
                            BCEnvironment.Get(SelectedInstalledApp."Customer No.", SelectedInstalledApp."Tenant ID", SelectedInstalledApp."Environment Name");
                            EnvironmentManagement.UpdateApp(BCEnvironment, SelectedInstalledApp."App ID", true);
                        until SelectedInstalledApp.Next() = 0;
                end;
            }
            action(DeleteAll)
            {
                Caption = 'Delete All';
                Image = Delete;
                ToolTip = 'Delete the selected installed apps records.';
                trigger OnAction()
                var
                    InstalledApp: Record "D4P BC Installed App";
                    RecordCount: Integer;
                    DeletedSuccessMsg: Label '%1 installed apps records deleted.', Comment = '%1 = Number of records';
                    DeleteMsg: Label 'Are you sure you want to delete %1 fetched installed apps record(s)?', Comment = '%1 = Number of records';
                begin
                    GetTargetInstalledApps(InstalledApp);
                    RecordCount := InstalledApp.Count();
                    if RecordCount = 0 then
                        exit;

                    if Confirm(DeleteMsg, false, RecordCount) then begin
                        InstalledApp.DeleteAll(false);
                        CurrPage.Update(false);
                        Message(DeletedSuccessMsg, RecordCount);
                    end;
                end;
            }
        }
        area(Promoted)
        {
            actionref(GetInstalledAppsPromoted; GetInstalledApps)
            {
            }
            actionref(GetAvailableUpdatesPromoted; GetAvailableUpdates)
            {
            }
            actionref(UpdateAppPromoted; UpdateApp)
            {
            }
            actionref(UpdateSelectedAppsPromoted; UpdateSelectedApps)
            {
            }
            actionref(DeleteAllPromoted; DeleteAll)
            {
            }
        }
    }

    views
    {
        view(NonMicrosoftApps)
        {
            Caption = 'Non-Microsoft Apps';
            Filters = where("App Publisher" = filter(<> 'Microsoft'));

        }
        view(AppsWithUpdates)
        {
            Caption = 'Apps with Available Updates';
            Filters = where("Available Update Version" = filter(<> ''));

        }
    }

    var
        UpdateAvailableStyleExpr: Text;

    /// <summary>
    /// Gets the targeted installed apps: the selected row(s).
    /// The current row always counts as selected, so a list that is not empty always has a target.
    /// </summary>
    local procedure GetTargetInstalledApps(var TargetInstalledApp: Record "D4P BC Installed App")
    begin
        CurrPage.SetSelectionFilter(TargetInstalledApp);
    end;

    /// <summary>
    /// Collects the environments of the targeted installed apps.
    /// Shows a message and returns false when no environment matches.
    /// </summary>
    local procedure GetTargetEnvironments(var TempBCEnvironment: Record "D4P BC Environment" temporary): Boolean
    var
        BCEnvironment: Record "D4P BC Environment";
        TargetInstalledApp: Record "D4P BC Installed App";
        NoEnvironmentMsg: Label 'There is no environment matching the current filters.';
    begin
        GetTargetInstalledApps(TargetInstalledApp);
        TargetInstalledApp.SetLoadFields("Customer No.", "Tenant ID", "Environment Name");
        if TargetInstalledApp.FindSet(false) then
            repeat
                if not TempBCEnvironment.Get(TargetInstalledApp."Customer No.", TargetInstalledApp."Tenant ID", TargetInstalledApp."Environment Name") then
                    if BCEnvironment.Get(TargetInstalledApp."Customer No.", TargetInstalledApp."Tenant ID", TargetInstalledApp."Environment Name") then begin
                        TempBCEnvironment := BCEnvironment;
                        TempBCEnvironment.Insert(false);
                    end;
            until TargetInstalledApp.Next() = 0
        else begin
            // No app in the list: target the environments matching the page filters
            BCEnvironment.SetRange(State, 'Active');
            BCEnvironment.SetFilter("Customer No.", Rec.GetFilter("Customer No."));
            BCEnvironment.SetFilter("Tenant ID", Rec.GetFilter("Tenant ID"));
            BCEnvironment.SetFilter(Name, Rec.GetFilter("Environment Name"));
            BCEnvironment.SetFilter(Type, Rec.GetFilter("Environment Type"));
            if BCEnvironment.FindSet(false) then
                repeat
                    TempBCEnvironment := BCEnvironment;
                    TempBCEnvironment.Insert(false);
                until BCEnvironment.Next() = 0;
        end;

        if TempBCEnvironment.IsEmpty() then begin
            Message(NoEnvironmentMsg);
            exit(false);
        end;
        exit(true);
    end;

    [TryFunction]
    local procedure TryGetInstalledApps(BCEnvironment: Record "D4P BC Environment")
    var
        EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
    begin
        EnvironmentManagement.SetHideMessages(true);
        EnvironmentManagement.GetInstalledApps(BCEnvironment);
    end;

    [TryFunction]
    local procedure TryGetAvailableAppUpdates(BCEnvironment: Record "D4P BC Environment")
    var
        EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
    begin
        EnvironmentManagement.SetHideMessages(true);
        EnvironmentManagement.GetAvailableAppUpdates(BCEnvironment, false);
    end;

    trigger OnAfterGetRecord()
    begin
        // Set style for App Name and Available Update Version when update is available
        if Rec."Available Update Version" <> '' then
            UpdateAvailableStyleExpr := Format(PageStyle::Attention)
        else
            UpdateAvailableStyleExpr := Format(PageStyle::Standard);
    end;
}