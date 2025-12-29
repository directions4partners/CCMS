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
        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
        }
        field(3; "Environment Name"; Text[30])
        {
            Caption = 'Environment Name';
        }
        field(4; "App ID"; Guid)
        {
            Caption = 'App ID';
        }
        field(5; "App Name"; Text[100])
        {
            Caption = 'App Name';
        }
        field(6; "App Publisher"; Text[100])
        {
            Caption = 'App Publisher';
        }
        field(7; "App Version"; Text[50])
        {
            Caption = 'App Version';
        }
        field(8; "State"; Enum "D4P App State")
        {
            Caption = 'State';
        }
        field(9; "Last Operation Id"; Guid)
        {
            Caption = 'Last Operation Id';
        }
        field(10; "Last Update Attempt Result"; Enum "D4P Update Attempt Result")
        {
            Caption = 'Last Update Attempt Result';
        }
        field(11; "Last Uninstall Operation Id"; Guid)
        {
            Caption = 'Last Uninstall Operation Id';
        }
        field(12; "Last Uninstall Attempt Result"; Enum "D4P Uninstall Attempt Result")
        {
            Caption = 'Last Uninstall Attempt Result';
        }
        field(13; "App Type"; Enum "D4P App Type")
        {
            Caption = 'App Type';
        }
        field(14; "Can Be Uninstalled"; Boolean)
        {
            Caption = 'Can Be Uninstalled';
        }
        field(15; "Available Update Version"; Text[50])
        {
            Caption = 'Available Update Version';
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
