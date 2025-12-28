namespace D4P.CCMS.Setup;

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
                    ApplicationArea = All;
                    ToolTip = 'Enable debug mode to display API response texts in messages for troubleshooting purposes.';
                }
            }
            group(API)
            {
                Caption = 'API Configuration';
                field("Admin API Base URL"; Rec."Admin API Base URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Base URL for Business Central Admin API calls. Default: https://api.businesscentral.dynamics.com/admin/v2.24';
                }
                field("Automation API Base URL"; Rec."Automation API Base URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Base URL for Business Central Automation API calls. Default: https://api.businesscentral.dynamics.com/v2.0';
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
                ApplicationArea = All;
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