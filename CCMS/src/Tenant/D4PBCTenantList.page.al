namespace D4P.CCMS.Tenant;

using D4P.CCMS.Setup;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;

page 62002 "D4P BC Tenant List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "D4P BC Tenant";
    Caption = 'D365BC Entra Tenants';
    CardPageId = "D4P BC Tenant Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number associated with this tenant.';
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of the Business Central tenant.';
                }
                field("Tenant Name"; Rec."Tenant Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Business Central tenant.';
                }
            }
        }
        area(FactBoxes)
        {
            part(TenantDetails; "D4P BC Tenant FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
            }
            part(EnvironmentsFactBox; "D4P BC Environments FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Customer No." = field("Customer No."), "Tenant ID" = field("Tenant ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Setup)
            {
                ApplicationArea = All;
                Caption = 'Setup';
                Image = Setup;
                RunObject = Page "D4P BC Setup";
                ToolTip = 'Configure D365BC Admin Center settings including debug mode.';
            }
            action(TestDebugMode)
            {
                ApplicationArea = All;
                Caption = 'Test Debug Mode';
                Image = TestReport;
                ToolTip = 'Test if debug mode is working properly.';
                trigger OnAction()
                var
                    DebugHelper: Codeunit "D4P BC Debug Helper";
                begin
                    DebugHelper.TestDebugMode();
                end;
            }
        }
        area(Navigation)
        {
            action(Environments)
            {
                ApplicationArea = All;
                Caption = 'Environments';
                Image = ViewDetails;
                RunObject = Page "D4P BC Environment List";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
                ToolTip = 'View Business Central environments for this tenant.';
            }
            action(PTEObjectRanges)
            {
                ApplicationArea = All;
                Caption = 'PTE Object Ranges';
                Image = NumberSetup;
                RunObject = Page "D4P PTE Object Ranges";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
                ToolTip = 'View PTE object ranges for this customer and tenant.';
            }
        }
        area(Promoted)
        {
            group(Category_Navigation)
            {
                Caption = 'Navigation';
                actionref(EnvironmentsPromoted; Environments)
                {
                }
                actionref(PTEObjectRangesPromoted; PTEObjectRanges)
                {
                }
            }
            group(Category_Setup)
            {
                Caption = 'Setup';
                actionref(SetupPromoted; Setup)
                {
                }
                actionref(TestDebugModePromoted; TestDebugMode)
                {
                }
            }
        }
    }
}