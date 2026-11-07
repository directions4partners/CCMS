namespace D4P.CCMS.Test;

using D4P.CCMS.Extension;

codeunit 62901 "D4P App Update Parser Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "D4P Test Assert";
        AppUpdateParser: Codeunit "D4P App Update Parser";

    [Test]
    procedure ParseAppStateIsCaseInsensitive()
    begin
        Assert.AreEqual(Enum::"D4P App State"::"Update Pending", AppUpdateParser.ParseAppState('UpdatePending'), 'UpdatePending');
        Assert.AreEqual(Enum::"D4P App State"::"Update Pending", AppUpdateParser.ParseAppState('updatePending'), 'updatePending');
        Assert.AreEqual(Enum::"D4P App State"::Updating, AppUpdateParser.ParseAppState('UPDATING'), 'UPDATING');
        Assert.AreEqual(Enum::"D4P App State"::Installed, AppUpdateParser.ParseAppState('Installed'), 'Installed');
    end;

    [Test]
    procedure ParseAppStateUnknownGivesInstalled()
    begin
        Assert.AreEqual(Enum::"D4P App State"::Installed, AppUpdateParser.ParseAppState(''), 'empty');
        Assert.AreEqual(Enum::"D4P App State"::Installed, AppUpdateParser.ParseAppState('SomethingNew'), 'unknown');
    end;

    [Test]
    procedure ApplyInstalledAppReadsAllFields()
    var
        InstalledApp: Record "D4P BC Installed App";
        AppId: Guid;
        LastOperationId: Guid;
        LastUninstallOperationId: Guid;
    begin
        // [GIVEN] A complete entry of the installed apps response
        AppId := CreateGuid();
        LastOperationId := CreateGuid();
        LastUninstallOperationId := CreateGuid();

        // [WHEN] The entry is applied to an empty record
        InstalledApp.Init();
        AppUpdateParser.ApplyInstalledApp(ToJson(
            '{"id":"' + GuidText(AppId) + '","name":"Continia Core","publisher":"Continia Software","version":"28.7.0.1",' +
            '"state":"UpdatePending","appType":"global","lastOperationId":"' + GuidText(LastOperationId) + '",' +
            '"lastUpdateAttemptResult":"Failed","lastUninstallOperationId":"' + GuidText(LastUninstallOperationId) + '",' +
            '"lastUninstallAttemptResult":"Canceled","canBeUninstalled":true}'), InstalledApp);

        // [THEN] All fields are taken over
        Assert.AreEqual(AppId, InstalledApp."App ID", 'App ID');
        Assert.AreEqual('Continia Core', InstalledApp."App Name", 'App Name');
        Assert.AreEqual('Continia Software', InstalledApp."App Publisher", 'App Publisher');
        Assert.AreEqual('28.7.0.1', InstalledApp."App Version", 'App Version');
        Assert.AreEqual(InstalledApp.State::"Update Pending", InstalledApp.State, 'State');
        Assert.AreEqual(InstalledApp."App Type"::Global, InstalledApp."App Type", 'App Type');
        Assert.AreEqual(LastOperationId, InstalledApp."Last Operation Id", 'Last Operation Id');
        Assert.AreEqual(InstalledApp."Last Update Attempt Result"::Failed, InstalledApp."Last Update Attempt Result", 'Last Update Attempt Result');
        Assert.AreEqual(LastUninstallOperationId, InstalledApp."Last Uninstall Operation Id", 'Last Uninstall Operation Id');
        Assert.AreEqual(InstalledApp."Last Uninstall Attempt Result"::Canceled, InstalledApp."Last Uninstall Attempt Result", 'Last Uninstall Attempt Result');
        Assert.IsTrue(InstalledApp."Can Be Uninstalled", 'Can Be Uninstalled');
        Assert.AreEqual(InstalledApp."Update Status"::"Update Scheduled", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure ApplyInstalledAppDoesNotKeepValuesOfPreviousApp()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] A record that still holds the values of a previously processed app with a failed update
        InstalledApp.Init();
        AppUpdateParser.ApplyInstalledApp(ToJson(
            '{"id":"' + NewGuidText() + '","name":"Previous App","state":"Updating","appType":"tenant",' +
            '"lastOperationId":"' + NewGuidText() + '","lastUpdateAttemptResult":"Failed","lastUninstallAttemptResult":"Failed",' +
            '"canBeUninstalled":true}'), InstalledApp);
        InstalledApp."Available Update Version" := '2.0.0.0';
        InstalledApp."Update Requirements" := 'Update Something (1.0.0.0)';
        InstalledApp."Scheduled Operation Id" := CreateGuid();

        // [WHEN] The next app is applied, whose entry has only a few properties (others missing or null)
        AppUpdateParser.ApplyInstalledApp(ToJson(
            '{"id":"' + NewGuidText() + '","name":"Next App","version":"1.0.0.0","state":null}'), InstalledApp);

        // [THEN] No value of the previous app survives (this used to show a wrong "Update Failed")
        Assert.AreEqual('Next App', InstalledApp."App Name", 'App Name');
        Assert.AreEqual('', InstalledApp."App Publisher", 'App Publisher');
        Assert.AreEqual(InstalledApp.State::Installed, InstalledApp.State, 'State');
        Assert.AreEqual(InstalledApp."App Type"::" ", InstalledApp."App Type", 'App Type');
        Assert.IsTrue(IsNullGuid(InstalledApp."Last Operation Id"), 'Last Operation Id');
        Assert.AreEqual(InstalledApp."Last Update Attempt Result"::" ", InstalledApp."Last Update Attempt Result", 'Last Update Attempt Result');
        Assert.AreEqual(InstalledApp."Last Uninstall Attempt Result"::" ", InstalledApp."Last Uninstall Attempt Result", 'Last Uninstall Attempt Result');
        Assert.IsFalse(InstalledApp."Can Be Uninstalled", 'Can Be Uninstalled');
        Assert.AreEqual('', InstalledApp."Available Update Version", 'Available Update Version');
        Assert.AreEqual('', InstalledApp."Update Requirements", 'Update Requirements');
        Assert.IsTrue(IsNullGuid(InstalledApp."Scheduled Operation Id"), 'Scheduled Operation Id');
        Assert.AreEqual(InstalledApp."Update Status"::"N/A", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure ApplyInstalledAppAcceptsDocumentedAppIdProperty()
    var
        InstalledApp: Record "D4P BC Installed App";
        AppId: Guid;
    begin
        // [GIVEN] An entry that uses "appId" as in the documentation instead of "id"
        AppId := CreateGuid();

        // [WHEN] The entry is applied
        InstalledApp.Init();
        AppUpdateParser.ApplyInstalledApp(ToJson('{"appId":"' + GuidText(AppId) + '","name":"Some App"}'), InstalledApp);

        // [THEN] The App ID is read
        Assert.AreEqual(AppId, InstalledApp."App ID", 'App ID');
    end;

    [Test]
    procedure ParseAppTypeMapsAllValues()
    begin
        Assert.AreEqual(Enum::"D4P App Type"::Global, AppUpdateParser.ParseAppType('Global'), 'Global');
        Assert.AreEqual(Enum::"D4P App Type"::PTE, AppUpdateParser.ParseAppType('tenant'), 'tenant');
        Assert.AreEqual(Enum::"D4P App Type"::PTE, AppUpdateParser.ParseAppType('PTE'), 'PTE');
        Assert.AreEqual(Enum::"D4P App Type"::DEV, AppUpdateParser.ParseAppType('dev'), 'dev');
        Assert.AreEqual(Enum::"D4P App Type"::" ", AppUpdateParser.ParseAppType('other'), 'unknown');
    end;

    [Test]
    procedure ParseAttemptResultsMapAllValues()
    begin
        Assert.AreEqual(Enum::"D4P Update Attempt Result"::Failed, AppUpdateParser.ParseUpdateAttemptResult('Failed'), 'Update Failed');
        Assert.AreEqual(Enum::"D4P Update Attempt Result"::Succeeded, AppUpdateParser.ParseUpdateAttemptResult('succeeded'), 'Update Succeeded');
        Assert.AreEqual(Enum::"D4P Update Attempt Result"::Canceled, AppUpdateParser.ParseUpdateAttemptResult('Canceled'), 'Update Canceled');
        Assert.AreEqual(Enum::"D4P Update Attempt Result"::Skipped, AppUpdateParser.ParseUpdateAttemptResult('SKIPPED'), 'Update Skipped');
        Assert.AreEqual(Enum::"D4P Update Attempt Result"::" ", AppUpdateParser.ParseUpdateAttemptResult(''), 'Update none');

        Assert.AreEqual(Enum::"D4P Uninstall Attempt Result"::Failed, AppUpdateParser.ParseUninstallAttemptResult('failed'), 'Uninstall Failed');
        Assert.AreEqual(Enum::"D4P Uninstall Attempt Result"::Succeeded, AppUpdateParser.ParseUninstallAttemptResult('Succeeded'), 'Uninstall Succeeded');
        Assert.AreEqual(Enum::"D4P Uninstall Attempt Result"::" ", AppUpdateParser.ParseUninstallAttemptResult('something'), 'Uninstall unknown');
    end;

    [Test]
    procedure RequirementsMissingGivesEmptyText()
    begin
        Assert.AreEqual('', AppUpdateParser.GetUpdateRequirements(ToJson('{"appId":"' + NewGuidText() + '","version":"1.0.0.0"}')), 'no requirements property');
        Assert.AreEqual('', AppUpdateParser.GetUpdateRequirements(ToJson('{"requirements":[]}')), 'empty requirements');
        Assert.AreEqual('', AppUpdateParser.GetUpdateRequirements(ToJson('{"requirements":null}')), 'null requirements');
    end;

    [Test]
    procedure RequirementsAreListed()
    var
        AvailableUpdate: JsonObject;
    begin
        // [GIVEN] An available update with an update and an install requirement
        AvailableUpdate := ToJson(
            '{"requirements":[' +
            '{"appId":"' + NewGuidText() + '","name":"Continia Core","publisher":"Continia Software","version":"28.7.0.1","type":"Update"},' +
            '{"appId":"' + NewGuidText() + '","name":"Some App","publisher":"Someone","version":"1.0.0.0","type":"Install"}]}');

        // [WHEN/THEN] Both requirements are listed with type, name and version
        Assert.AreEqual(
            'Update Continia Core (28.7.0.1), Install Some App (1.0.0.0)',
            AppUpdateParser.GetUpdateRequirements(AvailableUpdate), 'Update Requirements');
    end;

    [Test]
    procedure RequirementsWithNullValues()
    begin
        Assert.AreEqual(
            'Update Continia Core ()',
            AppUpdateParser.GetUpdateRequirements(ToJson('{"requirements":[{"name":"Continia Core","version":null,"type":"Update"}]}')),
            'Update Requirements');
    end;

    [Test]
    procedure RequirementsAreTruncatedToFieldLength()
    var
        InstalledApp: Record "D4P BC Installed App";
        Requirements: Text;
        i: Integer;
    begin
        // [GIVEN] Many requirements that exceed the field length
        for i := 1 to 20 do begin
            if Requirements <> '' then
                Requirements += ',';
            Requirements += '{"name":"A rather long dependency app name ' + Format(i) + '","version":"28.7.0.1","type":"Update"}';
        end;

        // [WHEN] The requirements are assigned to the field
        InstalledApp."Update Requirements" := AppUpdateParser.GetUpdateRequirements(ToJson('{"requirements":[' + Requirements + ']}'));

        // [THEN] No overflow error, the text is cut to the field length
        Assert.AreEqual(MaxStrLen(InstalledApp."Update Requirements"), StrLen(InstalledApp."Update Requirements"), 'Length');
    end;

    [Test]
    procedure NoScheduledOperationGivesEmptyGuid()
    var
        OperationId: Guid;
    begin
        OperationId := AppUpdateParser.FindScheduledOperationId(ToJson(
            '{"value":[' +
            '{"id":"' + NewGuidText() + '","status":"Succeeded","type":"update"},' +
            '{"id":"' + NewGuidText() + '","status":"Failed","type":"update"}]}'));
        Assert.IsTrue(IsNullGuid(OperationId), 'No operation is scheduled');

        Assert.IsTrue(IsNullGuid(AppUpdateParser.FindScheduledOperationId(ToJson('{"value":[]}'))), 'Empty list');
        Assert.IsTrue(IsNullGuid(AppUpdateParser.FindScheduledOperationId(ToJson('{}'))), 'No value property');
    end;

    [Test]
    procedure ScheduledOperationIsFound()
    var
        ExpectedId: Guid;
    begin
        // [GIVEN] A list of operations where one is scheduled (status casing as documented: "Scheduled")
        ExpectedId := CreateGuid();

        // [WHEN/THEN] The scheduled operation is returned
        Assert.AreEqual(ExpectedId, AppUpdateParser.FindScheduledOperationId(ToJson(
            '{"value":[' +
            '{"id":"' + NewGuidText() + '","status":"Succeeded","type":"update"},' +
            '{"id":"' + GuidText(ExpectedId) + '","status":"Scheduled","type":"update"}]}')),
            'Scheduled operation id');
    end;

    [Test]
    procedure ScheduledOperationWithInvalidIdIsSkipped()
    var
        ExpectedId: Guid;
    begin
        ExpectedId := CreateGuid();
        Assert.AreEqual(ExpectedId, AppUpdateParser.FindScheduledOperationId(ToJson(
            '{"value":[' +
            '{"id":"not-a-guid","status":"scheduled"},' +
            '{"id":"' + GuidText(ExpectedId) + '","status":"scheduled"}]}')),
            'Scheduled operation id');
    end;

    [Test]
    procedure ScheduledUpdateResponseSetsOperationId()
    var
        InstalledApp: Record "D4P BC Installed App";
        OperationId: Guid;
    begin
        // [GIVEN] An app with an available update
        InitInstalledAppWithUpdate(InstalledApp);
        OperationId := CreateGuid();

        // [WHEN] The update endpoint answers with a scheduled operation
        AppUpdateParser.ApplyUpdateOperationResponse(InstalledApp,
            '{"id":"' + GuidText(OperationId) + '","type":"update","status":"scheduled","targetAppVersion":"28.7.0.1"}');

        // [THEN] The operation id is stored and the status is Update is Scheduled
        Assert.AreEqual(OperationId, InstalledApp."Scheduled Operation Id", 'Scheduled Operation Id');
        Assert.AreEqual(InstalledApp.State::Installed, InstalledApp.State, 'State');
        Assert.AreEqual(InstalledApp."Update Status"::"Update Scheduled", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure RunningUpdateResponseSetsUpdating()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] An app with an available update
        InitInstalledAppWithUpdate(InstalledApp);

        // [WHEN] The update endpoint answers with a running operation
        AppUpdateParser.ApplyUpdateOperationResponse(InstalledApp,
            '{"id":"' + NewGuidText() + '","type":"update","status":"running","targetAppVersion":"28.7.0.1"}');

        // [THEN] The app is updating
        Assert.IsTrue(IsNullGuid(InstalledApp."Scheduled Operation Id"), 'Scheduled Operation Id');
        Assert.AreEqual(InstalledApp.State::Updating, InstalledApp.State, 'State');
        Assert.AreEqual(InstalledApp."Update Status"::Updating, InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure InvalidUpdateResponseKeepsState()
    var
        InstalledApp: Record "D4P BC Installed App";
    begin
        // [GIVEN] An app with an available update
        InitInstalledAppWithUpdate(InstalledApp);

        // [WHEN] The update endpoint answers with something that is not JSON
        AppUpdateParser.ApplyUpdateOperationResponse(InstalledApp, 'not json');

        // [THEN] Nothing changes, the update is still available
        Assert.AreEqual(InstalledApp.State::Installed, InstalledApp.State, 'State');
        Assert.AreEqual(InstalledApp."Update Status"::"Update Available", InstalledApp."Update Status", 'Update Status');
    end;

    [Test]
    procedure GetJsonTextHandlesMissingAndNull()
    var
        JsonObject: JsonObject;
    begin
        JsonObject := ToJson('{"a":"x","b":null,"c":{"d":1},"e":5}');
        Assert.AreEqual('x', AppUpdateParser.GetJsonText(JsonObject, 'a'), 'string');
        Assert.AreEqual('', AppUpdateParser.GetJsonText(JsonObject, 'b'), 'null');
        Assert.AreEqual('', AppUpdateParser.GetJsonText(JsonObject, 'c'), 'object');
        Assert.AreEqual('5', AppUpdateParser.GetJsonText(JsonObject, 'e'), 'number');
        Assert.AreEqual('', AppUpdateParser.GetJsonText(JsonObject, 'missing'), 'missing');
    end;

    [Test]
    procedure GetJsonGuidHandlesInvalidValues()
    var
        Expected: Guid;
        JsonObject: JsonObject;
    begin
        Expected := CreateGuid();
        JsonObject := ToJson('{"a":"' + GuidText(Expected) + '","b":"not-a-guid","c":null}');
        Assert.AreEqual(Expected, AppUpdateParser.GetJsonGuid(JsonObject, 'a'), 'valid');
        Assert.IsTrue(IsNullGuid(AppUpdateParser.GetJsonGuid(JsonObject, 'b')), 'invalid');
        Assert.IsTrue(IsNullGuid(AppUpdateParser.GetJsonGuid(JsonObject, 'c')), 'null');
        Assert.IsTrue(IsNullGuid(AppUpdateParser.GetJsonGuid(JsonObject, 'missing')), 'missing');
    end;

    local procedure InitInstalledAppWithUpdate(var InstalledApp: Record "D4P BC Installed App")
    begin
        InstalledApp.Init();
        InstalledApp."App ID" := CreateGuid();
        InstalledApp.State := InstalledApp.State::Installed;
        InstalledApp."Available Update Version" := '28.7.0.1';
        InstalledApp.SetUpdateStatus();
    end;

    local procedure ToJson(JsonText: Text) JsonObject: JsonObject
    begin
        JsonObject.ReadFrom(JsonText);
    end;

    local procedure NewGuidText(): Text
    begin
        exit(GuidText(CreateGuid()));
    end;

    local procedure GuidText(Value: Guid): Text
    begin
        exit(Format(Value, 0, 4));
    end;
}
