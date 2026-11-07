namespace D4P.CCMS.Extension;

using D4P.CCMS.Customer;

table 62003 "D4P BC Installed App"
{
    Caption = 'D365BC Installed App';
    DataClassification = CustomerContent;
    LookupPageId = "D4P BC Installed Apps List";
    DrillDownPageId = "D4P BC Installed Apps List";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer";
            ToolTip = 'Specifies the customer associated with the installed app.';
        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            ToolTip = 'Specifies the tenant identifier associated with the app.';
        }
        field(3; "Environment Name"; Text[30])
        {
            Caption = 'Environment Name';
            ToolTip = 'Specifies the environment where the app is installed.';
        }
        field(4; "App ID"; Guid)
        {
            Caption = 'App ID';
            ToolTip = 'Specifies the unique identifier of the app.';
        }
        field(5; "App Name"; Text[100])
        {
            Caption = 'App Name';
            ToolTip = 'Specifies the name of the installed app.';
        }
        field(6; "App Publisher"; Text[100])
        {
            Caption = 'App Publisher';
            ToolTip = 'Specifies the publisher of the app.';
        }
        field(7; "App Version"; Text[50])
        {
            Caption = 'App Version';
            ToolTip = 'Specifies the version of the installed app.';
        }
        field(8; State; Enum "D4P App State")
        {
            Caption = 'State';
            ToolTip = 'Specifies the current state of the app.';
        }
        field(9; "Last Operation Id"; Guid)
        {
            Caption = 'Last Operation Id';
        }
        field(10; "Last Update Attempt Result"; Enum "D4P Update Attempt Result")
        {
            Caption = 'Last Update Attempt Result';
            ToolTip = 'Specifies the result of the last update attempt.';
        }
        field(11; "Last Uninstall Operation Id"; Guid)
        {
            Caption = 'Last Uninstall Operation Id';
        }
        field(12; "Last Uninstall Attempt Result"; Enum "D4P Uninstall Attempt Result")
        {
            Caption = 'Last Uninstall Attempt Result';
            ToolTip = 'Specifies the result of the last uninstall attempt.';
        }
        field(13; "App Type"; Enum "D4P App Type")
        {
            Caption = 'App Type';
            ToolTip = 'Specifies the type of the app (Global, PTE, DEV).';
        }
        field(14; "Can Be Uninstalled"; Boolean)
        {
            Caption = 'Can Be Uninstalled';
            ToolTip = 'Specifies whether the app can be uninstalled.';
        }
        field(15; "Available Update Version"; Text[50])
        {
            Caption = 'Available Update Version';
            ToolTip = 'Specifies the version of the app that is available for update.';
        }
        field(16; "Environment Type"; Text[50])
        {
            Caption = 'Environment Type';
            ToolTip = 'Specifies the type of the environment where the app is installed.';
        }
        field(17; "Update Status"; Enum "D4P App Update Status")
        {
            Caption = 'Update';
            ToolTip = 'Specifies the update status of the app, as shown in the Business Central admin center (Update Available, Action Required, Update is Scheduled, Updating, Update Failed or N/A).';
        }
        field(18; "Update Requirements"; Text[250])
        {
            Caption = 'Update Requirements';
            ToolTip = 'Specifies the apps that must be installed or updated before this app can be updated (Action Required).';
        }
        field(19; "Scheduled Operation Id"; Guid)
        {
            Caption = 'Scheduled Operation Id';
            ToolTip = 'Specifies the ID of the scheduled update operation for this app.';
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Tenant ID", "Environment Name", "App ID")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Derives the update status (like the "Update" column in the admin center) from the app state,
    /// scheduled operations, update requirements and the available update version.
    /// </summary>
    procedure SetUpdateStatus()
    begin
        // The order of the checks defines the priority:
        // - a running update (Updating) beats everything else,
        // - a scheduled update beats open requirements, because they are resolved when the update runs,
        // - without an available version there is nothing to do (N/A),
        // - open requirements (Action Required) must be resolved before a failed update can be retried.
        case true of
            State = State::Updating:
                "Update Status" := "Update Status"::Updating;
            (State = State::"Update Pending") or not IsNullGuid("Scheduled Operation Id"):
                "Update Status" := "Update Status"::"Update Scheduled";
            "Available Update Version" = '':
                "Update Status" := "Update Status"::"N/A";
            "Update Requirements" <> '':
                "Update Status" := "Update Status"::"Action Required";
            "Last Update Attempt Result" = "Last Update Attempt Result"::Failed:
                "Update Status" := "Update Status"::"Update Failed";
            else
                "Update Status" := "Update Status"::"Update Available";
        end;
    end;
}
