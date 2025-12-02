namespace D4P.CCMS.General;

using D4P.CCMS.Customer;
using D4P.CCMS.Tenant;

page 62034 "D4P BC Admin Center Cues"
{
    PageType = CardPart;
    SourceTable = "D4P BC Admin Center Cue";
    Caption = 'BC Admin Center';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup(Overview)
            {
                Caption = 'Overview';

                field("Customers Count"; Rec."Customers Count")
                {
                    ApplicationArea = All;
                    Caption = 'Customers';
                    ToolTip = 'Number of D365 BC customers';
                    DrillDownPageId = "D4P BC Customers List";

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"D4P BC Customers List");
                    end;
                }

                field("Tenants Count"; Rec."Tenants Count")
                {
                    ApplicationArea = All;
                    Caption = 'Tenants';
                    ToolTip = 'Number of Entra ID tenants';
                    DrillDownPageId = "D4P BC Tenant List";

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"D4P BC Tenant List");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.CalcFields("Customers Count", "Tenants Count");
    end;
}
