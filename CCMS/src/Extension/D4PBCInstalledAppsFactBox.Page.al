namespace D4P.CCMS.Extension;

using D4P.CCMS.Environment;

page 62018 "D4P BC Installed Apps FactBox"
{
    Caption = 'Installed Apps';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "D4P BC Installed Apps";
    CardPageId = "D4P BC Installed App Card";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(InstalledApps)
            {
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                }
                field("App Publisher"; Rec."App Publisher")
                {
                    ApplicationArea = All;
                }
                field("App Version"; Rec."App Version")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GetInstalledApps)
            {
                ApplicationArea = All;
                Caption = 'Get Installed Apps';
                Image = Refresh;
                ToolTip = 'Get the list of installed apps for the selected environment.';
                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                begin
                    BCEnvironment.Get(Rec."Customer No.", Rec."Tenant ID", Rec."Environment Name");
                    EnvironmentManagement.GetInstalledApps(BCEnvironment);
                end;
            }
        }
    }
}