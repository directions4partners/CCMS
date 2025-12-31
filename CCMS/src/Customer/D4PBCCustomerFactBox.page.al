namespace D4P.CCMS.Customer;

using D4P.CCMS.Tenant;
using D4P.CCMS.Environment;

page 62030 "D4P BC Customer FactBox"
{
    PageType = CardPart;
    SourceTable = "D4P BC Customer";
    Caption = 'Customer';

    layout
    {
        area(Content)
        {
            cuegroup(cues)
            {
                ShowCaption = false;
                field(Tenants; Rec.Tenants)
                {
                    ApplicationArea = All;
                    Caption = 'Tenants';
                    ToolTip = 'Number of tenants for this customer';
                    DrillDownPageId = "D4P BC Tenant List";

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
                    ApplicationArea = All;
                    Caption = 'All Active Environments';
                    ToolTip = 'Number of active environments for this customer';
                    DrillDownPageId = "D4P BC Environment List";

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
                    ApplicationArea = All;
                    Caption = 'Active Production';
                    ToolTip = 'Number of active production environments for this customer';
                    DrillDownPageId = "D4P BC Environment List";

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

                field("Active Sandbox Environ."; Rec."Active Sandbox Environ.")
                {
                    ApplicationArea = All;
                    Caption = 'Active Sandbox';
                    ToolTip = 'Number of active sandbox environments for this customer';
                    DrillDownPageId = "D4P BC Environment List";

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
        Rec.CalcFields(Tenants, "All Active Environments", "Active Prod. Environments", "Active Sandbox Environ.");
    end;
}