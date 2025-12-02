namespace D4P.CCMS.Environment;

using D4P.CCMS.Tenant;

page 62007 "D4P Rename Environment Dialog"
{
    PageType = StandardDialog;
    Caption = 'Rename Environment';

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

    procedure RenameEnvironment()
    var
        EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
    begin
        EnvironmentManagement.RenameBCEnvironment(
            BCTenant, EnvironmentName, NewEnvironmentName);
    end;

    var
        EnvironmentName, NewEnvironmentName : Text[100];
        BCTenant: Record "D4P BC Tenant";
}