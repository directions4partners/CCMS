namespace D4P.CCMS.Setup;

using Microsoft.Foundation.NoSeries;

table 62009 "D4P BC Setup"
{
    Caption = 'D365BC Admin Center Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Debug Mode"; Boolean)
        {
            Caption = 'Debug Mode';
            ToolTip = 'Enable debug mode to display API response texts in messages for troubleshooting purposes.';
        }
        field(3; "Admin API Base URL"; Text[250])
        {
            Caption = 'Admin API Base URL';
            ToolTip = 'Base URL for Business Central Admin API calls. Default: https://api.businesscentral.dynamics.com/admin/v2.28';
        }
        field(4; "Automation API Base URL"; Text[250])
        {
            Caption = 'Automation API Base URL';
            ToolTip = 'Base URL for Business Central Automation API calls. Default: https://api.businesscentral.dynamics.com/v2.0';
        }
        field(5; "Customer Nos."; Code[20])
        {
            Caption = 'Customer Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series used to assign customer numbers automatically.';
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
        Rec."Debug Mode" := false;
        Rec."Admin API Base URL" := 'https://api.businesscentral.dynamics.com/admin/v2.28';
        Rec."Automation API Base URL" := 'https://api.businesscentral.dynamics.com/v2.0';
        Rec.Modify();
    end;
}