namespace D4P.CCMS.Environment;

page 62025 "D4P Update Selection Dialog"
{
    Caption = 'Select Update Version';
    PageType = StandardDialog;
    SourceTable = "D4P BC Available Update";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Updates)
            {
                Caption = 'Available Updates';
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is the currently selected version.';
                    StyleExpr = RowStyleExpr;

                    trigger OnValidate()
                    begin
                        HandleSelectedChange();
                        CurrPage.Update(true);
                    end;
                }
                field("Target Version"; Rec."Target Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the target version.';
                    StyleExpr = RowStyleExpr;
                }
                field(Available; Rec.Available)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if the version is available.';
                    StyleExpr = RowStyleExpr;
                }
                field("Latest Selectable Date"; Rec."Latest Selectable Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the latest date for which the update can be scheduled.';
                    StyleExpr = RowStyleExpr;
                }
                field("Selected Date"; Rec."User Selected Date")
                {
                    ApplicationArea = All;
                    Caption = 'Selected Date';
                    ToolTip = 'Select the date for the update (between today and latest selectable date).';
                    Editable = DateFieldEditable;
                    Visible = DateFieldsVisible;
                    StyleExpr = RowStyleExpr;

                    trigger OnValidate()
                    begin
                        ValidateSelectedDate();
                    end;
                }
                field("Rollout Status"; Rec."Rollout Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the rollout status (Active, UnderMaintenance, Postponed).';
                    Visible = DateFieldsVisible;
                    StyleExpr = RowStyleExpr;
                }
                field("Expected Month"; Rec."Expected Month")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the expected month for the release.';
                    Visible = ExpectedFieldsVisible;
                    StyleExpr = RowStyleExpr;
                }
                field("Expected Year"; Rec."Expected Year")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the expected year for the release.';
                    Visible = ExpectedFieldsVisible;
                    StyleExpr = RowStyleExpr;
                }
            }
            group(SelectionGroup)
            {
                Caption = 'Schedule Details';
                Visible = false; // Hidden since Selected Date is now in repeater
            }
        }
    }

    actions
    {
        area(Processing)
        {
        }
    }

    var
        DateFieldsVisible: Boolean;
        ExpectedFieldsVisible: Boolean;
        DateFieldEditable: Boolean;
        RowStyleExpr: Text;
        DateTooEarlyErr: Label 'Selected date cannot be earlier than current date and time.';
        DateTooLateErr: Label 'Selected date cannot be later than %1.';

    trigger OnOpenPage()
    begin
        UpdateFieldVisibility();
    end;

    trigger OnAfterGetRecord()
    begin
        SetRowStyle();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateFieldVisibility();
        SetDefaultDateTime();
    end;

    local procedure SetRowStyle()
    begin
        if Rec.Selected then
            RowStyleExpr := 'Favorable'
        else
            RowStyleExpr := 'Standard';
    end;

    local procedure UpdateFieldVisibility()
    begin
        // Show date fields if version is available
        DateFieldsVisible := Rec.Available;
        DateFieldEditable := Rec.Available and (Rec."Latest Selectable Date" <> 0D);

        // Show expected fields if version is not available
        ExpectedFieldsVisible := not Rec.Available;
    end;

    local procedure SetDefaultDateTime()
    begin
        // Set default date to Latest Selectable Date if available
        if (Rec."User Selected Date" = 0D) and DateFieldEditable then
            Rec."User Selected Date" := Rec."Latest Selectable Date";
    end;

    local procedure ValidateSelectedDate()
    begin
        if Rec."User Selected Date" = 0D then
            exit;

        // Validate that selected date is not in the past
        if Rec."User Selected Date" < Today then
            Error(DateTooEarlyErr);

        // Validate that selected date is not later than Latest Selectable Date
        if (Rec."Latest Selectable Date" <> 0D) and (Rec."User Selected Date" > Rec."Latest Selectable Date") then
            Error(DateTooLateErr, Rec."Latest Selectable Date");
    end;

    local procedure HandleSelectedChange()
    var
        TempUpdate: Record "D4P BC Available Update" temporary;
        CurrentEntryNo: Integer;
    begin
        CurrentEntryNo := Rec."Entry No.";

        // If this record is now selected, unselect all others
        if Rec.Selected then begin
            TempUpdate.Copy(Rec, true);
            TempUpdate.Reset();
            if TempUpdate.FindSet() then
                repeat
                    if TempUpdate."Entry No." <> CurrentEntryNo then begin
                        TempUpdate.Selected := false;
                        TempUpdate.Modify();
                    end;
                until TempUpdate.Next() = 0;
        end;
    end;

    procedure GetSelectedVersion(var TargetVersion: Text[100]; var SelectedDate: Date; var ExpectedMonth: Integer; var ExpectedYear: Integer)
    begin
        TargetVersion := Rec."Target Version";
        SelectedDate := Rec."User Selected Date";
        ExpectedMonth := Rec."Expected Month";
        ExpectedYear := Rec."Expected Year";
    end;

    procedure SetData(var TempSourceUpdate: Record "D4P BC Available Update" temporary)
    begin
        // Copy all records from source temporary table to page's temporary table
        TempSourceUpdate.Reset();
        if TempSourceUpdate.FindSet() then
            repeat
                Rec := TempSourceUpdate;
                Rec.Insert();
            until TempSourceUpdate.Next() = 0;
    end;
}
