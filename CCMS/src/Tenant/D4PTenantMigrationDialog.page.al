namespace D4P.CCMS.Tenant;

page 62017 "D4P Tenant Migration Dialog"
{
    PageType = StandardDialog;
    Caption = 'Tenant to Tenant Migration';

    layout
    {
        area(Content)
        {
            group(SourceGroup)
            {
                Caption = 'Source Environment';
                field(SourceCustomerNo; SourceCustomerNo)
                {
                    ApplicationArea = All;
                    Caption = 'Source Customer No.';
                    ToolTip = 'Specifies the source customer number.';
                }
                field(SourceTenantID; SourceTenantID)
                {
                    ApplicationArea = All;
                    Caption = 'Source Tenant ID';
                    ToolTip = 'Specifies the source tenant ID.';
                }
                field(SourceEnvironmentName; SourceEnvironmentName)
                {
                    ApplicationArea = All;
                    Caption = 'Source Environment Name';
                    ToolTip = 'Specifies the source environment name.';
                }
            }
            group(TargetGroup)
            {
                Caption = 'Target Environment';
                field(TargetCustomerNo; TargetCustomerNo)
                {
                    ApplicationArea = All;
                    Caption = 'Target Customer No.';
                    ToolTip = 'Specifies the target customer number.';
                }
                field(TargetTenantID; TargetTenantID)
                {
                    ApplicationArea = All;
                    Caption = 'Target Tenant ID';
                    ToolTip = 'Specifies the target tenant ID.';
                }
                field(TargetEnvironmentName; TargetEnvironmentName)
                {
                    ApplicationArea = All;
                    Caption = 'Target Environment Name';
                    ToolTip = 'Specifies the target environment name.';
                }
            }
            group(OptionsGroup)
            {
                Caption = 'Migration Options';
                field(MigrateData; MigrateData)
                {
                    ApplicationArea = All;
                    Caption = 'Migrate Data';
                    ToolTip = 'Specifies whether to migrate data along with the environment.';
                }
                field(MigrateApps; MigrateApps)
                {
                    ApplicationArea = All;
                    Caption = 'Migrate Apps';
                    ToolTip = 'Specifies whether to migrate installed apps.';
                }
                field(MigrationDescription; MigrationDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Migration Description';
                    ToolTip = 'Specifies a description for this migration.';
                    MultiLine = true;
                }
            }
        }
    }

    var
        SourceCustomerNo: Code[20];
        SourceTenantID: Text[50];
        SourceEnvironmentName: Text[100];
        TargetCustomerNo: Code[20];
        TargetTenantID: Text[50];
        TargetEnvironmentName: Text[100];
        MigrateData: Boolean;
        MigrateApps: Boolean;
        MigrationDescription: Text[250];

    procedure SetSourceEnvironment(CustomerNo: Code[20]; TenantID: Text[50]; EnvironmentName: Text[100])
    begin
        SourceCustomerNo := CustomerNo;
        SourceTenantID := TenantID;
        SourceEnvironmentName := EnvironmentName;
    end;

    procedure StartMigration()
    begin
        // TODO: Implement migration logic
        Message('Tenant to Tenant Migration functionality to be implemented.');
    end;
}