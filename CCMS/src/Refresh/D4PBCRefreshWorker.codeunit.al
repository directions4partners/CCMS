namespace D4P.CCMS.Refresh;

using D4P.CCMS.Capacity;
using D4P.CCMS.Environment;
using D4P.CCMS.Features;
using D4P.CCMS.Operations;
using D4P.CCMS.Tenant;

/// <summary>
/// Refreshes one task for one environment (or one tenant, for the tenant tasks). It is run with Codeunit.Run
/// so that an error stops only this environment.
/// </summary>
codeunit 62052 "D4P BC Refresh Worker"
{
    TableNo = "D4P BC Environment";

    var
        EnvironmentMgt: Codeunit "D4P BC Environment Mgt";
        RefreshTask: Enum "D4P Refresh Task";

    procedure SetTask(NewRefreshTask: Enum "D4P Refresh Task")
    begin
        RefreshTask := NewRefreshTask;
    end;

    trigger OnRun()
    var
        EnvironmentFeature: Record "D4P BC Environment Feature";
        BCTenant: Record "D4P BC Tenant";
        CapacityHelper: Codeunit "D4P BC Capacity Helper";
        FeaturesHelper: Codeunit "D4P BC Features Helper";
        OperationsHelper: Codeunit "D4P BC Operations Helper";
    begin
        case RefreshTask of
            RefreshTask::Environments:
                begin
                    BCTenant.Get(Rec."Customer No.", Rec."Tenant ID");
                    EnvironmentMgt.GetEnvironments(BCTenant);
                end;
            RefreshTask::Capacity:
                CapacityHelper.GetCapacityData(Rec."Customer No.", Rec."Tenant ID");
            RefreshTask::EnvironmentUpdates:
                EnvironmentMgt.GetEnvironmentUpdates(Rec, false);
            RefreshTask::Apps:
                begin
                    // Getting the installed apps clears the available update version, so both go together
                    EnvironmentMgt.GetInstalledApps(Rec);
                    EnvironmentMgt.GetAvailableAppUpdates(Rec, false);
                end;
            RefreshTask::Operations:
                OperationsHelper.GetEnvironmentOperations(Rec."Customer No.", Rec."Tenant ID", Rec.Name);
            RefreshTask::Features:
                begin
                    EnvironmentFeature."Customer No." := Rec."Customer No.";
                    EnvironmentFeature."Tenant ID" := CopyStr(Format(Rec."Tenant ID"), 1, MaxStrLen(EnvironmentFeature."Tenant ID"));
                    EnvironmentFeature."Environment Name" := Rec.Name;
                    FeaturesHelper.GetFeatures(EnvironmentFeature);
                end;
        end;
    end;
}
