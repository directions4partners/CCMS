namespace D4P.CCMS.Extension;

enum 62005 "D4P App Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; Global)
    {
        Caption = 'Global';
    }
    value(2; PTE)
    {
        Caption = 'PTE';
    }
    value(3; DEV)
    {
        Caption = 'DEV';
    }
}
