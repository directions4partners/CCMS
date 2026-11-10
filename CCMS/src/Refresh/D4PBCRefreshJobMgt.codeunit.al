namespace D4P.CCMS.Refresh;

using System.Threading;

codeunit 62053 "D4P BC Refresh Job Mgt"
{
    var
        CategoryCodeTok: Label 'D4PCCMS', Locked = true;

    /// <summary>
    /// Creates the job queue entries that refresh the CCMS data, for the tasks that do not have one yet.
    /// </summary>
    /// <returns>The number of entries created.</returns>
    procedure CreateJobQueueEntries() CreatedCount: Integer
    var
        NoTime: Time;
    begin
        CreateCategory();

        // Task, minutes between runs, start, end, only on Sundays
        if CreateJobQueueEntry(Enum::"D4P Refresh Task"::Environments, 240, NoTime, NoTime, false) then
            CreatedCount += 1;
        if CreateJobQueueEntry(Enum::"D4P Refresh Task"::EnvironmentUpdates, 240, NoTime, NoTime, false) then
            CreatedCount += 1;
        if CreateJobQueueEntry(Enum::"D4P Refresh Task"::Operations, 60, NoTime, NoTime, false) then
            CreatedCount += 1;
        if CreateJobQueueEntry(Enum::"D4P Refresh Task"::Apps, 1440, 010000T, 040000T, false) then
            CreatedCount += 1;
        if CreateJobQueueEntry(Enum::"D4P Refresh Task"::Capacity, 1440, 050000T, 070000T, false) then
            CreatedCount += 1;
        if CreateJobQueueEntry(Enum::"D4P Refresh Task"::Features, 1440, 030000T, 050000T, true) then
            CreatedCount += 1;
    end;

    local procedure CreateCategory()
    var
        JobQueueCategory: Record "Job Queue Category";
        CategoryDescriptionTxt: Label 'CCMS data refresh';
    begin
        if JobQueueCategory.Get(CategoryCodeTok) then
            exit;

        JobQueueCategory.Code := CategoryCodeTok;
        JobQueueCategory.Description := CategoryDescriptionTxt;
        JobQueueCategory.Insert();
    end;

    local procedure CreateJobQueueEntry(RefreshTask: Enum "D4P Refresh Task"; MinutesBetweenRuns: Integer; StartingTime: Time; EndingTime: Time; SundayOnly: Boolean): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        ParameterString: Text[250];
    begin
        ParameterString := CopyStr(Format(RefreshTask, 0, 9), 1, MaxStrLen(ParameterString));

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"D4P BC Refresh Data");
        JobQueueEntry.SetRange("Parameter String", ParameterString);
        if not JobQueueEntry.IsEmpty() then
            exit(false);

        JobQueueEntry.Reset();
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"D4P BC Refresh Data";
        JobQueueEntry."Parameter String" := ParameterString;
        JobQueueEntry.Description := CopyStr(Format(RefreshTask), 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."Job Queue Category Code" := CategoryCodeTok;
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."No. of Minutes between Runs" := MinutesBetweenRuns;
        JobQueueEntry."Starting Time" := StartingTime;
        JobQueueEntry."Ending Time" := EndingTime;
        JobQueueEntry."Run on Mondays" := not SundayOnly;
        JobQueueEntry."Run on Tuesdays" := not SundayOnly;
        JobQueueEntry."Run on Wednesdays" := not SundayOnly;
        JobQueueEntry."Run on Thursdays" := not SundayOnly;
        JobQueueEntry."Run on Fridays" := not SundayOnly;
        JobQueueEntry."Run on Saturdays" := not SundayOnly;
        JobQueueEntry."Run on Sundays" := true;
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry."Rerun Delay (sec.)" := 300;
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime();
        JobQueueEntry.Insert(true);

        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        exit(true);
    end;
}
