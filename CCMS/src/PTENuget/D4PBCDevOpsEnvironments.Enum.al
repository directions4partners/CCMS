namespace D4P.CCMS.Nuget;
enum 62009 "D4P BC DevOps Environment" implements "D4P BC DevOps Update"
{
    Extensible = true;

    value(0; NoDevOps)
    {
        Caption = 'No DevOps';
        Implementation = "D4P BC DevOps Update" = "D4P BC NoDevOps Update";
    }
    value(1; GitHub)
    {
        Caption = 'GitHub', Locked = true;
        Implementation = "D4P BC DevOps Update" = "D4P BC GitHub Update";
    }
    value(2; Azure)
    {
        Caption = 'Azure', Locked = true;
        Implementation = "D4P BC DevOps Update" = "D4P BC Azure Update";
    }
}