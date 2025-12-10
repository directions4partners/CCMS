namespace D4P.CCMS.Tenant;

using D4P.CCMS.Customer;

table 62001 "D4P BC Tenant"
{
    Caption = 'D365BC Tenant';
    DataClassification = CustomerContent;
    DrillDownPageId = "D4P BC Tenant List";
    LookupPageId = "D4P BC Tenant List";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = "D4P BC Customer";

        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = CustomerContent;
        }
        field(3; "Tenant Name"; Text[100])
        {
            Caption = 'Tenant Name';
            DataClassification = CustomerContent;
        }
        field(4; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            DataClassification = CustomerContent;
        }
        field(5; "Client Secret"; Text[100])
        {
            Caption = 'Client Secret';
            DataClassification = CustomerContent;
        }
        field(6; "Secret Expiration Date"; Date)
        {
            Caption = 'Secret Expiration Date';
            DataClassification = CustomerContent;
        }
        field(7; "Backup SAS URI"; Text[250])
        {
            Caption = 'Backup SAS URI';
            DataClassification = CustomerContent;
        }
        field(8; "Backup Container Name"; Text[250])
        {
            Caption = 'Backup Container Name';
            DataClassification = CustomerContent;
        }
        field(9; "Backup SAS Token Exp. Date"; Date)
        {
            Caption = 'Backup SAS Token Expiration Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Tenant ID")
        {
            Clustered = true;
        }
    }
}