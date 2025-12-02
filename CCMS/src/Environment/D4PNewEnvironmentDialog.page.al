namespace D4P.CCMS.Environment;

using D4P.CCMS.Tenant;

page 62005 "D4P New Environment Dialog"
{
    PageType = StandardDialog;
    Caption = 'New Environment Creation';

    layout
    {
        area(content)
        {
            field(EnvironmentName; EnvironmentName)
            {
                ApplicationArea = All;
                Caption = 'Environment Name';
            }
            field(Localization; Localization)
            {
                ApplicationArea = All;
                Caption = 'Localization';
            }
            field(EnvironmentType; EnvironmentType)
            {
                ApplicationArea = All;
                Caption = 'Environment Type';
            }
        }
    }

    procedure SetBCTenant(var _BCTenant: Record "D4P BC Tenant")
    begin
        BCTenant := _BCTenant;
    end;

    procedure CreateNewBCEnvironment()
    var
        EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
    begin
        EnvironmentManagement.CreateNewBCEnvironment(
            BCTenant, EnvironmentName, Localization, EnvironmentType);
    end;

    var
        EnvironmentName: Text[100];
        Localization: Code[2];
        EnvironmentType: Enum "D4P Environment Type";
        BCTenant: Record "D4P BC Tenant";
}