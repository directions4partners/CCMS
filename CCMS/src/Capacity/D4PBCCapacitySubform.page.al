namespace D4P.CCMS.Capacity;

using D4P.CCMS.Environment;

page 62022 "D4P BC Capacity Subform"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "D4P BC Capacity Line";
    Caption = 'Storage usage by environment';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Environment Name"; Rec."Environment Name")
                {
                }
                field("Environment Type"; Rec."Environment Type")
                {
                }
                field("Database Storage GB"; Rec."Database Storage GB")
                {
                    Caption = 'Database (GB)';
                }
                field("Database Storage MB"; Rec."Database Storage MB")
                {
                    Caption = 'Database (MB)';
                    Visible = false;
                }
                field("Database Storage KB"; Rec."Database Storage KB")
                {
                    Caption = 'Database (KB)';
                    Visible = false;
                }
                field("Application Family"; Rec."Application Family")
                {
                    Visible = false;
                }
                field("Measurement Date"; Rec."Measurement Date")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CapacityCard)
            {
                Caption = 'Capacity Card';
                Image = Capacity;
                ToolTip = 'View detailed capacity information for this environment.';

                trigger OnAction()
                begin
                    Page.Run(Page::"D4P BC Capacity Card", Rec);
                end;
            }
            action(DeleteAll)
            {
                Caption = 'Delete All';
                Image = Delete;
                ToolTip = 'Delete all capacity line records.';

                trigger OnAction()
                begin
                    if Confirm('Delete all capacity line records?', false) then begin
                        Rec.DeleteAll();
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(EnvironmentCard)
            {
                Caption = 'Environment Card';
                Image = Certificate;
                ToolTip = 'Open the environment card.';

                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    TenantIdGuid: Guid;
                begin
                    Evaluate(TenantIdGuid, Rec."Tenant ID");
                    if BCEnvironment.Get(Rec."Customer No.", TenantIdGuid, Rec."Environment Name") then
                        Page.Run(Page::"D4P BC Environment Card", BCEnvironment);
                end;
            }
        }
    }
}
