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
            group(GeneralInfo)
            {
                Caption = 'General Information';
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
                    DrillDown = false;
                }
            }
            group(StorageCapacityUsage)
            {
                Caption = 'Storage capacity usage';
                field("Total Storage Used GB"; Rec."Total Storage Used GB")
                {
                    StyleExpr = 'Strong';
                    Style = Strong;
                }
                field("Storage Total GB"; Rec."Storage Total GB")
                {
                    Caption = 'of';
                }
                field("Storage Available GB"; Rec."Storage Available GB")
                {
                    Caption = 'GB available';
                }
                field("Usage %"; Rec."Usage %")
                {
                }
                field("Last Update Date"; Rec."Last Update Date")
                {
                    Caption = 'Last updated date';
                }
            }
            group(StorageCapacityBySource)
            {
                Caption = 'Storage capacity, by source';
                field("Storage Default GB Display"; Rec."Storage Default GB")
                {
                    Caption = 'Org (tenant) default';
                }
                field("Storage User Licenses GB"; Rec."Storage User Licenses GB")
                {
                    Caption = 'User licenses';
                }
                field("Storage Additional Capacity GB"; Rec."Storage Additional Capacity GB")
                {
                    Caption = 'Additional capacity';
                }
                field("Storage Total GB Display"; Rec."Storage Total GB")
                {
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
                        Caption = 'Used';
                    }
                    field("Max Production Environments"; Rec."Max Production Environments")
                    {
                        Caption = 'of';
                    }
                    field("Production Env. Available"; Rec."Production Env. Available")
                    {
                        Caption = 'available';
                    }
                }
                group(Sandbox)
                {
                    Caption = 'Sandbox';
                    field("Sandbox Environments Used"; Rec."Sandbox Environments Used")
                    {
                        Caption = 'Used';
                    }
                    field("Max Sandbox Environments"; Rec."Max Sandbox Environments")
                    {
                        Caption = 'of';
                    }
                    field("Sandbox Env. Available"; Rec."Sandbox Env. Available")
                    {
                        Caption = 'available';
                    }
                }
            }
            part(Lines; "D4P BC Capacity Subform")
            {
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
                    BCTenant: Record "D4P BC Tenant";
                    CapacityHelper: Codeunit "D4P BC Capacity Helper";
                    TenantNotConfiguredErr: Label 'No tenant configured. Please add a tenant in the setup first.';
                    TenantNotFoundErr: Label 'Tenant not found for Customer %1, Tenant ID %2', Comment = '%1 - Customer No., %2 - Tenant ID';
                begin
                    // If no header record exists, use first tenant
                    if IsNullGuid(Rec."Tenant ID") then begin
                        if BCTenant.FindFirst() then begin
                            CapacityHelper.GetCapacityData(BCTenant."Customer No.", BCTenant."Tenant ID");
                            if Rec.Get(BCTenant."Customer No.", BCTenant."Tenant ID") then;
                        end else
                            Error(TenantNotConfiguredErr);
                    end else
                        if BCTenant.Get(Rec."Customer No.", Rec."Tenant ID") then
                            CapacityHelper.GetCapacityData(Rec."Customer No.", BCTenant."Tenant ID")
                        else
                            Error(TenantNotFoundErr, Rec."Customer No.", Rec."Tenant ID");
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
