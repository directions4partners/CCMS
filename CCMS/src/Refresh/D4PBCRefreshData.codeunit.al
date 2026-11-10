namespace D4P.CCMS.Refresh;

using D4P.CCMS.Environment;
using D4P.CCMS.Tenant;
using System.Threading;

/// <summary>
/// Entry point of the job queue entries that keep the CCMS data up to date. The task to run is
/// the parameter string of the job queue entry, see the "D4P Refresh Task" enum.
/// </summary>
codeunit 62051 "D4P BC Refresh Data"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        RefreshTask: Enum "D4P Refresh Task";
        InvalidTaskErr: Label 'The parameter string "%1" is not a valid refresh task.', Comment = '%1 = Parameter string';
    begin
        if not Evaluate(RefreshTask, Rec."Parameter String", 9) then
            Error(InvalidTaskErr, Rec."Parameter String");

        Refresh(RefreshTask);
    end;

    procedure Refresh(RefreshTask: Enum "D4P Refresh Task")
    var
        BCEnvironment: Record "D4P BC Environment";
        BCTenant: Record "D4P BC Tenant";
        Worker: Codeunit "D4P BC Refresh Worker";
        FailedCount: Integer;
        TotalCount: Integer;
        AllFailedErr: Label 'The refresh "%1" failed for all %2 items. Last error: %3', Comment = '%1 = Task, %2 = Number of items, %3 = Last error';
        LastError: Text;
    begin
        Worker.SetTask(RefreshTask);

        if RefreshTask in [RefreshTask::Environments, RefreshTask::Capacity] then begin
            // Tenant tasks: the worker only needs the keys of the tenant
            if BCTenant.FindSet() then
                repeat
                    Clear(BCEnvironment);
                    BCEnvironment."Customer No." := BCTenant."Customer No.";
                    BCEnvironment."Tenant ID" := BCTenant."Tenant ID";
                    RunWorker(Worker, BCEnvironment, TotalCount, FailedCount, LastError);
                until BCTenant.Next() = 0;
        end else begin
            BCEnvironment.SetRange(State, 'Active');
            if BCEnvironment.FindSet() then
                repeat
                    RunWorker(Worker, BCEnvironment, TotalCount, FailedCount, LastError);
                until BCEnvironment.Next() = 0;
        end;

        // Failing for one environment is logged and the others go on. When everything fails
        // (for example expired credentials) the job fails so that someone notices.
        if (TotalCount > 0) and (FailedCount = TotalCount) then
            Error(AllFailedErr, RefreshTask, TotalCount, LastError);
    end;

    local procedure RunWorker(var Worker: Codeunit "D4P BC Refresh Worker"; BCEnvironment: Record "D4P BC Environment"; var TotalCount: Integer; var FailedCount: Integer; var LastError: Text)
    var
        EnvironmentToRefresh: Record "D4P BC Environment";
    begin
        TotalCount += 1;
        EnvironmentToRefresh := BCEnvironment;

        // Codeunit.Run is not allowed with an open write transaction, and this keeps what was already refreshed
        Commit();
        if not Worker.Run(EnvironmentToRefresh) then begin
            FailedCount += 1;
            LastError := GetLastErrorText();
            LogFailure(BCEnvironment, LastError);
        end;
    end;

    local procedure LogFailure(BCEnvironment: Record "D4P BC Environment"; ErrorText: Text)
    var
        CategoryTok: Label 'CCMS Data Refresh', Locked = true;
        FailureTok: Label 'Refresh failed. Environment: %1, Error: %2', Locked = true;
    begin
        Session.LogMessage('D4P0051', StrSubstNo(FailureTok, BCEnvironment.Name, ErrorText), Verbosity::Warning,
            DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;
}
