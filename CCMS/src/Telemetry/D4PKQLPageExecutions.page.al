namespace D4P.CCMS.Telemetry;

using D4P.CCMS.Environment;

#pragma warning disable AA0218
page 62043 "D4P KQL Page Executions"
{

    PageType = List;
    UsageCategory = None;
    SourceTable = "D4P KQL Page Execution";
    SourceTableView = sorting("Execution Date/Time") order(descending);
    Caption = 'Page Executions', Locked = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Page Name"; Rec."Page Name")
                {
                    ApplicationArea = All;
                }
                field("Page ID"; Rec."Page ID")
                {
                    ApplicationArea = All;
                }
                field("Environment Type"; Rec."Environment Type")
                {
                    ApplicationArea = All;
                }
                field("Environment Name"; Rec."Environment Name")
                {
                    ApplicationArea = All;
                }
                field("Execution Date"; Rec."Execution Date")
                {
                    ApplicationArea = All;
                }
                field("Execution Date/Time"; Rec."Execution Date/Time")
                {
                    ApplicationArea = All;
                }
                field("Average Execution Time"; Rec."Average Execution Time")
                {
                    ApplicationArea = All;
                }
                field("Max. Execution Time"; Rec."Max. Execution Time")
                {
                    ApplicationArea = All;
                }
                field("No. Of Executions"; Rec."No. Of Executions")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadDataAction)
            {
                Caption = 'Load';
                ToolTip = 'Loads data from the API.';
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    LoadTelemetryReport: Report "D4P Load Data";
                    BCEnvironment: Record "D4P BC Environment";
                    NoEnvironmentContextErr: Label 'No environment context available. Please run this query from the Environment List or Environment Card.';
                begin
                    // If we have a stored environment context, use it
                    if EnvironmentContext.Name <> '' then begin
                        LoadTelemetryReport.InitRequestFromEnvironment(EnvironmentContext, 'PAGEEXEC');
                        LoadTelemetryReport.Run();
                        CurrPage.Update(false);
                        exit;
                    end;

                    // Fallback: Try to find environment from existing record
                    if Rec."Environment Code" <> '' then begin
                        BCEnvironment.SetRange(Name, Rec."Environment Code");
                        if BCEnvironment.FindFirst() then begin
                            LoadTelemetryReport.InitRequestFromEnvironment(BCEnvironment, 'PAGEEXEC');
                            LoadTelemetryReport.Run();
                            CurrPage.Update(false);
                            exit;
                        end;
                    end;

                    Error(NoEnvironmentContextErr);
                end;
            }
        }
    }

    var
        EnvironmentContext: Record "D4P BC Environment";

    /// <summary>
    /// Sets the environment context for this page
    /// </summary>
    procedure SetEnvironmentContext(Environment: Record "D4P BC Environment")
    begin
        EnvironmentContext := Environment;
    end;
}
