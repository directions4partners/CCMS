namespace D4P.CCMS.Setup;

using D4P.CCMS.Refresh;

page 62010 "D4P BC Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "D4P BC Setup";
    Caption = 'D365BC Admin Center Application Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';
                field("Debug Mode"; Rec."Debug Mode")
                {
                }
                field("Use Business Central Customer"; Rec."Use Business Central Customer")
                {
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Customer No. Series"; Rec."Customer Nos.")
                {
                }
            }
            group(API)
            {
                Caption = 'API Configuration';
                field("Admin API Base URL"; Rec."Admin API Base URL")
                {
                }
                field("Automation API Base URL"; Rec."Automation API Base URL")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RestoreDefaults)
            {
                Caption = 'Restore Defaults';
                Image = Restore;
                ToolTip = 'Restore default values for API configuration.';

                trigger OnAction()
                var
                    RestoreDefaultsMsg: Label 'Do you want to restore default API configuration values?';
                    RestoredSuccessMsg: Label 'Default values have been restored.';
                begin
                    if Confirm(RestoreDefaultsMsg, false) then begin
                        Rec.RestoreDefaults();
                        CurrPage.Update(false);
                        Message(RestoredSuccessMsg);
                    end;
                end;
            }
            action(CreateJobQueueEntries)
            {
                Caption = 'Create Job Queue Entries';
                Image = Job;
                ToolTip = 'Creates the job queue entries that keep environments, updates, apps, operations, capacity and features up to date. Entries that already exist are not changed.';

                trigger OnAction()
                var
                    RefreshJobMgt: Codeunit "D4P BC Refresh Job Mgt";
                    CreatedCount: Integer;
                    CreatedMsg: Label '%1 job queue entries created. Entries that already existed were not changed.', Comment = '%1 = Number of entries created';
                begin
                    CreatedCount := RefreshJobMgt.CreateJobQueueEntries();
                    Message(CreatedMsg, CreatedCount);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        BCSetup: Record "D4P BC Setup";
    begin
        BCSetup := BCSetup.GetSetup();
        if not Rec.Get() then begin
            Rec := BCSetup;
            Rec.Insert();
        end;
    end;
}