namespace D4P.CCMS.Customer;

using D4P.CCMS.Setup;
using D4P.CCMS.Tenant;
using Microsoft.Utilities;
using D4P.CCMS.Environment;

page 62001 "D4P BC Customer Card"
{
    ApplicationArea = All;
    Caption = 'D365BC Customer Card';
    PageType = Card;
    SourceTable = "D4P BC Customer";
    UsageCategory = None;

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
            action(BCEnvironments)
            {
                ApplicationArea = All;
                Caption = 'Environments';
                Image = ViewDetails;
                RunObject = page "D4P BC Environment List";
                RunPageLink = "Customer No." = field("No.");
                ToolTip = 'View Business Central environments for this customer.';
            }
        }
        area(Promoted)
        {
            actionref(BCTenantsPromoted; BCTenants)
            {
            }
            actionref(BCEnvironmentsPromoted; BCEnvironments)
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