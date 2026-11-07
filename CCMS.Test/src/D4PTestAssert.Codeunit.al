namespace D4P.CCMS.Test;

/// <summary>
/// Minimal assertion helpers for the CCMS tests.
/// Used instead of Microsoft's "Library Assert", which is not available in every online sandbox.
/// </summary>
codeunit 62903 "D4P Test Assert"
{
    var
        AreEqualErr: Label 'Assert.AreEqual failed. Expected: <%1>. Actual: <%2>. %3', Locked = true;
        IsTrueErr: Label 'Assert.IsTrue failed. %1', Locked = true;
        IsFalseErr: Label 'Assert.IsFalse failed. %1', Locked = true;
        ExpectedErrorErr: Label 'Assert.ExpectedError failed. Expected an error containing: <%1>. Actual error: <%2>.', Locked = true;
        ExpectedErrorCodeErr: Label 'Assert.ExpectedErrorCode failed. Expected error code: <%1>. Actual error code: <%2>. Actual error: <%3>.', Locked = true;

    /// <summary>
    /// Fails if the formatted values differ. Works for text, numbers, booleans, GUIDs and enums.
    /// </summary>
    /// <param name="Expected">The expected value.</param>
    /// <param name="Actual">The actual value.</param>
    /// <param name="Msg">Additional text shown when the assertion fails.</param>
    procedure AreEqual(Expected: Variant; Actual: Variant; Msg: Text)
    begin
        if Format(Expected, 0, 9) <> Format(Actual, 0, 9) then
            Error(AreEqualErr, Format(Expected, 0, 9), Format(Actual, 0, 9), Msg);
    end;

    /// <summary>
    /// Fails if the condition is false.
    /// </summary>
    /// <param name="Condition">The condition that must be true.</param>
    /// <param name="Msg">Additional text shown when the assertion fails.</param>
    procedure IsTrue(Condition: Boolean; Msg: Text)
    begin
        if not Condition then
            Error(IsTrueErr, Msg);
    end;

    /// <summary>
    /// Fails if the condition is true.
    /// </summary>
    /// <param name="Condition">The condition that must be false.</param>
    /// <param name="Msg">Additional text shown when the assertion fails.</param>
    procedure IsFalse(Condition: Boolean; Msg: Text)
    begin
        if Condition then
            Error(IsFalseErr, Msg);
    end;

    /// <summary>
    /// Call after asserterror: fails if the last error does not contain the expected text.
    /// </summary>
    /// <param name="ExpectedText">A text the last error message must contain.</param>
    procedure ExpectedError(ExpectedText: Text)
    begin
        if StrPos(GetLastErrorText(), ExpectedText) = 0 then
            Error(ExpectedErrorErr, ExpectedText, GetLastErrorText());
    end;

    /// <summary>
    /// Call after asserterror: fails if the last error code differs from the expected one.
    /// </summary>
    /// <param name="ExpectedCode">The expected error code, for example 'TestField'.</param>
    procedure ExpectedErrorCode(ExpectedCode: Text)
    begin
        if StrPos(GetLastErrorCode(), ExpectedCode) = 0 then
            Error(ExpectedErrorCodeErr, ExpectedCode, GetLastErrorCode(), GetLastErrorText());
    end;
}
