namespace D4P.CCMS.PartnerCenter;
using D4P.CCMS.Customer;

table 62006 "D4P BC Partner Center"
{
    Caption = 'Partner Center';
    DataClassification = CustomerContent;
    DrillDownPageId = "D4P BC Partner Center List";
    LookupPageId = "D4P BC Partner Center List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            ToolTip = 'Unique code to identify the Partner Center';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Partner Center description';
        }
        field(3; "Assigned Customer Count"; Integer)
        {
            Caption = 'Assigned Customer Count';
            FieldClass = FlowField;
            CalcFormula = Count("D4P BC Customer" where("Partner Center Code" = field("Code")));
            ToolTip = 'Number of customers associated with the Partner Center';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ConfirmDeleteTxt: Label 'The Partner Center %1 is associated with %2 customers. Are you sure you want to delete it?', Comment = '%1 = Partner Center code, %2 = Assigned Customer Count';
        CancelTxt: Label 'Deletion of Partner Center cancelled.', Comment = 'Message displayed when deletion of Partner Center is cancelled';
    begin
        CalcFields("Assigned Customer Count");
        if "Assigned Customer Count" > 0 then
            if not Confirm(ConfirmDeleteTxt, false, "Code", "Assigned Customer Count") then
                Error(CancelTxt);
    end;
}
