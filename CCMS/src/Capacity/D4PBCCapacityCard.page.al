namespace D4P.CCMS.Capacity;

using D4P.CCMS.Tenant;

page 62023 "D4P BC Capacity Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "D4P BC Capacity Line";
    Caption = 'Environment Capacity Details';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Environment Name"; Rec."Environment Name")
                {
                    Style = Strong;
                }
                field("Environment Type"; Rec."Environment Type")
                {
                }
                field("Application Family"; Rec."Application Family")
                {
                }
                field("Measurement Date"; Rec."Measurement Date")
                {
                }
            }
            group(StorageUsage)
            {
                Caption = 'Storage Usage';
                field("Database Storage GB"; Rec."Database Storage GB")
                {
                    Style = Strong;
                }
                field("Database Storage MB"; Rec."Database Storage MB")
                {
                }
                field("Database Storage KB"; Rec."Database Storage KB")
                {
                }
            }
            group(TenantInfo)
            {
                Caption = 'Tenant Information';
                field("Customer No."; Rec."Customer No.")
                {
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetCapacity)
            {
                Caption = 'Get Capacity';
                Image = Refresh;
                ToolTip = 'Refresh capacity information for this environment from Admin Center API.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    CapacityHelper: Codeunit "D4P BC Capacity Helper";
                    TenantIdGuid: Guid;
                begin
                    Evaluate(TenantIdGuid, Rec."Tenant ID");
                    if BCTenant.Get(Rec."Customer No.", TenantIdGuid) then begin
                        CapacityHelper.GetCapacityData(Rec."Customer No.", BCTenant."Tenant ID");
                        CurrPage.Update(false);
                    end else
                        Error('Tenant not found for Customer %1, Tenant ID %2', Rec."Customer No.", Rec."Tenant ID");
                end;
            }
        }
    }
}
