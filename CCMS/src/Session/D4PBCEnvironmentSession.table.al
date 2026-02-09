namespace D4P.CCMS.Session;

using D4P.CCMS.Customer;

table 62016 "D4P BC Environment Session"
{
    Caption = 'D365BC Environment Session';
    DataClassification = SystemMetadata;
    DrillDownPageId = "D4P BC Environment Sessions";
    LookupPageId = "D4P BC Environment Sessions";

    fields
    {
        field(1; "Session ID"; Text[50])
        {
            Caption = 'Session ID';
            NotBlank = true;
            ToolTip = 'Specifies the unique session identifier.';
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer"."No.";
            ToolTip = 'Specifies the customer number.';
        }
        field(10; "Tenant ID"; Text[50])
        {
            Caption = 'Tenant ID';
            ToolTip = 'Specifies the tenant ID.';
        }
        field(15; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            ToolTip = 'Specifies the environment name.';
        }
        field(17; "Application Family"; Text[50])
        {
            Caption = 'Application Family';
        }
        field(20; "User ID"; Text[132])
        {
            Caption = 'User ID';
            ToolTip = 'Specifies the user ID for this session.';
        }
        field(25; "Client Type"; Text[50])
        {
            Caption = 'Client Type';
            ToolTip = 'Specifies the client type.';
        }
        field(30; "Login Date"; DateTime)
        {
            Caption = 'Login Date';
            ToolTip = 'Specifies when the user logged in.';
        }
        field(35; "Entry Point Operation"; Text[250])
        {
            Caption = 'Entry Point Operation';
            ToolTip = 'Specifies the entry point operation.';
        }
        field(40; "Entry Point Object Name"; Text[250])
        {
            Caption = 'Entry Point Object Name';
            ToolTip = 'Specifies the entry point object name.';
        }
        field(45; "Entry Point Object ID"; Text[50])
        {
            Caption = 'Entry Point Object ID';
            ToolTip = 'Specifies the entry point object ID.';
        }
        field(50; "Entry Point Object Type"; Text[50])
        {
            Caption = 'Entry Point Object Type';
            ToolTip = 'Specifies the entry point object type.';
        }
        field(55; "Current Object Name"; Text[250])
        {
            Caption = 'Current Object Name';
            ToolTip = 'Specifies the current object name.';
        }
        field(60; "Current Object ID"; Integer)
        {
            Caption = 'Current Object ID';
            ToolTip = 'Specifies the current object ID.';
        }
        field(65; "Current Object Type"; Text[50])
        {
            Caption = 'Current Object Type';
            ToolTip = 'Specifies the current object type.';
        }
        field(70; "Current Operation Duration"; BigInteger)
        {
            Caption = 'Current Operation Duration (ms)';
            ToolTip = 'Specifies the duration of the current operation in milliseconds.';
        }
    }

    keys
    {
        key(PK; "Session ID")
        {
            Clustered = true;
        }
        key(Environment; "Customer No.", "Tenant ID", "Environment Name", "Login Date")
        {
        }
    }
}