namespace D4P.CCMS.Environment;

using D4P.CCMS.Tenant;

page 62006 "D4P Copy Environment Dialog"
{
    PageType = StandardDialog;
    Caption = 'Copy Environment';
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
            field(NewEnvironmentType; NewEnvironmentType)
            {
                Caption = 'New Environment Type';
            }
        }
    }

    procedure SetBCTenant(CurrBCTenant: Record "D4P BC Tenant")
    begin
        BCTenant := CurrBCTenant;
    end;

    procedure SetCurrentBCEnvironment(CurrEnvironmentName: Text[100])
    begin
        EnvironmentName := CurrEnvironmentName;
    end;

    procedure CopyEnvironment()
    var
        EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
    begin
        EnvironmentManagement.CopyBCEnvironment(
            BCTenant, EnvironmentName, NewEnvironmentName, NewEnvironmentType);
    end;

    var
        BCTenant: Record "D4P BC Tenant";
        NewEnvironmentType: Enum "D4P Environment Type";
        EnvironmentName, NewEnvironmentName : Text[100];
}