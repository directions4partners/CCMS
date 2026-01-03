namespace D4P.CCMS.Extension;

enum 62002 "D4P App State"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; Installed)
    {
        Caption = 'Installed';
    }
    value(2; "Update Pending")
    {
        Caption = 'Update Pending';
    }
    value(3; Updating)
    {
        Caption = 'Updating';
    }
}
