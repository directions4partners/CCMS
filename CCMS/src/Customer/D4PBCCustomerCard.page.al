namespace D4P.CCMS.Customer;

using D4P.CCMS.Setup;
using D4P.CCMS.Tenant;
using Microsoft.Utilities;

page 62001 "D4P BC Customer Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "D4P BC Customer";
    Caption = 'D365BC Customer Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    Importance = Standard;
                    Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Name; Rec.Name)
                {
                    Importance = Promoted;
                }
            }
            group("Address & Contact")
            {
                Caption = 'Address & Contact';

                field(Address; Rec.Address)
                {
                }
                field("Address 2"; Rec."Address 2")
                {
                }
                field(City; Rec.City)
                {
                }
                field("Post Code"; Rec."Post Code")
                {
                }
                field(County; Rec.County)
                {
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                }
                field("Contact Person Name"; Rec."Contact Person Name")
                {
                }
                field("Contact Person Email"; Rec."Contact Person Email")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(FactBoxes)
        {
            part(CustomerFactBox; "D4P BC Customer FactBox")
            {
                SubPageLink = "No." = field("No.");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(BCTenants)
            {
                ApplicationArea = All;
                Caption = 'BC Tenants';
                Image = List;
                RunObject = page "D4P BC Tenant List";
                RunPageLink = "Customer No." = field("No.");
                ToolTip = 'View Business Central tenants for this customer.';
            }
        }
        area(Promoted)
        {
            actionref(BCTenantsPromoted; BCTenants)
            {

            }
        }
    }

    trigger OnOpenPage()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        CCMSSetup.Get();
        NoFieldVisible := DocumentNoVisibility.ForceShowNoSeriesForDocNo(CCMSSetup."Customer Nos.");
    end;

    var
        CCMSSetup: Record "D4P BC Setup";
        NoFieldVisible: Boolean;
}