namespace D4P.CCMS.Customer;

using D4P.CCMS.Tenant;
using Microsoft.Utilities;
using D4P.CCMS.Setup;

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
                    ToolTip = 'Specifies the customer number.';
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
                    ToolTip = 'Specifies the customer name.';
                    Importance = Promoted;
                }
            }
            group("Address & Contact")
            {
                Caption = 'Address & Contact';

                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the customer''s address.';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ToolTip = 'Specifies additional address information.';
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the customer''s city.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the postal code.';
                }
                field(County; Rec.County)
                {
                    ToolTip = 'Specifies the county or state.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region code.';
                }
                field("Contact Person Name"; Rec."Contact Person Name")
                {
                    ToolTip = 'Specifies the name of the primary contact person for this customer.';
                }
                field("Contact Person Email"; Rec."Contact Person Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address of the primary contact person for this customer.';
                }
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