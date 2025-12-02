namespace D4P.CCMS.Session;

using D4P.CCMS.Environment;

page 62019 "D4P BC Environment Sess Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "D4P BC Environment Sessions";
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique session identifier.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user ID for this session.';
                }
                field("Client Type"; Rec."Client Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the client type.';
                }
                field("Login Date"; Rec."Login Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the user logged in.';
                }
                field("Current Operation Duration"; Rec."Current Operation Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the duration of the current operation in milliseconds.';
                }
            }
            group(EntryPoint)
            {
                Caption = 'Entry Point';
                field("Entry Point Operation"; Rec."Entry Point Operation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry point operation.';
                }
                field("Entry Point Object Name"; Rec."Entry Point Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry point object name.';
                }
                field("Entry Point Object ID"; Rec."Entry Point Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry point object ID.';
                }
                field("Entry Point Object Type"; Rec."Entry Point Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry point object type.';
                }
            }
            group(CurrentObject)
            {
                Caption = 'Current Object';
                field("Current Object Name"; Rec."Current Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current object name.';
                }
                field("Current Object ID"; Rec."Current Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current object ID.';
                }
                field("Current Object Type"; Rec."Current Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current object type.';
                }
            }
            group(Environment)
            {
                Caption = 'Environment';
                field("Environment Name"; Rec."Environment Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the environment name.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number.';
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tenant ID.';
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
                ApplicationArea = All;
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
                ApplicationArea = All;
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
