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
            DataClassification = CustomerContent;
            TableRelation = "D4P BC Customer";
        }
        field(2; "Tenant ID"; Guid)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Environment Name"; Text[30])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
        }
        field(4; "App ID"; Guid)
        {
            Caption = 'App ID';
            DataClassification = CustomerContent;
        }
        field(5; "App Name"; Text[100])
        {
            Caption = 'App Name';
            DataClassification = CustomerContent;
        }
        field(6; "App Publisher"; Text[100])
        {
            Caption = 'App Publisher';
            DataClassification = CustomerContent;
        }
        field(7; "App Version"; Text[50])
        {
            Caption = 'App Version';
            DataClassification = CustomerContent;
        }
        field(8; "State"; Enum "D4P App State")
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(9; "Last Operation Id"; Guid)
        {
            Caption = 'Last Operation Id';
            DataClassification = CustomerContent;
        }
        field(10; "Last Update Attempt Result"; Enum "D4P Update Attempt Result")
        {
            Caption = 'Last Update Attempt Result';
            DataClassification = CustomerContent;
        }
        field(11; "Last Uninstall Operation Id"; Guid)
        {
            Caption = 'Last Uninstall Operation Id';
            DataClassification = CustomerContent;
        }
        field(12; "Last Uninstall Attempt Result"; Enum "D4P Uninstall Attempt Result")
        {
            Caption = 'Last Uninstall Attempt Result';
            DataClassification = CustomerContent;
        }
        field(13; "App Type"; Enum "D4P App Type")
        {
            Caption = 'App Type';
            DataClassification = CustomerContent;
        }
        field(14; "Can Be Uninstalled"; Boolean)
        {
            Caption = 'Can Be Uninstalled';
            DataClassification = CustomerContent;
        }
        field(15; "Available Update Version"; Text[50])
        {
            Caption = 'Available Update Version';
            DataClassification = CustomerContent;
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
