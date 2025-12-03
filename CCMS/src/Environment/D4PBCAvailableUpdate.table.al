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
        }
        field(20; Available; Boolean)
        {
            Caption = 'Available';
        }
        field(30; Selected; Boolean)
        {
            Caption = 'Selected';
        }
        field(40; "Latest Selectable Date"; Date)
        {
            Caption = 'Latest Selectable Date';
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
        }
        field(80; "Target Version Type"; Text[50])
        {
            Caption = 'Target Version Type';
        }
        field(90; "Expected Month"; Integer)
        {
            Caption = 'Expected Month';
        }
        field(100; "Expected Year"; Integer)
        {
            Caption = 'Expected Year';
        }
        field(110; "User Selected Date"; Date)
        {
            Caption = 'User Selected Date';
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
