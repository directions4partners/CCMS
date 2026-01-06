namespace D4P.CCMS.Backup;

enum 62001 "D4P Export Status"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; "In Progress")
    {
        Caption = 'In Progress';
    }
    value(2; Completed)
    {
        Caption = 'Completed';
    }
    value(3; Failed)
    {
        Caption = 'Failed';
    }
    value(4; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
