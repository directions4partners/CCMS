namespace D4P.CCMS.General;

using D4P.CCMS.Capacity;
using D4P.CCMS.Customer;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Setup;
using D4P.CCMS.Tenant;

page 62049 "D4P BC Admin Role Center"
{
    ApplicationArea = All;
    Caption = 'D365 BC Admin Center';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Headline; "D4P BC Admin Headline")
            {
            }
            part(AdminCenterCues; "D4P BC Admin Center Cues")
            {
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(Customers)
            {
                ApplicationArea = All;
                Caption = 'Customers';
                RunObject = Page "D4P BC Customers List";
                ToolTip = 'View or manage D365BC customers';
            }
            action(Tenants)
            {
                ApplicationArea = All;
                Caption = 'Tenants';
                RunObject = Page "D4P BC Tenant List";
                ToolTip = 'View or manage Entra ID tenants';
            }
            action(Environments)
            {
                ApplicationArea = All;
                Caption = 'Environments';
                RunObject = Page "D4P BC Environment List";
                ToolTip = 'View or manage D365BC environments';
            }
            action("Installed Apps")
            {
                ApplicationArea = All;
                Caption = 'Installed Apps';
                RunObject = Page "D4P BC Installed Apps List";
                ToolTip = 'View installed apps across all environments';
            }
        }
        area(Processing)
        {
            action(Setup)
            {
                ApplicationArea = All;
                Caption = 'Setup';
                RunObject = Page "D4P BC Setup";
                ToolTip = 'Configure D365BC Admin Center settings';
            }
            action("Get Installed Apps")
            {
                ApplicationArea = All;
                Caption = 'Get Installed Apps';
                RunObject = Report "D4P Get Installed Apps";
                ToolTip = 'Retrieve installed apps from active environments';
            }
        }
        area(Sections)
        {
            group(Admin)
            {
                Caption = 'Administration';

                action("Customer Management")
                {
                    ApplicationArea = All;
                    Caption = 'Customers';
                    RunObject = Page "D4P BC Customers List";
                    ToolTip = 'Manage D365BC customers';
                }
                action("Tenant Management")
                {
                    ApplicationArea = All;
                    Caption = 'Tenants';
                    RunObject = Page "D4P BC Tenant List";
                    ToolTip = 'Manage Entra ID tenants and authentication';
                }
                action("Environment Management")
                {
                    ApplicationArea = All;
                    Caption = 'Environments';
                    RunObject = Page "D4P BC Environment List";
                    ToolTip = 'Manage D365BC environments';
                }
                action("Capacity Overview")
                {
                    ApplicationArea = All;
                    Caption = 'Capacity';
                    RunObject = Page "D4P BC Capacity List";
                    ToolTip = 'View storage capacity and usage';
                }
            }
            group(Extensions)
            {
                Caption = 'Extensions';

                action("All Installed Apps")
                {
                    ApplicationArea = All;
                    Caption = 'Installed Apps';
                    RunObject = Page "D4P BC Installed Apps List";
                    ToolTip = 'View all installed apps';
                }
                action("PTE Object Ranges")
                {
                    ApplicationArea = All;
                    Caption = 'PTE Object Ranges';
                    RunObject = Page "D4P PTE Object Ranges";
                    ToolTip = 'Manage Per-Tenant Extension object ranges';
                }
            }
        }
    }
}
