namespace D4P.CCMS.Extension;

using D4P.CCMS.Environment;

page 62024 "D4P BC Installed App Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "D4P BC Installed App";
    Caption = 'D365BC Installed App';
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("App ID"; Rec."App ID")
                {
                }
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

            }
            group(Update)
            {
                Caption = 'Update';

                field("Last Update Attempt Result"; Rec."Last Update Attempt Result")
                {
                }
                field("Available Update Version"; Rec."Available Update Version")
                {
                    StyleExpr = UpdateAvailableStyleExpr;
                }
            }
            group(Install)
            {
                Caption = 'Install';

                field("Environment Name"; Rec."Environment Name")
                {
                }
                field("Can Be Uninstalled"; Rec."Can Be Uninstalled")
                {
                }
                field("Last Uninstall Attempt Result"; Rec."Last Uninstall Attempt Result")
                {
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
                    EnvironmentManagement.GetAvailableAppUpdates(BCEnvironment, true);
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