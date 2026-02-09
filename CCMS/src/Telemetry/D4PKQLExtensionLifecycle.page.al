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
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Timestamp; Rec."Exec. Date/Time")
                {
                    StyleExpr = StyleExpression;
                }
                field("Event ID"; Rec."Event ID")
                {
                    StyleExpr = StyleExpression;
                }
                field("Extension Name"; Rec."Extension Name")
                {
                    StyleExpr = StyleExpression;
                }
                field("Extension ID"; Rec."Extension ID")
                {
                    StyleExpr = StyleExpression;
                }
                field("Version"; Rec."Version")
                {
                    StyleExpr = StyleExpression;
                }
                field(Publisher; Rec.Publisher)
                {
                    StyleExpr = StyleExpression;
                }
                field(Result; Rec.Result)
                {
                    StyleExpr = StyleExpression;
                }
                field(Message; Rec.Message)
                {
                    StyleExpr = StyleExpression;
                }
                field("Sync. Mode"; Rec."Sync. Mode")
                {
                    StyleExpr = StyleExpression;
                }
                field("Execution Time MS"; Rec."Execution Time")
                {
                    StyleExpr = StyleExpression;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    StyleExpr = StyleExpression;
                }
                field("Environment Type"; Rec."Environment Type")
                {
                    StyleExpr = StyleExpression;
                }
                field("Environment Name"; Rec."Environment Name")
                {
                    StyleExpr = StyleExpression;
                }
                field("Failure Reason"; Rec."Failure Reason")
                {
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
        EnvironmentContext: Record "D4P BC Environment";
        StyleExpression: Text;

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
                StyleExpression := Format(PageStyle::Unfavorable);
            'Success':
                StyleExpression := Format(PageStyle::Favorable);
        end;
    end;

    /// <summary>
    /// Sets the environment context for this page
    /// </summary>
    /// <param name="Environment">The environment to set as context</param>
    procedure SetEnvironmentContext(Environment: Record "D4P BC Environment")
    begin
        EnvironmentContext := Environment;
    end;
}