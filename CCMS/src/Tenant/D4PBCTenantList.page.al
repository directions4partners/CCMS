namespace D4P.CCMS.Tenant;

using D4P.CCMS.Capacity;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Setup;

page 62002 "D4P BC Tenant List"
{
    ApplicationArea = All;
    Caption = 'D365BC Entra Tenants';
    CardPageId = "D4P BC Tenant Card";
    Editable = false;
    PageType = List;
    SourceTable = "D4P BC Tenant";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Customer No."; Rec."Customer No.")
                {
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    DrillDown = false;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                }
                field("Tenant Name"; Rec."Tenant Name")
                {
                }
            }
        }
        area(FactBoxes)
        {
            part(TenantDetails; "D4P BC Tenant FactBox")
            {
                SubPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
            }
            part(EnvironmentsFactBox; "D4P BC Environments FactBox")
            {
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
                RunObject = page "D4P BC Setup";
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
            action(AdminCenter)
            {
                ApplicationArea = All;
                Caption = 'Admin Center';
                Image = LaunchWeb;
                ToolTip = 'Open the Dynamics 365 Business Central Admin Center for this tenant.';
                trigger OnAction()
                begin
                    Rec.OpenAdminCenter();
                end;
            }
            action(Environments)
            {
                ApplicationArea = All;
                Caption = 'Environments';
                Image = ViewDetails;
                RunObject = page "D4P BC Environment List";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
                ToolTip = 'View Business Central environments for this tenant.';
            }
            action(Capacity)
            {
                Caption = 'Capacity';
                Image = Capacity;
                ToolTip = 'View capacity information for all environments.';

                trigger OnAction()
                var
                    CapacityHeader: Record "D4P BC Capacity Header";
                    CapacityWorksheet: Page "D4P BC Capacity Worksheet";
                begin
                    CapacityHeader.SetRange("Customer No.", Rec."Customer No.");
                    CapacityHeader.SetRange("Tenant ID", Rec."Tenant ID");
                    CapacityWorksheet.SetTableView(CapacityHeader);
                    CapacityWorksheet.Run();
                end;
            }
            action(PTEObjectRanges)
            {
                ApplicationArea = All;
                Caption = 'PTE Object Ranges';
                Image = NumberSetup;
                RunObject = page "D4P PTE Object Ranges";
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
                actionref(AdminCenterPromoted; AdminCenter)
                {
                }
                actionref(EnvironmentsPromoted; Environments)
                {
                }
                actionref(CapacityPromoted; Capacity)
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