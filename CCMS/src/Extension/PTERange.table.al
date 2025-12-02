table 62000 "D4P PTE Range"
{
    Caption = 'PTE Range';
    DataClassification = CustomerContent;
    ToolTip = 'Table to store PTE Ranges';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "PTE ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'PTE ID';
        }
        field(3; "PTE Name"; Text[100])
        {
            Caption = 'PTE Name';
            DataClassification = CustomerContent;
        }
        field(4; "Range From"; Integer)
        {
            Caption = 'Range From';
            DataClassification = CustomerContent;
        }
        field(5; "Range To"; Integer)
        {
            Caption = 'Range To';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}