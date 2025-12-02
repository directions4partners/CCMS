namespace D4P.CCMS.Setup;

table 62009 "D4P BC Setup"
{
    Caption = 'D365BC Admin Center Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Debug Mode"; Boolean)
        {
            Caption = 'Debug Mode';
            DataClassification = CustomerContent;
        }
        field(3; "Admin API Base URL"; Text[250])
        {
            Caption = 'Admin API Base URL';
            DataClassification = CustomerContent;
        }
        field(4; "Automation API Base URL"; Text[250])
        {
            Caption = 'Automation API Base URL';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup(): Record "D4P BC Setup"
    var
        BCSetup: Record "D4P BC Setup";
    begin
        BCSetup."Primary Key" := '';
        if not BCSetup.Get() then begin
            BCSetup.Init();
            BCSetup."Primary Key" := '';
            BCSetup.Insert();
        end;
        exit(BCSetup);
    end;

    procedure IsDebugModeEnabled(): Boolean
    var
        BCSetup: Record "D4P BC Setup";
    begin
        BCSetup."Primary Key" := '';
        if BCSetup.Get() then
            exit(BCSetup."Debug Mode")
        else
            exit(false);
    end;

    procedure GetAdminAPIBaseUrl(): Text[250]
    var
        BCSetup: Record "D4P BC Setup";
    begin
        BCSetup := GetSetup();
        if BCSetup."Admin API Base URL" = '' then begin
            BCSetup."Admin API Base URL" := 'https://api.businesscentral.dynamics.com/admin/v2.28';
            BCSetup.Modify();
        end;
        exit(BCSetup."Admin API Base URL");
    end;

    procedure GetAutomationAPIBaseUrl(): Text[250]
    var
        BCSetup: Record "D4P BC Setup";
    begin
        BCSetup := GetSetup();
        exit(BCSetup."Automation API Base URL");
    end;

    procedure RestoreDefaults()
    begin
        rec."Debug Mode" := false;
        Rec."Admin API Base URL" := 'https://api.businesscentral.dynamics.com/admin/v2.28';
        Rec."Automation API Base URL" := 'https://api.businesscentral.dynamics.com/v2.0';
        Rec.Modify();
    end;
}