namespace D4P.CCMS.Capacity;

using D4P.CCMS.Tenant;

page 62021 "D4P BC Capacity Worksheet"
{
    PageType = Document;
    ApplicationArea = All;
    SourceTable = "D4P BC Capacity Header";
    Caption = 'D365BC Capacity';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(StorageCapacityUsage)
            {
                Caption = 'Storage capacity usage';
                field("Total Storage Used GB"; Rec."Total Storage Used GB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total database storage used across all environments.';
                    StyleExpr = 'Strong';
                    Style = Strong;
                }
                field("Storage Total GB"; Rec."Storage Total GB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total database storage capacity allowed.';
                    Caption = 'of';
                }
                field("Storage Available GB"; Rec."Storage Available GB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the available database storage capacity.';
                    Caption = 'GB available';
                }
                field("Last Update Date"; Rec."Last Update Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the capacity data was last updated.';
                    Caption = 'Last updated date';
                }
            }
            group(StorageCapacityBySource)
            {
                Caption = 'Storage capacity, by source';
                field("Storage Default GB Display"; Rec."Storage Default GB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default storage capacity (organization default).';
                    Caption = 'Org (tenant) default';
                }
                field("Storage User Licenses GB"; Rec."Storage User Licenses GB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the storage capacity from user licenses.';
                    Caption = 'User licenses';
                }
                field("Storage Additional Capacity GB"; Rec."Storage Additional Capacity GB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the additional purchased storage capacity.';
                    Caption = 'Additional capacity';
                }
                field("Storage Total GB Display"; Rec."Storage Total GB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total storage capacity.';
                    Caption = 'Total';
                    StyleExpr = 'Strong';
                    Style = Strong;
                }
            }
            group(EnvironmentQuotaUsage)
            {
                Caption = 'Environment quota usage';
                group(Production)
                {
                    Caption = 'Production';
                    field("Production Environments Used"; Rec."Production Environments Used")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the number of production environments currently in use.';
                        Caption = 'Used';
                    }
                    field("Max Production Environments"; Rec."Max Production Environments")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the maximum allowed number of production environments.';
                        Caption = 'of';
                    }
                    field("Production Env. Available"; Rec."Production Env. Available")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the number of available production environment slots.';
                        Caption = 'available';
                    }
                }
                group(Sandbox)
                {
                    Caption = 'Sandbox';
                    field("Sandbox Environments Used"; Rec."Sandbox Environments Used")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the number of sandbox environments currently in use.';
                        Caption = 'Used';
                    }
                    field("Max Sandbox Environments"; Rec."Max Sandbox Environments")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the maximum allowed number of sandbox environments.';
                        Caption = 'of';
                    }
                    field("Sandbox Env. Available"; Rec."Sandbox Env. Available")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the number of available sandbox environment slots.';
                        Caption = 'available';
                    }
                }
            }
            part(Lines; "D4P BC Capacity Subform")
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
            action(GetCapacity)
            {
                ApplicationArea = All;
                Caption = 'Get Capacity';
                Image = Refresh;
                ToolTip = 'Retrieve current capacity information from Admin Center API.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CapacityHelper: Codeunit "D4P BC Capacity Helper";
                    BCTenant: Record "D4P BC Tenant";
                    TenantIdGuid: Guid;
                begin
                    // If no header record exists, use first tenant
                    if Rec."Tenant ID" = '' then begin
                        if BCTenant.FindFirst() then begin
                            CapacityHelper.GetCapacityData(BCTenant."Customer No.", BCTenant."Tenant ID");
                            if Rec.Get(BCTenant."Customer No.", Format(BCTenant."Tenant ID")) then;
                        end else
                            Error('No tenant configured. Please add a tenant in the setup first.');
                    end else begin
                        // Convert Text Tenant ID to GUID
                        Evaluate(TenantIdGuid, Rec."Tenant ID");
                        if BCTenant.Get(Rec."Customer No.", TenantIdGuid) then
                            CapacityHelper.GetCapacityData(Rec."Customer No.", BCTenant."Tenant ID")
                        else
                            Error('Tenant not found for Customer %1, Tenant ID %2', Rec."Customer No.", Rec."Tenant ID");
                    end;
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
