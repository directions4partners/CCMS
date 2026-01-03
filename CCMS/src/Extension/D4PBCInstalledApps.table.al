namespace D4P.CCMS.Extension;

using D4P.CCMS.Customer;

table 62003 "D4P BC Installed Apps"
{
    Caption = 'D365BC Installed Apps';
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
        field(8; "State"; Enum "D4P App State")
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
    }

    keys
    {
        key(Key1; "Customer No.", "Tenant ID", "Environment Name", "App ID")
        {
            Clustered = true;
        }
    }
}
