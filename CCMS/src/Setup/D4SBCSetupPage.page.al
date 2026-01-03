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