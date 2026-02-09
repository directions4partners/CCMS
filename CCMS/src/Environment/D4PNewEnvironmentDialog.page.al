namespace D4P.CCMS.Environment;

using D4P.CCMS.Tenant;

page 62005 "D4P New Environment Dialog"
{
    PageType = StandardDialog;
    Caption = 'New Environment Creation';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field(EnvironmentName; EnvironmentName)
            {
                Caption = 'Environment Name';
            }
            field(Localization; Localization)
            {
                Caption = 'Localization';
            }
            field(EnvironmentType; EnvironmentType)
            {
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
        BCTenant: Record "D4P BC Tenant";
        Localization: Code[2];
        EnvironmentType: Enum "D4P Environment Type";
        EnvironmentName: Text[100];
}