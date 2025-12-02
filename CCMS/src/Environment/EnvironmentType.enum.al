namespace D4P.CCMS.Environment;

enum 62000 "D4P Environment Type"
{
    Extensible = false;

    value(0; Production)
    {
        Caption = 'Production';
    }
    value(1; Sandbox)
    {
        Caption = 'Sandbox';
    }
}
