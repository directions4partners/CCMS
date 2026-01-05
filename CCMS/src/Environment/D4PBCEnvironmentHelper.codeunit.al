namespace D4P.CCMS.Environment;

using D4P.CCMS.Backup;
using D4P.CCMS.Session;
using D4P.CCMS.Features;
using D4P.CCMS.Extension;
using D4P.CCMS.Capacity;

codeunit 62002 "D4P BC Environment Helper"
{

    /// <summary>
    /// Deletes an environment record and all related data from the local database.
    /// This includes environment backups, sessions, features, installed apps, capacity data, and the environment record itself.
    /// </summary>
    /// <param name="Environment">The environment record to delete.</param>
    procedure DeleteLocalEnvironmentData(Environment: Record "D4P BC Environment")
    begin
        DeleteEnvironmentBackups(Environment);
        DeleteEnvironmentSessions(Environment);
        DeleteEnvironmentFeatures(Environment);
        DeleteEnvironmentInstalledApps(Environment);
        DeleteEnvironmentCapacityData(Environment);
        DeleteEnvironment(Environment);
    end;

    local procedure DeleteEnvironment(Environment: Record "D4P BC Environment")
    var
        _Environment: Record "D4P BC Environment";
    begin
        if _Environment.Get(Environment."Customer No.", Environment."Tenant ID", Environment.Name) then
            _Environment.Delete(true);
    end;

    local procedure DeleteEnvironmentBackups(Environment: Record "D4P BC Environment")
    var
        EnvironmentBackup: Record "D4P BC Environment Backup";
    begin
        EnvironmentBackup.SetRange("Customer No.", Environment."Customer No.");
        EnvironmentBackup.SetRange("Tenant ID", Format(Environment."Tenant ID"));
        EnvironmentBackup.SetRange("Environment Name", Environment.Name);
        if not EnvironmentBackup.IsEmpty() then
            EnvironmentBackup.DeleteAll(true);
    end;

    local procedure DeleteEnvironmentSessions(Environment: Record "D4P BC Environment")
    var
        EnvironmentSession: Record "D4P BC Environment Session";
    begin
        EnvironmentSession.SetRange("Customer No.", Environment."Customer No.");
        EnvironmentSession.SetRange("Tenant ID", Format(Environment."Tenant ID"));
        EnvironmentSession.SetRange("Environment Name", Environment.Name);
        if not EnvironmentSession.IsEmpty() then
            EnvironmentSession.DeleteAll(true);
    end;

    local procedure DeleteEnvironmentFeatures(Environment: Record "D4P BC Environment")
    var
        EnvironmentFeature: Record "D4P BC Environment Feature";
    begin
        EnvironmentFeature.SetRange("Customer No.", Environment."Customer No.");
        EnvironmentFeature.SetRange("Tenant ID", Format(Environment."Tenant ID"));
        EnvironmentFeature.SetRange("Environment Name", Environment.Name);
        if not EnvironmentFeature.IsEmpty() then
            EnvironmentFeature.DeleteAll(true);
    end;

    local procedure DeleteEnvironmentInstalledApps(Environment: Record "D4P BC Environment")
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        InstalledApp.SetRange("Customer No.", Environment."Customer No.");
        InstalledApp.SetRange("Tenant ID", Environment."Tenant ID");
        InstalledApp.SetRange("Environment Name", Environment.Name);
        if not InstalledApp.IsEmpty() then
            InstalledApp.DeleteAll(true);
    end;

    local procedure DeleteEnvironmentCapacityData(Environment: Record "D4P BC Environment")
    var
        CapacityHeader: Record "D4P BC Capacity Header";
        CapacityLine: Record "D4P BC Capacity Line";
    begin
        if CapacityHeader.Get(Environment."Customer No.", Format(Environment."Tenant ID")) then begin
            CapacityLine.SetRange("Customer No.", Environment."Customer No.");
            CapacityLine.SetRange("Tenant ID", Format(Environment."Tenant ID"));
            if not CapacityLine.IsEmpty() then
                CapacityLine.DeleteAll(true);

            CapacityHeader.DeleteAll(true);
        end;
    end;
}
