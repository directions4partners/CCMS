namespace D4P.CCMS.Session;

using D4P.CCMS.Environment;

page 62016 "D4P BC Environment Sessions"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "D4P BC Environment Session";
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
                field(Duration; SessionDuration)
                {
                    Caption = 'Duration';
                    ToolTip = 'Specifies the session duration since login.';
                }
                field("Entry Point Operation"; Rec."Entry Point Operation")
                {
                }
                field("Entry Point Object Name"; Rec."Entry Point Object Name")
                {
                }
                field("Current Object Name"; Rec."Current Object Name")
                {
                }
                field("Current Object ID"; Rec."Current Object ID")
                {
                }
                field("Current Operation Duration"; Rec."Current Operation Duration")
                {
                }
                field("Environment Name"; Rec."Environment Name")
                {
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
                Caption = 'Delete All';
                Image = Delete;
                ToolTip = 'Delete all fetched session records.';
                trigger OnAction()
                var
                    Session: Record "D4P BC Environment Session";
                    RecordCount: Integer;
                    DeletedSuccessMsg: Label '%1 session records deleted.', Comment = '%1 = Number of records';
                    DeleteMsg: Label 'Are you sure you want to delete all %1 fetched session records?', Comment = '%1 = Number of records';
                begin
                    Session.CopyFilters(Rec);
                    RecordCount := Session.Count();
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
        SessionDuration := CurrentDateTime() - Rec."Login Date";
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