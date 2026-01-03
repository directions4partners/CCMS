namespace D4P.CCMS.Extension;

enum 62003 "D4P Update Attempt Result"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; Failed)
    {
        Caption = 'Failed';
    }
    value(2; Succeeded)
    {
        Caption = 'Succeeded';
    }
    value(3; Canceled)
    {
        Caption = 'Canceled';
    }
    value(4; Skipped)
    {
        Caption = 'Skipped';
    }
}
