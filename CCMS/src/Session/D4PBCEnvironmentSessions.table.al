namespace D4P.CCMS.Session;

using D4P.CCMS.Customer;

table 62016 "D4P BC Environment Sessions"
{
    Caption = 'D365BC Environment Sessions';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Session ID"; Text[50])
        {
            Caption = 'Session ID';
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer"."No.";
        }
        field(10; "Tenant ID"; Text[50])
        {
            Caption = 'Tenant ID';
        }
        field(15; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
        }
        field(17; "Application Family"; Text[50])
        {
            Caption = 'Application Family';
        }
        field(20; "User ID"; Text[132])
        {
            Caption = 'User ID';
        }
        field(25; "Client Type"; Text[50])
        {
            Caption = 'Client Type';
        }
        field(30; "Login Date"; DateTime)
        {
            Caption = 'Login Date';
        }
        field(35; "Entry Point Operation"; Text[250])
        {
            Caption = 'Entry Point Operation';
        }
        field(40; "Entry Point Object Name"; Text[250])
        {
            Caption = 'Entry Point Object Name';
        }
        field(45; "Entry Point Object ID"; Text[50])
        {
            Caption = 'Entry Point Object ID';
        }
        field(50; "Entry Point Object Type"; Text[50])
        {
            Caption = 'Entry Point Object Type';
        }
        field(55; "Current Object Name"; Text[250])
        {
            Caption = 'Current Object Name';
        }
        field(60; "Current Object ID"; Integer)
        {
            Caption = 'Current Object ID';
        }
        field(65; "Current Object Type"; Text[50])
        {
            Caption = 'Current Object Type';
        }
        field(70; "Current Operation Duration"; BigInteger)
        {
            Caption = 'Current Operation Duration (ms)';
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