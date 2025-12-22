namespace D4P.CCMS.PTEApps;

page 62031 "D4P BC Input Token"
{
    ApplicationArea = All;
    Caption = 'D365BC Input Token';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Token; Token)
                {
                    Caption = 'Personal Access Token';
                    ToolTip = 'Specifies the Personal Access Token for DevOps organization access.';
                    MultiLine = true;
                }
            }
        }
    }

    var
        Token: Text[250];

    procedure GetToken(): Text
    begin
        exit(Token);
    end;
}
