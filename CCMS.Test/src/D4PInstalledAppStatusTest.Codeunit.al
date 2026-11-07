namespace D4P.CCMS.Test;

using D4P.CCMS.Extension;

codeunit 62900 "D4P Installed App Status Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "D4P Test Assert";

    [Test]
    procedure NoAvailableUpdateGivesNA()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] An installed app without an available update
        InitInstalledApp(InstalledApp);

        // [WHEN] The update status is calculated
        InstalledApp.SetUpdateStatus();

        // [THEN] The status is N/A
        Assert.AreEqual(InstalledApp."Update Status"::"N/A", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure AvailableUpdateGivesUpdateAvailable()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] An installed app with an available update and no requirements
        InitInstalledApp(InstalledApp);
        InstalledApp."Available Update Version" := '28.7.0.1';

        // [WHEN] The update status is calculated
        InstalledApp.SetUpdateStatus();

        // [THEN] The status is Update Available
        Assert.AreEqual(InstalledApp."Update Status"::"Update Available", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure UpdateRequirementsGiveActionRequired()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] An available update that requires other apps to be updated first
        InitInstalledApp(InstalledApp);
        InstalledApp."Available Update Version" := '28.7.0.1';
        InstalledApp."Update Requirements" := 'Update Continia Core (28.7.0.1)';

        // [WHEN] The update status is calculated
        InstalledApp.SetUpdateStatus();

        // [THEN] The status is Action Required
        Assert.AreEqual(InstalledApp."Update Status"::"Action Required", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure FailedLastAttemptGivesUpdateFailed()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] An available update whose last update attempt failed
        InitInstalledApp(InstalledApp);
        InstalledApp."Available Update Version" := '28.7.0.1';
        InstalledApp."Last Update Attempt Result" := InstalledApp."Last Update Attempt Result"::Failed;

        // [WHEN] The update status is calculated
        InstalledApp.SetUpdateStatus();

        // [THEN] The status is Update Failed
        Assert.AreEqual(InstalledApp."Update Status"::"Update Failed", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure RequirementsWinOverFailedAttempt()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] A failed last attempt and open requirements
        InitInstalledApp(InstalledApp);
        InstalledApp."Available Update Version" := '28.7.0.1';
        InstalledApp."Last Update Attempt Result" := InstalledApp."Last Update Attempt Result"::Failed;
        InstalledApp."Update Requirements" := 'Install Some App (1.0.0.0)';

        // [WHEN] The update status is calculated
        InstalledApp.SetUpdateStatus();

        // [THEN] The requirements must be resolved first: Action Required
        Assert.AreEqual(InstalledApp."Update Status"::"Action Required", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure UpdatePendingStateGivesScheduled()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] The API reports the app as UpdatePending (available version not fetched yet)
        InitInstalledApp(InstalledApp);
        InstalledApp.State := InstalledApp.State::"Update Pending";

        // [WHEN] The update status is calculated
        InstalledApp.SetUpdateStatus();

        // [THEN] The status is Update is Scheduled
        Assert.AreEqual(InstalledApp."Update Status"::"Update Scheduled", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure ScheduledOperationGivesScheduled()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] An available update with a scheduled operation, even though requirements exist
        InitInstalledApp(InstalledApp);
        InstalledApp."Available Update Version" := '28.7.0.1';
        InstalledApp."Update Requirements" := 'Update Continia Core (28.7.0.1)';
        InstalledApp."Scheduled Operation Id" := CreateGuid();

        // [WHEN] The update status is calculated
        InstalledApp.SetUpdateStatus();

        // [THEN] The status is Update is Scheduled
        Assert.AreEqual(InstalledApp."Update Status"::"Update Scheduled", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure UpdatingStateWinsOverEverything()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] An app that is currently updating and also has a scheduled operation
        InitInstalledApp(InstalledApp);
        InstalledApp.State := InstalledApp.State::Updating;
        InstalledApp."Available Update Version" := '28.7.0.1';
        InstalledApp."Scheduled Operation Id" := CreateGuid();

        // [WHEN] The update status is calculated
        InstalledApp.SetUpdateStatus();

        // [THEN] The status is Updating
        Assert.AreEqual(InstalledApp."Update Status"::Updating, InstalledApp."Update Status", 'Update Status');
    end;

    local procedure InitInstalledApp(var InstalledApp: Record "D4P BC Installed App")
    begin
        InstalledApp.Init();
        InstalledApp."App ID" := CreateGuid();
        InstalledApp.State := InstalledApp.State::Installed;
        InstalledApp."Last Update Attempt Result" := InstalledApp."Last Update Attempt Result"::Succeeded;
    end;
}
