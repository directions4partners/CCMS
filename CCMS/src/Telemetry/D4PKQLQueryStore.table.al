namespace D4P.CCMS.Telemetry;

table 62033 "D4P KQL Query Store"
{
    Caption = 'KQL Query Store';
    DataClassification = SystemMetadata;

    LookupPageId = "D4P KQL Queries";
    DrillDownPageId = "D4P KQL Queries";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(3; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(4; Query; Blob)
        {
            Caption = 'Query';
            Subtype = Memo; // store plain text KQL
        }
        field(10; "Result Table ID"; Integer)
        {
            Caption = 'Result Table ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specify the table ID where results should be stored (e.g., 72008 for Page Execution)';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
