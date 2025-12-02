namespace D4P.CCMS.General;

page 62049 "D4P BC Admin Role Center"
{
    PageType = RoleCenter;
    Caption = 'D365 BC Admin Center';
    ApplicationArea = All;

    layout
    {
        area(RoleCenter)
        {
            group(Group)
            {
                part(AdminCenterCues; "D4P BC Admin Center Cues")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
