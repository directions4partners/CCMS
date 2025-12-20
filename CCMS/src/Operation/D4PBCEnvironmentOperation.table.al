namespace D4P.CCMS.Operations;

using D4P.CCMS.Customer;

table 62025 "D4P BC Environment Operation"
{
    Caption = 'D365BC Environment Operation';
    DataClassification = SystemMetadata;
    LookupPageId = "D4P BC Environment Operations";
    DrillDownPageId = "D4P BC Environment Operations";

    fields
    {
        field(1; "Operation ID"; Guid)
        {
            Caption = 'Operation ID';
            ToolTip = 'Specifies the unique identifier for the operation.';
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer"."No.";
            ToolTip = 'Specifies the customer number.';
        }
        field(20; "Tenant ID"; Text[50])
        {
            Caption = 'Tenant ID';
            ToolTip = 'Specifies the tenant ID.';
        }
        field(30; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            ToolTip = 'Specifies the environment name.';
        }
        field(40; "Environment Type"; Text[50])
        {
            Caption = 'Environment Type';
            ToolTip = 'Specifies the environment type.';
        }
        field(50; "Product Family"; Text[50])
        {
            Caption = 'Product Family';
        }
        field(60; "Operation Type"; Text[50])
        {
            Caption = 'Operation Type';
            ToolTip = 'Specifies the type of operation.';
        }
        field(70; Status; Text[50])
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of the operation.';
        }
        field(80; "AAD Tenant ID"; Text[50])
        {
            Caption = 'AAD Tenant ID';
        }
        field(90; "Created On"; DateTime)
        {
            Caption = 'Created On';
            ToolTip = 'Specifies when the operation was created.';
        }
        field(100; "Started On"; DateTime)
        {
            Caption = 'Started On';
            ToolTip = 'Specifies when the operation started.';
        }
        field(110; "Completed On"; DateTime)
        {
            Caption = 'Completed On';
            ToolTip = 'Specifies when the operation completed.';
        }
        field(120; "Created By"; Text[100])
        {
            Caption = 'Created By';
            ToolTip = 'Specifies who created the operation.';
        }
        field(130; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            ToolTip = 'Specifies the error message if the operation failed.';
        }
        field(140; Parameters; Blob)
        {
            Caption = 'Parameters';
            ToolTip = 'Specifies the operation parameters in JSON format.';
        }
    }

    keys
    {
        key(PK; "Operation ID")
        {
            Clustered = true;
        }
        key(Environment; "Customer No.", "Tenant ID", "Environment Name", "Created On")
        {
        }
        key(CreatedOn; "Created On")
        {
        }
        key(Status; Status)
        {
        }
    }
}
