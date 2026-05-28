report 62000 "D4P Get Installed Apps"
{
    ApplicationArea = All;
    Caption = 'Get D365BC Installed Apps';
    UsageCategory = Administration;
    ProcessingOnly = true;
    ToolTip = 'Get installed apps from environments.';

    dataset
    {
        dataitem("D4P BC Environment"; "D4P BC Environment")
        {
            RequestFilterFields = "Customer No.", "Tenant ID", Type, Name;
            DataItemTableView = where("State" = const('Active'));

            trigger OnAfterGetRecord()
            var
                D4PBCEnvironmentMgt: Codeunit "D4P BC Environment Mgt";
            begin
                D4PBCEnvironmentMgt.GetInstalledApps("D4P BC Environment");
                if GetAppUpdates then
                    D4PBCEnvironmentMgt.GetAvailableAppUpdates("D4P BC Environment", false);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(GetAppUpdatesOption; GetAppUpdates)
                    {
                        ApplicationArea = All;
                        Caption = 'Get App Updates After Retrieval';
                        ToolTip = 'If selected, the system will also check for available updates for the installed apps after retrieval.';
                    }
                }
            }
        }
    }
    var
        GetAppUpdates: Boolean;
}