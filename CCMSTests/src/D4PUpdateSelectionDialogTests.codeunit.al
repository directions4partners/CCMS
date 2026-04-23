namespace D4P.CCMS.Environment.Tests;

using D4P.CCMS.Environment;

codeunit 62050 "D4P Update Selection Dialog Tests"
{
    Subtype = Test;

    [Test]
    procedure IgnoreUpdateWindowTrue_RoundTripsCorrectly()
    var
        TempUpdate: Record "D4P BC Available Update" temporary;
        UpdateSelectionDialog: Page "D4P Update Selection Dialog";
        TargetVersion: Text[100];
        SelectedDate: Date;
        ExpectedMonth: Integer;
        ExpectedYear: Integer;
        IgnoreUpdateWindow: Boolean;
    begin
        // Arrange: available update with IgnoreUpdateWindow = true
        InsertAvailableUpdate(TempUpdate, 1, '25.1.0.0', true, Today(), true);

        // Act
        UpdateSelectionDialog.SetData(TempUpdate);
        TempUpdate.FindFirst();
        UpdateSelectionDialog.GetSelectedVersion(TargetVersion, SelectedDate, ExpectedMonth, ExpectedYear, IgnoreUpdateWindow);

        // Assert
        VerifyIsTrue(IgnoreUpdateWindow, 'IgnoreUpdateWindow should be true');
    end;

    [Test]
    procedure IgnoreUpdateWindowFalse_RoundTripsCorrectly()
    var
        TempUpdate: Record "D4P BC Available Update" temporary;
        UpdateSelectionDialog: Page "D4P Update Selection Dialog";
        TargetVersion: Text[100];
        SelectedDate: Date;
        ExpectedMonth: Integer;
        ExpectedYear: Integer;
        IgnoreUpdateWindow: Boolean;
    begin
        // Arrange: available update with IgnoreUpdateWindow = false
        InsertAvailableUpdate(TempUpdate, 1, '25.1.0.0', true, Today(), false);

        // Act
        UpdateSelectionDialog.SetData(TempUpdate);
        TempUpdate.FindFirst();
        UpdateSelectionDialog.GetSelectedVersion(TargetVersion, SelectedDate, ExpectedMonth, ExpectedYear, IgnoreUpdateWindow);

        // Assert
        VerifyIsFalse(IgnoreUpdateWindow, 'IgnoreUpdateWindow should be false');
    end;

    [Test]
    procedure UserSelectedDateToday_NoLatestSelectableDate_RoundTripsCorrectly()
    var
        TempUpdate: Record "D4P BC Available Update" temporary;
        UpdateSelectionDialog: Page "D4P Update Selection Dialog";
        TargetVersion: Text[100];
        SelectedDate: Date;
        ExpectedMonth: Integer;
        ExpectedYear: Integer;
        IgnoreUpdateWindow: Boolean;
    begin
        // Arrange: no LatestSelectableDate (0D) — regression for Bug 1
        InsertAvailableUpdate(TempUpdate, 1, '25.1.0.0', true, Today(), false);
        TempUpdate.FindFirst();
        TempUpdate."Latest Selectable Date" := 0D;
        TempUpdate.Modify();

        // Act
        UpdateSelectionDialog.SetData(TempUpdate);
        TempUpdate.FindFirst();
        UpdateSelectionDialog.GetSelectedVersion(TargetVersion, SelectedDate, ExpectedMonth, ExpectedYear, IgnoreUpdateWindow);

        // Assert: User Selected Date passes through correctly
        VerifyDateEqual(SelectedDate, Today(), 'SelectedDate should equal Today when LatestSelectableDate is 0D');
    end;

    [Test]
    procedure UserSelectedDate_WithLatestSelectableDate_RoundTripsCorrectly()
    var
        TempUpdate: Record "D4P BC Available Update" temporary;
        UpdateSelectionDialog: Page "D4P Update Selection Dialog";
        TargetVersion: Text[100];
        SelectedDate: Date;
        ExpectedDate: Date;
        ExpectedMonth: Integer;
        ExpectedYear: Integer;
        IgnoreUpdateWindow: Boolean;
    begin
        // Arrange: LatestSelectableDate = Today + 30
        ExpectedDate := CalcDate('<+30D>', Today());
        InsertAvailableUpdate(TempUpdate, 1, '25.1.0.0', true, ExpectedDate, false);

        // Act
        UpdateSelectionDialog.SetData(TempUpdate);
        TempUpdate.FindFirst();
        UpdateSelectionDialog.GetSelectedVersion(TargetVersion, SelectedDate, ExpectedMonth, ExpectedYear, IgnoreUpdateWindow);

        // Assert
        VerifyDateEqual(SelectedDate, ExpectedDate, 'SelectedDate should equal the inserted UserSelectedDate');
    end;

    [Test]
    procedure AllParameters_RoundTripCorrectly()
    var
        TempUpdate: Record "D4P BC Available Update" temporary;
        UpdateSelectionDialog: Page "D4P Update Selection Dialog";
        TargetVersion: Text[100];
        SelectedDate: Date;
        ExpectedMonth: Integer;
        ExpectedYear: Integer;
        IgnoreUpdateWindow: Boolean;
    begin
        // Arrange
        InsertAvailableUpdate(TempUpdate, 1, '25.2.0.0', true, CalcDate('<+14D>', Today()), true);

        // Act
        UpdateSelectionDialog.SetData(TempUpdate);
        TempUpdate.FindFirst();
        UpdateSelectionDialog.GetSelectedVersion(TargetVersion, SelectedDate, ExpectedMonth, ExpectedYear, IgnoreUpdateWindow);

        // Assert all 5 output params
        VerifyTextEqual(TargetVersion, '25.2.0.0', 'TargetVersion');
        VerifyDateEqual(SelectedDate, CalcDate('<+14D>', Today()), 'SelectedDate');
        VerifyIsTrue(IgnoreUpdateWindow, 'IgnoreUpdateWindow');
    end;

    [Test]
    procedure UnavailableUpdate_ExpectedMonthYear_RoundTripCorrectly()
    var
        TempUpdate: Record "D4P BC Available Update" temporary;
        UpdateSelectionDialog: Page "D4P Update Selection Dialog";
        TargetVersion: Text[100];
        SelectedDate: Date;
        ExpectedMonth: Integer;
        ExpectedYear: Integer;
        IgnoreUpdateWindow: Boolean;
        CurrentMonth: Integer;
        CurrentYear: Integer;
    begin
        // Arrange: unavailable (future) update
        CurrentMonth := Date2DMY(Today(), 2);
        CurrentYear := Date2DMY(Today(), 3);
        TempUpdate.Init();
        TempUpdate."Entry No." := 1;
        TempUpdate."Target Version" := '26.0.0.0';
        TempUpdate.Available := false;
        TempUpdate."Expected Month" := CurrentMonth;
        TempUpdate."Expected Year" := CurrentYear;
        TempUpdate.Insert();

        // Act
        UpdateSelectionDialog.SetData(TempUpdate);
        TempUpdate.FindFirst();
        UpdateSelectionDialog.GetSelectedVersion(TargetVersion, SelectedDate, ExpectedMonth, ExpectedYear, IgnoreUpdateWindow);

        // Assert
        VerifyTextEqual(TargetVersion, '26.0.0.0', 'TargetVersion for unavailable update');
        VerifyIntEqual(ExpectedMonth, CurrentMonth, 'ExpectedMonth');
        VerifyIntEqual(ExpectedYear, CurrentYear, 'ExpectedYear');
    end;

    local procedure InsertAvailableUpdate(var TempUpdate: Record "D4P BC Available Update" temporary; EntryNo: Integer; Version: Text[100]; IsAvailable: Boolean; UserSelectedDate: Date; IgnoreWindow: Boolean)
    begin
        TempUpdate.Init();
        TempUpdate."Entry No." := EntryNo;
        TempUpdate."Target Version" := Version;
        TempUpdate.Available := IsAvailable;
        TempUpdate."User Selected Date" := UserSelectedDate;
        TempUpdate."Ignore Update Window" := IgnoreWindow;
        TempUpdate.Insert();
    end;

    local procedure VerifyIsTrue(Value: Boolean; Message: Text)
    begin
        if not Value then
            Error('Assert failed (expected true): %1', Message);
    end;

    local procedure VerifyIsFalse(Value: Boolean; Message: Text)
    begin
        if Value then
            Error('Assert failed (expected false): %1', Message);
    end;

    local procedure VerifyDateEqual(Actual: Date; Expected: Date; FieldName: Text)
    begin
        if Actual <> Expected then
            Error('Assert failed (%1): expected %2, got %3', FieldName, Expected, Actual);
    end;

    local procedure VerifyTextEqual(Actual: Text; Expected: Text; FieldName: Text)
    begin
        if Actual <> Expected then
            Error('Assert failed (%1): expected "%2", got "%3"', FieldName, Expected, Actual);
    end;

    local procedure VerifyIntEqual(Actual: Integer; Expected: Integer; FieldName: Text)
    begin
        if Actual <> Expected then
            Error('Assert failed (%1): expected %2, got %3', FieldName, Expected, Actual);
    end;
}
