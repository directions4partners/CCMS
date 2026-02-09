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
                // After merge of previous PR this should be uncommented. Reason - the GetAvailableAppUpdates method now has second parameter to not show messages.
                // if UpdateApps then
                //     D4PBCEnvironmentMgt.GetAvailableAppUpdates("D4P BC Environment",true);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(UpdateAppsOption; UpdateApps)
                    {
                        ApplicationArea = All;
                        Caption = 'Update Apps After Retrieval';
                        ToolTip = 'If selected, the system will also check for available updates for the installed apps after retrieval.';
                    }
                }
            }
        }
    }
    var
        UpdateApps: Boolean;
}