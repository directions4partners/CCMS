namespace D4P.CCMS.Environment;

page 62025 "D4P Update Selection Dialog"
{
    Caption = 'Select Update Version';
    PageType = StandardDialog;
    SourceTable = "D4P BC Available Update";
    SourceTableTemporary = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Updates)
            {
                Caption = 'Available Updates';
                field(Selected; Rec.Selected)
                {
                    StyleExpr = RowStyleExpr;

                    trigger OnValidate()
                    begin
                        HandleSelectedChange();
                        CurrPage.Update(true);
                    end;
                }
                field("Target Version"; Rec."Target Version")
                {
                    Editable = false;
                    StyleExpr = RowStyleExpr;
                }
                field(Available; Rec.Available)
                {
                    Editable = false;
                    StyleExpr = RowStyleExpr;
                }
                field("Latest Selectable Date"; Rec."Latest Selectable Date")
                {
                    Editable = false;
                    StyleExpr = RowStyleExpr;
                }
                field("Selected Date"; Rec."User Selected Date")
                {
                    Caption = 'Selected Date';
                    Editable = DateFieldEditable;
                    Visible = DateFieldsVisible;
                    StyleExpr = RowStyleExpr;
                    ToolTip = 'Specifies the date for the update. Select a date between today and the latest selectable date.';

                    trigger OnValidate()
                    begin
                        ValidateSelectedDate();
                    end;
                }
                field("Ignore Update Window"; Rec."Ignore Update Window")
                {
                    Caption = 'Ignore Update Window';
                    Editable = DateFieldEditable;
                    Visible = DateFieldsVisible;
                    StyleExpr = RowStyleExpr;
                    ToolTip = 'Specifies whether to bypass the configured update window and schedule the update for any time on the selected date.';
                }
                field("Rollout Status"; Rec."Rollout Status")
                {
                    Editable = false;
                    Visible = DateFieldsVisible;
                    StyleExpr = RowStyleExpr;
                }
                field("Expected Month"; Rec."Expected Month")
                {
                    Editable = false;
                    Visible = ExpectedFieldsVisible;
                    StyleExpr = RowStyleExpr;
                }
                field("Expected Year"; Rec."Expected Year")
                {
                    Editable = false;
                    Visible = ExpectedFieldsVisible;
                    StyleExpr = RowStyleExpr;
                }
            }
        }
    }


    var
        DateFieldEditable: Boolean;
        DateFieldsVisible: Boolean;
        ExpectedFieldsVisible: Boolean;
        DateTooEarlyErr: Label 'Selected date cannot be earlier than current date and time.';
        DateTooLateErr: Label 'Selected date cannot be later than %1.', Comment = '%1 = Maximum date';
        RowStyleExpr: Text;

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
            RowStyleExpr := Format(PageStyle::Favorable)
        else
            RowStyleExpr := Format(PageStyle::Standard);
    end;

    local procedure UpdateFieldVisibility()
    begin
        DateFieldsVisible := Rec.Available;
        DateFieldEditable := Rec.Available;
        ExpectedFieldsVisible := not Rec.Available;
    end;

    local procedure SetDefaultDateTime()
    begin
        if (Rec."User Selected Date" = 0D) and DateFieldEditable then
            if Rec."Latest Selectable Date" <> 0D then
                Rec."User Selected Date" := Rec."Latest Selectable Date"
            else
                Rec."User Selected Date" := Today();
    end;

    local procedure ValidateSelectedDate()
    begin
        if Rec."User Selected Date" = 0D then
            exit;

        if Rec."User Selected Date" < Today() then
            Error(DateTooEarlyErr);

        if (Rec."Latest Selectable Date" <> 0D) and (Rec."User Selected Date" > Rec."Latest Selectable Date") then
            Error(DateTooLateErr, Rec."Latest Selectable Date");
    end;

    local procedure HandleSelectedChange()
    var
        TempUpdate: Record "D4P BC Available Update" temporary;
        CurrentEntryNo: Integer;
    begin
        CurrentEntryNo := Rec."Entry No.";

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

    procedure GetSelectedVersion(var TargetVersion: Text[100]; var SelectedDate: Date; var ExpectedMonth: Integer; var ExpectedYear: Integer; var IgnoreUpdateWindow: Boolean)
    begin
        TargetVersion := Rec."Target Version";
        SelectedDate := Rec."User Selected Date";
        ExpectedMonth := Rec."Expected Month";
        ExpectedYear := Rec."Expected Year";
        IgnoreUpdateWindow := Rec."Ignore Update Window";
    end;

    procedure SetData(var TempSourceUpdate: Record "D4P BC Available Update" temporary)
    begin
        TempSourceUpdate.Reset();
        if TempSourceUpdate.FindSet() then
            repeat
                Rec := TempSourceUpdate;
                Rec.Insert();
            until TempSourceUpdate.Next() = 0;
    end;
}
