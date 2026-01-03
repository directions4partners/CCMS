namespace D4P.CCMS.Environment;

table 62024 "D4P BC Available Update"
{
    Caption = 'BC Available Update';
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Target Version"; Text[100])
        {
            Caption = 'Target Version';
            ToolTip = 'Specifies the target version.';
        }
        field(20; Available; Boolean)
        {
            Caption = 'Available';
            ToolTip = 'Specifies if the version is available.';
        }
        field(30; Selected; Boolean)
        {
            Caption = 'Selected';
            ToolTip = 'Specifies if this is the currently selected version.';
        }
        field(40; "Latest Selectable Date"; Date)
        {
            Caption = 'Latest Selectable Date';
            ToolTip = 'Specifies the latest date for which the update can be scheduled.';
        }
        field(50; "Selected DateTime"; Date)
        {
            Caption = 'Selected Date';
        }
        field(60; "Ignore Update Window"; Boolean)
        {
            Caption = 'Ignore Update Window';
        }
        field(70; "Rollout Status"; Text[50])
        {
            Caption = 'Rollout Status';
            ToolTip = 'Specifies the rollout status (Active, UnderMaintenance, Postponed).';
        }
        field(80; "Target Version Type"; Text[50])
        {
            Caption = 'Target Version Type';
        }
        field(90; "Expected Month"; Integer)
        {
            Caption = 'Expected Month';
            ToolTip = 'Specifies the expected month for the release.';
        }
        field(100; "Expected Year"; Integer)
        {
            Caption = 'Expected Year';
            ToolTip = 'Specifies the expected year for the release.';
        }
        field(110; "User Selected Date"; Date)
        {
            Caption = 'User Selected Date';
            ToolTip = 'Select the date for the update (between today and latest selectable date).';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
