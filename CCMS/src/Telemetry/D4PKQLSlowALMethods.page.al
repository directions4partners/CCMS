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
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Execution Date"; Rec."Execution Date")
                {
                }
                field("Execution Date/Time"; Rec."Execution Date/Time")
                {
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                }
                field("Environment Type"; Rec."Environment Type")
                {
                }
                field("Environment Name"; Rec."Environment Name")
                {
                }
                field("Extension ID"; Rec."Extension ID")
                {
                }
                field("Extension Name"; Rec."Extension Name")
                {
                }
                field("Company Name"; Rec."Company Name")
                {
                }
                field("AL Object ID"; Rec."AL Object ID")
                {
                }
                field("AL Object Type"; Rec."AL Object Type")
                {
                }
                field("AL Object Name"; Rec."AL Object Name")
                {
                }
                field("AL Method"; Rec."Method Name")
                {
                }
                field("Client Type"; Rec."Client Type")
                {
                }
                field("No. of Executions"; Rec."No. of Executions")
                {
                }
                field("Max. Execution Time"; Rec."Max. Execution Time")
                {
                }
                field(Publisher; Rec.Publisher)
                {
                }
                field("Version"; Rec."Version")
                {
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
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    BCEnvironment: Record "D4P BC Environment";
                    LoadTelemetryReport: Report "D4P Load Data";
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
    /// <param name="Environment">The environment to set as context</param>
    procedure SetEnvironmentContext(Environment: Record "D4P BC Environment")
    begin
        EnvironmentContext := Environment;
    end;
}