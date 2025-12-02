namespace D4P.CCMS.Telemetry;

using D4P.CCMS.Environment;

#pragma warning disable AA0218
page 62044 "D4P KQL Report Executions"
{

    PageType = List;
    Caption = 'Report Executions', Locked = true;

    UsageCategory = None;
    SourceTable = "D4P KQL Report Execution";
    SourceTableView = sorting("Execution Date/Time") order(descending);
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Company Name"; Rec."Company Name")
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

                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = All;
                }
                field("Report Name"; Rec."Report Name")
                {
                    ApplicationArea = all;
                }
                field("Extension Name"; Rec."Extension Name")
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
                field("Average Rows"; Rec."Average Rows")
                {
                    ApplicationArea = All;
                }
                field("Max. Execution Time"; Rec."Max. Execution Time")
                {
                    ApplicationArea = All;
                }
                field("Max. Rows"; Rec."Max. Rows")
                {
                    ApplicationArea = All;
                }
                field("No. Of Executions"; Rec."No. Of Executions")
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
                        LoadTelemetryReport.InitRequestFromEnvironment(EnvironmentContext, 'REPORTEXEC');
                        LoadTelemetryReport.Run();
                        CurrPage.Update(false);
                        exit;
                    end;

                    // Fallback: Try to find environment from existing record
                    if Rec."Environment Code" <> '' then begin
                        BCEnvironment.SetRange(Name, Rec."Environment Code");
                        if BCEnvironment.FindFirst() then begin
                            LoadTelemetryReport.InitRequestFromEnvironment(BCEnvironment, 'REPORTEXEC');
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