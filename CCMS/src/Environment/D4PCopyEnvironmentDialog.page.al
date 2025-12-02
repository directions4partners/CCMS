namespace D4P.CCMS.Environment;

using D4P.CCMS.Tenant;

page 62006 "D4P Copy Environment Dialog"
{
    PageType = StandardDialog;
    Caption = 'Copy Environment';

    layout
    {
        area(content)
        {
            field(EnvironmentName; EnvironmentName)
            {
                ApplicationArea = All;
                Caption = 'Current Environment Name';
                Editable = false;
            }
            field(NewEnvironmentName; NewEnvironmentName)
            {
                ApplicationArea = All;
                Caption = 'New Environment Name';
            }
            field(NewEnvironmentType; NewEnvironmentType)
            {
                ApplicationArea = All;
                Caption = 'New Environment Type';
            }
        }
    }

    procedure SetBCTenant(var _BCTenant: Record "D4P BC Tenant")
    begin
        BCTenant := _BCTenant;
    end;

    procedure SetCurrentBCEnvironment(var _EnvironmentName: Text[100])
    begin
        EnvironmentName := _EnvironmentName;
    end;

    procedure CopyEnvironment()
    var
        EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
    begin
        EnvironmentManagement.CopyBCEnvironment(
            BCTenant, EnvironmentName, NewEnvironmentName, NewEnvironmentType);
    end;

    var
        EnvironmentName, NewEnvironmentName : Text[100];
        NewEnvironmentType: Enum "D4P Environment Type";
        BCTenant: Record "D4P BC Tenant";
}