namespace D4P.CCMS.Customer;

using D4P.CCMS.Environment;
using D4P.CCMS.Tenant;

page 62030 "D4P BC Customer FactBox"
{
    ApplicationArea = All;
    Caption = 'Customer';
    PageType = CardPart;
    SourceTable = "D4P BC Customer";

    layout
    {
        area(Content)
        {
            cuegroup(cues)
            {
                ShowCaption = false;
                field(Tenants; Rec.Tenants)
                {
                    trigger OnDrillDown()
                    var
                        BCTenant: Record "D4P BC Tenant";
                    begin
                        BCTenant.SetRange("Customer No.", Rec."No.");
                        Page.Run(Page::"D4P BC Tenant List", BCTenant);
                    end;
                }

                field("All Active Environments"; Rec."All Active Environments")
                {
                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        BCEnvironment.SetRange("Customer No.", Rec."No.");
                        BCEnvironment.SetRange(State, 'Active');
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }

                field("Active Prod. Environments"; Rec."Active Prod. Environments")
                {
                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        BCEnvironment.SetRange("Customer No.", Rec."No.");
                        BCEnvironment.SetRange(State, 'Active');
                        BCEnvironment.SetRange(Type, 'Production');
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }

                field("Active Sand. Environments"; Rec."Active Sand. Environments")
                {
                    trigger OnDrillDown()
                    var
                        BCEnvironment: Record "D4P BC Environment";
                    begin
                        BCEnvironment.SetRange("Customer No.", Rec."No.");
                        BCEnvironment.SetRange(State, 'Active');
                        BCEnvironment.SetRange(Type, 'Sandbox');
                        Page.Run(Page::"D4P BC Environment List", BCEnvironment);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields(Tenants, "All Active Environments", "Active Prod. Environments", "Active Sand. Environments");
    end;
}