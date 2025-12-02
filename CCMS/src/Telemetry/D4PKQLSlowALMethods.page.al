namespace D4P.CCMS.Telemetry;

using D4P.CCMS.Environment;

#pragma warning disable AA0218
page 62045 "D4P KQL Slow AL Methods"
{

    PageType = List;
    UsageCategory = None;
    SourceTable = "D4P KQL Slow AL Method";
    Caption = 'Long Running AL Methods', Locked = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {

                field("Execution Date"; Rec."Execution Date")
                {
                    ApplicationArea = All;
                }
                field("Execution Date/Time"; Rec."Execution Date/Time")
                {
                    ApplicationArea = All;
                }
                field("Tenant ID"; Rec."Tenant ID")
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
                field("Extension ID"; Rec."Extension ID")
                {
                    ApplicationArea = All;
                }
                field("Extension Name"; Rec."Extension Name")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                }
                field("AL Object ID"; Rec."AL Object ID")
                {
                    ApplicationArea = All;
                }
                field("AL Object Type"; Rec."AL Object Type")
                {
                    ApplicationArea = All;
                }
                field("AL Object Name"; Rec."AL Object Name")
                {
                    ApplicationArea = All;
                }
                field("AL Method"; Rec."Method Name")
                {
                    ApplicationArea = All;
                }
                field("Client Type"; Rec."Client Type")
                {
                    ApplicationArea = All;
                }
                field("No. of Executions"; Rec."No. of Executions")
                {
                    ApplicationArea = All;
                }
                field("Max. Execution Time"; Rec."Max. Execution Time")
                {
                    ApplicationArea = All;
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                }
                field("Version"; Rec."Version")
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
                        LoadTelemetryReport.InitRequestFromEnvironment(EnvironmentContext, 'SLOWAL');
                        LoadTelemetryReport.Run();
                        CurrPage.Update(false);
                        exit;
                    end;

                    // Fallback: Try to find environment from existing record
                    if Rec."Environment Code" <> '' then begin
                        BCEnvironment.SetRange(Name, Rec."Environment Code");
                        if BCEnvironment.FindFirst() then begin
                            LoadTelemetryReport.InitRequestFromEnvironment(BCEnvironment, 'SLOWAL');
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