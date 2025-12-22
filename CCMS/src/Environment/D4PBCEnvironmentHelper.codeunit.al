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
        EnvironmentSessions: Record "D4P BC Environment Sessions";
    begin
        EnvironmentSessions.SetRange("Customer No.", Environment."Customer No.");
        EnvironmentSessions.SetRange("Tenant ID", Format(Environment."Tenant ID"));
        EnvironmentSessions.SetRange("Environment Name", Environment.Name);
        if not EnvironmentSessions.IsEmpty() then
            EnvironmentSessions.DeleteAll(true);
    end;

    local procedure DeleteEnvironmentFeatures(Environment: Record "D4P BC Environment")
    var
        EnvironmentFeatures: Record "D4P BC Environment Features";
    begin
        EnvironmentFeatures.SetRange("Customer No.", Environment."Customer No.");
        EnvironmentFeatures.SetRange("Tenant ID", Format(Environment."Tenant ID"));
        EnvironmentFeatures.SetRange("Environment Name", Environment.Name);
        if not EnvironmentFeatures.IsEmpty() then
            EnvironmentFeatures.DeleteAll(true);
    end;

    local procedure DeleteEnvironmentInstalledApps(Environment: Record "D4P BC Environment")
    var
        InstalledApps: Record "D4P BC Installed Apps";
    begin
        InstalledApps.SetRange("Customer No.", Environment."Customer No.");
        InstalledApps.SetRange("Tenant ID", Environment."Tenant ID");
        InstalledApps.SetRange("Environment Name", Environment.Name);
        if not InstalledApps.IsEmpty() then
            InstalledApps.DeleteAll(true);
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
