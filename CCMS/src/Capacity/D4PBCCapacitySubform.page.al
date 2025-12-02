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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the environment name.';
                }
                field("Environment Type"; Rec."Environment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the environment type (Production or Sandbox).';
                }
                field("Database Storage GB"; Rec."Database Storage GB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the database storage used in gigabytes.';
                    Caption = 'Database (GB)';
                }
                field("Database Storage MB"; Rec."Database Storage MB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the database storage used in megabytes.';
                    Caption = 'Database (MB)';
                    Visible = false;
                }
                field("Database Storage KB"; Rec."Database Storage KB")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the database storage used in kilobytes.';
                    Caption = 'Database (KB)';
                    Visible = false;
                }
                field("Application Family"; Rec."Application Family")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application family.';
                    Visible = false;
                }
                field("Measurement Date"; Rec."Measurement Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the measurement was taken.';
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
                ApplicationArea = All;
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
                ApplicationArea = All;
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
                ApplicationArea = All;
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
