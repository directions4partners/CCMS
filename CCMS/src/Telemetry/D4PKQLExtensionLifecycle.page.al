namespace D4P.CCMS.Telemetry;

using D4P.CCMS.Environment;

#pragma warning disable AA0218
page 62042 "D4P KQL Extension Lifecycle"
{

    PageType = List;
    UsageCategory = None;
    SourceTable = "D4P KQL Extension Lifecycle";
    Caption = 'Extension Lifecycle', Locked = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Timestamp; Rec."Exec. Date/Time")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Event ID"; Rec."Event ID")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Extension Name"; Rec."Extension Name")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Extension ID"; Rec."Extension ID")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Version"; Rec."Version")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field(Result; Rec.Result)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field(Message; Rec.Message)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Sync. Mode"; Rec."Sync. Mode")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Execution Time MS"; Rec."Execution Time")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Environment Type"; Rec."Environment Type")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Environment Name"; Rec."Environment Name")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
                }
                field("Failure Reason"; Rec."Failure Reason")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression;
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
                        LoadTelemetryReport.InitRequestFromEnvironment(EnvironmentContext, 'EXTLIFECYCLE');
                        LoadTelemetryReport.Run();
                        CurrPage.Update(false);
                        exit;
                    end;

                    // Fallback: Try to find environment from existing record
                    if Rec."Environment Code" <> '' then begin
                        BCEnvironment.SetRange(Name, Rec."Environment Code");
                        if BCEnvironment.FindFirst() then begin
                            LoadTelemetryReport.InitRequestFromEnvironment(BCEnvironment, 'EXTLIFECYCLE');
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
        StyleExpression: Text;
        EnvironmentContext: Record "D4P BC Environment";

    trigger OnAfterGetRecord()
    begin
        StyleExpression := '';
        SetStyleExpr();
    end;

    local procedure SetStyleExpr(): Text
    begin
        case
            Rec.Result of
            'Failure':
                StyleExpression := 'Unfavorable';
            'Success':
                StyleExpression := 'Favorable';
        end;
    end;

    /// <summary>
    /// Sets the environment context for this page
    /// </summary>
    procedure SetEnvironmentContext(Environment: Record "D4P BC Environment")
    begin
        EnvironmentContext := Environment;
    end;
}