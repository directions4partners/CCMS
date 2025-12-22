namespace D4P.CCMS.Backup;

using D4P.CCMS.Environment;
using D4P.CCMS.Setup;

page 62014 "D4P BC Environment Backups"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "D4P BC Environment Backup";
    Caption = 'D365BC Environment Database Exports';
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Export Time"; Rec."Export Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the database export was performed.';
                }
                field("Environment Name"; Rec."Environment Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the environment that was exported.';
                }
                field("Export Status"; Rec."Export Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the export.';
                }
                field("Application Version"; Rec."Application Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application version at the time of export.';
                }
                field("Storage Account"; Rec."Storage Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure storage account where the export is stored.';
                }
                field("Container"; Rec."Container")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the container name where the export is stored.';
                }
                field("Blob"; Rec."Blob")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the blob name of the exported file.';
                }
                field("Exported By"; Rec."Exported By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who initiated the export.';
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country code of the environment.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(StartExport)
            {
                ApplicationArea = All;
                Caption = 'Start Database Export';
                Image = Export;
                ToolTip = 'Start a new database export of the environment. Only available for Production environments.';
                Enabled = IsProductionEnvironment;

                trigger OnAction()
                var
                    BackupHelper: Codeunit "D4P BC Backup Helper";
                begin
                    CheckEnvironmentContext();
                    BackupHelper.StartEnvironmentDatabaseExport(CurrentEnvironment);
                end;
            }
            action(GetExportHistory)
            {
                ApplicationArea = All;
                Caption = 'Get Export History';
                Image = History;
                ToolTip = 'Retrieve the history of database exports.';
                Enabled = EnvironmentSet;

                trigger OnAction()
                var
                    BackupHelper: Codeunit "D4P BC Backup Helper";
                    ExportHistoryDialog: Page "D4P Export History Dialog";
                    StartTime: DateTime;
                    EndTime: DateTime;
                begin
                    CheckEnvironmentContext();

                    // Show dialog to select time period
                    if ExportHistoryDialog.RunModal() = Action::OK then begin
                        ExportHistoryDialog.GetDateRange(StartTime, EndTime);
                        BackupHelper.GetExportHistory(CurrentEnvironment, StartTime, EndTime);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(GetExportMetrics)
            {
                ApplicationArea = All;
                Caption = 'Get Export Metrics';
                Image = Statistics;
                ToolTip = 'Get information about export quotas and usage.';
                Enabled = EnvironmentSet;

                trigger OnAction()
                var
                    BackupHelper: Codeunit "D4P BC Backup Helper";
                begin
                    CheckEnvironmentContext();
                    BackupHelper.GetExportMetrics(CurrentEnvironment);
                end;
            }
            action(PITRestore)
            {
                ApplicationArea = All;
                Caption = 'PIT Restore';
                Image = Restore;
                ToolTip = 'Perform a Point-in-Time restore of an environment.';

                trigger OnAction()
                begin
                    // TODO: Implement PIT restore logic
                    if Confirm('Are you sure you want to perform a Point-in-Time restore?') then
                        Message('PIT Restore functionality to be implemented.');
                end;
            }
            action(DeleteAll)
            {
                ApplicationArea = All;
                Caption = 'Delete All';
                Image = Delete;
                ToolTip = 'Delete all fetched backup records.';
                trigger OnAction()
                var
                    Backup: Record "D4P BC Environment Backup";
                    DeleteMsg: Label 'Are you sure you want to delete all %1 fetched backup records?';
                    DeletedSuccessMsg: Label '%1 backup records deleted.';
                    RecordCount: Integer;
                begin
                    Backup.CopyFilters(Rec);
                    RecordCount := Backup.Count;
                    if RecordCount = 0 then
                        exit;

                    if Confirm(DeleteMsg, false, RecordCount) then begin
                        Backup.DeleteAll();
                        CurrPage.Update(false);
                        Message(DeletedSuccessMsg, RecordCount);
                    end;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Export)
            {
                Caption = 'Database Export';
                actionref(StartExportPromoted; StartExport)
                {
                }
                actionref(GetExportHistoryPromoted; GetExportHistory)
                {
                }
                actionref(GetExportMetricsPromoted; GetExportMetrics)
                {
                }
                actionref(DeleteAllPromoted; DeleteAll)
                {
                }
            }
            group(Category_Restore)
            {
                Caption = 'Restore';
                actionref(PITRestorePromoted; PITRestore)
                {
                }
            }
        }
    }

    var
        CurrentEnvironment: Record "D4P BC Environment";
        EnvironmentSet: Boolean;
        IsProductionEnvironment: Boolean;
        PageCaptionTxt: Label 'Database Exports - %1 (%2) - %3';

    trigger OnOpenPage()
    begin
        UpdateEnabledState();
        UpdateCaption();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateEnabledState();
    end;

    procedure SetEnvironmentContext(var BCEnvironment: Record "D4P BC Environment")
    begin
        CurrentEnvironment.Copy(BCEnvironment);
        EnvironmentSet := true;
        UpdateEnabledState();
        UpdateCaption();

        // Filter backup records for this environment
        Rec.SetRange("Customer No.", CurrentEnvironment."Customer No.");
        Rec.SetRange("Tenant ID", CurrentEnvironment."Tenant ID");
        Rec.SetRange("Environment Name", CurrentEnvironment.Name);

        CurrPage.Update(false);
    end;

    local procedure UpdateCaption()
    begin
        if EnvironmentSet then
            CurrPage.Caption := StrSubstNo(PageCaptionTxt, CurrentEnvironment.Name, CurrentEnvironment.Type, CurrentEnvironment."Tenant ID");
    end;

    local procedure UpdateEnabledState()
    var
        BCSetup: Record "D4P BC Setup";
    begin
        if not EnvironmentSet then
            IsProductionEnvironment := false
        else
            IsProductionEnvironment := (CurrentEnvironment.Type = 'Production');

        // Debug message to verify the logic
        if EnvironmentSet and BCSetup.Get() and BCSetup."Debug Mode" then
            Message('Environment: %1\Type: %2\IsProduction: %3\TenantID: %4',
                CurrentEnvironment.Name, CurrentEnvironment.Type, IsProductionEnvironment, CurrentEnvironment."Tenant ID");
    end;

    local procedure CheckEnvironmentContext()
    begin
        if not EnvironmentSet then
            Error('Environment context is not set. This page must be opened from an environment card or list.');
    end;
}
