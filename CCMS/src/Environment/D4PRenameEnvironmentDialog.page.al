namespace D4P.CCMS.Environment;

using D4P.CCMS.Tenant;

page 62007 "D4P Rename Environment Dialog"
{
    PageType = StandardDialog;
    Caption = 'Rename Environment';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field(EnvironmentName; EnvironmentName)
            {
                Caption = 'Current Environment Name';
                Editable = false;
            }
            field(NewEnvironmentName; NewEnvironmentName)
            {
                Caption = 'New Environment Name';
            }
        }
    }

    procedure SetBCTenant(_BCTenant: Record "D4P BC Tenant")
    begin
        BCTenant := _BCTenant;
    end;

    procedure SetCurrentBCEnvironment(_EnvironmentName: Text[100])
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
        BCTenant: Record "D4P BC Tenant";
        EnvironmentName, NewEnvironmentName : Text[100];
}