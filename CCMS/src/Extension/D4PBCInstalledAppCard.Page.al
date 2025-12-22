namespace D4P.CCMS.Extension;

using D4P.CCMS.Environment;

page 62024 "D4P BC Installed App Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "D4P BC Installed Apps";
    Caption = 'D365BC Installed App';
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("App ID"; Rec."App ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of the app.';
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the installed app.';
                    StyleExpr = UpdateAvailableStyleExpr;
                }
                field("App Publisher"; Rec."App Publisher")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the publisher of the app.';
                }
                field("App Version"; Rec."App Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the version of the installed app.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current state of the app.';
                }
                field("App Type"; Rec."App Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the app (Global, PTE, DEV).';
                }

            }
            group(Update)
            {
                field("Last Update Attempt Result"; Rec."Last Update Attempt Result")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the result of the last update attempt.';
                }

                field("Available Update Version"; Rec."Available Update Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the version of the app that is available for update.';
                    StyleExpr = UpdateAvailableStyleExpr;
                }

            }
            group(Install)
            {
                field("Environment Name"; Rec."Environment Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the environment where the app is installed.';
                }
                field("Can Be Uninstalled"; Rec."Can Be Uninstalled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the app can be uninstalled.';
                }
                field("Last Uninstall Attempt Result"; Rec."Last Uninstall Attempt Result")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the result of the last uninstall attempt.';
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
                ApplicationArea = All;
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
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    BCEnvironment: Record "D4P BC Environment";
                begin
                    BCEnvironment.Get(Rec."Customer No.", Rec."Tenant ID", Rec."Environment Name");
                    EnvironmentManagement.UpdateApp(BCEnvironment, Rec."App ID", false);
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
                    InstalledApp: Record "D4P BC Installed Apps";
                    DeleteMsg: Label 'Are you sure you want to delete all %1 fetched installed apps records?';
                    DeletedSuccessMsg: Label '%1 installed apps records deleted.';
                    RecordCount: Integer;
                begin
                    InstalledApp.CopyFilters(Rec);
                    RecordCount := InstalledApp.Count;
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
            actionref(DeleteAllPromoted; DeleteAll)
            {
            }
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