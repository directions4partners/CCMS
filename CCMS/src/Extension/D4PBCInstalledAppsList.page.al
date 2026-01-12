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
                ToolTip = 'Get the list of installed apps for the selected environment.';
                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    BCEnvironment.Get(Rec."Customer No.", Rec."Tenant ID", Rec."Environment Name");
                    EnvironmentManagement.GetInstalledApps(BCEnvironment);
                end;
            }
            action(GetAvailableUpdates)
            {
                ApplicationArea = All;
                Caption = 'Get Available Updates';
                Image = Refresh;
                ToolTip = 'Get the list of available apps updates for the selected environment.';
                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    BCEnvironment.Get(Rec."Customer No.", Rec."Tenant ID", Rec."Environment Name");
                    EnvironmentManagement.GetAvailableAppUpdates(BCEnvironment);
                end;
            }
            action(UpdateApp)
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
                Caption = 'Update Selected Apps';
                Image = UpdateXML;
                ToolTip = 'Update the selected apps (multiple) to the latest version.';
                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    BCEnvironment.Get(Rec."Customer No.", Rec."Tenant ID", Rec."Environment Name");
                    CurrPage.SetSelectionFilter(Rec);
                    if Rec.FindSet() then
                        repeat
                            EnvironmentManagement.UpdateApp(BCEnvironment, Rec."App ID", true);
                        until Rec.Next() = 0;
                end;
            }
            action(DeleteAll)
            {
                ApplicationArea = All;
                Caption = 'Delete All';
                Image = Delete;
                ToolTip = 'Delete all fetched installed apps records.';
                trigger OnAction()
                var
                    InstalledApp: Record "D4P BC Installed App";
                    RecordCount: Integer;
                    DeletedSuccessMsg: Label '%1 installed apps records deleted.';
                    DeleteMsg: Label 'Are you sure you want to delete all %1 fetched installed apps records?';
                begin
                    InstalledApp.CopyFilters(Rec);
                    RecordCount := InstalledApp.Count();
                    if RecordCount = 0 then
                        exit;

                    if Confirm(DeleteMsg, false, RecordCount) then begin
                        InstalledApp.DeleteAll();
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

    trigger OnAfterGetRecord()
    begin
        // Set style for App Name and Available Update Version when update is available
        if Rec."Available Update Version" <> '' then
            UpdateAvailableStyleExpr := 'Attention'
        else
            UpdateAvailableStyleExpr := 'Standard';
    end;
}