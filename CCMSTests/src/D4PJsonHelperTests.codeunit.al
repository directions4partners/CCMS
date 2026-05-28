namespace D4P.CCMS.Environment.Tests;

using D4P.CCMS.Environment;

codeunit 62051 "D4P JSON Helper Tests"
{
    Subtype = Test;

    var
        EnvironmentMgt: Codeunit "D4P BC Environment Mgt";

    [Test]
    procedure TryGetJsonDate_DateOnlyString_ParsesCorrectly()
    var
        JsonObj: JsonObject;
        ResultDate: Date;
        Found: Boolean;
    begin
        // Arrange: date-only ISO string (root cause of Bug 1)
        JsonObj.Add('latestSelectableDate', '2025-06-15');

        // Act
        Found := EnvironmentMgt.TryGetJsonDate(JsonObj, 'latestSelectableDate', ResultDate);

        // Assert
        VerifyIsTrue(Found, 'TryGetJsonDate should return true for date-only string');
        VerifyDateEqual(ResultDate, DMY2Date(15, 6, 2025), 'Parsed date');
    end;

    [Test]
    procedure TryGetJsonDate_DateTimeString_ParsesDatePortion()
    var
        JsonObj: JsonObject;
        ResultDate: Date;
        Found: Boolean;
    begin
        // Arrange: datetime string — the root cause scenario (AsDateTime() returned 0DT for this)
        JsonObj.Add('latestSelectableDate', '2025-06-15T00:00:00Z');

        // Act
        Found := EnvironmentMgt.TryGetJsonDate(JsonObj, 'latestSelectableDate', ResultDate);

        // Assert
        VerifyIsTrue(Found, 'TryGetJsonDate should return true for datetime string');
        VerifyDateEqual(ResultDate, DMY2Date(15, 6, 2025), 'Parsed date from datetime string');
    end;

    [Test]
    procedure TryGetJsonDate_NullValue_ReturnsFalse()
    var
        JsonObj: JsonObject;
        NullToken: JsonToken;
        ResultDate: Date;
        Found: Boolean;
    begin
        // Arrange: JSON null value
        NullToken.ReadFrom('null');
        JsonObj.Add('latestSelectableDate', NullToken);

        // Act
        Found := EnvironmentMgt.TryGetJsonDate(JsonObj, 'latestSelectableDate', ResultDate);

        // Assert
        VerifyIsFalse(Found, 'TryGetJsonDate should return false for null');
        VerifyDateEqual(ResultDate, 0D, 'ResultDate should be 0D for null');
    end;

    [Test]
    procedure TryGetJsonDate_MissingField_ReturnsFalse()
    var
        JsonObj: JsonObject;
        ResultDate: Date;
        Found: Boolean;
    begin
        // Arrange: empty object
        // Act
        Found := EnvironmentMgt.TryGetJsonDate(JsonObj, 'latestSelectableDate', ResultDate);

        // Assert
        VerifyIsFalse(Found, 'TryGetJsonDate should return false for missing field');
        VerifyDateEqual(ResultDate, 0D, 'ResultDate should be 0D for missing field');
    end;

    [Test]
    procedure TryGetJsonDateTime_ValidDateTimeString_ParsesCorrectly()
    var
        JsonObj: JsonObject;
        ResultDateTime: DateTime;
        Found: Boolean;
    begin
        // Arrange
        JsonObj.Add('selectedDateTime', '2025-06-15T10:30:00');

        // Act
        Found := EnvironmentMgt.TryGetJsonDateTime(JsonObj, 'selectedDateTime', ResultDateTime);

        // Assert
        VerifyIsTrue(Found, 'TryGetJsonDateTime should return true for valid string');
        VerifyIsTrue(ResultDateTime <> 0DT, 'ResultDateTime should not be 0DT');
    end;

    [Test]
    procedure TryGetJsonDateTime_NullValue_ReturnsFalse()
    var
        JsonObj: JsonObject;
        NullToken: JsonToken;
        ResultDateTime: DateTime;
        Found: Boolean;
    begin
        // Arrange
        NullToken.ReadFrom('null');
        JsonObj.Add('selectedDateTime', NullToken);

        // Act
        Found := EnvironmentMgt.TryGetJsonDateTime(JsonObj, 'selectedDateTime', ResultDateTime);

        // Assert
        VerifyIsFalse(Found, 'TryGetJsonDateTime should return false for null');
        VerifyIsTrue(ResultDateTime = 0DT, 'ResultDateTime should be 0DT for null');
    end;

    [Test]
    procedure TryGetJsonDateTime_MissingField_ReturnsFalse()
    var
        JsonObj: JsonObject;
        ResultDateTime: DateTime;
        Found: Boolean;
    begin
        // Act
        Found := EnvironmentMgt.TryGetJsonDateTime(JsonObj, 'selectedDateTime', ResultDateTime);

        // Assert
        VerifyIsFalse(Found, 'TryGetJsonDateTime should return false for missing field');
    end;

    local procedure VerifyIsTrue(Value: Boolean; Msg: Text)
    begin
        if not Value then
            Error('Assert failed (expected true): %1', Msg);
    end;

    local procedure VerifyIsFalse(Value: Boolean; Msg: Text)
    begin
        if Value then
            Error('Assert failed (expected false): %1', Msg);
    end;

    local procedure VerifyDateEqual(Actual: Date; Expected: Date; FieldName: Text)
    begin
        if Actual <> Expected then
            Error('Assert failed (%1): expected %2, got %3', FieldName, Expected, Actual);
    end;
}
