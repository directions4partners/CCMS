namespace D4P.CCMS.Session;

using D4P.CCMS.Environment;

page 62019 "D4P BC Environment Sess Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "D4P BC Environment Session";
    Caption = 'D365BC Environment Session Details';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Session ID"; Rec."Session ID")
                {
                }
                field("User ID"; Rec."User ID")
                {
                }
                field("Client Type"; Rec."Client Type")
                {
                }
                field("Login Date"; Rec."Login Date")
                {
                }
                field("Current Operation Duration"; Rec."Current Operation Duration")
                {
                }
            }
            group(EntryPoint)
            {
                Caption = 'Entry Point';
                field("Entry Point Operation"; Rec."Entry Point Operation")
                {
                }
                field("Entry Point Object Name"; Rec."Entry Point Object Name")
                {
                }
                field("Entry Point Object ID"; Rec."Entry Point Object ID")
                {
                }
                field("Entry Point Object Type"; Rec."Entry Point Object Type")
                {
                }
            }
            group(CurrentObject)
            {
                Caption = 'Current Object';
                field("Current Object Name"; Rec."Current Object Name")
                {
                }
                field("Current Object ID"; Rec."Current Object ID")
                {
                }
                field("Current Object Type"; Rec."Current Object Type")
                {
                }
            }
            group(Environment)
            {
                Caption = 'Environment';
                field("Environment Name"; Rec."Environment Name")
                {
                }
                field("Customer No."; Rec."Customer No.")
                {
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshDetails)
            {
                Caption = 'Refresh Details';
                Image = Refresh;
                ToolTip = 'Refresh the session details from the API.';

                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    SessionHelper: Codeunit "D4P BC Session Helper";
                    TenantIdGuid: Guid;
                begin
                    Evaluate(TenantIdGuid, Rec."Tenant ID");
                    BCEnvironment.Get(Rec."Customer No.", TenantIdGuid, Rec."Environment Name");
                    SessionHelper.GetSessionDetails(BCEnvironment, Rec."Session ID");
                    CurrPage.Update(false);
                end;
            }
            action(TerminateSession)
            {
                Caption = 'Terminate Session';
                Image = Stop;
                ToolTip = 'Terminate this session.';

                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    SessionHelper: Codeunit "D4P BC Session Helper";
                    TenantIdGuid: Guid;
                begin
                    Evaluate(TenantIdGuid, Rec."Tenant ID");
                    BCEnvironment.Get(Rec."Customer No.", TenantIdGuid, Rec."Environment Name");
                    SessionHelper.DeleteSession(BCEnvironment, Rec."Session ID");
                    CurrPage.Close();
                end;
            }
        }
        area(Promoted)
        {
            actionref(RefreshDetailsPromoted; RefreshDetails)
            {
            }
            actionref(TerminateSessionPromoted; TerminateSession)
            {
            }
        }
    }
}
