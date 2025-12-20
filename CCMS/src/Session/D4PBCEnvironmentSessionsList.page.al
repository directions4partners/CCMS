namespace D4P.CCMS.Session;

using D4P.CCMS.Environment;

page 62016 "D4P BC Environment Sessions"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "D4P BC Environment Sessions";
    Caption = 'D365BC Environment Sessions';
    InsertAllowed = false;
    ModifyAllowed = false;
    CardPageId = "D4P BC Environment Sess Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
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
                field(Duration; SessionDuration)
                {
                    ApplicationArea = All;
                    Caption = 'Duration';
                    ToolTip = 'Specifies the session duration since login.';
                }
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
                field("Current Operation Duration"; Rec."Current Operation Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the duration of the current operation in milliseconds.';
                }
                field("Environment Name"; Rec."Environment Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the environment name.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetSessions)
            {
                ApplicationArea = All;
                Caption = 'Get Sessions';
                Image = Users;
                ToolTip = 'Retrieve current session information for this environment.';

                trigger OnAction()
                var
                    SessionHelper: Codeunit "D4P BC Session Helper";
                begin
                    SessionHelper.GetSessions(CurrentEnvironment);
                    CurrPage.Update(false);
                end;
            }
            action(SessionDetails)
            {
                ApplicationArea = All;
                Caption = 'Session Details';
                Image = Document;
                ToolTip = 'View detailed information for the selected session.';

                trigger OnAction()
                var
                    SessionCard: Page "D4P BC Environment Sess Card";
                begin
                    SessionCard.SetRecord(Rec);
                    SessionCard.Run();
                end;
            }
            action(TerminateSession)
            {
                ApplicationArea = All;
                Caption = 'Terminate Session';
                Image = Stop;
                ToolTip = 'Terminate the selected session.';

                trigger OnAction()
                var
                    SessionHelper: Codeunit "D4P BC Session Helper";
                begin
                    SessionHelper.DeleteSession(CurrentEnvironment, Rec."Session ID");
                    CurrPage.Update(false);
                end;
            }
            action(DeleteAll)
            {
                ApplicationArea = All;
                Caption = 'Delete All';
                Image = Delete;
                ToolTip = 'Delete all fetched session records.';
                trigger OnAction()
                var
                    Session: Record "D4P BC Environment Sessions";
                    DeleteMsg: Label 'Are you sure you want to delete all %1 fetched session records?';
                    DeletedSuccessMsg: Label '%1 session records deleted.';
                    RecordCount: Integer;
                begin
                    Session.CopyFilters(Rec);
                    RecordCount := Session.Count;
                    if RecordCount = 0 then
                        exit;

                    if Confirm(DeleteMsg, false, RecordCount) then begin
                        Session.DeleteAll();
                        CurrPage.Update(false);
                        Message(DeletedSuccessMsg, RecordCount);
                    end;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Sessions)
            {
                Caption = 'Sessions';
                actionref(GetSessionsPromoted; GetSessions)
                {
                }
                actionref(SessionDetailsPromoted; SessionDetails)
                {
                }
                actionref(TerminateSessionPromoted; TerminateSession)
                {
                }
                actionref(DeleteAllPromoted; DeleteAll)
                {
                }
            }
        }
    }

    var
        CurrentEnvironment: Record "D4P BC Environment";
        SessionDuration: Duration;

    trigger OnAfterGetRecord()
    begin
        SessionDuration := CurrentDateTime - Rec."Login Date";
    end;

    procedure SetEnvironmentContext(Environment: Record "D4P BC Environment")
    var
        TenantIdGuid: Guid;
    begin
        CurrentEnvironment := Environment;
        TenantIdGuid := Environment."Tenant ID";
        Rec.SetRange("Customer No.", Environment."Customer No.");
        Rec.SetRange("Tenant ID", Format(TenantIdGuid));
        Rec.SetRange("Environment Name", Environment.Name);
    end;
}