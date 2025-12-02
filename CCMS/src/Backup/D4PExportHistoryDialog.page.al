namespace D4P.CCMS.Backup;

page 62020 "D4P Export History Dialog"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    Caption = 'Get Export History';

    layout
    {
        area(Content)
        {
            group(Period)
            {
                Caption = 'Select Time Period';

                field(TimePeriod; TimePeriodOption)
                {
                    ApplicationArea = All;
                    Caption = 'Time Period';
                    ToolTip = 'Select the time period for which to retrieve export history.';

                    trigger OnValidate()
                    begin
                        UpdateDateRange();
                    end;
                }
                field(StartDate; StartDateTime)
                {
                    ApplicationArea = All;
                    Caption = 'Start Date/Time';
                    ToolTip = 'The start date and time for the export history query.';
                    Editable = TimePeriodOption = TimePeriodOption::Custom;
                }
                field(EndDate; EndDateTime)
                {
                    ApplicationArea = All;
                    Caption = 'End Date/Time';
                    ToolTip = 'The end date and time for the export history query.';
                    Editable = TimePeriodOption = TimePeriodOption::Custom;
                }
            }
        }
    }

    var
        TimePeriodOption: Option "Current Month","Last 12 Months",Custom;
        StartDateTime: DateTime;
        EndDateTime: DateTime;

    trigger OnOpenPage()
    begin
        // Default to Current Month
        TimePeriodOption := TimePeriodOption::"Current Month";
        UpdateDateRange();
    end;

    local procedure UpdateDateRange()
    var
        FirstDayOfMonth: Date;
    begin
        EndDateTime := CurrentDateTime;

        case TimePeriodOption of
            TimePeriodOption::"Current Month":
                begin
                    FirstDayOfMonth := CalcDate('<-CM>', Today);
                    StartDateTime := CreateDateTime(FirstDayOfMonth, 0T);
                end;
            TimePeriodOption::"Last 12 Months":
                begin
                    StartDateTime := CreateDateTime(CalcDate('<-12M>', Today), 0T);
                end;
            TimePeriodOption::Custom:
                begin
                    // User can edit manually
                    if StartDateTime = 0DT then
                        StartDateTime := CreateDateTime(CalcDate('<-1M>', Today), 0T);
                    if EndDateTime = 0DT then
                        EndDateTime := CurrentDateTime;
                end;
        end;
    end;

    procedure GetDateRange(var StartDT: DateTime; var EndDT: DateTime)
    begin
        StartDT := StartDateTime;
        EndDT := EndDateTime;
    end;
}
