namespace D4P.CCMS.Extension;

using D4P.CCMS.Customer;
using D4P.CCMS.Tenant;
using D4P.CCMS.PTEApps;
table 62004 "D4P PTE Object Range"
{
    Caption = 'PTE Object Range';
    DataClassification = CustomerContent;
    LookupPageId = "D4P PTE Object Ranges";
    DrillDownPageId = "D4P PTE Object Ranges";

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
            TableRelation = "D4P BC Tenant"."Tenant ID" where("Customer No." = field("Customer No."));
        }
        field(3; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(4; "PTE ID"; Guid)
        {
            Caption = 'PTE ID';
        }
        field(5; "PTE Name"; Text[100])
        {
            Caption = 'PTE Name';
        }
        field(6; "Range From"; Integer)
        {
            Caption = 'Range From';
        }
        field(7; "Range To"; Integer)
        {
            Caption = 'Range To';
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Tenant ID", "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure CopyValuesFromApp(PTEID: Guid)
    var
        PTEApp: Record "D4P BC PTE App";
    begin
        if not PTEApp.Get(PTEID) then
            exit;
        Rec."PTE Name" := PTEApp."PTE Name";
        Rec."Range From" := PTEApp."Range From";
        Rec."Range To" := PTEApp."Range To";
    end;
}