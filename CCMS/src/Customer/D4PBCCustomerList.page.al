namespace D4P.CCMS.Customer;

using D4P.CCMS.Tenant;

page 62000 "D4P BC Customers List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "D4P BC Customer";
    Caption = 'D365BC Customers - Environment Management';
    CardPageId = "D4P BC Customer Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                }
                field(Name; Rec.Name)
                {
                }
                field(City; Rec.City)
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
}